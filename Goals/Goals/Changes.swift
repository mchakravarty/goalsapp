//
//  Changes.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 28/06/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//
//  Simple event-based change propagation (FRP-style). This simplified API omits some features to be easier to
//  understand. In particular, there is no support for observing on specific GCD queues and there is no distinction
//  between the reading and writing end of a stream of changes.
//
//  To be self-contained, we inline some general purpose definitions, such as `WeakBox` and `Either`.

import Foundation


// MARK: Weak box

/// Wrap an object reference such that is only weakly referenced. (This is, e.g., useful to have an array of object
/// references that doesn't keep the referenced objects alive.)
///
struct WeakBox<T: AnyObject> {     // aka Schrödinger's Box
  fileprivate weak var box: T?
  var unbox: T? { get { return box } }
  init(_ value: T) { self.box = value }
}

func ===<T>(lhs: WeakBox<T>, rhs: WeakBox<T>) -> Bool {
  return lhs.box === rhs.box
}

/// Delayed application of a function to a value, where the application is only computed if the weakly referenced
/// value is still available when the result is demanded.
///
struct WeakApply<T> {
  fileprivate let arg: WeakBox<AnyObject>
  fileprivate let fun: (AnyObject) -> T
  var unbox: T? { get { return arg.unbox.map(fun) } }
  init<S: AnyObject>(_ fun: @escaping (S) -> T, _ value: S) {
    self.arg = WeakBox(value)
    self.fun = { fun(($0 as? S)!) }
  }
}

/// Two weak applications are considered equivalent if they wrap the same argument (the function is not considered).
///
func ===<T>(lhs: WeakApply<T>, rhs: WeakApply<T>) -> Bool {
  return lhs.arg === rhs.arg
}


// MARK: -
// MARK: Either

enum Either<S, T> {
  case left(S)
  case right(T)
}


// MARK: -
// MARK: LeftRight

final class LeftRight {
  let left:  AnyObject
  let right: AnyObject
  init(left: AnyObject, right: AnyObject) { self.left = left; self.right = right }
}


// MARK: -
// MARK: Observables

/// Observers are functions that receive an observed value together with a context in which the observation is being made.
///
typealias Observer<Context, ObservedValue> = (Context, ObservedValue) -> ()

/// Observer that has been partially applied to its context.
///
typealias ContextualObserver<ObservedValue> = (ObservedValue) -> ()

/// Opaque observation handle to be able to identify observations and to disable them.
///
final class Observation<ObservedValue> {
  private let contextualObserver: WeakApply<ContextualObserver<ObservedValue>>
  private var disabled:           Int = 0

  /// Observations are observers that are applied to context objects tracked by weak references, the context object may
  /// go at any time, which implicitly unregisters the corresponding observer.
  ///
  fileprivate init<Context: AnyObject>(observer: @escaping Observer<Context, ObservedValue>, context: Context) {
    contextualObserver = WeakApply({ (context: Context) in { (change: ObservedValue) in observer(context, change) }},
                         context)
  }

  /// Apply the observer to an observed value, unless the observer is disabled.
  ///
  /// The return value is `false` if the observer is no longer alive (i.e., its context object got deallocated).
  ///
  fileprivate func apply(_ value: ObservedValue) -> Bool {
    if disabled >= 0 {

      guard let observer = contextualObserver.unbox else { return false }
      observer(value)
    }
    return true
  }

  /// Temporarily disable the given observation while performing the changes contained in the closure. Applications of
  /// this function can be nested.
  ///
  func disable(in performChanges: () -> ()) {
    disabled -= 1
    performChanges()
    disabled += 1
  }
}

/// Abstract interface to an observable stream of changes over time.
///
protocol Observable: class {

  /// The type of observed values.
  ///
  associatedtype ObservedValue

  /// Registers an observer together with a context object whose lifetime determines the duration of the observation.
  ///
  /// The context object is stored using a weak reference. (It cannot be fully parametric as only objects can have
  /// weak references.)
  ///
  /// The observer will be called on the same thread where a new value is announced.
  ///
  @discardableResult
  func observe<Context: AnyObject>(withContext context: Context, observer: @escaping Observer<Context, ObservedValue>)
    -> Observation<ObservedValue>
}


/// A changing value is represented by a stream of changes of which registered observers are being notified.
///
class Changing<Value>: Observable {
  typealias ObservedValue = Value

  /// Registered observers
  ///
  private var observers: [Observation<ObservedValue>] = []

  /// In changes pipelines, we need to keep earlier stages of the pipeline alive.
  ///
  private let retainedObservedObject: AnyObject?


  init() { self.retainedObservedObject = nil }

  init(retainObservedObject: AnyObject) { self.retainedObservedObject = retainObservedObject }

  /// Announce a change to all observers.
  ///
  func announce(change: Value) {

      // Apply all observers to the change value and, at the same time, prune all stale observers (i.e., those whose
      // context object got deallocated).
    observers = observers.filter{ $0.apply(change) }
  }

  /// Registers an observer together with a context object whose lifetime determines the duration of the observation.
  /// A newly registered observer will receive change notification for every change *after* it has been registered.
  ///
  /// The context object is only stored using a weak reference.
  ///
  /// The observer will be called on the same thread as the change announcement.
  ///
  @discardableResult
  func observe<Context: AnyObject>(withContext context: Context, observer: @escaping Observer<Context, ObservedValue>)
    -> Observation<Value>
  {
    let observation = Observation(observer: observer, context: context)
    observers.append(observation)
    return observation
  }
}

/// Trigger streams are changes that only convey a point in time.
///
typealias Triggers = Changing<()>

/// An accumulating value combines a stream of changes into an evolving value that may be observed by registered
/// observers.
///
class Accumulating<Value, Accumulator>: Observable {
  typealias ObservedValue = Accumulator

  private let retainedObserved: AnyObject                // This is to keep the observed object alive.
  private var accumulator:      Accumulator              // Encapsulated accumulator value
  private var changes:          Changing<Accumulator>   // Stream of accumulator changes

  /// Constructs an accumulator with the given initial value, which is fed by an observed object by applying an
  /// accumulation function to the current accumulator value and the observed change to determine the new accumulator
  /// value.
  ///
  init<Observed: Observable>
    (observing observed: Observed,
     startingFrom initial: Accumulator,
     accumulateWith accumulate: @escaping (Value, Accumulator) -> Accumulator) where Value == Observed.ObservedValue
  {
    retainedObserved = observed
    accumulator      = initial
    changes          = Changing<Accumulator>()

    observed.observe(withContext: self){ (context: Accumulating<Value, ObservedValue>, value: Value) in
      context.accumulator = accumulate(value, context.accumulator)
      context.changes.announce(change: context.accumulator)
    }
  }

  /// Registers an observer together with a context object whose lifetime determines the duration of the observation.
  /// A newly registered observer will receive a change notification immediately on registering for the current
  /// accumulator value and, henceforth, for every change of the accumulator after it has been registered.
  ///
  /// The context object is only stored using a weak reference.
  ///
  /// The observer will be called on the same thread as the change announcement.
  ///
  @discardableResult
  func observe<Context: AnyObject>(withContext context: Context, observer: @escaping Observer<Context, ObservedValue>)
    -> Observation<ObservedValue>
  {
    let observation = changes.observe(withContext: context, observer: observer)
    observer(context, accumulator)
    return observation
  }
}


// MARK: -
// MARK: Combinators for streams of changes

extension Observable {

  /// Transform a stream of observations to a derived stream of changes.
  ///
  /// The derived stream will cease to announce changes if the last reference to it has been dropped. (That does not
  /// mean that it hasn't got any observers anymore, but that no other object keeps a strong reference to the stream
  /// of changes itself.)
  ///
  func map<MappedValue>(transform: @escaping (ObservedValue) -> MappedValue) -> Changing<MappedValue> {

    let changes = Changing<MappedValue>(retainObservedObject: self)
    observe(withContext: changes,
            observer: { changesContext, change in changesContext.announce(change: transform(change)) })
    return changes
  }

  /// Filter the changes in a stream of changes through a rpedicate.
  ///
  /// The result stream will cease to announce triggers if the last reference to it has been dropped. (That does not
  /// mean that it hasn't got any observers anymore, but that no other object keeps a strong reference to the stream
  /// of triggers itself.)
  ///
  func filter(predicate: @escaping (ObservedValue) -> Bool) -> Changing<ObservedValue> {

    let changes = Changing<ObservedValue>(retainObservedObject: self)
    self.observe(withContext: changes,
                 observer: { changesContext, change in
                              if predicate(change) { changesContext.announce(change: change) } })
    return changes
  }

  func accumulate<Accumulator>(startingFrom initial: Accumulator,
                               accumulateWith accumulate: @escaping (ObservedValue, Accumulator) -> Accumulator)
    -> Accumulating<ObservedValue, Accumulator>
  {
    return Accumulating<ObservedValue, Accumulator>(observing: self, startingFrom: initial, accumulateWith: accumulate)
  }

  /// Merge two observation streams into one.
  ///
  /// The derived stream will cease to announce changes if the last reference to it has been dropped. (That does not
  /// mean that it hasn't got any observers anymore, but that no other object keeps a strong reference to the stream
  /// of changes itself.)
  ///
  func merge<ObservedRight: Observable>(right: ObservedRight)
    -> Changing<Either<ObservedValue, ObservedRight.ObservedValue>>
  {

    typealias Change = Either<ObservedValue, ObservedRight.ObservedValue>

    let changes = Changing<Change>(retainObservedObject: LeftRight(left: self, right: right))
    self.observe(withContext: changes,
                 observer: { changesContext, change in
                  let leftChange: Change = .left(change)
                  changesContext.announce(change: leftChange) })
    right.observe(withContext: changes,
                  observer: { changesContext, change in
                    let rightChange: Change = .right(change)
                    changesContext.announce(change: rightChange) })
    return changes
  }
}

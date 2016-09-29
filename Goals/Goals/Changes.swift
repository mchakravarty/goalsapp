//
//  Changes.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 28/06/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//
//  Simple event-based change propagation (FRP-style). This simplified API omits features, such as observing on specific
//  GCD queues and temporary disabling of observers, to be easy to understand.
//
//  To be self-contained, we inline some general purpose definitions, such as `WeakBox` and `Either`.

import Foundation


// MARK: Weak box

/// Wrap an object reference such that is only weakly referenced. (This is, e.g., useful to have an array of object
/// references that doesn't keep the referenced objects alive.)
///
struct WeakBox<T: AnyObject> {     // aka Schrödinger's Box
  private weak var box: T?
  var unbox: T? { get { return box } }
  init(_ value: T) { self.box = value }

//  static func ===<T>(lhs: WeakBox<T>, rhs: WeakBox<T>) -> Bool {
//    return lhs.box === rhs.box
//  }
}

/// Delayed application of a function to a value, where the application is only computed if the weakly referenced
/// value is still available when the result is demanded.
///
struct WeakApply<T> {
  private let arg: WeakBox<AnyObject>
  private let fun: (AnyObject) -> T
  var unbox: T? { get { return arg.unbox.map(fun) } }
  init<S: AnyObject>(_ fun: @escaping (S) -> T, _ value: S) {
    self.arg = WeakBox(value)
    self.fun = { fun(($0 as? S)!) }
  }

//  /// Two weak applications are considered equivalent if they wrap the same argument (the function is not considered).
//  ///
//  static func ===<T>(lhs: WeakApply<T>, rhs: WeakApply<T>) -> Bool {
//    return lhs.arg === rhs.arg
//  }
}


// MARK: -
// MARK: Either

enum Either<S, T> {
  case Left(S)
  case Right(T)
}


// MARK: -
// MARK: LeftRight

class LeftRight {
  let left:  AnyObject
  let right: AnyObject
  init(left: AnyObject, right: AnyObject) { self.left = left; self.right = right }
}


// MARK: -
// MARK: Observables

/// Abstract interface to an observable stream of changes over time.
///
protocol Observable: class {

  /// The type of observed values.
  ///
  associatedtype ObservedValue

  /// Registered observers
  ///
  /// NB: Observers are associated with objects tracked by weak references. These objects may go at any time, which
  ///     implicitly unregisters the corresponding observer.
  ///
//  typealias Observer<Context> = (Context, ObservedValue) -> ()

  /// Registers an observer together with a context object whose lifetime determines the duration of the observation.
  ///
  /// The context object is stored using a weak reference. (It cannot be fully parametric as only objects can have
  /// weak references.)
  ///
  /// The observer will be called on the same thread where a new value is announced.
  ///
  func observe<Context: AnyObject>(withContext context: Context, observer: @escaping (Context, ObservedValue) -> ()) -> ()

  /*
  /// Temporarily disable the given observation while performing the changes contained in the closure. Applications of
  /// this method can be nested.
  ///
  func disableObservation(observation: Observation<Value>, @noescape inChanges performChanges: () -> ())
 */
}


/// A changing value is represented by a stream of changes of which registered observers are being notified.
///
class Changing<Value>: Observable {
  typealias ObservedValue = Value

  typealias ContextualObserver = (Value) -> ()

  /// Registered observers
  ///
  /// NB: Observers are bound to objects tracked by weak references, they may go at any time, which implicitly
  ///     unregisters the corresponding observer.
  ///
  private var observers: [WeakApply<ContextualObserver>] = []

  /*
  /// Temporarily disabled observers.
  ///
  private var disabledObservers: [WeakApply<ContextualObserver>] = []
 */

  /// In changes pipelines, we need to keep earlier stages of the pipeline alive.
  ///
  private let retainedObservedObject: AnyObject?


  init() { self.retainedObservedObject = nil }

  init(retainObservedObject: AnyObject) { self.retainedObservedObject = retainObservedObject }

  /// Announce a change to all observers.
  ///
  func announce(change: Value)
  {
    for observer in observers {
//      if (!disabledObservers.contains{ $0 === observer}) {
        observer.unbox?(change)
//      }
    }

      // Prune stale observers.
    observers = observers.filter{ $0.unbox != nil }
  }

  /// Registers an observer together with a context object whose lifetime determines the duration of the observation.
  /// A newly registered observer will receive change notification for every change *after* it has been registered.
  ///
  /// The context object is only stored using a weak reference.
  ///
  /// The observer will be called on the same thread as the change announcement.
  ///
  func observe<Context: AnyObject>(withContext context: Context, observer: @escaping (Context, ObservedValue) -> ()) -> ()
//    -> Observation<Value>
  {
    let appliedObserver = WeakApply({ (context: Context) in { (change: ObservedValue) in observer(context, change) }},
                                    context)
    observers.append(appliedObserver)
//    return Observation(observer: appliedObserver)
  }

  /*
  /// Temporarily disable the given observation while performing the changes contained in the closure. Applications of
  /// this method can be nested.
  ///
  public func disableObservation(observation: Observation<Value>, @noescape inChanges performChanges: () -> ()) {
    let originalDisabledObservers = disabledObservers
    disabledObservers.append(observation.observer)

    performChanges()

    disabledObservers = originalDisabledObservers
  }
 */
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
  private var changes:          Changing<Accumulator>?   // Stream of accumulator changes

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
      context.changes?.announce(change: context.accumulator)
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
  func observe<Context: AnyObject>(withContext context: Context, observer: @escaping (Context, ObservedValue) -> ()) -> ()
  {
    changes?.observe(withContext: context, observer: observer)
    observer(context, accumulator)
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
                  let leftChange: Change = .Left(change)
                  changesContext.announce(change: leftChange) })
    right.observe(withContext: changes,
                  observer: { changesContext, change in
                    let rightChange: Change = .Right(change)
                    changesContext.announce(change: rightChange) })
    return changes
  }
}

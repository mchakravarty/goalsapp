//
//  Goals.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 22/06/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//
//  Model representation

import Foundation
import UIKit


// MARK: Model data structures

/// The set of colours that might be used to render goals.
///
let goalColours: [UIColor] = [.blue, .cyan, .green, .yellow, .orange, .red, .purple]

enum GoalInterval: CustomStringConvertible {
  case daily, weekly, monthly

  var description: String {
    switch self {
    case .daily:   return "Daily"
    case .weekly:  return "Weekly"
    case .monthly: return "Monthly"
    }
  }
}

/// Specification of a single goal
///
struct Goal {
  let uuid:       UUID            // Unique identifier for a specific goal

  var colour:     UIColor
  var title:      String
  var interval:   GoalInterval
  var frequency:  Int             // how often the goal ought to be achieved during the interval

  init(colour: UIColor, title: String, interval: GoalInterval, frequency: Int) {
    self.uuid      = UUID()
    self.colour    = colour
    self.title     = title
    self.interval  = interval
    self.frequency = frequency
  }

  init() { self = Goal(colour: .green, title: "New Goal", interval: .daily, frequency: 1) }

  var frequencyPerInterval: String {
    // FIXME: use NumberFormatter to print frequency in words
    return "\(frequency) times (\(interval.description))"
  }

  /// Percentage towards achieving the goal in the current interval given a specific count of how often the task/activity
  /// has been done in the current interval.
  ///
  func percentage(count: Int) -> Float { return Float(count) / Float(frequency) }
}

extension Goal {
  static func ===(lhs: Goal, rhs: Goal) -> Bool { return lhs.uuid == rhs.uuid }
}

/// A goal and the progress towards that goal in an interval. Only active goals make progress.
///
/// FIXME: Would probably be nicer to use a dictionary instead of an array of pairs.
typealias GoalProgress = (goal: Goal, progress: Int?)

/// Specification of a collection of goals with progress — complete, immutable model state.
///
/// * The order of the goals in the array determines their order on the overview screen.
///
typealias Goals = [GoalProgress]

/// Adjust the progress component of goals with progress according to the activity array.
///
/// Precondition: the activities array has at least as many entries as the goals array
///
func mergeActivity(goals: Goals, activity: [Bool]) -> Goals {
  return zip(goals, activity).map{ goal, isActive in
    switch (goal.progress, isActive) {
    case (nil, false),
         (.some, true):  return goal
    case (nil, true):    return (goal: goal.goal, progress: 0)
    case (.some, false): return (goal: goal.goal, progress: nil)
    }
  }
}


// MARK: -
// MARK: Goals edits

/// This type encompases all transformations that may be applied to goals except advancing the progress counts in values
/// of type `Goals`.
///
enum GoalEdit {
  case add(goal: Goal)
  case delete(goal: Goal)
  case update(goal: Goal)
  case setActivity(activity: [Bool])
}

extension GoalEdit {

  func transform(_ goals: Goals) -> Goals {

    switch self {
    case .add(let newGoal):
      guard !goals.contains(where: { $0.goal === newGoal} ) else { return goals }

      var newGoals = goals
      newGoals.insert((goal: newGoal, progress: nil), at: 0)
      return newGoals

    case .delete(let goal):
      return goals.filter{ !($0.goal === goal) }

    case .update(let newGoal):
      return goals.map{ (goal: Goal, count: Int?) in
        return (goal === newGoal) ? (goal: newGoal, progress: count) : (goal: goal, progress: count) }

    case .setActivity(let goalsActivity):
      return mergeActivity(goals: goals, activity: goalsActivity)
    }
  }
}

/// Type of a stream of goal edits.
///
typealias GoalEdits = Changing<GoalEdit>


// MARK: -
// MARK: Progress edits

/// This type captures the transformations that advance goal progress.
///
enum ProgressEdit {
  case bump(goal: Goal)
}

extension ProgressEdit {

  func transform(_ goals: Goals) -> Goals {

    switch self {
    case .bump(let bumpedGoal):
      return goals.map{ (goal: Goal, count: Int?) in
        return (goal === bumpedGoal) ? (goal: goal, progress: count.flatMap{ $0 + 1 }) : (goal: goal, progress: count) }
    }
  }
}

/// Type of a stream of progress edits.
///
typealias ProgressEdits = Changing<ProgressEdit>


// MARK: -
// MARK: All model edits

/// Merged edits
///
enum Edit {
  case goalEdit(edit: GoalEdit)
  case progressEdit(edit: ProgressEdit)
}

extension Edit {

  init(goalOrProgressEdit: Either<GoalEdit, ProgressEdit>) {
    switch goalOrProgressEdit {
    case .left(let goalEdit):      self = .goalEdit(edit: goalEdit)
    case .right(let progressEdit): self = .progressEdit(edit: progressEdit)
    }
  }

  func transform(_ goals: Goals) -> Goals {

    switch self {
    case .goalEdit(let goalEdit):         return goalEdit.transform(goals)
    case .progressEdit(let progressEdit): return progressEdit.transform(goals)
    }
  }
}

typealias Edits = Changing<Edit>


// MARK: -
// MARK: Model store

// NB: This is overly simplistic, keeping all the observables as toplevel values that can be accessed from anywhere in
//     the app. In production code, you want to restrict access and permission to announce edits to individual
//     subsystems of the app by passing the observables into only those data sources, views, or controllers that need
//     the corresponding access.


// Streams of edits.

let goalEdits     = GoalEdits(),
    progressEdits = ProgressEdits(),
    edits: Edits  = goalEdits.merge(right: progressEdits).map{ Edit(goalOrProgressEdit: $0) }

  // FIXME: needs to be read from persistent store
let initialGoals: Goals = [ (goal:  Goal(colour: .blue, title: "Yoga", interval: .monthly, frequency: 5),
                             progress: 3)
                          , (goal:  Goal(colour: .orange, title: "Walks", interval: .weekly, frequency: 3),
                             progress: 0)
                          , (goal:  Goal(colour: .purple, title: "Stretching", interval: .daily, frequency: 3),
                             progress: 1)
                          ]

/// The current model value is determined by accumulating all edits.
///
let model: Accumulating<Edit, Goals> = edits.accumulate(startingFrom: initialGoals){ edit, currentGoals in
  return edit.transform(currentGoals)
}

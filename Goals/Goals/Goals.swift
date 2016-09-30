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
  var active:     Bool            // is the goal being displayed in the overview

  init(colour: UIColor, title: String, interval: GoalInterval, frequency: Int, active: Bool) {
    self.uuid      = UUID()
    self.colour    = colour
    self.title     = title
    self.interval  = interval
    self.frequency = frequency
    self.active    = active
  }

  init() { self = Goal(colour: .blue, title: "", interval: .daily, frequency: 1, active: false) }

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

/// A goal and the progress towards that goal in an interval.
///
typealias GoalProgress = (goal: Goal, count: Int)

/// Specification of a collection of goals with progress — complete, immutable model state.
///
/// * The order of the goals in the array determines their order on the overview screen.
///
typealias Goals = [GoalProgress]


// MARK: -
// MARK: Model store

/// This type encompases all transformations that may be applied to everything but the progress counts in values of
/// type `Goals`.
///
enum GoalEdit {
  case delete(goal: Goal)
}

extension GoalEdit {
  func transform(_ goals: Goals) -> Goals {
    switch self {
    case .delete(let goal): return goals.filter{ !($0.goal === goal) }
    }
  }
}

/// We keep things simple here...

/// Type of a stream of goal edits.
///
typealias GoalEdits = Changing<GoalEdit>

/// Collects all goal edits in this app.
///
let edits = GoalEdits()

  // FIXME: needs to be read from persistent store
let initialGoals = [ (goal:  Goal(colour: .blue, title: "Yoga", interval: .monthly, frequency: 5, active: true),
                      count: 3)
                   , (goal:  Goal(colour: .orange, title: "Walks", interval: .weekly, frequency: 3, active: true),
                      count: 0)
                   , (goal:  Goal(colour: .purple, title: "Stretching", interval: .daily, frequency: 3, active: true),
                      count: 1)
                   ]

/// The current model value is determined by accumulating all edits.
///
let model: Accumulating<GoalEdit, Goals> = edits.accumulate(startingFrom: initialGoals){ edit, currentGoals in
  return edit.transform(currentGoals)
}

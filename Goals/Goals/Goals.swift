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


// MARK: Value types describing goals

//enum GoalColour {
//  case blue, cyan, green, yellow, orange, red, purple
//
//  var uiColor: UIColor {
//    switch self {
//    case .blue:   return .blue()
//    case .cyan:   return .cyan()
//    case .green:  return .green()
//    case .yellow: return .yellow()
//    case .orange: return .orange()
//    case .red:    return .red()
//    case .purple: return .purple()
//    }
//  }
//}

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
  var colour:    UIColor
  var title:     String
  var interval:  GoalInterval
  var frequency: Int            // how often the goal ought to be achieved during the interval
  var active:    Bool           // is the goal being displayed in the overview

  init(colour: UIColor, title: String, interval: GoalInterval, frequency: Int, active: Bool) {
    self.colour    = colour
    self.title     = title
    self.interval  = interval
    self.frequency = frequency
    self.active    = active
  }

  init() { self = Goal(colour: .blue, title: "", interval: .daily, frequency: 1, active: false) }

  var frequencyPerInterval: String {
    // FIXME: use NumberFormatter to print frequency in words
    return "\(frequency) \(interval.description)"
  }

  /// Percentage towards achieving the goal in the current interval given a specific count of how often the task/activity
  /// has been done in the current interval.
  ///
  func percentage(count: Int) -> Float { return Float(count) / Float(frequency) }
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

enum GoalEdit {
  // FIXME: define all possible edits
}

/// We keep things simple here...

let edits = Changing<GoalEdit>()

  // FIXME: needs to be read from persistent store
let initialGoals = [ (goal:  Goal(colour: .blue, title: "Yoga", interval: .monthly, frequency: 5, active: true),
                      count: 3)
                   , (goal:  Goal(colour: .orange, title: "Walks", interval: .weekly, frequency: 3, active: true),
                      count: 0)
                   , (goal:  Goal(colour: .purple, title: "Stretching", interval: .daily, frequency: 3, active: true),
                      count: 1)
                   ]

let model : Accumulating<GoalEdit, Goals> = edits.accumulate(startingFrom: initialGoals){ edit, currentGoals in
  // FIXME: actually apply the edits
  return currentGoals
}

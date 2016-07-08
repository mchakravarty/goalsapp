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

enum GoalColour {
  case blue, cyan, green, yellow, orange, red, purple

  var uiColor: UIColor {
    switch self {
    case .blue:   return .blue()
    case .cyan:   return .cyan()
    case .green:  return .green()
    case .yellow: return .yellow()
    case .orange: return .orange()
    case .red:    return .red()
    case .purple: return .purple()
    }
  }
}

// FIXME: Could we just use an array of `UIColor`s?
let goalColours: [GoalColour] = [.blue, .cyan, .green, .yellow, .orange, .red, .purple]

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
  var colour:    GoalColour    // FIXME: use `UIColor` directly??
  var title:     String
  var interval:  GoalInterval
  var frequency: Int            // how often the goal ought to be achieved during the interval
  var active:    Bool           // is the goal being displayed in the overview

  init(colour: GoalColour, title: String, interval: GoalInterval, frequency: Int, active: Bool) {
    self.colour    = colour
    self.title     = title
    self.interval  = interval
    self.frequency = frequency
    self.active    = active
  }

  init() { self = Goal(colour: .blue, title: "", interval: .daily, frequency: 1, active: false) }

  var frequencyPerInterval: String {
    // FIXME: use NSNumberFormatter to print frequency in words
    return "\(frequency) \(interval.description)"
  }
}

/// Specification of a collection of goals — complete, immutable model state.
///
/// * The order of the goals in the array determines their order on the overview screen.
///
typealias Goals = [Goal]


// MARK: -
// MARK: Model store

enum GoalEdit {
  // FIXME: define all possible edits
}

/// We keep things simple here...

let edits = Changing<GoalEdit>()

  // FIXME: needs to be read from persistent store
let initialGoals = [Goal(colour: .blue, title: "My Goal", interval: .daily, frequency: 3, active: true)]

let model : Accumulating<GoalEdit, Goals> = edits.accumulate(startingFrom: initialGoals){ edit, currentGoals in
  // FIXME: actually apply the edits
  return currentGoals
}

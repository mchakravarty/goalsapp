//
//  SummaryCell.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 15/07/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


private let percentageFormatter: NumberFormatter = { formatter in
  formatter.multiplier  = NSNumber(value: 100)
  formatter.numberStyle = .percent
  return formatter
  }(NumberFormatter())

class SummaryCell: UICollectionViewCell {

  @IBOutlet private weak var name:       UILabel?
  @IBOutlet private weak var percentage: UILabel?

  func configure(goalProgress: GoalProgress) {

    let percentageValue = goalProgress.goal.percentage(count: goalProgress.progress ?? 0)

    name?.text            = goalProgress.goal.title
    percentage?.text      = percentageFormatter.string(from: NSNumber(value: percentageValue))
    percentage?.textColor = goalProgress.goal.colour
  }
}

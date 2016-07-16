//
//  SummaryCell.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 15/07/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


private let percentageFormatter = NumberFormatter()

class SummaryCell: UICollectionViewCell {

  @IBOutlet private weak var name:       UILabel?
  @IBOutlet private weak var percentage: UILabel?

  func configure(goalProgress: GoalProgress) {

    name?.text = goalProgress.goal.title
    name?.text = percentageFormatter.string(from: NSNumber(value: goalProgress.goal.percentage(count: goalProgress.count)))
  }
}

//
//  SummaryDataSource.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 15/07/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


private let kSummaryCell = "SummaryCell"

class SummaryDataSource: NSObject {

  var goals: Goals = []     // Cache the last model data we observed.

  override init() {
    super.init()

    model.observe(withContext: self){ context, goals in
      context.goals = goals
    }
  }
}

extension SummaryDataSource: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection _section: Int) -> Int
  {
    return goals.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: kSummaryCell, for: indexPath) as? SummaryCell) ??
               SummaryCell()

    let idx = indexPath[0],
        goalProgress: GoalProgress
    if idx >= goals.startIndex && idx < goals.endIndex { goalProgress = goals[idx] }
    else { goalProgress = (goal: Goal(), count: 0) }

    cell.configure(goal: goalProgress)
    return cell
  }
}

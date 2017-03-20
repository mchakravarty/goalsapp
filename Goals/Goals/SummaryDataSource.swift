//
//  SummaryDataSource.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 15/07/2016.
//  Copyright © [2016..2017] Chakravarty & Keller. All rights reserved.
//

import UIKit


private let kSummaryCell = "SummaryCell"

class SummaryDataSource: NSObject {

  @IBOutlet private weak var collectionView: UICollectionView?

  fileprivate var goals:         Goals = []     // Cache only the active goals from the last model data we observed.
  fileprivate var progressEdits: ChangesInlet<ProgressEdit>?

  override init() {
    super.init()

      // Register with app delegate.
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.summaryDataSource = self
  }

  /// Configure this data source with observables and announcables to tie it into the data model.
  ///
  func configure(model: Changing<Goals>, edits: ChangesInlet<ProgressEdit>) {
    model.observe(withContext: self){ context, goals in
      context.goals = goals.filter{ $0.progress != nil }
      context.collectionView?.reloadData()
    }
    progressEdits = edits
  }

  func bumpProgress(of idx: Int) {
    guard idx < goals.count else { return }

    progressEdits?.announce(change: .bump(goal: goals[idx].goal))
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

    let idx = indexPath[1],
        goalProgress: GoalProgress
    if idx >= goals.startIndex && idx < goals.endIndex { goalProgress = goals[idx] }
    else { goalProgress = (goal: Goal(), progress: nil) }

    cell.configure(goalProgress: goalProgress)
    return cell
  }
}

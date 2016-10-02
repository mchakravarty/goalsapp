//
//  SummaryController.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 02.10.16.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


private let reuseIdentifier = "SummaryCell"

class SummaryController: UICollectionViewController {

  override func viewDidLoad() {
      super.viewDidLoad()
  }
}

// MARK: -
// MARK: Recording progress

extension SummaryController {

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let summaryDataSource = collectionView.dataSource as? SummaryDataSource else { return }

    summaryDataSource.bumpProgress(of: indexPath.item)
    collectionView.deselectItem(at: indexPath, animated: true)
  }
}

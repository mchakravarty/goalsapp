//
//  DetailController.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 17/07/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


class DetailController: UIViewController {

  @IBOutlet private weak var titleLabel:    UILabel!
  @IBOutlet private weak var intervalLabel: UILabel!
  @IBOutlet private weak var frequency:     UILabel!
  @IBOutlet private weak var colour:        UIImageView?

  /// The goal presented and edited by this view controller.
  ///
  var goal: Goal?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    navigationItem.title    = goal?.title
    titleLabel.text         = goal?.title
    intervalLabel.text      = goal?.interval.description
    frequency.text          = goal?.frequencyPerInterval
    colour?.backgroundColor = goal?.colour
//    let size = goalColour?.bounds.size ?? CGSize.zero,
//    rect = CGRect(origin: CGPoint.zero, size: size),
//    path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
//    UIGraphicsBeginImageContext(size)
//    //    goal.colour.setFill()
//    UIColor.blue().setFill()
//    path.fill()
//    goalColour?.image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
  }


//  // MARK: - Interacting with Storyboards and Segues
//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//  }
}

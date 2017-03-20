//
//  DetailController.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 17/07/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


class DetailController: UIViewController {

  @IBOutlet fileprivate weak var titleLabel:     UILabel!
  @IBOutlet fileprivate weak var titleTextField: UITextField!
  @IBOutlet fileprivate weak var intervalLabel:  UILabel!
  @IBOutlet fileprivate weak var frequency:      UILabel!
  @IBOutlet fileprivate weak var colour:         UIImageView?

  /// The goal presented and edited by this view controller.
  ///
  var goal: Goal? {
    didSet {
      updateGoalUI()
    }
  }

  /// Changes inlet consuming goal detail edits.
  ///
  var goalEdits: ChangesInlet<GoalEdit>?

  override func viewDidLoad() {
    super.viewDidLoad()
    updateGoalUI()
    titleTextField.isHidden = true
  }

  private func updateGoalUI() {
    if isViewLoaded {
      navigationItem.title    = goal?.title
      titleLabel.text         = goal?.title
      intervalLabel.text      = goal?.interval.description
      frequency.text          = goal?.frequencyPerInterval
      colour?.backgroundColor = goal?.colour
    }
  }

// TODO: Add support to edit the other properties of a goal.

  @IBAction func tappedTitle(_ sender: AnyObject) {
    titleTextField.text     = goal?.title
    titleTextField.isHidden = false
    titleLabel.isHidden     = true

    titleTextField.becomeFirstResponder()
  }

  @IBAction func titleFinishedEditing(_ sender: AnyObject) {
    titleTextField.isHidden = true
    titleLabel.isHidden     = false
  }

  @IBAction func titleChanged(_ sender: AnyObject) {
    let newTitle = titleTextField.text ?? ""
    goal?.title  = newTitle

    if let goal = goal { goalEdits?.announce(change: .update(goal: goal)) }
  }
}

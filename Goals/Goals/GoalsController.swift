//
//  GoalsController.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 17/07/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


private let kShowGoalDetail = "ShowGoalDetail"    // Segue identifier

/// Tracks the UI state of the table view.
///
private enum GoalsEditState {
  case displaying
  case editing(goalsActivity: [Bool])
}

class GoalsController: UITableViewController {

  private var editState: GoalsEditState = .displaying
  private var addButton: UIBarButtonItem?               // Keep the button around while removed from the UI.

  override func viewDidLoad() {
    super.viewDidLoad()

      // Keep a reference to the add button; so, we can remove it temporarily from the UI during edit mode.
    addButton = navigationItem.leftBarButtonItem

      // Display an Edit button in the navigation bar for this view controller.
    navigationItem.rightBarButtonItem = editButtonItem
  }

  // MARK: - Managing editing

  override func setEditing(_ editing: Bool, animated: Bool) {
    guard let goalsDataSource = tableView.dataSource as? GoalsDataSource else { return }

    super.setEditing(editing, animated: animated)

    switch (editing, editState) {

      // We are already in the target state — don't do anything.
    case (false, .displaying): ()
    case (true, .editing):     ()

      // Enter edit state.
    case (true, .displaying):
      navigationItem.setLeftBarButton(nil, animated: true)
      editState = .editing(goalsActivity: goalsDataSource.goalsActivity)

      // Leave edit state.
    case (false, .editing(let goalsActivity)):
      navigationItem.setLeftBarButton(addButton, animated: true)
      goalsDataSource.commitGoalsActivity(goalsActivity)
      editState = .displaying
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }

      // This operation is only valid in editing state.
    guard case .editing(var goalsActivity) = editState else { return }

    let newIsActive = !goalsActivity[indexPath.item]              // toggle the current activity state
    cell.editingAccessoryType = newIsActive ? .checkmark : .none
    tableView.deselectRow(at: indexPath, animated: true)

    goalsActivity[indexPath.item] = newIsActive
    editState = .editing(goalsActivity: goalsActivity)
  }


  /*
  // Override to support rearranging the table view.
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

  }
  */

  // MARK: - Interacting with Storyboards and Segues

  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == kShowGoalDetail { return !isEditing }
    return false
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let goalsDataSource = tableView.dataSource as? GoalsDataSource,
          let indexPath       = tableView.indexPathForSelectedRow else { return }

    if segue.identifier == kShowGoalDetail, let detailController = segue.destination as? DetailController {

      detailController.goal = goalsDataSource.goal(at: indexPath)?.goal
    }
  }
}

// MARK: Actions

extension GoalsController {

  @IBAction func addGoal(_ sender: AnyObject) {
    if isEditing { return }     // Adding a goal in editing state can lead to inconsistency

    goalEdits.announce(change: .add(goal: Goal()))
  }
}

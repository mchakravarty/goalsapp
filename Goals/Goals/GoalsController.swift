//
//  GoalsController.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 17/07/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


let kShowGoalDetail = "ShowGoalDetail"    // Segue identifier


class GoalsController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

      // Display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  /*
  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      // Return false if you do not want the specified item to be editable.
      return true
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
      // Return false if you do not want the item to be re-orderable.
      return true
  }
  */

  // MARK: - Interacting with Storyboards and Segues

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
    edits.announce(change: .add(goal: Goal()))
  }
}

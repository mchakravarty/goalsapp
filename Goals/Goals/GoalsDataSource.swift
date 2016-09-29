//
//  GoalsDataSource.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 22/06/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


private let kGoalTableCell = "GoalTableCell"
private let size           = CGSize(width: 35, height: 35)

class GoalsDataSource: NSObject {

  fileprivate var goals: Goals = []     // Cache the last model data we observed.

  override init() {
    super.init()

    model.observe(withContext: self){ context, goals in
      context.goals = goals
    }
  }

  /// Retrieve the goal at the given index path in the model data, if available.
  ///
  fileprivate func goal(at indexPath: IndexPath) -> Goal? {
    let idx = indexPath[1]
    if idx >= goals.startIndex && idx < goals.endIndex { return goals[idx].goal } else { return nil }
  }
}

extension GoalsDataSource: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return goals.count }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kGoalTableCell) ?? UITableViewCell(),
        goal = self.goal(at: indexPath) ?? Goal ()

    let rect = CGRect(origin: CGPoint.zero, size: size),
        path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
    UIGraphicsBeginImageContext(size)
    goal.colour.setFill()
    path.fill()
    cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    cell.textLabel?.text       = goal.title
    cell.detailTextLabel?.text = goal.frequencyPerInterval
    return cell
  }

  func tableView(_ tableView: UITableView,
                 commit editingStyle: UITableViewCellEditingStyle,
                 forRowAt indexPath: IndexPath)
  {
    guard let goal = self.goal(at: indexPath) else { return }

    edits.announce(change: .delete(goal: goal))
    tableView.deleteRows(at: [indexPath], with: .left)
  }
}

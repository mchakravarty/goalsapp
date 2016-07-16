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

  var goals: Goals = []     // Cache the last model data we observed.

  override init() {
    super.init()

    model.observe(withContext: self){ context, goals in
      context.goals = goals
    }
  }
}

extension GoalsDataSource: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return goals.count }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kGoalTableCell) ?? UITableViewCell()

    let idx = indexPath[0],
        goal: Goal
    if idx >= goals.startIndex && idx < goals.endIndex { goal = goals[idx].goal } else { goal = Goal() }

    let rect = CGRect(origin: CGPoint.zero, size: size),
        path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
    UIGraphicsBeginImageContext(size)
    goal.colour.uiColor.setFill()
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
    // FIXME: action on swipe to delete
  }
}

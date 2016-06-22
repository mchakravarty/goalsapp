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

}

extension GoalsDataSource: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kGoalTableCell) ?? UITableViewCell()

    let rect = CGRect(origin: CGPoint.zero, size: size),
        path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
    UIGraphicsBeginImageContext(size)
    UIColor.blue().setFill()
    path.fill()
    cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    cell.textLabel?.text = "My Goal"
    cell.detailTextLabel?.text = "Twice weekly"
    return cell
  }

  func tableView(_ tableView: UITableView,
                 commit editingStyle: UITableViewCellEditingStyle,
                 forRowAt indexPath: IndexPath)
  {
    // FIXME: action on swipe to delete
  }
}

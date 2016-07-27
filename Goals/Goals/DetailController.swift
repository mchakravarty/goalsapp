//
//  DetailController.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 17/07/2016.
//  Copyright © 2016 Chakravarty & Keller. All rights reserved.
//

import UIKit


class DetailController: UIViewController {

  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var intervalLabel: UILabel!
  @IBOutlet private weak var frequency: UILabel!
  @IBOutlet private weak var goalColour: UIImageView?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
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

  override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
  

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}

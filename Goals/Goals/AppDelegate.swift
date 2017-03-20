//
//  AppDelegate.swift
//  Goals
//
//  Created by Manuel M T Chakravarty on 22/06/2016.
//  Copyright © [2016..2017] Chakravarty & Keller. All rights reserved.
//

import UIKit


// FIXME: needs to be read from persistent store
let initialGoals: Goals = [ (goal:  Goal(colour: .blue, title: "Yoga", interval: .monthly, frequency: 5),
                             progress: 3)
                          , (goal:  Goal(colour: .orange, title: "Walks", interval: .weekly, frequency: 3),
                             progress: 0)
                          , (goal:  Goal(colour: .purple, title: "Stretching", interval: .daily, frequency: 3),
                             progress: 1)
                          ]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  weak var goalsDataSource:   GoalsDataSource?
  weak var summaryDataSource: SummaryDataSource?

  var window: UIWindow?
  var model : GoalsModel?


  // MARK: Life cycle management

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil)
    -> Bool
  {
    model = GoalsModel(initial: initialGoals)
    summaryDataSource?.configure(model: model!.model, edits: model!.progressEdits.inlet)
    goalsDataSource?.configure(model: model!.model, edits: model!.goalEdits.inlet)
    return true
  }
}

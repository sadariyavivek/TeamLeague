//
//  AppDelegate.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initialize()
        return true
    }
}

extension AppDelegate {
    private func initialize() {
        window = UIWindow(frame: UIScreen.main.bounds)
        loadTeamListScreen()
        window?.makeKeyAndVisible()
    }

    private func loadTeamListScreen() {
        let teamListViewController = TeamListBuilder().build()
        let navigationController = UINavigationController(rootViewController: teamListViewController)
        window?.rootViewController = navigationController
    }
}

//
//  AppDelegate.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import UIKit
import SwifterSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let coordinator = AppCoordinator(rootController: .hero)
        self.coordinator = coordinator
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator.navigationController
        window?.makeKeyAndVisible()
        setupDatasource()
        return true
    }
    
    private func setupDatasource() {
        Datasource.shared.warmUp()
    }

}


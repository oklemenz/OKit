//
//  AppDelegate.swift
//  Bookshop
//
//  Created by Klemenz, Oliver on 25.06.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import OKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var shop: Shop!
    var settings: ModelSettings?
    var directory: Directory?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Model.initialize(window, secure: true) {
            self.shop = Model.register(Shop.self)
            self.settings = Model.register(ModelSettings.self, name: "settings")
            self.directory = Model.register(Directory.self, name: "directory")
        }
        Model.state() {
            Model.store(self.shop)
            Model.store(self.settings)
            Model.store(self.directory)
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Model.storeState()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Model.restoreState()
    }
}

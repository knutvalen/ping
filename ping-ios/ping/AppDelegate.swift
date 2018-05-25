//
//  AppDelegate.swift
//  ping
//
//  Created by Knut Valen on 23/05/2018.
//  Copyright © 2018 Knut Valen. All rights reserved.
//

import UIKit
import UserNotifications
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    
    // MARK: - Private functions
    
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    // MARK: - Delegate functions
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Login.shared.username = "foo"
        registerForPushNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        os_log("AppDelegate application(_:didRegisterForRemoteNotificationsWithDeviceToken:) token: %@", token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("AppDelegate application(_:didFailToRegisterForRemoteNotificationsWithError:) error: %@", error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        os_log("AppDelegate application(_:didReceiveRemoteNotification:fetchCompletionHandler:)")
            if let aps = userInfo["aps"] as? [String: AnyObject] {
            if aps["content-available"] as? Int == 1 {
                RestController.shared.onPing = { () in
                    RestController.shared.onPing = nil
                    completionHandler(.newData)
                    os_log("AppDelegate onPing")
                }
                
                RestController.shared.pingBackground(login: Login.shared)
//                RestController.shared.pingForeground(login: Login.shared)
            }
        }
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        RestController.shared.backgroundSessionCompletionHandler = completionHandler
    }
}

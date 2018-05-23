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
class AppDelegate: UIResponder, UIApplicationDelegate, URLSessionDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?
    
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
    
    // MARK: - UIApplicationDelegate functions
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        os_log("AppDelegate didRegisterForRemoteNotificationsWithDeviceToken token: %@", token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("AppDelegate didFailToRegisterForRemoteNotificationsWithError error: %@", error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        os_log("AppDelegate didReceiveRemoteNotification")
            if let aps = userInfo["aps"] as? [String: AnyObject] {
            if aps["content-available"] as? Int == 1 {
                
                RestController.shared.onPing = { () in
                    RestController.shared.onPing = nil
                    completionHandler(.newData)
                    os_log("AppDelegate onPing")
                }
                
                RestController.shared.pingBackground(login: Login.shared, urlSessionDelegate: self) // does not work
//                RestController.shared.pingForeground(login: Login.shared) // works
            }
        }
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    // MARK: - URLSessionDelegate functions
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let completionHandler = self.backgroundSessionCompletionHandler {
                self.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
            
            RestController.shared.onPing?()
        }
    }
}

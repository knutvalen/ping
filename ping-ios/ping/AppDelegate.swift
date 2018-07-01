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
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate {

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
        let registry = PKPushRegistry(queue: nil)
        registry.delegate = self
        registry.desiredPushTypes = [PKPushType.voIP]
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("AppDelegate application(_:didFailToRegisterForRemoteNotificationsWithError:) error: %@", error.localizedDescription)
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        RestController.shared.backgroundSessionCompletionHandler = completionHandler
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        RestController.shared.onPing = { () in
            RestController.shared.onPing = nil
            os_log("AppDelegate pushRegistry(_:didReceiveIncomingPushWith:for:completion:) onPing")
        }
        
        RestController.shared.pingBackground(login: Login.shared)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        os_log("AppDelegate pushRegistry(_:didUpdate:for:) token: %@", pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined())
    }
}

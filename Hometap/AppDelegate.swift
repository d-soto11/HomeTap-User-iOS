//
//  AppDelegate.swift
//  Hometap
//
//  Created by Daniel Soto on 7/12/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
import DropDown
import Stripe
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Configurar Firebase
        FirebaseApp.configure()
        // Configurar Google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()!.options.clientID
        // Configurar Facebook
         FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Configuracion de GMaps
        GMSServices.provideAPIKey(K.Hometap.google_api_key)
        GMSPlacesClient.provideAPIKey(K.Hometap.google_api_key)
        // Configuracion Stripe
        STPPaymentConfiguration.shared().publishableKey = K.Hometap.stripe_key
        // Private configurations
        // ...
        DropDown.startListeningToKeyboard()
        // Crashalytics
        Fabric.with([Crashlytics.self])
        // New Relic
        NewRelic.start(withApplicationToken:K.Hometap.new_relic_key)
        // Notifications configuration
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        
        if let u = UserDefaults.standard.dictionary(forKey: K.User.savingKey) as [String: AnyObject]? {
            K.User.client = Client(dict: u)
        }
        
        AppContent.loadAppContent()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled_by_fb = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        let handled_by_google = GIDSignIn.sharedInstance().handle(url,
                                                                  sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                  annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled_by_fb || handled_by_google
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if let u = K.User.client {
            UserDefaults.standard.set(u.original_dictionary, forKey: K.User.savingKey)
        }
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        
        statusBar.backgroundColor = color
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        K.User.reloadClient()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        K.User.reloadClient()
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        K.User.client?.saveNotificationToken(token: fcmToken)
    }

}


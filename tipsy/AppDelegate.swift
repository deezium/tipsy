//
//  AppDelegate.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/17/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Amplitude_iOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
   // var storyboard: UIStoryboard?
    
    let googleMapsApiKey = "AIzaSyDrlwN6ie4HlBZENulJ7pbHs3dOZfSqMtM"
    

    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        Fabric.with([Crashlytics()])
        GMSServices.provideAPIKey(googleMapsApiKey)
        
        Amplitude.instance().trackingSessionEvents = true
        
        
        
        // DEVELOPMENT PARAMETERS
        
        Parse.setApplicationId("GmfZQGE8InioR7PvkyPFv3SZamsFNm4jJ3c6qbPu", clientKey: "UxLUds7UwHmVnc9OxNhVXtRRd5Q9jVzeAg3cdO51")
        
        Amplitude.instance().initializeApiKey("648b71e9e12bc11948c0cad31d252028")

        
        // PRODUCTION PARAMETERS
        
//        Parse.setApplicationId("utBelvysdG4ZgK8aghYjOJYaDPjpnn1LmW3b3Egs", clientKey: "RbDtGrF7qXzbucbbpE7bCwCcV5DrVz8kJhYtdOC8")
      
//        Amplitude.instance().initializeApiKey("b7b0a552d87f1b49de41269d010e37f5")
        
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
 
        
        
        
        // Register for Push Notitications

        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            print("app registered for push notifications")
        } else {
            let types: UIRemoteNotificationType = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Alert, UIRemoteNotificationType.Sound]
            application.registerForRemoteNotificationTypes(types)
        }

        let installation = PFInstallation.currentInstallation()
        
//        application.applicationIconBadgeNumber = installation.badge
        
        installation.setObject(0, forKey: "badge")
        
        installation.saveInBackground()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if (PFUser.currentUser() != nil) {
            let tabBarController = storyboard.instantiateViewControllerWithIdentifier("TabViewController") as! UITabBarController
            
            tabBarController.selectedIndex = 0
            
            let welcomeViewController = storyboard.instantiateViewControllerWithIdentifier("WelcomeViewController") 
            
//            self.window?.rootViewController = welcomeViewController
            
            self.window?.rootViewController? = tabBarController
            
    
        }
        
        if (PFUser.currentUser() != nil) {

            if (!NSUserDefaults.standardUserDefaults().boolForKey("registeredForGlobalPushNotifications")) {
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation["user"] = PFUser.currentUser()
                currentInstallation.addUniqueObject("global", forKey: "channels")
                currentInstallation.saveInBackground()
                print("registered installation for pushes")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "registeredForGlobalPushNotifications")
                NSUserDefaults.standardUserDefaults().synchronize()
            }

        }

        
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
    }
    
    func initialViewControllerDidLogin(controller: InitialViewController) {
    
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

}


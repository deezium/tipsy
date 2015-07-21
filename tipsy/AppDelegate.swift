//
//  AppDelegate.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/17/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   // var storyboard: UIStoryboard?

    let googleMapsApiKey = "AIzaSyDrlwN6ie4HlBZENulJ7pbHs3dOZfSqMtM"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey(googleMapsApiKey)
        
        Parse.setApplicationId("utBelvysdG4ZgK8aghYjOJYaDPjpnn1LmW3b3Egs", clientKey: "RbDtGrF7qXzbucbbpE7bCwCcV5DrVz8kJhYtdOC8")
      //  PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
//        if (PFUser.currentUser() != nil) {
//            println(PFUser.currentUser()?.objectForKey("username"))
//        }
        
        if (PFUser.currentUser() != nil && PFUser.currentUser()?.objectForKey("fullname") == nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                println("has access token")
                let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        println("OOPS")
                    }
                    else {
                        println(result["name"])
                        PFUser.currentUser()?.setObject(result["name"], forKey: "fullname")
                        PFUser.currentUser()?.saveInBackground()
                    }
                })
            }
            
        }
        
        if (PFUser.currentUser() != nil && PFUser.currentUser()?.objectForKey("profileImage") == nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                println("has access token")
                let pictureRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
                pictureRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        println("OOPS")
                    }
                    else {
                        println(result["data"]!["url"])
                        let pictureString = result["data"]!["url"] as! String
                        let pictureURL = NSURL(string: pictureString)
                        let pictureData = NSData(contentsOfURL: pictureURL!)
                        println(pictureData)
                        var pictureFile = PFFile(data: pictureData!)
                        PFUser.currentUser()?.setObject(pictureFile, forKey: "profileImage")
                        PFUser.currentUser()?.saveInBackground()
                    }
                })
            }
            
        }

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if (PFUser.currentUser() != nil) {
            let tabBarController = storyboard.instantiateViewControllerWithIdentifier("TabViewController") as! UITabBarController
            
            tabBarController.selectedIndex = 0
            
            self.window?.rootViewController? = tabBarController
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    func initialViewControllerDidLogin(controller: InitialViewController) {
    
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

}


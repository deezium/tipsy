//
//  ViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/17/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import UIKit
//import SwiftAddressBook
import AddressBook

class ViewController: UIViewController {

////    //var swiftAddressBook : SwiftAddressBook!
////    let status : ABAuthorizationStatus = SwiftAddressBook.authorizationStatus()
////    
////    @IBAction func locationButtonPressed(sender: AnyObject) {
////        let locationViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
////        self.navigationController!.pushViewController(locationViewController, animated: true)
////
////    }
////    
////    @IBAction func buttonPressed(sender: AnyObject) {
////        swiftAddressBook?.requestAccessWithCompletion({ (success, error) -> Void in
////            if success{
////                println("Yay!")
////            }
////            else {
////                println("Boo, error")
////            }
////        })
////        if self.isAuthorized(){
////            let friendsListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FriendsListViewController") as! FriendsListViewController
////            self.navigationController!.pushViewController(friendsListViewController, animated: true)
////        }
////    }
////    
//    func isAuthorized() -> Bool {
//        return status == ABAuthorizationStatus.Authorized
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
//        if (FBSDKAccessToken.currentAccessToken() != nil) {
//            
//            let friendsListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FriendsListViewController") as! FriendsListViewController
//            
//            self.navigationController!.pushViewController(friendsListViewController, animated: true)
//        }
//        else {
//            let loginView : FBSDKLoginButton = FBSDKLoginButton()
//            self.view.addSubview(loginView)
//            loginView.center = self.view.center
//            loginView.readPermissions = ["public_profile", "email", "user_friends"]
//            loginView.delegate = self
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
//        println("User logged in")
//        let friendsListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FriendsListViewController") as! FriendsListViewController
//        
//        self.navigationController!.pushViewController(friendsListViewController, animated: true)
//
//        if ((error) != nil)
//        {
//            println("Shit's fucked")
//        }
//        else if result.isCancelled {
//            println("Cancelled")
//        }
//        else {
//            if result.grantedPermissions.contains("email")
//            {
//                // Do Shit
//            }
//        }
//    }
//
//    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
//        println("User logged out")
//    }
    
}

//
//  ViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/17/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // Do shit
        }
        else {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User logged in")
        
        if ((error) != nil)
        {
            println("Shit's fucked")
        }
        else if result.isCancelled {
            println("Cancelled")
        }
        else {
            if result.grantedPermissions.contains("email")
            {
                // Do Shit
            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User logged out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                println("Error: \(error)")
            }
            else
            {
                println("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                println("User name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                println("User email is: \(userEmail)")
            }
        })
    }
}

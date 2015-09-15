//
//  InitialViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/30/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import Parse
import ParseFacebookUtilsV4

protocol InitialViewControllerDelegate {
    func initialViewControllerDidLogin(controller: InitialViewController)
}

class InitialViewController: UIViewController {
    
    
    @IBAction func didTapFacebookLogin(sender: AnyObject) {
        
        let permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: {(user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                
                if user.isNew {
                    print("Successful sign up!")
                    self.performSegueWithIdentifier("loggedInSegue", sender: nil)
                }
                else {
                    print("User already logged in!")
                    self.performSegueWithIdentifier("loggedInSegue", sender: nil)
                }
            }
            else {
                print("Oh noes! Login cancelled!")
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
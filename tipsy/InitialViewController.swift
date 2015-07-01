//
//  InitialViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/30/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

class InitialViewController: UIViewController {
    
    @IBAction func didTapFacebookLogin(sender: AnyObject) {
        
        var permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: {(user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    println("Successful sign up!")
                }
                else {
                    println("User logged in!")
                }
            }
            else {
                println("Oh noes! Login cancelled!")
            }
            })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var testObject = PFObject(className: "TestObject")
        testObject.setObject(2048, forKey: "score")
        testObject.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if success == true {
                println("Success")
            }
            else {
                println("Fail")
            }
        }
    }
}
//
//  FacebookController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/24/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

class FacebookController {
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User email is: \(userEmail)")
                let userFirstName : NSString = result.valueForKey("first_name") as! NSString
                print("User first name is: \(userFirstName)")
            }
        })
    }

}
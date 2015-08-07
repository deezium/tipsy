//
//  EditProfileViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/3/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class EditProfileViewController: UIViewController, UITextFieldDelegate {
    
    let currentUser = PFUser.currentUser()!
    
    @IBOutlet weak var aboutField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutField.delegate = self
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        aboutField.resignFirstResponder()
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        let n = self.navigationController?.viewControllers?.count as Int!
        let profileViewController = self.navigationController?.viewControllers[n-1] as! PlanProfileViewController
        
        self.navigationController?.navigationBar.backItem
        profileViewController.aboutLabel.text = aboutField.text
    }

    
    @IBAction func didTapSaveButton(sender: AnyObject) {
        
        currentUser.setObject(aboutField.text, forKey: "about")
        
        
        currentUser.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if success == true {
                
                let alert = UIAlertController(title: "Success", message: "Your profile has been updated!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                //self.aboutField.text = ""
    
//                NSNotificationCenter.defaultCenter().postNotificationName(planMadeNotificationKey, object: self)
            }
            else {
                let alert = UIAlertController(title: "Sorry!", message: "We had trouble updating your profile.  Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }

        
        
    }
    
}
//
//  AboutViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/25/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import Amplitude_iOS
import Parse

class AboutViewController: UIViewController {
    
    let version: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
    
    let user = PFUser.currentUser()
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = "Tipsy is made and distributed by a small team of developers based in San Francisco, California.\r\n\nShout out to Icons8 (http://www.icons8.com/) for providing us with icons distributed under the Creative Commons License.\r\n\nAnd another shout out to Google for powering our location search.\r\n\nVersion number: \(version!)\r\n\nUser ID: \(user!.objectId!)"
        
    }
    
    override func viewDidAppear(animated: Bool) {
        Amplitude.instance().logEvent("aboutViewed")
        
    }
    
    
}
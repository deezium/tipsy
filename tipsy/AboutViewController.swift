//
//  AboutViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/25/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

class AboutViewController: UIViewController {
    
    let version: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = "Tipsy is made and distributed by Tipsy, LLC, based in San Francisco, California.\r\n\nIcons made by Icons8 (http://www.icons8.com/) and distributed under Creative Commons License.\r\n\nLocation search powered by Google.\r\n\nVersion number: \(version!)"
        
    }
    
}
//
//  TwitterViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/16/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import SwifteriOS

class TwitterViewController: UIViewController {
    
    var swifter : Swifter
    
    required init(coder aDecoder: NSCoder) {
        self.swifter = Swifter(consumerKey: "4t8tQ5YahzQtQv51QzVFQcCIM", consumerSecret: "nVwsRazhqHvZP2WNmJ0n6jlhGms3UwC46qM42fTav0UxSvU8Rd", appOnly: true)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        println(swifter)
        swifter.authorizeAppOnlyWithSuccess({ (accessToken, response) -> Void in
            println("yee")
            }, failure: { (error) -> Void in
                println("Error Authenticating: \(error.localizedDescription)")
        })
    }
    
    @IBAction func didTapGetTwitterData(sender: AnyObject) {
        
        swifter.getSearchTweetsWithQuery("sup", geocode: nil, lang: nil, locale: nil, resultType: nil, count: 20, until: nil, sinceID: nil, maxID: nil, includeEntities: false, callback: nil, success: {
            (statuses, searchMetadata) -> Void in
                println(statuses)
            }, failure: { (error) -> Void in
            println("Failed to get tweets")
        })
       
    }
}
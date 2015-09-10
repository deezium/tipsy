//
//  ProfileViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/30/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


class ProfileViewController: UIViewController {
    
    var databasePath = NSString()
    let user = PFUser.currentUser()
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(false)
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docsDir = dirPaths[0] 
        
//        databasePath = docsDir.stringByAppendingPathComponent("tipsy.db")
        
        print(user)
        
        let tipsyDB = FMDatabase(path: databasePath as String)
        
        if tipsyDB.open() {
            let query = "SELECT * FROM CHECKINS"
            
            let results:FMResultSet? = tipsyDB.executeQuery(query, withArgumentsInArray: nil)
            
            
            
//            while results?.next() == true {
//                println(results?.stringForColumn("latitude"))
//                println(results?.stringForColumn("longitude"))
//                println(results?.stringForColumn("message"))
//            }
            tipsyDB.close()
        }
        else {
            print("Error: \(tipsyDB.lastErrorMessage())")
        }
        
    }
    
}
//
//  ModelManager.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/29/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

let sharedInstance = ModelManager()

class ModelManager {
    var database: FMDatabase? = nil
    
    class var instance: ModelManager {
//        sharedInstance.database = FMDatabase(path: Util.getPath("tipsy.sqlite"))
//        let path = Util.getPath("tipsy.sqlite")
//        print("path: \(path)")
        return sharedInstance
    }
    
    func addCheckinData(checkIn: Checkin) -> Bool {
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO CHECKINS (message) VALUES (?)", withArgumentsInArray: [checkIn.message])
        sharedInstance.database!.close()
        return isInserted
    }
}


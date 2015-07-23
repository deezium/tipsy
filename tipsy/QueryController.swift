//
//  QueryController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/11/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

protocol QueryControllerProtocol {
    func didReceiveQueryResults(objects: [PFObject])
}

class QueryController {
//    init(delegate: QueryControllerProtocol) {
//        self.delegate = delegate
//    }
    
    let user = PFUser.currentUser()!
    var delegate : QueryControllerProtocol?
    
    func queryPosts(filter: String) {

            println("fuck")
        var query = PFQuery(className: "CheckIn")
        
        if (filter != "") {
            query.whereKey(filter, equalTo: user)            
        }
        query.includeKey("creatingUser")
        query.orderByDescending("createdAt")
        query.limit = 20
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        println(objects)
        
//        if let objects = objects {
//        }
        
//        return objects
    }
    
    func queryPlans(filter: String) {
        
        println("fuck")
        var query = PFQuery(className: "Plan")
        
        if (filter != "") {
            query.whereKey(filter, equalTo: user)
        }
        
        let currentDate = NSDate()
        
//        query.whereKey("endTime", greaterThanOrEqualTo: currentDate)
        query.includeKey("creatingUser")
        query.orderByAscending("startTime")
        query.limit = 40
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        println(objects)
        
        
    }
    
    func queryProfilePlans(filter: String) {
        
        println("fuck")
        var query = PFQuery(className: "Plan")
        
        if (filter != "") {
            query.whereKey(filter, equalTo: user)
        }
        
        let currentDate = NSDate()
        
        query.includeKey("creatingUser")
        query.orderByAscending("startTime")
        query.limit = 20
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        println(objects)
        
        
    }

}
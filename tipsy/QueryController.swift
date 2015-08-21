//
//  QueryController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/11/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

@objc protocol QueryControllerProtocol {
    func didReceiveQueryResults(objects: [PFObject])
    
    optional func didReceiveSecondQueryResults(objects: [PFObject])
    
    optional func didReceiveThirdQueryResults(objects: [PFObject])
    
    optional func didReceiveFourthQueryResults(objects: [PFObject])

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
        let friendsArray = PFUser.currentUser()?.objectForKey("friendsUsingTipsy")
        
        if (filter != "") {
            query.whereKey(filter, equalTo: user)
        }
        
        let currentDate = NSDate()
        
//        query.whereKey("endTime", greaterThanOrEqualTo: currentDate)
//        query.whereKey("creatingUser", containedIn: friendsArray)
        query.includeKey("creatingUser")
        query.orderByDescending("startTime")
        query.limit = 40
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        println(objects)
        
        
    }
    
    func queryProfilePlans(filter: String, userId: String) {
        
        println("fuck")
        var query = PFQuery(className: "Plan")
        
        var pointer = PFObject(withoutDataWithClassName: "_User", objectId: userId)
        
        if (filter != "") {
            query.whereKey(filter, equalTo: pointer)
        }
        
        let currentDate = NSDate()
        
        query.includeKey("heartedPlan")
        query.includeKey("creatingUser")
        query.orderByDescending("startTime")
        query.limit = 20
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        println(objects)
        
        
    }
    
    func queryComments(plan: PFObject) {
        var query = PFQuery(className: "Comment")
        
        println("querying for plan \(plan)")
        
        query.includeKey("commentingUser")
        query.includeKey("commentedPlan")
        query.orderByAscending("createdAt")
        query.whereKey("commentedPlan", equalTo: plan)
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        println(objects)
    }
    
    
    func queryUserIdsForFriends() {
        
        let currentUser = PFUser.currentUser()
        let currentUserFriends = PFUser.currentUser()?.objectForKey("friendsUsingTipsy") as! NSArray
        var query = PFUser.query()!
        query.whereKey("facebookID", containedIn: currentUserFriends as [AnyObject])
        query.orderByAscending("fullname")
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        println("friend users for \(currentUser) are \(objects)")
    }
    
    func queryPlansForFriends(friends: [PFObject], point: PFGeoPoint) {
        
        var query = PFQuery(className: "Plan")
        let currentUser = PFUser.currentUser()
        
        let currentDate = NSDate()
        
        println("friends being queried \(friends)")
        println("queriedPoint \(point)")
        
        let newPoint = PFGeoPoint(latitude: 37.790027, longitude: -122.3975)
        
        query.includeKey("creatingUser")
        query.orderByDescending("startTime")
        query.whereKey("creatingUser", containedIn: friends as [AnyObject])
//        query.whereKey("googlePlaceCoordinate", nearGeoPoint: newPoint, withinMiles: 20.0)
        query.limit = 40
        
        var objects = query.findObjects() as? [PFObject]
        self.delegate!.didReceiveSecondQueryResults!(objects!)
        
        println("plans for friends are \(objects)")
        
        
    }
    


    func queryHotPlansForActivity(point: PFGeoPoint) {
        let currentUser = PFUser.currentUser()!
        
        
        var visiblePlans = PFQuery(className: "Plan")
        visiblePlans.whereKey("visibility", notEqualTo: 1)
        
        var currentUserPlans = PFQuery(className: "Plan")
        currentUserPlans.whereKey("creatingUser", equalTo: currentUser)

        var query = PFQuery.orQueryWithSubqueries([visiblePlans, currentUserPlans])

        let currentTime = NSDate()
        
        println("newQueriedPoint \(point)")
        
        query.includeKey("creatingUser")
        //        query.whereKey("googlePlaceCoordinate", nearGeoPoint: point, withinRadians: 1.0)
        query.whereKey("endTime", greaterThanOrEqualTo: currentTime)
        query.orderByDescending("heartCount")
        query.limit = 40
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
    }

    func queryNewPlansForActivity(point: PFGeoPoint) {
        let currentUser = PFUser.currentUser()!
        
        println("newQueriedPoint \(point)")
        
        //        query.whereKey("googlePlaceCoordinate", nearGeoPoint: point, withinRadians: 1.0)
        
        
        var visiblePlans = PFQuery(className: "Plan")
        visiblePlans.whereKey("visibility", notEqualTo: 1)
        
        var currentUserPlans = PFQuery(className: "Plan")
        currentUserPlans.whereKey("creatingUser", equalTo: currentUser)
        
        var query = PFQuery.orQueryWithSubqueries([visiblePlans, currentUserPlans])

        query.includeKey("creatingUser")
        query.orderByDescending("createdAt")
        query.limit = 40
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveSecondQueryResults!(objects)
    }
    
    func queryOngoingPlansForActivity(point: PFGeoPoint) {

        let currentUser = PFUser.currentUser()!
        
        
        var visiblePlans = PFQuery(className: "Plan")
        visiblePlans.whereKey("visibility", notEqualTo: 1)
        
        var currentUserPlans = PFQuery(className: "Plan")
        currentUserPlans.whereKey("creatingUser", equalTo: currentUser)
        
        var query = PFQuery.orQueryWithSubqueries([visiblePlans, currentUserPlans])
        
        let currentTime = NSDate()
        
        println("queriedCurrentTime \(currentTime)")
        println("ongoingQueriedPoint \(point)")
        
        query.includeKey("creatingUser")
        query.whereKey("endTime", greaterThanOrEqualTo: currentTime)
        query.whereKey("startTime", lessThanOrEqualTo: currentTime)
//        query.whereKey("googlePlaceCoordinate", nearGeoPoint: point, withinRadians: 1.0)
        query.orderByDescending("startTime")
        
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveThirdQueryResults!(objects)
    }
    
    func queryAttendingUsersForPlan(plan: PFObject) {
        var query = PFUser.query()!
        let planId = plan.objectId
        query.whereKey("attendedPlans", equalTo: planId!)
        
        var objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveSecondQueryResults!(objects)
        
        println("attending users for \(planId) are \(objects)")
        
    }


    
}
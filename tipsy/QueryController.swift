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

            print("fuck")
        let query = PFQuery(className: "CheckIn")
        
        if (filter != "") {
            query.whereKey(filter, equalTo: user)            
        }
        query.includeKey("creatingUser")
        query.orderByDescending("createdAt")
        query.limit = 20
        
        let objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        print(objects)
        
//        if let objects = objects {
//        }
        
//        return objects
    }
    
    func queryPlans(filter: String) {
        
        print("fuck")
        let query = PFQuery(className: "Plan")
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
        
        let objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        print(objects)
        
        
    }
    
    func queryProfilePlans(filter: String, userId: String, friends: [PFObject]) {
        
        let currentUser = PFUser.currentUser()!
        
        var friendsIdArray = [String]()
        for friend in friends {
            friendsIdArray.append(friend.objectId!)
        }
        
        print("fuck")
        let createdPlans = PFQuery(className: "Plan")
        
        let pointer = PFObject(withoutDataWithClassName: "_User", objectId: userId)
        
        if (filter != "") {
            createdPlans.whereKey(filter, equalTo: pointer)
        }
        
        let currentDate = NSDate()
        
        if !friendsIdArray.contains(userId) {
            print("boo you're not friends")
            createdPlans.whereKey("visibility", notEqualTo: 1)
            
        }
        
        
        var query: PFQuery
        
        if currentUser.objectId == userId {
            let joinedPlans = PFQuery(className: "Plan")
            joinedPlans.whereKey("attendingUsers", equalTo: currentUser.objectId!)
            query = PFQuery.orQueryWithSubqueries([createdPlans, joinedPlans])
        }
        else {
            query = createdPlans
        }

        
        query.includeKey("heartedPlan")
        query.includeKey("creatingUser")
        query.orderByDescending("startTime")
        query.limit = 20
        
        let objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveSecondQueryResults!(objects)
        
        print(objects)
        
        
    }
    
    func queryComments(plan: PFObject) {
        let query = PFQuery(className: "Comment")
        
        print("querying for plan \(plan)")
        
        query.includeKey("commentingUser")
        query.includeKey("commentedPlan")
        query.orderByAscending("createdAt")
        query.whereKey("commentedPlan", equalTo: plan)
        
        let objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        print(objects)
    }
    
    
    func queryUserIdsForFriends() {
        
        let currentUser = PFUser.currentUser()
        let currentUserFriends = PFUser.currentUser()?.objectForKey("friendsUsingTipsy") as! NSArray
        let query = PFUser.query()!
        query.whereKey("facebookID", containedIn: currentUserFriends as [AnyObject])
        query.orderByAscending("fullname")
        let objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveQueryResults(objects)
        
        print("friend users for \(currentUser) are \(objects)")
    }
    
    func queryPlansForFriends(friends: [PFObject], point: PFGeoPoint) {
        
        let query = PFQuery(className: "Plan")
        let currentUser = PFUser.currentUser()
        
        let currentDate = NSDate()
        
        print("friends being queried \(friends)")
        print("friendsqueriedPoint \(point)")
        
//        let newPoint = PFGeoPoint(latitude: 37.790027, longitude: -122.3975)
        
        query.includeKey("creatingUser")
        query.orderByDescending("startTime")
        query.whereKey("creatingUser", containedIn: friends as [AnyObject])
        query.whereKey("googlePlaceCoordinate", nearGeoPoint: point, withinMiles: 40.0)
        query.limit = 40
        
        let objects = query.findObjects() as? [PFObject]
        self.delegate!.didReceiveSecondQueryResults!(objects!)
        
        print("plans for friends are \(objects)")
        
        
    }
    


    func queryHotPlansForActivity(friends: [PFObject], point: PFGeoPoint) {
        let currentUser = PFUser.currentUser()!
        
 
        let friendPlans = PFQuery(className: "Plan")
        friendPlans.whereKey("creatingUser", containedIn: friends as [AnyObject])

        
        let visiblePlans = PFQuery(className: "Plan")
        visiblePlans.whereKey("visibility", notEqualTo: 1)
        
        let query = PFQuery.orQueryWithSubqueries([visiblePlans, friendPlans])

        let currentTime = NSDate()
        
        print("newQueriedPoint \(point)")
        query.whereKey("googlePlaceCoordinate", nearGeoPoint: point, withinMiles: 10.0)
        
        query.includeKey("creatingUser")
        query.whereKey("endTime", greaterThanOrEqualTo: currentTime)
        query.orderByDescending("heartCount")
        query.limit = 40
        
        let objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveSecondQueryResults!(objects)
    }

    func queryNewPlansForActivity(friends: [PFObject], point: PFGeoPoint) {
        let currentUser = PFUser.currentUser()!
        
        
        let friendPlans = PFQuery(className: "Plan")
        friendPlans.whereKey("creatingUser", containedIn: friends as [AnyObject])
        
        let visiblePlans = PFQuery(className: "Plan")
        visiblePlans.whereKey("visibility", notEqualTo: 1)
        
        let query = PFQuery.orQueryWithSubqueries([visiblePlans, friendPlans])

        print("newQueriedPoint \(point)")
        query.whereKey("googlePlaceCoordinate", nearGeoPoint: point, withinMiles: 10.0)

        query.includeKey("creatingUser")
        query.orderByDescending("createdAt")
        query.limit = 40
        
        let objects = query.findObjects() as! [PFObject]
        print("new plans \(objects)")
        self.delegate!.didReceiveThirdQueryResults!(objects)
    }
    
    func queryOngoingPlansForActivity(friends: [PFObject], point: PFGeoPoint) {

        let currentUser = PFUser.currentUser()!
        
        let friendPlans = PFQuery(className: "Plan")
        friendPlans.whereKey("creatingUser", containedIn: friends as [AnyObject])
        
        let visiblePlans = PFQuery(className: "Plan")
        visiblePlans.whereKey("visibility", notEqualTo: 1)
        
        let query = PFQuery.orQueryWithSubqueries([visiblePlans, friendPlans])
        
        let currentTime = NSDate()
        
        print("queriedCurrentTime \(currentTime)")
        print("ongoingQueriedPoint \(point)")
        query.whereKey("googlePlaceCoordinate", nearGeoPoint: point, withinMiles: 10.0)
        
        query.includeKey("creatingUser")
        query.whereKey("endTime", greaterThanOrEqualTo: currentTime)
        query.whereKey("startTime", lessThanOrEqualTo: currentTime)
        query.orderByDescending("startTime")
        query.limit = 40
        
        
        let objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveFourthQueryResults!(objects)
    }
    
    func queryAttendingUsersForPlan(plan: PFObject) {
        let query = PFUser.query()!
        let planId = plan.objectId
        query.whereKey("attendedPlans", equalTo: planId!)
        
        let objects = query.findObjects() as! [PFObject]
        self.delegate!.didReceiveSecondQueryResults!(objects)
        
        print("attending users for \(planId) are \(objects)")
        
    }


    
}
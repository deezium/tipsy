//
//  PlanTableViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/21/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class PlanTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol {
 
    @IBOutlet weak var planTableView: UITableView!
    var query = QueryController()
    var queryObjects = [PFObject]()

    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.planTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query.delegate = self
        query.queryPlans("")
        
        self.planTableView!.delegate = self
        self.planTableView!.dataSource = self
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        var objects = queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 10)
        //        println(objects.count)
        //        return objects.count
        
        println(queryObjects.count)
        return queryObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let queryObject = queryObjects[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("PlanTableCell") as! PlanFeedCell
        
        let user = queryObject.objectForKey("creatingUser") as! PFUser
        let username = user.objectForKey("fullname") as? String
        let startTime = queryObject.objectForKey("startTime") as? NSDate
        let endTime = queryObject.objectForKey("endTime") as? NSDate
        let place = queryObject.objectForKey("googlePlaceId") as? String
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, hh:mm a"
        
        let startTimeString = dateFormatter.stringFromDate(startTime!)
        let endTimeString = dateFormatter.stringFromDate(endTime!)
        
        println(startTime)
        println(endTime)
        
        
        if let postImage = user.objectForKey("profileImage") as? PFFile {
            let imageData = postImage.getData()
            let image = UIImage(data: imageData!)
            cell.profileImage.image = image
            
        }

        
        cell.name.text = username
        cell.startTime.text = startTimeString
        cell.endTime.text = endTimeString
        cell.location.text = place
        
        return cell
    }


}
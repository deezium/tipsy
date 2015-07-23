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
 
    @IBOutlet weak var timeFilter: UIDatePicker!
    @IBOutlet weak var planTableView: UITableView!
    var query = QueryController()
    var queryObjects = [PFObject]()
    var filteredObjects = [PFObject]()
    var filtered: Bool = false
    
    @IBAction func didTapRemoveFilters(sender: AnyObject) {
        filtered = false
        self.planTableView.reloadData()
    }
    
    @IBAction func didTapFilter(sender: AnyObject) {
        filtered = true
        filteredObjects = [PFObject]()
        self.filterQueryResults(queryObjects)
        self.planTableView.reloadData()
    }
    
    

    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.planTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func filterQueryResults(objects: [PFObject]) {
        for object in objects {
            let startTime = object.objectForKey("startTime") as? NSDate
            let endTime = object.objectForKey("endTime") as? NSDate
            let filterTime = timeFilter.date
            
            if (startTime!.isEarlierThanOrEqualTo(filterTime)) {
                if (endTime!.isLaterThanOrEqualTo(filterTime)) {
                    filteredObjects.append(object)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query.delegate = self
        query.queryPlans("")
        
        self.planTableView!.delegate = self
        self.planTableView!.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planMadeNotificationKey, object: nil)

        
    }
    
    func refreshPosts() {
        query.queryPlans("")
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        var objects = queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 10)
        //        println(objects.count)
        //        return objects.count
        
        println(queryObjects.count)
        
        if filtered == false {
            return queryObjects.count
        }
        else {
            return filteredObjects.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var queryObject: PFObject
        
        if filtered == false {
            queryObject = queryObjects[indexPath.row]
        }
        else {
            queryObject = filteredObjects[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PlanTableCell") as! PlanFeedCell
        
        let user = queryObject.objectForKey("creatingUser") as! PFUser
        let fullname = user.objectForKey("fullname") as? String
        let message = queryObject.objectForKey("message") as? String
        let startTime = queryObject.objectForKey("startTime") as? NSDate
        let endTime = queryObject.objectForKey("endTime") as? NSDate
        let placeName = queryObject.objectForKey("googlePlaceName") as? String
        let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
        let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
        var placeLabel: String?
        var addressLabel: String?
        
        if let placeName = placeName {
            placeLabel = placeName
        }

        if let shortAddress = shortAddress {
            addressLabel = shortAddress
        }

        
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

        let firstname = fullname?.componentsSeparatedByString(" ")[0]
        
        cell.name.text = firstname
        cell.startTime.text = startTimeString
        cell.endTime.text = endTimeString
        cell.location.text = placeLabel
        cell.addressLabel.text = shortAddress
        
        if let message = message {
            cell.message.text = message
        }
        
        return cell
    }


}
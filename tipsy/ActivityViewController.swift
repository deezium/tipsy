//
//  ActivityViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/18/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var query = QueryController()
    var newQueryObjects = [PFObject]()
    var hotQueryObjects = [PFObject]()
    var ongoingQueryObjects = [PFObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        query.delegate = self
        query.queryNewPlansForActivity()
        query.queryOngoingPlansForActivity()
        
    }
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.newQueryObjects = objects
            
//            var locValue:CLLocationCoordinate2D = self.currentLocation.coordinate
//            
//            
//            let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
//            
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func didReceiveSecondQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.ongoingQueryObjects = objects
            
            //            var locValue:CLLocationCoordinate2D = self.currentLocation.coordinate
            //
            //
            //            let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
            //
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    
    @IBAction func didChangeSegment(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            println("hot")
        case 1:
            println("new")
        case 2:
            println("ongoing")
        default:
            break;
        }
        self.tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return hotQueryObjects.count
            
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            return newQueryObjects.count
        }
        else if segmentedControl.selectedSegmentIndex == 2 {
            return ongoingQueryObjects.count
        }
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var finalCell: UITableViewCell?

        
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ActivityHotCell") as! ActivityHotCell
            
            

            
            finalCell = cell
        }

        else if segmentedControl.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ActivityNewCell") as! ActivityNewCell
            
            let queryObject = newQueryObjects[indexPath.row]
            
            let user = queryObject.objectForKey("creatingUser") as! PFUser
            let fullname = user.objectForKey("fullname") as? String
            let firstname = fullname?.componentsSeparatedByString(" ")[0]

            let message = queryObject.objectForKey("message") as? String
            let createdAt = queryObject.objectForKey("createdAt") as? String
            let placeName = queryObject.objectForKey("googlePlaceName") as? String
            let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
            let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
            
            var placeLabel: String?
            
            if let placeName = placeName {
                placeLabel = placeName
            }
            
            cell.nameLabel.text = firstname
            cell.messageLabel.text = message
            cell.locationLabel.text = placeName

            
            finalCell = cell
        }

        else if segmentedControl.selectedSegmentIndex == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ActivityOngoingCell") as! ActivityOngoingCell
            
            let queryObject = ongoingQueryObjects[indexPath.row]
            
            let user = queryObject.objectForKey("creatingUser") as! PFUser
            let fullname = user.objectForKey("fullname") as? String
            let firstname = fullname?.componentsSeparatedByString(" ")[0]
            
            let message = queryObject.objectForKey("message") as? String
            let createdAt = queryObject.objectForKey("createdAt") as? String
            let placeName = queryObject.objectForKey("googlePlaceName") as? String
            let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
            let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
            
            var placeLabel: String?
            
            if let placeName = placeName {
                placeLabel = placeName
            }
            
            cell.nameLabel.text = firstname
            cell.messageLabel.text = message
            cell.locationLabel.text = placeName

        finalCell = cell
        }
        

        return finalCell!
    }
    
}
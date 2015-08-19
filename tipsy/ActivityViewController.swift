//
//  ActivityViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/18/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import DateTools

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
            let createdAt = queryObject.createdAt
            let placeName = queryObject.objectForKey("googlePlaceName") as? String
            let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
            let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM d, hh:mm a"
            

            let timeAgo = createdAt!.shortTimeAgoSinceNow()
            
            var placeLabel: String?
            
            if let placeName = placeName {
                placeLabel = placeName
            }

            
            
            if let postImage = user.objectForKey("profileImage") as? PFFile {
                println("postImage \(postImage)")
                let imageData = postImage.getData()
                let image = UIImage(data: imageData!)
                cell.profileButton.setImage(image, forState: UIControlState.Normal)
                // cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.profileButton.tag = indexPath.row
                
            }

            cell.nameLabel.text = firstname
            cell.messageLabel.text = message
            cell.locationLabel.text = placeName
            cell.timeLabel.text = timeAgo

            
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
            
            let startTime = queryObject.objectForKey("startTime") as? NSDate
            let endTime = queryObject.objectForKey("endTime") as? NSDate
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM d, hh:mm a"
            
            let startTimeString = dateFormatter.stringFromDate(startTime!)
            let endTimeString = dateFormatter.stringFromDate(endTime!)

            
            
            var placeLabel: String?
            
            if let placeName = placeName {
                placeLabel = placeName
            }
            
            
            if let postImage = user.objectForKey("profileImage") as? PFFile {
                println("postImage \(postImage)")
                let imageData = postImage.getData()
                let image = UIImage(data: imageData!)
                cell.profileButton.setImage(image, forState: UIControlState.Normal)
                // cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.profileButton.tag = indexPath.row
                
            }
            
            cell.nameLabel.text = firstname
            cell.messageLabel.text = message
            cell.locationLabel.text = placeName

        finalCell = cell
        }
        

        return finalCell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("ActivityHeaderCell") as! CalendarHeaderCell
        
        
        if segmentedControl.selectedSegmentIndex == 0 {
            headerCell.headerLabel.text =  "Popular around you"
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            headerCell.headerLabel.text =  "Recently created"
        }
        else if segmentedControl.selectedSegmentIndex == 2 {
            headerCell.headerLabel.text =  "Happening now"
        }

        
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowPlanDetailsFromActivity", sender: nil)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowPlanDetailsFromActivity" {
            var selectedPlans = [PFObject]()
            
            let planDetailViewController = segue.destinationViewController as! PlanDetailViewController
            
            let index = self.tableView.indexPathForSelectedRow()!
        
            var queryObject: PFObject
            
            if segmentedControl.selectedSegmentIndex == 0 {
                queryObject = hotQueryObjects[index.row]
            }
            else if segmentedControl.selectedSegmentIndex == 1 {
                queryObject = newQueryObjects[index.row]
            }
            else  {
                queryObject = ongoingQueryObjects[index.row]
            }

            
            //            if segmentedControl.selectedSegmentIndex == 0 {
            //                queryObject = upcomingPlans[index.row]
            //            }
            //            else {
            //                queryObject = pastPlans[index.row]
            //            }
            selectedPlans.append(queryObject)
            println("selected plan \(selectedPlans)")
            planDetailViewController.planObjects = selectedPlans
        }
        
        
    }

    
}
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

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol, CLLocationManagerDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var query = QueryController()
    var newQueryObjects = [PFObject]()
    var hotQueryObjects = [PFObject]()
    var ongoingQueryObjects = [PFObject]()
    var userFriendsQueryObjects = [PFObject]()

    var newQueryPage = 0
    
    let locationManager = CLLocationManager()
    var refreshControl = UIRefreshControl()
    let currentUser = PFUser.currentUser()
    var currentLocation = CLLocation()

    func refreshPosts() {
        var locValue:CLLocationCoordinate2D = self.currentLocation.coordinate
        
        
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        query.queryUserIdsForFriends()
        self.refreshControl.endRefreshing()
    }

    override func viewWillDisappear(animated: Bool) {
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(animated: Bool) {
        activityIndicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.backgroundColor = UIColor(red:15/255, green: 65/255, blue: 79/255, alpha: 1)
        refreshControl.addTarget(self, action: "refreshPosts", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            if (locationManager.location != nil) {
                self.currentLocation = locationManager.location
            }
            println("queriedLocation \(currentLocation)")
        }

        var locValue:CLLocationCoordinate2D = self.currentLocation.coordinate


        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        
        
        query.delegate = self
        query.queryUserIdsForFriends()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planInteractedNotificationKey, object: nil)


        
    }
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.userFriendsQueryObjects = objects
            self.userFriendsQueryObjects.append(self.currentUser!)
            //self.createFriendIdArrays(objects)
            
            var locValue:CLLocationCoordinate2D = self.currentLocation.coordinate
            
            
            let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
            
            self.query.queryHotPlansForActivity(self.userFriendsQueryObjects, point: point)
            self.query.queryNewPlansForActivity(self.userFriendsQueryObjects, point: point)
            self.query.queryOngoingPlansForActivity(self.userFriendsQueryObjects, point: point)
            
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    
    func didReceiveSecondQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.hotQueryObjects = objects
            self.tableView.reloadData()

            self.activityIndicator.stopAnimating()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func didReceiveThirdQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.newQueryObjects = objects
            
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func didReceiveFourthQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.ongoingQueryObjects = objects
            
            
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
            
            let queryObject = hotQueryObjects[indexPath.row]
            
            let user = queryObject.objectForKey("creatingUser") as! PFUser
            let fullname = user.objectForKey("fullname") as? String
            let firstname = fullname?.componentsSeparatedByString(" ")[0]
            
            let message = queryObject.objectForKey("message") as? String
            let createdAt = queryObject.createdAt
            let placeName = queryObject.objectForKey("googlePlaceName") as? String
            let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
            let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
            let heartCount = queryObject.objectForKey("heartCount") as? Int
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM d, hh:mm a"
            
            
            let timeAgo = createdAt!.shortTimeAgoSinceNow()
            
            var placeLabel: String?
            
            if let placeName = placeName {
                placeLabel = placeName
            }
            
            
            
            println("heartCount \(heartCount)")
            
            
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
            cell.heartButton.setTitle(heartCount?.description, forState: UIControlState.Normal)

            
            if (indexPath.row == newQueryObjects.count - 1) {
                println("reached bottom")
            }
            
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

            
            if (indexPath.row == newQueryObjects.count - 1) {
                println("reached bottom")
            }
            
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
            
            if (indexPath.row == ongoingQueryObjects.count - 1) {
                println("reached bottom")
            }


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

    
    @IBAction func didTapHeart(sender: AnyObject) {
        
        let heartButton: UIButton = sender as! UIButton
        
        let cell = heartButton.superview?.superview as! ActivityHotCell
        
        
        //        println(cell)
        
        let index = self.tableView.indexPathForCell(cell)!
        
        var plan: PFObject
        
        if segmentedControl.selectedSegmentIndex == 0 {
            plan = hotQueryObjects[index.row]
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            plan = newQueryObjects[index.row]
        }
        else  {
            plan = ongoingQueryObjects[index.row]
        }
        
        //        println("selectedPlan \(plan)")
        
        var heartState = Bool()
        
        let heartingUsers = plan.objectForKey("heartingUsers") as? [String]
        
        if let hearts = heartingUsers {
            println("dem hearts \(hearts)")
            println("dat user \(currentUser!.objectId!)")
            if contains(hearts, currentUser!.objectId!) {
                //println ("plan \(queryObject) is hearted by \(currentUser!.objectId!)")
                heartState = true
            }
            else {
                heartState = false
            }
        }
        
        if heartState == false {
            plan.addUniqueObject(currentUser!.objectId!, forKey: "heartingUsers")
            
            heartState = !heartState
            
            let originalHeartingUserCount = heartingUsers?.count ?? 0
            
            let newHeartingUserCount = originalHeartingUserCount + 1
            
            let newHeartingUserCountString = String(newHeartingUserCount)
            
            cell.heartButton.setImage(UIImage(named: "LikeFilled.png"), forState: UIControlState.Normal)
            cell.heartButton.setTitle(newHeartingUserCountString, forState: UIControlState.Normal)
            println("hearted! \(heartState)")
            
        }
        else {
            plan.removeObject(currentUser!.objectId!, forKey: "heartingUsers")
            
            heartState = !heartState
            
            let originalHeartingUserCount = heartingUsers?.count ?? 0
            
            let newHeartingUserCount = originalHeartingUserCount - 1
            
            let newHeartingUserCountString = String(newHeartingUserCount)
            
            cell.heartButton.setImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
            cell.heartButton.setTitle(newHeartingUserCountString, forState: UIControlState.Normal)
            println("unhearted! \(heartState)")
        }
        
        
        plan.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                println("Success")
                NSNotificationCenter.defaultCenter().postNotificationName(planInteractedNotificationKey, object: self)

            }
            else {
                println("error \(error)")
            }
        }
    }
    
}
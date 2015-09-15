//
//  PlanTableViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/21/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import Darwin
import UIKit
import Amplitude_iOS
import Parse

class PlanTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol, CLLocationManagerDelegate {
 
    @IBOutlet weak var timeFilter: UIDatePicker!
    @IBOutlet weak var planTableView: UITableView!
    var query = QueryController()
    var queryObjects = [PFObject]()
    var filteredObjects = [PFObject]()
    var filtered: Bool = false
    var pastPlans = [PFObject]()
    var pastPlansOriginal = [PFObject]()
    var upcomingPlans = [PFObject]()
    var upcomingPlansOriginal = [PFObject]()
    let locationManager = CLLocationManager()
    var refreshControl = UIRefreshControl()
    let currentUser = PFUser.currentUser()
    var currentLocation = CLLocation()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var userFriendsQueryObjects = [PFObject]()
    
    var planTableHeaderArray = [String]()
    var friendIdArray = [String]()
    
    
    
    
    @IBOutlet weak var noFriendsLabel: UILabel!
    
    @IBOutlet weak var inviteLabel: UILabel!
    
    @IBOutlet weak var inviteButton: UIButton!
    
    
    @IBAction func didTapInvite(sender: AnyObject) {
        
        let textToShare = "Are you getting Tipsy?"
        
        if let website = NSURL(string: "http://www.everybodygettipsy.com/") {
            let objectsToShare = [textToShare, website]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
        
        Amplitude.instance().logEvent("tipsyInviteTapped")
    }
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.userFriendsQueryObjects = objects
            self.userFriendsQueryObjects.append(self.currentUser!)
            //self.createFriendIdArrays(objects)
            
            let locValue:CLLocationCoordinate2D = self.currentLocation.coordinate
            
            
            let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
            

            self.query.queryPlansForFriends(self.userFriendsQueryObjects, point: point)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func didReceiveSecondQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            print("friend feed objects \(self.queryObjects)")
            self.createPlanArrays(objects)
            self.createTableSections()
            self.planTableView!.reloadData()
            
            if self.upcomingPlans.count == 0 {
                self.planTableView!.hidden = true
                self.noFriendsLabel.hidden = false
                self.inviteLabel.hidden = false
                self.inviteButton.hidden = false
            }
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    

    
    func createFriendIdArrays(objects: [PFObject]) {
        for object in objects {
            let id = object.objectId
            friendIdArray.append(id!)
        }
    }

    
    func createPlanArrays(objects: [PFObject]) {
        
        upcomingPlansOriginal = [PFObject]()
        pastPlansOriginal = [PFObject]()
        pastPlans = [PFObject]()
        
        for object in objects {
            
            let endTime = object.objectForKey("endTime") as? NSDate
            let currentTime = NSDate()
            
            if currentTime.isEarlierThan(endTime) {
                upcomingPlansOriginal.append(object)
            }
            else {
                pastPlansOriginal.append(object)
            }
        }
        upcomingPlans = Array(upcomingPlansOriginal.reverse())
        pastPlans = pastPlansOriginal
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(animated: Bool) {
        activityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        Amplitude.instance().logEvent("friendFeedViewed")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        query.delegate = self
        query.queryUserIdsForFriends()
        
        self.planTableView!.delegate = self
        self.planTableView!.dataSource = self
        
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.backgroundColor = UIColor(red:15/255, green: 65/255, blue: 79/255, alpha: 1)
        self.refreshControl.addTarget(self, action: "refreshPosts", forControlEvents: UIControlEvents.ValueChanged)
        self.planTableView.addSubview(refreshControl)
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            
            if (locationManager.location != nil) {
                self.currentLocation = locationManager.location!
            }
        }

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planMadeNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planInteractedNotificationKey, object: nil)

        
        self.inviteButton.hidden = true
        self.inviteLabel.hidden = true
        self.noFriendsLabel.hidden = true
        
    }
    

    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func refreshPosts() {
        let locValue:CLLocationCoordinate2D = self.currentLocation.coordinate
        
        
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        query.queryPlansForFriends(self.userFriendsQueryObjects, point: point)
        self.refreshControl.endRefreshing()
    }
    
    
    @IBAction func didTapHeart(sender: AnyObject) {
        
        let heartButton: UIButton = sender as! UIButton
        
        let cell = heartButton.superview?.superview?.superview as! PlanFeedCell
        
        let index = self.planTableView.indexPathForCell(cell)!
        
        
        let sectionItems = self.getSectionItems(index.section)
        
        let plan = sectionItems[index.row]
        
        var heartState = Bool()
        
        let heartingUsers = plan.objectForKey("heartingUsers") as? [String]
        
        if let hearts = heartingUsers {
            if hearts.contains((currentUser!.objectId!)) {
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
            
        }
        else {
            plan.removeObject(currentUser!.objectId!, forKey: "heartingUsers")
            
            heartState = !heartState
            
            let originalHeartingUserCount = heartingUsers?.count ?? 0
            
            let newHeartingUserCount = originalHeartingUserCount - 1
            
            let newHeartingUserCountString = String(newHeartingUserCount)
            
            cell.heartButton.setImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
            cell.heartButton.setTitle(newHeartingUserCountString, forState: UIControlState.Normal)
        }
        
        
        plan.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                print("Success")
                NSNotificationCenter.defaultCenter().postNotificationName(planInteractedNotificationKey, object: self)
                
                let heartedPlanProperties = NSDictionary(object: plan.objectId!, forKey: "planId") as? [NSObject : AnyObject]
                
                Amplitude.instance().logEvent("planHearted", withEventProperties: heartedPlanProperties)

            }
            else {
                print("error \(error)")
            }
        }
    }
    
    @IBAction func didTapJoin(sender: AnyObject) {
        
        let joinButton: UIButton = sender as! UIButton
        
        let cell = joinButton.superview?.superview?.superview as! PlanFeedCell
        
        
        let index = self.planTableView.indexPathForCell(cell)!
        
        
        let sectionItems = self.getSectionItems(index.section)
        
        let plan = sectionItems[index.row]
        
        var attendanceState = Bool()
        
        let attendingUsers = plan.objectForKey("attendingUsers") as? [String]
        
        if let attendees = attendingUsers {
            if attendees.contains((currentUser!.objectId!)) {
                attendanceState = true
            }
            else {
                attendanceState = false
            }
        }
        
        
        if attendanceState == false {
            plan.addUniqueObject(currentUser!.objectId!, forKey: "attendingUsers")
            currentUser?.addUniqueObject(plan.objectId!, forKey: "attendedPlans")
            
            attendanceState = !attendanceState
            
            
            cell.joinButton.setImage(UIImage(named: "GenderNeutralUserFilled.png"), forState: UIControlState.Normal)
            cell.joinButton.setTitle("Joined!", forState: UIControlState.Normal)
            
        }
        else {
            
            plan.removeObject(currentUser!.objectId!, forKey: "attendingUsers")
            currentUser?.removeObject(plan.objectId!, forKey: "attendedPlans")
            
            attendanceState = !attendanceState
            
            cell.joinButton.setImage(UIImage(named: "AddUser.png"), forState: UIControlState.Normal)
            cell.joinButton.setTitle("Join", forState: UIControlState.Normal)
           
        }

        
        plan.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                print("Plan save success")
                
                let joinChannel = "join-" + plan.objectId!
                let commentsChannel = "comments-" + plan.objectId!
                
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject(joinChannel, forKey: "channels")
                currentInstallation.addUniqueObject(commentsChannel, forKey: "channels")
                currentInstallation.saveInBackground()
                print("registered installation for pushes")
                NSNotificationCenter.defaultCenter().postNotificationName(planInteractedNotificationKey, object: self)
                
                let joinedPlanProperties = NSDictionary(object: plan.objectId!, forKey: "planId") as? [NSObject : AnyObject]
                
                Amplitude.instance().logEvent("planJoined", withEventProperties: joinedPlanProperties)

            }
            else {
                print("Plan save error \(error)")
            }
        }

        currentUser?.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                print("User save success")
            }
            else {
                print("User save error \(error)")
            }
        }

        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowPlanDetailView" {
            var selectedPlans = [PFObject]()
            
            let planDetailViewController = segue.destinationViewController as! PlanDetailViewController
            
            let index = self.planTableView.indexPathForSelectedRow!
            
            
            let sectionItems = self.getSectionItems(index.section)
            
            var queryObject: PFObject
            
            queryObject = sectionItems[index.row]
            
            selectedPlans.append(queryObject)
            planDetailViewController.planObjects = selectedPlans
        }
        
    }
    
    func createTableSections() {
        
        planTableHeaderArray = [String]()
        
        var plansForSection = [PFObject]()
        
        plansForSection = upcomingPlans
        let sections = NSSet(array: planTableHeaderArray)
        
        for object in plansForSection {
            let objectDate = object.objectForKey("startTime") as! NSDate
            
            let df = NSDateFormatter()
            df.dateFormat = "MM/dd/yyyy"
            
            let dateString = df.stringFromDate(objectDate)
            
            if !planTableHeaderArray.contains(dateString) {
                planTableHeaderArray.append(dateString)
            }
        }

    }
    
    func getSectionItems(section: Int) -> [PFObject] {
        var sectionItems = [PFObject]()

        var plansForSection = [PFObject]()

        
        plansForSection = upcomingPlans
        
        for object in plansForSection {
            let objectDate = object.objectForKey("startTime") as! NSDate
            
            let df = NSDateFormatter()
            df.dateFormat = "MM/dd/yyyy"
            
            let dateString = df.stringFromDate(objectDate)
            
            if dateString == planTableHeaderArray[section] as NSString {
                sectionItems.append(object)
            }
            
        }
        
        return sectionItems

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return planTableHeaderArray.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("CalendarHeaderCell") as! CalendarHeaderCell

        let dateString = planTableHeaderArray[section]
        
        let df = NSDateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        let date = df.dateFromString(dateString)!
        
        let today = NSDate()
        let todayString = df.stringFromDate(today)
        
        df.dateFormat = "EEEE"
        
        let dayOfWeekString = df.stringFromDate(date)
        
        df.dateFormat = "MMMM dd"
        let prettyDateString = df.stringFromDate(date)
        
        if (dateString == todayString) {
            headerCell.headerLabel.text = "Today"
        }
        else {
            headerCell.headerLabel.text =  dayOfWeekString + ", " + prettyDateString
            
        }
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.getSectionItems(section).count
        
    }

    func didTapUserProfileImage(sender: UIButton!) {
        var queryObject: PFObject
        
        let tag = sender.tag
        let section = sender.tag / 100
        let row = sender.tag % 100
        
        let sectionItems = self.getSectionItems(section)
        
        queryObject = sectionItems[row]

        let user = queryObject.objectForKey("creatingUser") as? PFUser
        
        let profileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PlanProfileViewController") as! PlanProfileViewController
        profileViewController.user = user
        self.navigationController?.pushViewController(profileViewController, animated: true)

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var queryObject: PFObject
        
        let sectionItems = self.getSectionItems(indexPath.section)
        
        queryObject = sectionItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PlanTableCell") as! PlanFeedCell
        
        cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        let user = queryObject.objectForKey("creatingUser") as! PFUser
        let fullname = user.objectForKey("fullname") as? String
        let message = queryObject.objectForKey("message") as? String
        let startTime = queryObject.objectForKey("startTime") as? NSDate
        let endTime = queryObject.objectForKey("endTime") as? NSDate
        let placeName = queryObject.objectForKey("googlePlaceName") as? String
        let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
        let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
        
        var placeLabel: String?
        
        var heartState: Bool? = false
        
        let heartingUsers = queryObject.objectForKey("heartingUsers") as? [String]
        let countHeartingUsers = heartingUsers?.count
        
        if let hearts = heartingUsers {
            if hearts.contains((currentUser!.objectId!)) {
                heartState = true
            }
        }
        
        var attendanceState: Bool? = false
        
        let attendingUsers = queryObject.objectForKey("attendingUsers") as? [String]
        let countAttendingUsers = attendingUsers?.count
        
        if let attendees = attendingUsers {
            if attendees.contains((currentUser!.objectId!)) {
                attendanceState = true
            }
        }
        
        let comments = queryObject.objectForKey("comments") as? [String]
        let commentCount = comments?.count
        
        cell.commentButton.setTitle(commentCount?.description, forState: UIControlState.Normal)
        
        if let placeName = placeName {
            placeLabel = placeName
        }

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        let startTimeString = dateFormatter.stringFromDate(startTime!)
        let endTimeString = dateFormatter.stringFromDate(endTime!)

        let currentTime = NSDate()
        
        if currentTime.isEarlierThan(endTime) && currentTime.isLaterThan(startTime) {
            cell.happeningNowBadge.hidden = false
        }
        
        let fullTimeString = "\(startTimeString) to \(endTimeString)"

        
        if let postImage = user.objectForKey("profileImage") as? PFFile {
            
            postImage.getDataInBackgroundWithBlock({
                (imageData,error) -> Void in
                if error == nil {
                    
                    if let imageData = imageData {
                        dispatch_async(dispatch_get_main_queue()) {
                            let image = UIImage(data: imageData)
                            
                            cell.profileImageButton.setImage(image, forState: UIControlState.Normal)
                            cell.profileImageButton.tag = (indexPath.section)*100 + indexPath.row
                            cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                        }
                    }
                }
                else {
                    print("image retrieval error")
                }
            })
            
            
        }
        
        

        let firstname = fullname?.componentsSeparatedByString(" ")[0]
        
        cell.name.text = firstname
        cell.fullTime.text = fullTimeString
        cell.location.text = placeLabel
        
        if let message = message {
            cell.message.text = message
        }
        
        if (heartState == true) {
            cell.heartButton.setImage(UIImage(named: "LikeFilled.png"), forState: UIControlState.Normal)
        }
        else {
            cell.heartButton.setImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)

        }

        if heartingUsers?.count == 0 {
            cell.heartButton.setTitle(" ", forState: UIControlState.Normal)
        }
        else {
            cell.heartButton.setTitle(heartingUsers?.count.description, forState: UIControlState.Normal)
            
        }

        if (queryObject.objectForKey("creatingUser")?.objectId == PFUser.currentUser()?.objectId) {
            cell.joinButton.hidden = true
        }
        else if (attendanceState == true) {
            cell.joinButton.setImage(UIImage(named: "GenderNeutralUserFilled.png"), forState: UIControlState.Normal)
            cell.joinButton.setTitle("Joined!", forState: UIControlState.Normal)

        }
        else {
            cell.joinButton.setImage(UIImage(named: "AddUser.png"), forState: UIControlState.Normal)
            cell.joinButton.setTitle("Join", forState: UIControlState.Normal)

            
        }

        
  
//        cell.heartButton.setTitle(heartState?.description, forState: UIControlState.Normal)

        
    
        
        return cell
    }


}
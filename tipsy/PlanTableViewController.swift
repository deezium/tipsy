//
//  PlanTableViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/21/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

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
    
    var planTableHeaderArray = [String]()
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    @IBAction func didChangeSegment(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            println("upcoming")
        case 1:
            println("past")

        default:
            break;
        }
        self.createTableSections()
        self.planTableView.reloadData()
    }
    
    

    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.createPlanArrays(objects)
            self.createTableSections()
            self.planTableView!.reloadData()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
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
        upcomingPlans = upcomingPlansOriginal.reverse()
        pastPlans = pastPlansOriginal
        println("upcomingPlans \(upcomingPlans)")
        println("pastPlansCount \(pastPlans.count)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveFacebookData()
        query.delegate = self
        query.queryPlans("")
        
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
//        if (CLLocationManager.locationServicesEnabled()) {
//            self.locationManager.delegate = self
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            self.locationManager.startUpdatingLocation()
//        }

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planMadeNotificationKey, object: nil)
        

        
    }
    
    func saveFacebookData() {
        if (PFUser.currentUser() != nil && PFUser.currentUser()?.objectForKey("fullname") == nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                println("has access token")
                let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        println("OOPS")
                    }
                    else {
                        println(result["name"])
                        PFUser.currentUser()?.setObject(result["name"], forKey: "fullname")
                        PFUser.currentUser()?.saveInBackground()
                    }
                })
            }
            
        }
        
        if (PFUser.currentUser() != nil && PFUser.currentUser()?.objectForKey("profileImage") == nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                println("has access token")
                let pictureRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
                pictureRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        println("OOPS")
                    }
                    else {
                        println(result["data"]!["url"])
                        let pictureString = result["data"]!["url"] as! String
                        let pictureURL = NSURL(string: pictureString)
                        let pictureData = NSData(contentsOfURL: pictureURL!)
                        println(pictureData)
                        var pictureFile = PFFile(data: pictureData!)
                        PFUser.currentUser()?.setObject(pictureFile, forKey: "profileImage")
                        PFUser.currentUser()?.saveInBackground()
                    }
                })
            }
            
        }
    }

    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            println("your current location is \(location)")
            locationManager.stopUpdatingLocation()
        }
    }
    
    func refreshPosts() {
        query.queryPlans("")
        self.refreshControl.endRefreshing()
    }
    
    
    @IBAction func didTapHeart(sender: AnyObject) {
        
        let heartButton: UIButton = sender as! UIButton
        
        let cell = heartButton.superview?.superview?.superview as! PlanFeedCell
        
        
//        println(cell)
        
        let index = self.planTableView.indexPathForCell(cell)!
        
        
        let sectionItems = self.getSectionItems(index.section)
        
        let plan = sectionItems[index.row]

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
            }
            else {
                println("error \(error)")
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
            println("dem attendees \(attendees)")
            println("dat user \(currentUser!.objectId!)")
            if contains(attendees, currentUser!.objectId!) {
                //println ("plan \(queryObject) is hearted by \(currentUser!.objectId!)")
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
            println("joined! \(attendanceState)")
            
        }
        else {
            plan.removeObject(currentUser!.objectId!, forKey: "attendingUsers")
            currentUser?.removeObject(plan.objectId!, forKey: "attendedPlans")
            
            attendanceState = !attendanceState
           
            
            cell.joinButton.setImage(UIImage(named: "AddUser.png"), forState: UIControlState.Normal)
            cell.joinButton.setTitle("Join", forState: UIControlState.Normal)
            println("left! \(attendanceState)")
        }

        
        plan.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                println("Plan save success")
            }
            else {
                println("Plan save error \(error)")
            }
        }

        currentUser?.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                println("User save success")
            }
            else {
                println("User save error \(error)")
            }
        }

        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowPlanDetailView" {
            var selectedPlans = [PFObject]()
            
            let planDetailViewController = segue.destinationViewController as! PlanDetailViewController
            
            let index = self.planTableView.indexPathForSelectedRow()!
            
            
            let sectionItems = self.getSectionItems(index.section)
            
            var queryObject: PFObject
            
            queryObject = sectionItems[index.row]
            
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
    
    func createTableSections() {
        
        planTableHeaderArray = [String]()
        
        var plansForSection = [PFObject]()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            plansForSection = upcomingPlans
        }
        else {
            plansForSection = pastPlans
        }
        
        let sections = NSSet(array: planTableHeaderArray)
        
        println("plansForSection \(plansForSection)")
        
        for object in plansForSection {
            let objectDate = object.objectForKey("startTime") as! NSDate
            
            let df = NSDateFormatter()
            df.dateFormat = "MM/dd/yyyy"
            
            let dateString = df.stringFromDate(objectDate)
            
            println("sections \(sections)")
            
            
            
            if !contains(planTableHeaderArray, dateString) {
                planTableHeaderArray.append(dateString)
            }
        }
        println("planTableHeaderArrayCount \(planTableHeaderArray.count)")

    }
    
    func getSectionItems(section: Int) -> [PFObject] {
        var sectionItems = [PFObject]()

        var plansForSection = [PFObject]()

        
        if segmentedControl.selectedSegmentIndex == 0 {
            plansForSection = upcomingPlans
        }
        else {
            plansForSection = pastPlans
        }
        
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
//        
//        println(queryObjects.count)
//        if segmentedControl.selectedSegmentIndex == 0 {
//            return upcomingPlans.count
//        }
//        else {
//            return pastPlans.count
//        }
//        
        
        return self.getSectionItems(section).count
        
    }

    func didTapUserProfileImage(sender: UIButton!) {

        var queryObject: PFObject
        
        println("profile image tapped!")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var queryObject: PFObject
        
//        if segmentedControl.selectedSegmentIndex == 0 {
//            queryObject = upcomingPlans[indexPath.row]
//        }
//        else {
//            queryObject = pastPlans[indexPath.row]
//        }
        
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
            println("dem hearts \(hearts)")
            println("dat user \(currentUser!.objectId!)")
            if contains(hearts, currentUser!.objectId!) {
                println ("plan \(queryObject.objectId) is hearted by \(currentUser!.objectId!)")
                heartState = true
            }
        }
        
        var attendanceState: Bool? = false
        
        let attendingUsers = queryObject.objectForKey("attendingUsers") as? [String]
        let countAttendingUsers = attendingUsers?.count
        
        if let attendees = attendingUsers {
            println("dem hearts \(attendees)")
            println("dat user \(currentUser!.objectId!)")
            if contains(attendees, currentUser!.objectId!) {
                println ("plan \(queryObject) is being attended by \(currentUser!.objectId!)")
                attendanceState = true
            }
        }
        
        let comments = queryObject.objectForKey("comments") as? [String]
        let commentCount = comments?.count
        
        cell.commentButton.setTitle(commentCount?.description, forState: UIControlState.Normal)
        
        if let placeName = placeName {
            placeLabel = placeName
        }

        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        let startTimeString = dateFormatter.stringFromDate(startTime!)
        let endTimeString = dateFormatter.stringFromDate(endTime!)
        
        println(startTime)
        println(endTime)

        
        let fullTimeString = "\(startTimeString) to \(endTimeString)"

        
        if let postImage = user.objectForKey("profileImage") as? PFFile {
            let imageData = postImage.getData()
            let image = UIImage(data: imageData!)
            let testImage = UIImage(named: "Map-50.png") as UIImage!
            
            cell.profileImageButton.setImage(image, forState: UIControlState.Normal)
        }
        
        

        let firstname = fullname?.componentsSeparatedByString(" ")[0]
        
        cell.name.text = firstname
//        cell.startTime.text = startTimeString
//        cell.endTime.text = endTimeString
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

        cell.heartButton.setTitle(heartingUsers?.count.description, forState: UIControlState.Normal)

        if (attendanceState == true) {
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
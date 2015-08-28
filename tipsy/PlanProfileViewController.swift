//
//  PlanProfileViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/21/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import Amplitude_iOS

class PlanProfileViewController: UIViewController, QueryControllerProtocol, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var planTableView: UITableView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var aboutLabel: UILabel!
    var planTableHeaderArray = [String]()

    @IBOutlet weak var interestsLabel: UILabel!
    let currentUser = PFUser.currentUser()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    @IBAction func didChangeSegment(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                println("upcoming")
                var viewedProfileProperties = NSDictionary(object: user!.objectId!, forKey: "userId") as? [NSObject : AnyObject]
                
                Amplitude.instance().logEvent("profileUpcomingPlansViewed", withEventProperties: viewedProfileProperties)
            case 1:
                println("past")
                var viewedProfileProperties = NSDictionary(object: user!.objectId!, forKey: "userId") as? [NSObject : AnyObject]

                Amplitude.instance().logEvent("profilePastPlansViewed", withEventProperties: viewedProfileProperties)
            default:
                break;
        }
        self.createTableSections()
        self.planTableView.reloadData()
    }
    
    var user = PFUser.currentUser()
    
    var query = QueryController()
    var queryObjects = [PFObject]()
    var pastPlans = [PFObject]()
    var pastPlansOriginal = [PFObject]()
    var upcomingPlans = [PFObject]()
    var upcomingPlansOriginal = [PFObject]()
    var userFriendsQueryObjects = [PFObject]()

 
    func didReceiveSecondQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.createPlanArrays(objects)
            self.createTableSections()

            self.planTableView!.reloadData()
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.userFriendsQueryObjects = objects
            self.userFriendsQueryObjects.append(self.currentUser!)
            //self.createFriendIdArrays(objects)
            
            
            self.query.queryProfilePlans("creatingUser", userId: self.user!.objectId!, friends: self.userFriendsQueryObjects)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
            let planCreationViewController = segue.destinationViewController as! PlanCreationViewController
            
            var selectedPlans = [PFObject]()

            
            
            if let selectedEditButton = sender as? UIButton {
            
                let index = selectedEditButton.tag
                let selectedPlan = upcomingPlans[index]
                
                // There's probably a better way to do this
                
                selectedPlans.append(selectedPlan)
                planCreationViewController.plans = selectedPlans
                println("pcvc plans\(planCreationViewController.plans)")
            }
            
        }
        
        
        if segue.identifier == "ShowPlanDetailViewFromProfile" {
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
        println("profileUpcomingPlans \(upcomingPlans)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(animated: Bool) {
        activityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        user!.fetchInBackground()
        
        if let about = user!.objectForKey("about") as? String {
            aboutLabel.text = "About me: " + about
        }
        else {
            aboutLabel.text = "About me: I'm awesome, duh."
        }
        
        var viewedProfileProperties = NSDictionary(object: user!.objectId!, forKey: "userId") as? [NSObject : AnyObject]
        
        
        Amplitude.instance().logEvent("profileViewed", withEventProperties: viewedProfileProperties)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
     
        
        query.delegate = self
        query.queryUserIdsForFriends()


        self.username.text = user!.objectForKey("fullname") as? String
        
        if let profileImage = user!.objectForKey("profileImage") as? PFFile {
            let imageData = profileImage.getData()
            let image = UIImage(data: imageData!)
            self.profileImage.image = image
            
        }
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        if let about = user!.objectForKey("about") as? String {
            aboutLabel.text = "About me: " + about
        }
        else {
            aboutLabel.text = "About me: I'm awesome, duh."
        }
        
        self.planTableView!.delegate = self
        self.planTableView!.dataSource = self
        
        if (user?.objectId != PFUser.currentUser()?.objectId) {
            editButton.hidden = true
            segmentedControl.selectedSegmentIndex = 1
        }
        else {
            editButton.hidden = false
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planMadeNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planInteractedNotificationKey, object: nil)


        
    }
    
    func refreshPosts() {
        println("profile refreshPosts called")
        query.queryProfilePlans("creatingUser", userId: self.user!.objectId!, friends: self.userFriendsQueryObjects)
    }

    
    @IBAction func didTapHeartButton(sender: AnyObject) {
        
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
                NSNotificationCenter.defaultCenter().postNotificationName(planInteractedNotificationKey, object: self)
                
                var heartedPlanProperties = NSDictionary(object: plan.objectId!, forKey: "planId") as? [NSObject : AnyObject]
                
                Amplitude.instance().logEvent("planHearted", withEventProperties: heartedPlanProperties)

            }
            else {
                println("error \(error)")
            }
        }
        
    }
    
    
    
    @IBAction func didTapJoinButton(sender: AnyObject) {
        
        
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
                let joinChannel = "join-" + plan.objectId!
                let commentsChannel = "comments-" + plan.objectId!
                
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject(joinChannel, forKey: "channels")
                currentInstallation.addUniqueObject(commentsChannel, forKey: "channels")
                currentInstallation.saveInBackground()
                println("registered installation for pushes")

                NSNotificationCenter.defaultCenter().postNotificationName(planInteractedNotificationKey, object: self)

                println("Plan save success")
                
                var joinedPlanProperties = NSDictionary(object: plan.objectId!, forKey: "planId") as? [NSObject : AnyObject]
                
                
                Amplitude.instance().logEvent("planJoined", withEventProperties: joinedPlanProperties)

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
        let headerCell = tableView.dequeueReusableCellWithIdentifier("ProfileFeedHeaderCell") as! CalendarHeaderCell
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFeedCell") as! PlanFeedCell
        
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
        
        let comments = queryObject.objectForKey("comments") as? [String]
        let commentCount = comments?.count
        
        cell.commentButton.setTitle(commentCount?.description, forState: UIControlState.Normal)

        
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
        
        
        
        if let placeName = placeName {
            placeLabel = placeName
        }
        
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        let startTimeString = dateFormatter.stringFromDate(startTime!)
        let endTimeString = dateFormatter.stringFromDate(endTime!)
        
        println(startTime)
        println(endTime)
        
        let currentTime = NSDate()
        
        if currentTime.isEarlierThan(endTime) && currentTime.isLaterThan(startTime) {
            cell.happeningNowBadge.hidden = false
        }

        
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
        if heartingUsers?.count == 0 {
            cell.heartButton.setTitle("0", forState: UIControlState.Normal)
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
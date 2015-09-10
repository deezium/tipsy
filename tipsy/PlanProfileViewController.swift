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
                let viewedProfileProperties = NSDictionary(object: user!.objectId!, forKey: "userId") as? [NSObject : AnyObject]
                
                Amplitude.instance().logEvent("profileUpcomingPlansViewed", withEventProperties: viewedProfileProperties)
            case 1:
                let viewedProfileProperties = NSDictionary(object: user!.objectId!, forKey: "userId") as? [NSObject : AnyObject]

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
            }
            
        }
        
        
        if segue.identifier == "ShowPlanDetailViewFromProfile" {
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
        user!.fetchInBackground()
        activityIndicator.startAnimating()
        query.delegate = self
        query.queryUserIdsForFriends()

        
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


        self.username.text = user!.objectForKey("fullname") as? String
        
        if let profileImage = user!.objectForKey("profileImage") as? PFFile {
            
            profileImage.getDataInBackgroundWithBlock({
                (imageData,error) -> Void in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        let image = UIImage(data: imageData!)
                        self.profileImage.image = image
                    }
                }
                else {
                    print("image retrieval error")
                }
            })
            
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
        print("profile refreshPosts called")
        query.queryProfilePlans("creatingUser", userId: self.user!.objectId!, friends: self.userFriendsQueryObjects)
    }

    
    @IBAction func didTapHeartButton(sender: AnyObject) {
        
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
    
    
    
    @IBAction func didTapJoinButton(sender: AnyObject) {
        
        
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
                let joinChannel = "join-" + plan.objectId!
                let commentsChannel = "comments-" + plan.objectId!
                
                let currentInstallation = PFInstallation.currentInstallation()
                
                let currentChannels = currentInstallation.objectForKey("channels") as? [String]
                
//                if contains(currentChannels!, joinChannel) {
//                    currentInstallation.removeObject(joinChannel, forKey: "channels")
//                }
//                else {
//                    currentInstallation.addUniqueObject(joinChannel, forKey: "channels")
//                }
                
//                if currentInstallation.objectForKey("channels") != nil {
//                    currentInstallation.addUniqueObject(joinChannel, forKey: "channels")
//                    currentInstallation.addUniqueObject(commentsChannel, forKey: "channels")
//                }
//                else {
//                    currentInstallation.setObject(joinChannel, forKey: "channels")
//                    currentInstallation.setObject(commentsChannel, forKey: "channels")
//                }

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
        
        
        
        if let placeName = placeName {
            placeLabel = placeName
        }
        
        
        var dateFormatter = NSDateFormatter()
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
                    dispatch_async(dispatch_get_main_queue()) {
                        let image = UIImage(data: imageData!)
                        cell.profileImageButton.setImage(image, forState: UIControlState.Normal)
                    }
                }
                else {
                    print("image retrieval error")
                }
            })

            
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
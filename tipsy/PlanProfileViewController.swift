//
//  PlanProfileViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/21/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class PlanProfileViewController: UIViewController, QueryControllerProtocol, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var planTableView: UITableView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var planTableHeaderArray = [String]()

    let currentUser = PFUser.currentUser()

    
    @IBAction func didChangeSegment(sender: UISegmentedControl) {
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
    
    let user = PFUser.currentUser()
    
    var query = QueryController()
    var queryObjects = [PFObject]()
    var pastPlans = [PFObject]()
    var pastPlansOriginal = [PFObject]()
    var upcomingPlans = [PFObject]()
    var upcomingPlansOriginal = [PFObject]()

 
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.createPlanArrays(objects)
            self.createTableSections()

            self.planTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let planCreationViewController = segue.destinationViewController as! PlanCreationViewController
            
            var selectedPlans = [PFObject]()

            
//            if let selectedRow = sender as? UITableViewCell {
//                let index = selectedRow[indexPath.row]
//                let selectedPlan = upcomingPlans[index]
//                selectedPlans.append(selectedPlan)
//                planCreationViewController.plans = selectedPlans
//                println(planCreationViewController.plans)
//            }
//            
            
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
            var queryObject: PFObject
            if segmentedControl.selectedSegmentIndex == 0 {
                queryObject = upcomingPlans[index.row]
            }
            else {
                queryObject = pastPlans[index.row]
            }
            selectedPlans.append(queryObject)
            println("selected plan \(selectedPlans)")
            planDetailViewController.planObjects = selectedPlans
        }

    }
    
    
    func createPlanArrays(objects: [PFObject]) {
        
        upcomingPlans = [PFObject]()
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

        pastPlans = pastPlansOriginal.reverse()
        println("profileUpcomingPlans \(upcomingPlans)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        query.delegate = self
        query.queryProfilePlans("creatingUser")

        self.username.text = user!.objectForKey("fullname") as? String
        
        if let profileImage = user!.objectForKey("profileImage") as? PFFile {
            let imageData = profileImage.getData()
            let image = UIImage(data: imageData!)
            self.profileImage.image = image
            
        }
        
        self.planTableView!.delegate = self
        self.planTableView!.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planMadeNotificationKey, object: nil)

        
    }
    
    func refreshPosts() {
        query.queryProfilePlans("creatingUser")
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
        
        df.dateFormat = "EEEE"
        
        let dayOfWeekString = df.stringFromDate(date)
        
        df.dateFormat = "MMMM dd"
        let prettyDateString = df.stringFromDate(date)
        
        headerCell.headerLabel.text =  dayOfWeekString + ", " + prettyDateString
        
        
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
        
        
        let fullTimeString = "\(startTimeString) to \(endTimeString)"
        
        
        if let postImage = user.objectForKey("profileImage") as? PFFile {
            let imageData = postImage.getData()
            let image = UIImage(data: imageData!)
            let testImage = UIImage(named: "Map-50.png") as UIImage!
            cell.profileImage.image = image
            
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

    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//
//        var queryObject: PFObject
//        let cell = tableView.dequeueReusableCellWithIdentifier("PlanProfileCell") as! PlanProfileCell
//        
//        if segmentedControl.selectedSegmentIndex == 0 {
//            queryObject = upcomingPlans[indexPath.row]
//            cell.editButton.hidden = false
//            cell.checkboxImage.hidden = true
//        }
//        else {
//            queryObject = pastPlans[indexPath.row]
//            cell.editButton.hidden = true
//            cell.checkboxImage.hidden = false
//        }
//        
//        
//        let user = queryObject.objectForKey("creatingUser") as! PFUser
//        let username = user.objectForKey("fullname") as? String
//        let message = queryObject.objectForKey("message") as? String
//        let startTime = queryObject.objectForKey("startTime") as? NSDate
//        let endTime = queryObject.objectForKey("endTime") as? NSDate
//        let placeName = queryObject.objectForKey("googlePlaceName") as? String
//        let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
//        let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
//        var placeLabel: String?
//        var addressLabel: String?
//        
//        if let placeName = placeName {
//            placeLabel = placeName
//        }
//        
//        if let shortAddress = shortAddress {
//            addressLabel = shortAddress
//        }
//
//        var dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "MMM d, hh:mm a"
//        
//        let startTimeString = dateFormatter.stringFromDate(startTime!)
//        let endTimeString = dateFormatter.stringFromDate(endTime!)
//
//        cell.startTime.text = startTimeString
//        cell.endTime.text = endTimeString
//        cell.location.text = placeLabel
//        cell.addressLabel.text = shortAddress
//        cell.editButton.tag = indexPath.row
//
//        if let message = message {
//            cell.message.text = message
//        }
//        
//        return cell
//    }
    
}
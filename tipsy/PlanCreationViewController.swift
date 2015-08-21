//
//  PlanCreationViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/20/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps
import Darwin

let planMadeNotificationKey = "planMadeNotificationKey"

class PlanCreationViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()

    var selectedPlaceId = String()
    var selectedPlaceName = String()
    var selectedPlaceGeoPoint = PFGeoPoint()
    var selectedPlaceFormattedAddress = String()
    var plans = [PFObject]()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
   
    
    // DATE PICKER CONSTANTS
    
    let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker into view
    let kDatePickerTag           = 99   // view tag identifiying the date picker view
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    let kDateStartRow = 3
    let kDateEndRow   = 4
    
    let kDateCellID       = "dateCell";       // the cells with the start or end date
    let kDatePickerCellID = "DatePickerCell"; // the cell containing the date picker
    let kOtherCellID      = "otherCell";      // the remaining cells at the end
    let kDividerCellID = "PlanCreationDividerCell"
    let kPlanCreationActivityCellID = "PlanCreationActivityCell"
    let kPlanCreationLocationCellID = "PlanCreationLocationCell"
    
    var dataArray: [[String: AnyObject]] = []
    var dateFormatter = NSDateFormatter()
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: NSIndexPath?
    
    var pickerCellRowHeight: CGFloat = 216

    @IBOutlet var pickerView: UIDatePicker!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    @IBAction func didTapPostButton(sender: AnyObject) {

        let currentTime = NSDate()
//        let futureBoundTime = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: 168, toDate: currentTime, options: NSCalendarOptions.WrapComponents) as NSDate!
//        let lengthBound = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: 24, toDate: currentTime, options: NSCalendarOptions.WrapComponents) as NSDate!
        
        let activityIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let activityCell = self.tableView.cellForRowAtIndexPath(activityIndexPath) as! PlanCreationActivityCell
        println("activityCell \(activityCell.messageLabel.text)")
        
        let locationIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        let locationCell = self.tableView.cellForRowAtIndexPath(locationIndexPath) as! PlanCreationLocationCell
        println("locationCell \(locationCell.locationLabel.text)")
        
        
        
        let startDateIndexPath = NSIndexPath(forRow: 3, inSection: 0)
        let startDateCell = self.tableView.cellForRowAtIndexPath(startDateIndexPath) as UITableViewCell?
        let startDateString = startDateCell?.detailTextLabel?.text as String!
        
        println("startDateString \(startDateString)")
        
        let planStartDate = self.dateFormatter.dateFromString(startDateString) as NSDate!
        
        
        let endDateIndexPath = NSIndexPath(forRow: 4, inSection: 0)
        let endDateCell = self.tableView.cellForRowAtIndexPath(endDateIndexPath) as UITableViewCell?
        let endDateString = endDateCell?.detailTextLabel?.text as String!
        
        let planEndDate = self.dateFormatter.dateFromString(endDateString) as NSDate!
        
        println("endDateString \(endDateString)")

        let lengthBound = planStartDate.dateByAddingHours(24)
        
        println("planEndDate \(planEndDate)")
        println("lengthBound \(lengthBound)")


        if activityCell.messageLabel.text == "" {
            let alert = UIAlertController(title: "Sorry!", message: "You didn't tell us what you're doing!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Whoops!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else if locationCell.locationLabel.text == "Where are you going?" {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make a plan without a location!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else if planEndDate.isEarlierThan(planStartDate) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans that end before they start!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
//        else if planStartDate.isLaterThan(futureBoundTime) {
//            let alert = UIAlertController(title: "Sorry!", message: "We love your enthusiasm, but you can't make an event more than a week in advance.", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//            
//        }
        else if planEndDate.isLaterThan(lengthBound) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make an event that lasts longer than 24 hours.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }

        else {
            postButton.enabled = false
            activityIndicator.startAnimating()

            let activityIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            let activityCell = self.tableView.cellForRowAtIndexPath(activityIndexPath) as! PlanCreationActivityCell
            println("activityCell \(activityCell.messageLabel.text)")


            let visibilityIndexPath = NSIndexPath(forRow: 2, inSection: 0)
            let visibilityCell = self.tableView.cellForRowAtIndexPath(visibilityIndexPath) as! PlanCreationVisibilityCell

            
            let startDateIndexPath = NSIndexPath(forRow: 3, inSection: 0)
            let startDateCell = self.tableView.cellForRowAtIndexPath(startDateIndexPath) as UITableViewCell?
            let startDateString = startDateCell?.detailTextLabel?.text as String!
            
            println("startDateString \(startDateString)")
            
            let planStartDate = self.dateFormatter.dateFromString(startDateString) as NSDate!

            
            let endDateIndexPath = NSIndexPath(forRow: 4, inSection: 0)
            let endDateCell = self.tableView.cellForRowAtIndexPath(endDateIndexPath) as UITableViewCell?
            let endDateString = endDateCell?.detailTextLabel?.text as String!
            
            let planEndDate = self.dateFormatter.dateFromString(endDateString) as NSDate!

            
            println("endDateString \(endDateString)")
        
            var visibilityStatus = 0
            
            if visibilityCell.visibilityControl.selectedSegmentIndex == 1 {
                visibilityStatus = 1
            }
        
            let planObject = PFObject(className: "Plan")
            planObject.setObject(planStartDate, forKey: "startTime")
            planObject.setObject(planEndDate, forKey: "endTime")
            planObject.setObject(PFUser.currentUser()!, forKey: "creatingUser")
            planObject.setObject(selectedPlaceId, forKey: "googlePlaceId")
            planObject.setObject(selectedPlaceName, forKey: "googlePlaceName")
            planObject.setObject(selectedPlaceFormattedAddress, forKey: "googlePlaceFormattedAddress")
            planObject.setObject(activityCell.messageLabel.text, forKey: "message")
            planObject.setObject(selectedPlaceGeoPoint, forKey: "googlePlaceCoordinate")
            planObject.setObject(visibilityStatus, forKey: "visibility")
            
            let ACL = PFACL()
            ACL.setPublicReadAccess(true)
            ACL.setPublicWriteAccess(true)
            planObject.ACL = ACL
            
            planObject.saveInBackgroundWithBlock {
                (success, error) -> Void in
                if success == true {
                    println("Success \(planObject.objectId)")
                    
                    let pushChannel = "all-" + planObject.objectId!
                    
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation.addUniqueObject(pushChannel, forKey: "channels")
                    currentInstallation.saveInBackground()
                    println("registered installation for pushes")
                    self.activityIndicator.stopAnimating()
                    self.postButton.enabled = true
                    self.performSegueWithIdentifier("ShowProfileFromCreation", sender: nil)
           
                    NSNotificationCenter.defaultCenter().postNotificationName(planMadeNotificationKey, object: self)
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.postButton.enabled = true
                    let alert = UIAlertController(title: "Sorry!", message: "We had trouble posting your plan.  Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        

        }
    }
    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        self.tableView.endEditing(true)
//    }
    
    override func viewWillDisappear(animated: Bool) {
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(animated: Bool) {
        activityIndicator.stopAnimating()
    }
    
    @IBAction func didTapUpdateButton(sender: AnyObject) {
        let currentTime = NSDate()
            
        
        let activityIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let activityCell = self.tableView.cellForRowAtIndexPath(activityIndexPath) as! PlanCreationActivityCell
        println("activityCell \(activityCell.messageLabel.text)")

        let locationIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        let locationCell = self.tableView.cellForRowAtIndexPath(locationIndexPath) as! PlanCreationLocationCell
        println("locationCell \(locationCell.locationLabel.text)")

        
        let visibilityIndexPath = NSIndexPath(forRow: 2, inSection: 0)
        let visibilityCell = self.tableView.cellForRowAtIndexPath(visibilityIndexPath) as! PlanCreationVisibilityCell
        
        
        let startDateIndexPath = NSIndexPath(forRow: 3, inSection: 0)
        let startDateCell = self.tableView.cellForRowAtIndexPath(startDateIndexPath) as UITableViewCell?
        let startDateString = startDateCell?.detailTextLabel?.text as String!
        
        println("startDateString \(startDateString)")
        
        let planStartDate = self.dateFormatter.dateFromString(startDateString) as NSDate!
        
        
        let endDateIndexPath = NSIndexPath(forRow: 4, inSection: 0)
        let endDateCell = self.tableView.cellForRowAtIndexPath(endDateIndexPath) as UITableViewCell?
        let endDateString = endDateCell?.detailTextLabel?.text as String!
        
        let planEndDate = self.dateFormatter.dateFromString(endDateString) as NSDate!
        
        let lengthBound = planStartDate.dateByAddingHours(24)
        
        println("planEndDate \(planEndDate)")
        println("lengthBound \(lengthBound)")

        println("endDateString \(endDateString)")
        
        if locationCell.locationLabel.text == "Where are you going?" {
            
            self.performSegueWithIdentifier("ShowProfileFromCreation", sender: nil)
            let alert = UIAlertController(title: "Sorry!", message: "You can't make a plan without a location!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else if planEndDate.isEarlierThan(planStartDate) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans that end before they start!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
           
        }
//        else if planStartDate.isLaterThan(futureBoundTime) {
//            let alert = UIAlertController(title: "Sorry!", message: "We love your enthusiasm, but you can't make an event more than a week in advance.", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//            
//        }
        else if planEndDate.isLaterThan(lengthBound) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make an event that lasts longer than 24 hours.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else {
            activityIndicator.startAnimating()
            self.updateButton.enabled = false

            
            var visibilityStatus = 0
            
            if visibilityCell.visibilityControl.selectedSegmentIndex == 1 {
                visibilityStatus = 1
            }
            
            let objectId = plans.first?.objectId as String!
            println(objectId)
            let planObject = PFObject(withoutDataWithClassName: "Plan", objectId: objectId)
            planObject.setObject(planStartDate, forKey: "startTime")
            planObject.setObject(planEndDate, forKey: "endTime")
            planObject.setObject(PFUser.currentUser()!, forKey: "creatingUser")
            planObject.setObject(selectedPlaceId, forKey: "googlePlaceId")
            planObject.setObject(selectedPlaceName, forKey: "googlePlaceName")
            planObject.setObject(selectedPlaceFormattedAddress, forKey: "googlePlaceFormattedAddress")
            planObject.setObject(activityCell.messageLabel.text, forKey: "message")
            planObject.setObject(selectedPlaceGeoPoint, forKey: "googlePlaceCoordinate")
            planObject.setObject(visibilityStatus, forKey: "visibility")


        
            
            planObject.saveInBackgroundWithBlock {
                (success, error) -> Void in
                if success == true {
                    println("Success")
                    self.activityIndicator.stopAnimating()
                    let alert = UIAlertController(title: "Success", message: "Your plans have been updated!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {
                        Void in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        
                        }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.updateButton.enabled = true
                    NSNotificationCenter.defaultCenter().postNotificationName(planMadeNotificationKey, object: self)
                
    //                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.updateButton.enabled = true
                    println("Update fail")
                    let alert = UIAlertController(title: "Sorry!", message: "We had trouble updating your plan.  Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            }
            
        }


    }
    
    @IBAction func didTapDeleteButton(sender: AnyObject) {
        
        let plan = plans.first
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this plan?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler:
            {
                Void in
                plan?.deleteInBackground()
                self.performSegueWithIdentifier("ShowProfileFromCreation", sender: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(planMadeNotificationKey, object: self)
//                self.dismissViewControllerAnimated(true, completion: nil)

            }
        )
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func dismissKeyboard(){
        println("dismissKeyboard called")
        tableView.endEditing(true)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveFacebookData()

        
        tableView.delegate = self
        tableView.dataSource = self

        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)

        // setup our data source
        let itemOne = [kTitleKey : ""]
        let itemTwo = [kTitleKey : ""]
        let itemThree = [kTitleKey : ""]
        let itemFour = [kTitleKey : "Start Date", kDateKey : NSDate()]
        let itemFive = [kTitleKey : "End Date", kDateKey : NSDate()]
        dataArray = [itemOne, itemTwo, itemThree, itemFour, itemFive]
        
        dateFormatter.dateStyle = .ShortStyle // show short-style date format
        dateFormatter.timeStyle = .ShortStyle
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeChanged:", name: NSCurrentLocaleDidChangeNotification, object: nil)
        
        
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
            println(currentLocation)
        }
        
        
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
        
        if (PFUser.currentUser() != nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                println("has access token")
                let pictureRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/picture?width=100&height=100&redirect=false", parameters: nil)
                pictureRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        println("OOPS")
                    }
                    else {
                        println(result["data"]!["url"])
                        let pictureString = result["data"]!["url"] as! String
                        let pictureURL = NSURL(string: pictureString)
                        let pictureData = NSData(contentsOfURL: pictureURL!)
                        println("pictureData \(pictureData)")
                        var pictureFile = PFFile(data: pictureData!)
                        PFUser.currentUser()?.setObject(pictureFile, forKey: "profileImage")
                        PFUser.currentUser()?.saveInBackground()
                    }
                })
            }
            
        }
        
        if (PFUser.currentUser() != nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil ) {
                var friendsArray = [String]()
                PFUser.currentUser()?.setObject(friendsArray, forKey: "friendsUsingTipsy")
                PFUser.currentUser()?.saveInBackground()
                let userFriendsRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
                userFriendsRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        println("Oops, friend fetch failed")
                    }
                    else {
                        println(result["data"]![0]["id"])
                        let resultArray = result.objectForKey("data") as! NSArray
                        println(resultArray)
                        for i in resultArray {
                            var id = i.objectForKey("id") as! String
                            friendsArray.append(id)
                        }
                        PFUser.currentUser()?.setObject(friendsArray, forKey: "friendsUsingTipsy")
                        PFUser.currentUser()?.saveInBackground()
                    }
                })
            }
        }
        
        if (PFUser.currentUser() != nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                let userIDRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                userIDRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        println("Oops, id fetch failed")
                    }
                    else {
                        println("idrequest")
                        println(result["id"])
                        
                        PFUser.currentUser()?.setObject(result["id"], forKey: "facebookID")
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

            if (locationManager.location != nil) {
                self.currentLocation = locationManager.location
            }
            println(currentLocation)
        }
    }


    //PROPERLY HIDE BUTTONS
    
    override func viewWillAppear(animated: Bool) {

        
        tableView.delegate = self
        tableView.dataSource = self
        

        println("dese plans \(plans)")
        
        if plans.count != 0 {
            println("hay plans")
            let plan = plans.first
            let planStartTime = plan?.objectForKey("startTime") as! NSDate
            let planEndTime = plan?.objectForKey("endTime") as! NSDate
       
            
            
            postButton.hidden = true
            updateButton.hidden = false
            deleteButton.hidden = false
        }
        else {
            updateButton.hidden = true
            deleteButton.hidden = true
            postButton.hidden = false
            if selectedPlaceName != "" {
                let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PlanCreationLocationCell
                println(cell.locationLabel)
                
                cell.locationLabel.text = selectedPlaceName
                
            }

        }
        
        println("selectedPlace \(selectedPlaceName)")
        

        
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            println("your current location is \(currentLocation)")
            locationManager.stopUpdatingLocation()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        var cellID = kOtherCellID
        
        if indexPathHasPicker(indexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kDatePickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath) {
            // the indexPath is one that contains the date information
            cellID = kDateCellID       // the start/end date cells
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? UITableViewCell
        
//        if indexPath.row == 0 {
//            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDividerCell") as! PlanCreationDividerCell
//        }
        if indexPath.row == 0 {
            var tempcell = tableView.dequeueReusableCellWithIdentifier("PlanCreationActivityCell") as! PlanCreationActivityCell
            if plans.count != 0 {
                tempcell.messageLabel.text = plans.first?.objectForKey("message") as? String
            }
            
            
            cell = tempcell
        }
        if indexPath.row == 1 {
           var tempcell = tableView.dequeueReusableCellWithIdentifier("PlanCreationLocationCell") as! PlanCreationLocationCell
            if plans.count != 0 {
                tempcell.locationLabel.text = plans.first?.objectForKey("googlePlaceName") as? String
            }
            cell = tempcell
        }
        
        if indexPath.row == 2 {
            var tempcell = tableView.dequeueReusableCellWithIdentifier("VisibilityCell") as! PlanCreationVisibilityCell
            if plans.count != 0 {
                let visibilityStatus = plans.first?.objectForKey("visibility") as? Int
                
                if let visibilityStatus = visibilityStatus {
                    tempcell.visibilityControl.selectedSegmentIndex = visibilityStatus
                }
            }
            cell = tempcell
        }
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && datePickerIndexPath?.row <= indexPath.row) {
            modelRow--
        }
        
        let itemData = dataArray[modelRow]
        
        if cellID == kDateCellID {
            // we have either start or end date cells, populate their date field
            //
            
            if plans.count != 0 {
                
                let plan = plans.first
            
                let planStartTime = plan?.objectForKey("startTime") as! NSDate
                let planEndTime = plan?.objectForKey("endTime") as! NSDate

                
                if indexPath.row == 3 {
                    cell?.detailTextLabel?.text = self.dateFormatter.stringFromDate(planStartTime) as String?
                }
                if indexPath.row == 4 {
                    cell?.detailTextLabel?.text = self.dateFormatter.stringFromDate(planEndTime) as String?
                }

            }
            else {
                cell?.textLabel?.text = itemData[kTitleKey] as? String
                cell?.detailTextLabel?.text = self.dateFormatter.stringFromDate(itemData[kDateKey] as! NSDate)
            }
        } else if cellID == kOtherCellID {
            // this cell is a non-date cell, just assign it's text label
            //
            cell?.textLabel?.text = itemData[kTitleKey] as? String
        }
        
//        cell?.indentationLevel = 0
//        cell?.indentationWidth = 0.0
        cell?.layoutMargins = UIEdgeInsetsZero
        cell?.preservesSuperviewLayoutMargins = false
        
        return cell!
    }
    

    
    func localeChanged(notif: NSNotification) {
        // the user changed the locale (region format) in Settings, so we are notified here to
        // update the date format in the table view cells
        //
        tableView.reloadData()
    }

    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
    
    @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
    */
    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: 0))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
    */
    func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = tableView.cellForRowAtIndexPath(indexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker? {
                let itemData = dataArray[self.datePickerIndexPath!.row - 1]
                targetedDatePicker.setDate(itemData[kDateKey] as! NSDate, animated: false)
            }
        }
    }
    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
    */
    func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
    
    @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
    */
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row
    }
    
    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
    
    @param indexPath The indexPath to check if it represents start/end date cell.
    */
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        var hasDate = false
        
        if (indexPath.row == kDateStartRow) || (indexPath.row == kDateEndRow || (hasInlineDatePicker() && (indexPath.row == kDateEndRow + 1))) {
            hasDate = true
        }
        return hasDate
    }
    
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasInlineDatePicker() {
            // we have a date picker, so allow for it in the number of rows in this section
            var numRows = dataArray.count
            return ++numRows;
        }
        
        return dataArray.count;
    }
    

    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
    
    @param indexPath The indexPath to reveal the UIDatePicker.
    */
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        
        tableView.beginUpdates()
        
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 0)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath) {
            // found a picker below it, so remove it
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
        tableView.endUpdates()
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
    
    @param indexPath The indexPath to reveal the UIDatePicker.
    */
    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath) {
        
        // display the date picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if hasInlineDatePicker() {
            before = datePickerIndexPath?.row < indexPath.row
        }
        
        var sameCellClicked = (datePickerIndexPath?.row == indexPath.row + 1)
        
        // remove any date picker cell if it exists
        if self.hasInlineDatePicker() {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: datePickerIndexPath!.row, inSection: 0)], withRowAnimation: .Fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 0)
            
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 0)
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        tableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    
    /*! Reveals the UIDatePicker as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".
    
    @param indexPath The indexPath used to display the UIDatePicker.
    */
    /*
    func displayExternalDatePickerForRowAtIndexPath(indexPath: NSIndexPath) {
    
    // first update the date picker's date value according to our model
    let itemData: AnyObject = self.dataArray[indexPath.row]
    self.pickerView.setDate(itemData.valueForKey(kDateKey) as NSDate, animated: true)
    
    // the date picker might already be showing, so don't add it to our view
    if self.pickerView.superview == nil {
    var startFrame = self.pickerView.frame
    var endFrame = self.pickerView.frame
    
    // the start position is below the bottom of the visible frame
    startFrame.origin.y = CGRectGetHeight(self.view.frame)
    
    // the end position is slid up by the height of the view
    endFrame.origin.y = startFrame.origin.y - CGRectGetHeight(endFrame)
    
    self.pickerView.frame = startFrame
    
    self.view.addSubview(self.pickerView)
    
    // animate the date picker into view
    UIView.animateWithDuration(kPickerAnimationDuration, animations: { self.pickerView.frame = endFrame }, completion: {(value: Bool) in
    // add the "Done" button to the nav bar
    //self.navigationItem.rightBarButtonItem = self.doneButton
    })
    }
    }
    */
    
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == kDateCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    // MARK: - Actions
    
    /*! User chose to change the date by changing the values inside the UIDatePicker.
    
    @param sender The sender for this action: UIDatePicker.
    */
    
    
    @IBAction func dateAction(sender: UIDatePicker) {
        
        var targetedCellIndexPath: NSIndexPath?
        
        if self.hasInlineDatePicker() {
            // inline date picker: update the cell's date "above" the date picker cell
            //
            targetedCellIndexPath = NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: 0)
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = tableView.indexPathForSelectedRow()!
        }
        
        var cell = tableView.cellForRowAtIndexPath(targetedCellIndexPath!)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[targetedCellIndexPath!.row]
        itemData[kDateKey] = targetedDatePicker.date
        dataArray[targetedCellIndexPath!.row] = itemData
        
        // update the cell's date string
        cell?.detailTextLabel?.text = dateFormatter.stringFromDate(targetedDatePicker.date)
        
        
    }
    
}
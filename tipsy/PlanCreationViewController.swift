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

let planMadeNotificationKey = "planMadeNotificationKey"

class PlanCreationViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()

    var selectedPlaceId = String()
    var selectedPlaceName = String()
    var selectedPlaceGeoPoint = PFGeoPoint()
    var selectedPlaceFormattedAddress = String()
    var plans = [PFObject]()

    
    @IBOutlet weak var tableView: UITableView!
    
//    @IBOutlet weak var messageField: UITextField!
//
//    @IBOutlet weak var startTime: UIDatePicker!
//    
//    @IBOutlet weak var endTime: UIDatePicker!

    // DATE PICKER CONSTANTS
    
    let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker into view
    let kDatePickerTag           = 99   // view tag identifiying the date picker view
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    let kDateStartRow = 4
    let kDateEndRow   = 5
    
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
        let futureBoundTime = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: 72, toDate: currentTime, options: NSCalendarOptions.WrapComponents)
//        if searchBar.text == "" {
//            let alert = UIAlertController(title: "Sorry!", message: "You can't make a plan without a location!", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
//        else {
//            
        
            let planObject = PFObject(className: "Plan")
            //planObject.setObject(startTime.date, forKey: "startTime")
            //planObject.setObject(endTime.date, forKey: "endTime")
            planObject.setObject(PFUser.currentUser()!, forKey: "creatingUser")
            planObject.setObject(selectedPlaceId, forKey: "googlePlaceId")
            planObject.setObject(selectedPlaceName, forKey: "googlePlaceName")
            planObject.setObject(selectedPlaceFormattedAddress, forKey: "googlePlaceFormattedAddress")
          //  planObject.setObject(activityLabel.text, forKey: "message")
            planObject.setObject(selectedPlaceGeoPoint, forKey: "googlePlaceCoordinate")
            
            let ACL = PFACL()
            ACL.setPublicReadAccess(true)
            ACL.setPublicWriteAccess(true)
            planObject.ACL = ACL
            
            planObject.saveInBackgroundWithBlock {
                (success, error) -> Void in
                if success == true {
                    println("Success \(planObject.objectId)")
                    
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation.addUniqueObject(planObject.objectId!, forKey: "channels")
                    currentInstallation.saveInBackground()
                    println("registered installation for pushes")

                    let alert = UIAlertController(title: "Success", message: "Your plans have been shared!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
            //        self.activityLabel.text = ""
           //         self.startTime.date = NSDate()
          //          self.endTime.date = NSDate().dateByAddingHours(1)
                    NSNotificationCenter.defaultCenter().postNotificationName(planMadeNotificationKey, object: self)
                }
                else {
                    let alert = UIAlertController(title: "Sorry!", message: "We had trouble posting your plan.  Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        

//        }
    }
    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        self.view.endEditing(true)
//    }
    
    
    @IBAction func didTapUpdateButton(sender: AnyObject) {
        let currentTime = NSDate()
        let futureBoundTime = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: 72, toDate: currentTime, options: NSCalendarOptions.WrapComponents)

            
        
        let objectId = plans.first?.objectId as String!
        println(objectId)
        let planObject = PFObject(withoutDataWithClassName: "Plan", objectId: objectId)
    //    planObject.setObject(startTime.date, forKey: "startTime")
      //  planObject.setObject(endTime.date, forKey: "endTime")
        planObject.setObject(PFUser.currentUser()!, forKey: "creatingUser")
        planObject.setObject(selectedPlaceId, forKey: "googlePlaceId")
        planObject.setObject(selectedPlaceName, forKey: "googlePlaceName")
        planObject.setObject(selectedPlaceFormattedAddress, forKey: "googlePlaceFormattedAddress")
       // planObject.setObject(activityLabel.text, forKey: "message")
        planObject.setObject(selectedPlaceGeoPoint, forKey: "googlePlaceCoordinate")


        
        
        planObject.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if success == true {
                println("Success")
                let alert = UIAlertController(title: "Success", message: "Your plans have been updated!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {
                    Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    
                    }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(planMadeNotificationKey, object: self)
            
//                    self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                println("Update fail")
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
                NSNotificationCenter.defaultCenter().postNotificationName(planMadeNotificationKey, object: self)
                self.dismissViewControllerAnimated(true, completion: nil)

            }
        )
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func timeValidation() -> Bool {
        let currentTime = NSDate()
        let futureBoundTime = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: 48, toDate: currentTime, options: NSCalendarOptions.WrapComponents)
//        if startTime.date.isEarlierThan(currentTime) {
//            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans in the past!", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//            return false
//        }
//        if endTime.date.isEarlierThan(startTime.date) {
//            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans that end before they start!", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//            return false
//        }
////        if futureBoundTime!.isEarlierThan(startTime.date) {
//            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans more than 48 hours in the future!", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.endTime.date = NSDate().dateByAddingHours(1)
        tableView.delegate = self
        tableView.dataSource = self
        
        // setup our data source
        let itemOne = [kTitleKey : ""]
        let itemTwo = [kTitleKey : ""]
        let itemThree = [kTitleKey : ""]
        let itemFour = [kTitleKey : ""]
        let itemFive = [kTitleKey : "Start Date", kDateKey : NSDate()]
        let itemSix = [kTitleKey : "End Date", kDateKey : NSDate()]
        let itemSeven = [kTitleKey: ""]
        dataArray = [itemOne, itemTwo, itemThree, itemFour, itemFive, itemSix, itemSeven]
        
        dateFormatter.dateStyle = .ShortStyle // show short-style date format
        dateFormatter.timeStyle = .ShortStyle
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeChanged:", name: NSCurrentLocaleDidChangeNotification, object: nil)
        
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.currentLocation = locationManager.location
            println(currentLocation)
        }
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.currentLocation = locationManager.location
            println(currentLocation)
        }
    }


    //PROPERLY HIDE BUTTONS
    
    override func viewWillAppear(animated: Bool) {

        
        tableView.separatorColor = UIColor.grayColor()

        println("dese plans \(plans)")
        
        if plans.count != 0 {
            println("hay plans")
            let plan = plans.first
            let planStartTime = plan?.objectForKey("startTime") as! NSDate
            let planEndTime = plan?.objectForKey("endTime") as! NSDate
            selectedPlaceId = plan?.objectForKey("googlePlaceId") as! String
            selectedPlaceName = plan?.objectForKey("googlePlaceName") as! String
            selectedPlaceFormattedAddress = plan?.objectForKey("googlePlaceFormattedAddress") as! String
        //    messageField.text = plan?.objectForKey("message") as? String
      //      startTime.date = planStartTime
       //     endTime.date = planEndTime
      //      searchBar.text = selectedPlaceName
            postButton.hidden = true
            updateButton.hidden = false
            deleteButton.hidden = false
        }
        else {
            updateButton.hidden = true
            deleteButton.hidden = true
            postButton.hidden = false
        }
    }
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return false
//    }
    
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
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDividerCell") as! PlanCreationDividerCell
        }
        if indexPath.row == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationActivityCell") as! PlanCreationActivityCell
        }
        if indexPath.row == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationLocationCell") as! PlanCreationLocationCell
        }
        else if indexPath.row == 3 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDividerCell") as! PlanCreationDividerCell
        }
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && datePickerIndexPath?.row <= indexPath.row) {
            modelRow--
        }
        
        let itemData = dataArray[modelRow]
        
        if indexPath.row == 4 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDateCell") as! PlanCreationTableDateCell
            
        }
        
        if cellID == kDateCellID {
            // we have either start or end date cells, populate their date field
            //
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = self.dateFormatter.stringFromDate(itemData[kDateKey] as! NSDate)
        } else if cellID == kOtherCellID {
            // this cell is a non-date cell, just assign it's text label
            //
            cell?.textLabel?.text = itemData[kTitleKey] as? String
        }
        
        return cell!
    }
    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        var cell: UITableViewCell?
//        
//        var cellID = String()
//        
//        if indexPathHasPicker(indexPath) {
//            // the indexPath is the one containing the inline date picker
//            cellID = kDatePickerCellID     // the current/opened date picker cell
//        } else if indexPathHasDate(indexPath) {
//            // the indexPath is one that contains the date information
//            cellID = kDateCellID       // the start/end date cells
//        }
//        
//        
//        if indexPath.row == 0 {
//            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDividerCell") as! PlanCreationDividerCell
//
//        }
//        if indexPath.row == 1 {
//            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationActivityCell") as! PlanCreationActivityCell
//        }
//        if indexPath.row == 2 {
//            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationLocationCell") as! PlanCreationLocationCell
//        }
//        if indexPath.row == 3 {
//            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDividerCell") as! PlanCreationDividerCell
//            
//        }
//        if indexPath.row == 4 {
//            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDateCell") as! PlanCreationTableDateCell
//            
//        }
//        if indexPath.row == 5 {
//            cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? UITableViewCell
//            
//        }
//        
//        if indexPath.row == 6 {
//            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDateCell") as! PlanCreationTableDateCell
//            
//        }
//        if indexPath.row == 7 {
//            cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? UITableViewCell
//            
//        }
//
//        if indexPath.row == 8 {
//            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDividerCell") as! PlanCreationDividerCell
//            
//        }
//        
//        println("yocell \(cell)")
//        
//        return cell!
//    }
    
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
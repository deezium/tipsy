//
//  PlanCreationViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/20/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
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
    @IBOutlet weak var planCreationTable: UITableView!
    
    @IBOutlet weak var messageField: UITextField!

    @IBOutlet weak var startTime: UIDatePicker!
    
    @IBOutlet weak var endTime: UIDatePicker!
    
    
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
            planObject.setObject(startTime.date, forKey: "startTime")
            planObject.setObject(endTime.date, forKey: "endTime")
            planObject.setObject(PFUser.currentUser()!, forKey: "creatingUser")
            planObject.setObject(selectedPlaceId, forKey: "googlePlaceId")
            planObject.setObject(selectedPlaceName, forKey: "googlePlaceName")
            planObject.setObject(selectedPlaceFormattedAddress, forKey: "googlePlaceFormattedAddress")
            planObject.setObject(messageField.text, forKey: "message")
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
                    self.messageField.text = ""
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
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func didTapUpdateButton(sender: AnyObject) {
        let currentTime = NSDate()
        let futureBoundTime = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: 72, toDate: currentTime, options: NSCalendarOptions.WrapComponents)

            
        
        let objectId = plans.first?.objectId as String!
        println(objectId)
        let planObject = PFObject(withoutDataWithClassName: "Plan", objectId: objectId)
        planObject.setObject(startTime.date, forKey: "startTime")
        planObject.setObject(endTime.date, forKey: "endTime")
        planObject.setObject(PFUser.currentUser()!, forKey: "creatingUser")
        planObject.setObject(selectedPlaceId, forKey: "googlePlaceId")
        planObject.setObject(selectedPlaceName, forKey: "googlePlaceName")
        planObject.setObject(selectedPlaceFormattedAddress, forKey: "googlePlaceFormattedAddress")
        planObject.setObject(messageField.text, forKey: "message")
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
        if startTime.date.isEarlierThan(currentTime) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans in the past!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        if endTime.date.isEarlierThan(startTime.date) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans that end before they start!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
//        if futureBoundTime!.isEarlierThan(startTime.date) {
//            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans more than 48 hours in the future!", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.endTime.date = NSDate().dateByAddingHours(1)
        planCreationTable.delegate = self
        planCreationTable.dataSource = self
        
        
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.currentLocation = locationManager.location
            println(currentLocation)
        }

        
//        if (CLLocationManager.locationServicesEnabled()) {
//            self.locationManager.delegate = self
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            self.locationManager.startUpdatingLocation()
//            self.currentLocation = locationManager.location
//            println(currentLocation)
//        }
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

        
        planCreationTable.separatorColor = UIColor.grayColor()

        println("dese plans \(plans)")
        
        if plans.count != 0 {
            println("hay plans")
            let plan = plans.first
            let planStartTime = plan?.objectForKey("startTime") as! NSDate
            let planEndTime = plan?.objectForKey("endTime") as! NSDate
            selectedPlaceId = plan?.objectForKey("googlePlaceId") as! String
            selectedPlaceName = plan?.objectForKey("googlePlaceName") as! String
            selectedPlaceFormattedAddress = plan?.objectForKey("googlePlaceFormattedAddress") as! String
            messageField.text = plan?.objectForKey("message") as? String
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
        
        var cell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDividerCell") as! PlanCreationDividerCell

        }
        if indexPath.row == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationActivityCell") as! PlanCreationActivityCell
        }
        if indexPath.row == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationLocationCell") as! PlanCreationLocationCell
        }
        if indexPath.row == 3 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDividerCell") as! PlanCreationDividerCell
            
        }
        if indexPath.row == 4 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationTimeCell") as! PlanCreationTimeCell
            cell.textLabel?.text = "Start Time"
            
        }
        if indexPath.row == 5 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationTimeCell") as! PlanCreationTimeCell
            cell.textLabel?.text = "End Time"
            
        }
        if indexPath.row == 6 {
            cell = tableView.dequeueReusableCellWithIdentifier("PlanCreationDividerCell") as! PlanCreationDividerCell
            
        }
        
        println("yocell \(cell)")
        
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    
    
}
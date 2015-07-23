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

class PlanCreationViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    var placesClient: GMSPlacesClient = GMSPlacesClient()
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var searchResultData = [GMSAutocompletePrediction]()
    var selectedPlaceId = String()
    var selectedPlaceName = String()
    var selectedPlaceFormattedAddress = String()
    var plans = [PFObject]()
    
    @IBOutlet weak var messageField: UITextField!

    @IBOutlet weak var startTime: UIDatePicker!
    
    @IBOutlet weak var endTime: UIDatePicker!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResults: UITableView!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func didTapPostButton(sender: AnyObject) {
        
        let currentTime = NSDate()
        let futureBoundTime = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: 72, toDate: currentTime, options: NSCalendarOptions.WrapComponents)
        if searchBar.text == "" {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make a plan without a location!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if startTime.date.isEarlierThan(currentTime) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans in the past!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if endTime.date.isEarlierThan(startTime.date) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans that end before they start!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        //       else if futureBoundTime!.isEarlierThan(startTime.date) {
        //            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans more than 72 hours in the future!", preferredStyle: UIAlertControllerStyle.Alert)
        //            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        //            self.presentViewController(alert, animated: true, completion: nil)
        //        }
        
        else {
            
            
            let planObject = PFObject(className: "Plan")
            planObject.setObject(startTime.date, forKey: "startTime")
            planObject.setObject(endTime.date, forKey: "endTime")
            planObject.setObject(PFUser.currentUser()!, forKey: "creatingUser")
            planObject.setObject(selectedPlaceId, forKey: "googlePlaceId")
            planObject.setObject(selectedPlaceName, forKey: "googlePlaceName")
            planObject.setObject(selectedPlaceFormattedAddress, forKey: "googlePlaceFormattedAddress")
            planObject.setObject(messageField.text, forKey: "message")
            
            let ACL = PFACL()
            ACL.setPublicReadAccess(true)
            ACL.setPublicWriteAccess(true)
            planObject.ACL = ACL
            
            planObject.saveInBackgroundWithBlock {
                (success, error) -> Void in
                if success == true {
                    println("Success")
                    let alert = UIAlertController(title: "Success", message: "Your plans have been shared!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.searchBar.text = ""
                    self.messageField.text = ""
                    self.startTime.date = NSDate()
                    self.endTime.date = NSDate()
                    NSNotificationCenter.defaultCenter().postNotificationName(planMadeNotificationKey, object: self)
                }
                else {
                    let alert = UIAlertController(title: "Sorry!", message: "We had trouble posting your plan.  Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }

            

        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    @IBAction func didTapCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func didTapUpdateButton(sender: AnyObject) {
        let currentTime = NSDate()
        let futureBoundTime = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: 72, toDate: currentTime, options: NSCalendarOptions.WrapComponents)
        if startTime.date.isEarlierThan(currentTime) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans in the past!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if endTime.date.isEarlierThan(startTime.date) {
            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans that end before they start!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
            //       else if futureBoundTime!.isEarlierThan(startTime.date) {
            //            let alert = UIAlertController(title: "Sorry!", message: "You can't make plans more than 72 hours in the future!", preferredStyle: UIAlertControllerStyle.Alert)
            //            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            //            self.presentViewController(alert, animated: true, completion: nil)
            //        }
            
        else {
            
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
            
            
            planObject.saveInBackgroundWithBlock {
                (success, error) -> Void in
                if success == true {
                    println("Success")
                    let alert = UIAlertController(title: "Success", message: "Your plans have been updated!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {
                        Void in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        
                        }
))
                    self.presentViewController(alert, animated: true, completion: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(planMadeNotificationKey, object: self)
                
//                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    println("Update fail")
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
        locationManager.requestWhenInUseAuthorization()
        searchBar.delegate = self
        self.searchResults.hidden = true
        self.searchResults.delegate = self
        self.searchResults.dataSource = self
        
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            self.currentLocation = locationManager.location
            println(currentLocation)
        }
    }

    //PROPERLY HIDE BUTTONS
    
    override func viewWillAppear(animated: Bool) {
        
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
            startTime.date = planStartTime
            endTime.date = planEndTime
            searchBar.text = selectedPlaceName
            postButton.hidden = true
            updateButton.hidden = false
            deleteButton.hidden = false
            cancelButton.hidden = false
        }
        else {
            updateButton.hidden = true
            deleteButton.hidden = true
            postButton.hidden = false
            cancelButton.hidden = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            println("your current location is \(currentLocation)")
            locationManager.stopUpdatingLocation()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = self.searchResultData[indexPath.row]
        let placeText = place.attributedFullText.string
        println("row selected")
        self.searchBar.text = placeText
        self.selectedPlaceId = place.placeID
        self.searchResults.hidden = true
        
        let placeId = "ChIJv2V798IJlR4Rq66ydZpHmt0"
        
        placesClient.lookUpPlaceID(selectedPlaceId, callback: {(place, error) -> Void in
            if error != nil {
                println("lookup place id query error")
                return
            }
            
            if place != nil {
                self.selectedPlaceName = place!.name
                self.selectedPlaceFormattedAddress = place!.formattedAddress
            }
            
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaceAutocompleteCell") as! UITableViewCell
        let place = self.searchResultData[indexPath.row]
        
        cell.textLabel!.text = place.attributedFullText.string
        //cell.backgroundColor = UIColor.redColor()
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            //self.places = []
            println("aint nothin here")
            searchResults.hidden = true
            self.searchResultData = [GMSAutocompletePrediction]()
            self.searchResults.reloadData()
        }
        else {
            searchResults.hidden = false
            println("searching for \(searchText)")
            let locValue = currentLocation.coordinate
            println("location at \(locValue.latitude), \(locValue.longitude)")
            let northEast = CLLocationCoordinate2DMake(locValue.latitude + 1, locValue.longitude + 1)
            let southWest = CLLocationCoordinate2DMake(locValue.latitude - 1, locValue.longitude - 1)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let filter = GMSAutocompleteFilter()
            filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
            
            placesClient.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: {
                (results, error) -> Void in
                if error != nil {
                    println("Hay error \(error)")
                    return
                }
                else {
                    self.searchResultData = [GMSAutocompletePrediction]()
                    for result in results as! [GMSAutocompletePrediction] {
                        self.searchResultData.append(result)
                        println(result)
                    }
                    self.searchResults.reloadData()
                }
            })
        }
    }
}
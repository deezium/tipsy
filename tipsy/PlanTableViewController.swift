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
    let locationManager = CLLocationManager()

    
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
        self.planTableView.reloadData()
    }
    
    @IBAction func didTapRemoveFilters(sender: AnyObject) {
        filtered = false
        self.planTableView.reloadData()
    }
    
    @IBAction func didTapFilter(sender: AnyObject) {
        filtered = true
        filteredObjects = [PFObject]()
        self.filterQueryResults(queryObjects)
        self.planTableView.reloadData()
    }

    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.createPlanArrays(objects)
            self.planTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func filterQueryResults(objects: [PFObject]) {
        for object in objects {
            let startTime = object.objectForKey("startTime") as? NSDate
            let endTime = object.objectForKey("endTime") as? NSDate
            let filterTime = timeFilter.date
            
            if (startTime!.isEarlierThanOrEqualTo(filterTime)) {
                if (endTime!.isLaterThanOrEqualTo(filterTime)) {
                    filteredObjects.append(object)
                }
            }
        }
    }
    
    func createPlanArrays(objects: [PFObject]) {
        
        upcomingPlans = [PFObject]()
        pastPlansOriginal = [PFObject]()
        
        for object in objects {
            
            let endTime = object.objectForKey("endTime") as? NSDate
            let currentTime = NSDate()
            
            if currentTime.isEarlierThan(endTime) {
                upcomingPlans.append(object)
            }
            else {
                pastPlansOriginal.append(object)
            }
        }
        pastPlans = pastPlansOriginal.reverse()
        println("upcomingPlans \(upcomingPlans)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveFacebookData()
        query.delegate = self
        query.queryPlans("")
        
        self.planTableView!.delegate = self
        self.planTableView!.dataSource = self
        
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
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        var objects = queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 10)
        //        println(objects.count)
        //        return objects.count
        
        println(queryObjects.count)
        if segmentedControl.selectedSegmentIndex == 0 {
            return upcomingPlans.count
        }
        else {
            return pastPlans.count
        }

        
        
//        if filtered == false {
//            return queryObjects.count
//        }
//        else {
//            return filteredObjects.count
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowPlanDetailView" {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var queryObject: PFObject
        
        if segmentedControl.selectedSegmentIndex == 0 {
            queryObject = upcomingPlans[indexPath.row]
        //    cell.editButton.hidden = false
        }
        else {
            queryObject = pastPlans[indexPath.row]
          //  cell.editButton.hidden = true
        }
        
        
//        if filtered == false {
//            queryObject = queryObjects[indexPath.row]
//        }
//        else {
//            queryObject = filteredObjects[indexPath.row]
//        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PlanTableCell") as! PlanFeedCell
        
        let user = queryObject.objectForKey("creatingUser") as! PFUser
        let fullname = user.objectForKey("fullname") as? String
        let message = queryObject.objectForKey("message") as? String
        let startTime = queryObject.objectForKey("startTime") as? NSDate
        let endTime = queryObject.objectForKey("endTime") as? NSDate
        let placeName = queryObject.objectForKey("googlePlaceName") as? String
        let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
        let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
        var placeLabel: String?
        var addressLabel: String?
        
        if let placeName = placeName {
            placeLabel = placeName
        }

        if let shortAddress = shortAddress {
            addressLabel = shortAddress
        }

        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, hh:mm a"
        
        let startTimeString = dateFormatter.stringFromDate(startTime!)
        let endTimeString = dateFormatter.stringFromDate(endTime!)
        
        println(startTime)
        println(endTime)
        
        
        if let postImage = user.objectForKey("profileImage") as? PFFile {
            let imageData = postImage.getData()
            let image = UIImage(data: imageData!)
            cell.profileImage.image = image
            
        }

        let firstname = fullname?.componentsSeparatedByString(" ")[0]
        
        cell.name.text = firstname
        cell.startTime.text = startTimeString
        cell.endTime.text = endTimeString
        cell.location.text = placeLabel
        cell.addressLabel.text = shortAddress
        
        if let message = message {
            cell.message.text = message
        }
        
        return cell
    }


}
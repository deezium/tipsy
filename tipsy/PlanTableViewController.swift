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
            self.createTableSections()
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
        
        df.dateFormat = "EEEE"
        
        let dayOfWeekString = df.stringFromDate(date)
        
        headerCell.headerLabel.text =  dayOfWeekString + ", " + dateString
        
    
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
        
        let user = queryObject.objectForKey("creatingUser") as! PFUser
        let fullname = user.objectForKey("fullname") as? String
        let message = queryObject.objectForKey("message") as? String
        let startTime = queryObject.objectForKey("startTime") as? NSDate
        let endTime = queryObject.objectForKey("endTime") as? NSDate
        let placeName = queryObject.objectForKey("googlePlaceName") as? String
        let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
        let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
        var placeLabel: String?
        
        
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
        
        return cell
    }


}
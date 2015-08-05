//
//  PlanDetailViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/23/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

let commentMadeNotificationKey = "commentMadeNotificationKey"

class PlanDetailViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol {
    

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var commentEntry: UITextField!
    
    @IBOutlet weak var commentTable: UITableView!
    
    var planObjects = [PFObject]()
    
    var query = QueryController()
    var queryObjects = [PFObject]()

    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.commentTable!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentTable.delegate = self
        self.commentTable.dataSource = self
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        
        
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
//            mapView.myLocationEnabled = true
//            mapView.settings.myLocationButton = true
        }
        
        
        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            if let location = locations.first as? CLLocation {
//                mapView.camera=GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                self.locationManager.stopUpdatingLocation()
            }
        }
    

        let plan = planObjects.first
        let creatingUser = plan!.objectForKey("creatingUser") as! PFObject
        let fullname = creatingUser.objectForKey("fullname") as? String
        let firstname = fullname!.componentsSeparatedByString(" ")[0]
        
        let startTime = plan!.objectForKey("startTime") as? NSDate
        let endTime = plan!.objectForKey("endTime") as? NSDate
        let placeName = plan!.objectForKey("googlePlaceName") as? String

        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, hh:mm a"
        
        let startTimeString = dateFormatter.stringFromDate(startTime!)
        let endTimeString = dateFormatter.stringFromDate(endTime!)

        messageLabel.text = plan!.objectForKey("message") as! String
        nameLabel.text = firstname
        locationLabel.text = placeName
        timeLabel.text = "\(startTimeString) to \(endTimeString)"
        
        if let postImage = creatingUser.objectForKey("profileImage") as? PFFile {
            let imageData = postImage.getData()
            let image = UIImage(data: imageData!)
            self.profileImage.image = image
            
        }

        
        let planGeoPoint = plan!.objectForKey("googlePlaceCoordinate") as? PFGeoPoint
        
        if let planGeoPoint = planGeoPoint {
            let latitude = planGeoPoint.latitude
            let longitude = planGeoPoint.longitude
            
            let planCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
//            mapView.camera=GMSCameraPosition(target: planCoordinate, zoom: 15, bearing: 0, viewingAngle: 0)
 //           var marker = GMSMarker(position: planCoordinate)
  //          marker.map = self.mapView

        }
        
        query.delegate = self
        query.queryComments(plan!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshComments", name: commentMadeNotificationKey, object: nil)


        
    }
    
    func refreshComments() {
        let plan = planObjects.first
        query.queryComments(plan!)

    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(queryObjects.count)
        return queryObjects.count + 3
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var finalCell: UITableViewCell?
        
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PlanDetailAddressCell") as? PlanDetailAddressCell
            let placeAddress = planObjects.first?.objectForKey("googlePlaceFormattedAddress") as? String
            let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
            
            cell?.addressLabel.text = placeAddress

            
            finalCell = cell
        }
        
        else if indexPath.row == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PlanDetailInteractionCell") as? PlanDetailInteractionCell
            finalCell = cell

        }
        
        else if indexPath.row == 2 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PlanDetailAttendingCell") as? UITableViewCell
            finalCell = cell
            
        }
        
//        else if indexPath.row == 3 {
//            var cell = tableView.dequeueReusableCellWithIdentifier("PlanDetailHeaderCell") as? UITableViewCell
//            finalCell = cell
//            
//        }
        
        else {
            var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
            let commentObject = queryObjects[indexPath.row-3]
            
            let user = commentObject.objectForKey("commentingUser") as! PFUser
            let fullname = user.objectForKey("fullname") as? String
            let firstname = fullname?.componentsSeparatedByString(" ")[0]
            let timeAgo = commentObject.createdAt!.shortTimeAgoSinceNow()
            let commentBody = commentObject.objectForKey("body") as? String
            
            if let postImage = user.objectForKey("profileImage") as? PFFile {
                let imageData = postImage.getData()
                let image = UIImage(data: imageData!)
                cell.profileImage.image = image
                
            }
            
            cell.nameLabel.text = firstname
            cell.messageLabel.text = commentBody
            cell.timeLabel.text = timeAgo
            
            finalCell = cell
            
        }
        

        
        return finalCell!

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    
    @IBAction func didTapCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowEditFromPlan" {
            var selectedPlans = [PFObject]()
            
            let editProfileViewController = segue.destinationViewController as! EditProfileViewController
            
//            let index = self.planTableView.indexPathForSelectedRow()!
//            var queryObject: PFObject
//            if segmentedControl.selectedSegmentIndex == 0 {
//                queryObject = upcomingPlans[index.row]
//            }
//            else {
//                queryObject = pastPlans[index.row]
//            }
//            selectedPlans.append(queryObject)
//            println("selected plan \(selectedPlans)")
//            planDetailViewController.planObjects = selectedPlans
        }
        
    }

    
    @IBAction func didTapPostButton(sender: AnyObject) {
        
        let commentObject = PFObject(className: "Comment")
        commentObject.setObject(commentEntry.text, forKey: "body")
        commentObject.setObject(PFUser.currentUser()!, forKey: "commentingUser")
        commentObject.setObject(planObjects.first!, forKey: "commentedPlan")
        
        
        let ACL = PFACL()
        ACL.setPublicReadAccess(true)
        ACL.setPublicWriteAccess(true)
        commentObject.ACL = ACL
        
        commentObject.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if success == true {
                println("Success")
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject(self.planObjects.first!.objectId!, forKey: "channels")
                currentInstallation.saveInBackground()
                println("registered installation for pushes")

                let alert = UIAlertController(title: "Success", message: "Comment posted!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.commentEntry.text = ""
                NSNotificationCenter.defaultCenter().postNotificationName(commentMadeNotificationKey, object: self)
            }
            else {
                let alert = UIAlertController(title: "Sorry!", message: "We had trouble posting your comment.  Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }

    }
}
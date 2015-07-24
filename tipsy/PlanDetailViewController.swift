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

class PlanDetailViewController: UIViewController, CLLocationManagerDelegate {
    

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var commentEntry: UITextField!
    
    @IBOutlet weak var commentTable: UITableView!
    
    var planObjects = [PFObject]()
    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
        
        
        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            if let location = locations.first as? CLLocation {
                mapView.camera=GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
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

        
        nameLabel.text = "\(firstname) will be at..."
        locationLabel.text = placeName
        timeLabel.text = "\(startTimeString) to \(endTimeString)"
        
        if let postImage = creatingUser.objectForKey("profileImage") as? PFFile {
            let imageData = postImage.getData()
            let image = UIImage(data: imageData!)
            self.profileImage.image = image
            
        }

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    
    @IBAction func didTapCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
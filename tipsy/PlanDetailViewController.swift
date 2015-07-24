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

class PlanDetailViewController: UIViewController, CLLocationManagerDelegate {
    

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var commentTable: UITableView!
    @IBOutlet weak var commentEntry: UITextField!
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
      //      mapView.myLocationEnabled = true
        //    mapView.settings.myLocationButton = true
        }
        
        
        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            if let location = locations.first as? CLLocation {
          //      mapView.camera=GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
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
    
    
    @IBAction func didTapBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
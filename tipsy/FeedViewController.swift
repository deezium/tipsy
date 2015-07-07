//
//  FeedViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/6/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var feedTableView: UITableView!
    let kcellIdentifier: String = "FeedCell"
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let user = PFUser.currentUser()
    let searchRadiusKilometers = CLLocationAccuracy()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            println("location services enabled")
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        }
        

        
        self.feedTableView!.delegate = self
        self.feedTableView!.dataSource = self
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        
  //      println("locationManager \(manager.location)")
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        
        self.currentLocation = manager.location
    //    println("currentLocation \(self.currentLocation)")
        locationManager.stopUpdatingLocation()
        //        self.addCheckinPins()
        //
        //        var locationLat = currentLocation.coordinate.latitude
        //        var locationLong = currentLocation.coordinate.longitude
        //
        //        println("currentLocation = \(locationLat) \(locationLong)")
        
    }

    
    func queryForAllPostsNearLocation(currentLocation: CLLocation, withNearbyDistance nearbyDistance: CLLocationAccuracy) -> [PFObject] {
        
//        println("fuck my balls did this work \(currentLocation)")
        var locValue:CLLocationCoordinate2D = currentLocation.coordinate
        
        var query = PFQuery(className: "CheckIn")
        
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        
        //query.whereKey("location", nearGeoPoint: point, withinKilometers: 10)
        query.includeKey("creatingUser")
        query.orderByDescending("createdAt")
        query.limit = 20
        var checkins: NSMutableArray = []
        
        var objects = query.findObjects() as! [PFObject]
        
        println(objects)
        
        return objects
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var objects = queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 10)
        println(objects.count)
        return objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kcellIdentifier) as! UITableViewCell
        //let album = self.albums[indexPath.row]
        
        
        var objects = queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 10)
        var count = objects.count
        
        if (count == 0) {
            println("no objects found")
        }
        else {
            let object = objects[indexPath.row]
            
            println(object)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    let user = object.objectForKey("creatingUser") as! PFUser
                    let createdAt = object.createdAt
                    let timeAgo = createdAt!.shortTimeAgoSinceNow()
                    let message = object.objectForKey("message") as! String
                    
                    cellToUpdate.textLabel?.text = user.username! as String

                    cellToUpdate.detailTextLabel?.text = "\(message), \(timeAgo)"
                    
                }
            })
           // cell.detailTextLabel?.text = object.username
           // cell.textLabel?.text = object.message
        }
        
        
        return cell
    }
}

    

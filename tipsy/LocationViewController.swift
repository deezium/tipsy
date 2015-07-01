//
//  LocationViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/24/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let user = PFUser.currentUser()
    let searchRadiusKilometers = CLLocationAccuracy()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(user)
        
     //   self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            println("location services enabled")
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        
        println("locationManager \(manager.location)")
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        self.currentLocation = manager.location
        println("currentLocation \(self.currentLocation)")
        locationManager.stopUpdatingLocation()
        self.queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 1)
//        
//        var locationLat = currentLocation.coordinate.latitude
//        var locationLong = currentLocation.coordinate.longitude
//        
//        println("currentLocation = \(locationLat) \(locationLong)")
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func queryForAllPostsNearLocation(currentLocation: CLLocation, withNearbyDistance nearbyDistance: CLLocationAccuracy) {
        
        println("fuck my balls did this work \(currentLocation)")
        var locValue:CLLocationCoordinate2D = currentLocation.coordinate
        
        var query = PFQuery(className: "CheckIn")
        
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        
        query.whereKey("location", nearGeoPoint: point, withinKilometers: 1)
        query.includeKey("creatingUser")
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    println("Yeee query succeeded")
                    var checkins: NSMutableArray = []
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            checkins.addObject(object)
                        }
                    }
                    println(checkins)
                 //   self.mapView.addAnnotations(checkins as [AnyObject])
                
                }
                else {
                    println("Fuck query failed")
                }
            
            }
        
    }
}
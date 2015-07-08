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
import DateTools

class LocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let user = PFUser.currentUser()
    let searchRadiusKilometers = CLLocationAccuracy()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // println(user)
        
     //   self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
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
//        self.addCheckinPins()
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
    
    func queryForAllPostsNearLocation(currentLocation: CLLocation, withNearbyDistance nearbyDistance: CLLocationAccuracy) -> NSMutableArray {
        
        println("fuck my balls did this work \(currentLocation)")
        var locValue:CLLocationCoordinate2D = currentLocation.coordinate
        
        var query = PFQuery(className: "CheckIn")
        
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        
        query.whereKey("location", nearGeoPoint: point, withinKilometers: 1)
        query.includeKey("creatingUser")
        query.limit = 20
        var checkins: NSMutableArray = []
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    println("Yeee query succeeded")
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            let user = object.objectForKey("creatingUser") as! PFUser
                            let title = user.username! as String
                            let point = object.objectForKey("location") as? PFGeoPoint
                            let createdAt = object.createdAt
                            let timeAgo = createdAt!.shortTimeAgoSinceNow()
                            let st = object.objectForKey("message") as! String
                            let subtitle = "\(st), time since post: \(timeAgo)"
                            let coordinate = CLLocationCoordinate2D(latitude: point!.latitude, longitude: point!.longitude)
                            println("time ago \(timeAgo)")
                            var checkinPin = MKPointAnnotation()
                            checkinPin.coordinate = coordinate
                            checkinPin.title = title
                            checkinPin.subtitle = subtitle
                            
                            
                           // let annotation = CheckinAnnotation(coordinate: coordinate, title: title, subtitle: subtitle)
                            self.mapView.removeAnnotation(checkinPin)
                            self.mapView.addAnnotation(checkinPin)
                            //checkins.addObject(object)
                            
                        }
                        println("Checkins added \(checkins)")
                    }
                 
                 //   self.mapView.addAnnotations(checkins as [AnyObject])
                
                }
                else {
                    println("Fuck query failed")
                }
            
            }
        println("These my checkins yo \(checkins)")
        return checkins
    }
    
    // TO DO: MODIFY TO ACTUALLY USE DATA FROM SERVER
    // RUN QUERY TO GET PFOBJECTS BACK
    // BUILD ARRAY OF DICTS (OR DICT OF DICTS?) TO HOLD ALL NECESSARY VALUES
    // READ FROM ARRAY TO PUT ALL RELEVANT PARAMETERS ON THE ANNOTATION

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Purple
            var label = UILabel(frame: CGRectMake(0,0,21,21))
            label.text = "3h"
//            pinView!.rightCalloutAccessoryView = label
            
  //          pinView!.leftCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func addCheckinPins() {
        
        let x = self.queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 1)
        //println(x)
        let coordinate = currentLocation.coordinate
        let title = "Debarshi Chaudhuri"
        let subtitle = "My House"
        let annotation = CheckinAnnotation(coordinate: coordinate, title: title, subtitle: subtitle)
        mapView.addAnnotation(annotation)
    }
}
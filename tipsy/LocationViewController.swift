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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: checkinMadeNotificationKey, object: nil)

        
    }
    
    func refreshPosts() {
        self.queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 1)
    }

    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        
        println("locationManager \(manager.location)")
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
        
        self.currentLocation = manager.location
        println("currentLocation \(self.currentLocation)")
        locationManager.stopUpdatingLocation()
        self.queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 1)
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
        var checkins: NSMutableArray = []
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    println("Yeee query succeeded")
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            let user = object.objectForKey("creatingUser") as! PFUser
                            let title = user.objectForKey("fullname") as! String
                            let point = object.objectForKey("location") as? PFGeoPoint
                            let createdAt = object.createdAt
                            let timeAgo = createdAt!.shortTimeAgoSinceNow()
                            let st = object.objectForKey("message") as! String
                            let subtitle = "\(st), time since post: \(timeAgo)"
                            let coordinate = CLLocationCoordinate2D(latitude: point!.latitude, longitude: point!.longitude)
                            
                            let image = user.objectForKey("profileImage") as! PFFile
                            let imageData = image.getData()
                            let posterImage = UIImage(data: imageData!)
                            
                            self.addCheckinPin(coordinate, title: title, subtitle: subtitle, posterImage: posterImage!)
                            
                        }
                    }
                 
                 //   self.mapView.addAnnotations(checkins as [AnyObject])
                
                }
                else {
                    println("Fuck query failed")
                }
            
            }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let checkinView = CheckinAnnotationView(annotation: annotation, reuseIdentifier: "checkin")
        checkinView.canShowCallout = true
        println(checkinView.image)
        return checkinView
//
//        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
//        annotationView.canShowCallout = true
//        return annotationView
        
        
//        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
//        pinView!.canShowCallout = true
//        return pinView

//        let reuseId = "pin"
//        
//        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
//        if pinView == nil {
//            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            pinView!.canShowCallout = true
//            pinView!.animatesDrop = true
//            pinView!.pinColor = .Green
//            var label = UILabel(frame: CGRectMake(0,0,21,21))
//            label.text = "3h"
////            pinView!.rightCalloutAccessoryView = label
//            
//  //          pinView!.leftCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
//        }
//        else {
//            pinView!.annotation = annotation
//        }
//        return pinView
    }
    
    func addCheckinPin(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, posterImage: UIImage) {
//        checkinPin.coordinate = coordinate
//        checkinPin.title = title
//        checkinPin.subtitle = subtitle
        
        let typeRawValue = 0
        let type = CheckinType(rawValue: typeRawValue)!
        let annotation = CheckinAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type)
        self.mapView.addAnnotation(annotation)

//        let checkinPin = CheckinAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, posterImage: posterImage)
//        
//        self.mapView.addAnnotation(checkinPin)
        
    }
    
}
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

class LocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, QueryControllerProtocol {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let user = PFUser.currentUser()
    let searchRadiusKilometers = CLLocationAccuracy()
    
    var query = QueryController()
    var queryObjects = [PFObject]()
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            println("objects received")
            self.addQueryControllerCheckinPins(self.queryObjects)
            self.mapView.reloadInputViews()
//            self.feedTableView!.reloadData()
 //           UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
       // println(user)
        
     //   self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        query.delegate = self
        query.queryPosts("")
        
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
        query.queryPosts("")
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
        
        //self.queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 1)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        if (annotation is CheckinAnnotation) {
            let checkinView = CheckinAnnotationView(annotation: annotation, reuseIdentifier: "checkin")
            let newAnnotation = annotation as! CheckinAnnotation
            println(newAnnotation.posterImage)
            
            //checkinView.canShowCallout = true // toggle default checkin annotation

            checkinView.calloutOffset = CGPointMake(0, -10)
            
            let imageView = UIImageView(frame: CGRectMake(-15, -15, 30, 30))
            
            imageView.image = newAnnotation.posterImage
            
            checkinView.addSubview(imageView)
            
            return checkinView

        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let mapPin = view as? CheckinAnnotationView {
            updatePinPosition(mapPin)
        }
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if let mapPin = view as? CheckinAnnotationView {
            if mapPin.preventDeselection {
                mapView.selectAnnotation(view.annotation, animated: false)
            }
        }
    }
    
    func updatePinPosition(pin:CheckinAnnotationView) {
        let defaultShift:CGFloat = 50
        let pinPosition = CGPointMake(pin.frame.midX, pin.frame.maxY)
        
        let y = pinPosition.y - defaultShift
        
        let controlPoint = CGPointMake(pinPosition.x, y)
        let controlPointCoordinate = mapView.convertPoint(controlPoint, toCoordinateFromView: mapView)
        
        mapView.setCenterCoordinate(controlPointCoordinate, animated: true)
    }
    
    func addQueryControllerCheckinPins(objects: [PFObject]) {
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
            let typeRawValue = 1
            let type = CheckinType(rawValue: typeRawValue)!
            let annotation = CheckinAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type, posterImage: posterImage!)
            self.mapView.addAnnotation(annotation)
        }
    }
    
}
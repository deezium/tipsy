//
//  CheckInViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/29/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class CheckInViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var message: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var databasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            println("location services enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
        println("yay loaded!")
//        let filemgr = NSFileManager.defaultManager()
//        let dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        let docsDir = dirPaths[0] as! String
//        
//        databasePath = docsDir.stringByAppendingPathComponent("tipsy.db")
//        
//        if !filemgr.fileExistsAtPath(databasePath as String) {
//            let tipsyDB = FMDatabase(path: databasePath as String)
//        
//            if tipsyDB == nil {
//                println("Error: \(tipsyDB.lastErrorMessage())")
//            }
//            
//            if tipsyDB.open() {
//                let sql_statement = "CREATE TABLE IF NOT EXISTS CHECKINS (ID INTEGER PRIMARY KEY AUTOINCREMENT, MESSAGE TEXT, LATITUDE REAL, LONGITUDE REAL, DATE INTEGER)"
//                
//                if !tipsyDB.executeStatements(sql_statement) {
//                    println("Error: \(tipsyDB.lastErrorMessage())")
//                }
//                else {
//                    println("Error: \(tipsyDB.lastErrorMessage())")
//                }
//
//            }
//        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        
        println("locations = \(locValue.latitude) \(locValue.longitude)")
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: false)
        var currentLocation = CLLocation()
        
        var locationLat = currentLocation.coordinate.latitude
        var locationLong = currentLocation.coordinate.longitude
        
        println("locations = \(locationLat) \(locationLong) \(currentLocation.coordinate.latitude) \(currentLocation.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    @IBAction func checkinButtonPressed(sender: AnyObject) {
        var locValue:CLLocationCoordinate2D = self.locationManager.location.coordinate
    
        let user = PFUser.currentUser()
        
        let currentPoint = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        
        let checkInObject = PFObject(className: "CheckIn")
        checkInObject.setObject(message.text, forKey: "message")
        checkInObject.setObject(currentPoint, forKey: "location")
        checkInObject.setObject(user!, forKey: "creatingUser")
        
        let readOnlyACL = PFACL()
        readOnlyACL.setPublicReadAccess(true)
        readOnlyACL.setPublicWriteAccess(false)
        checkInObject.ACL = readOnlyACL
        
        checkInObject.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if success == true {
                println("Success")
            }
            else {
                println("Fail")
            }
        }
        
        message.resignFirstResponder()
        message.text = ""
        
//        let tipsyDB = FMDatabase(path: databasePath as String)
//        let date = NSDate().timeIntervalSince1970
//        let humanLocalDate = NSDate(timeIntervalSince1970: date)
//        
//        if tipsyDB.open() {
//            let insertSQL = "INSERT INTO CHECKINS (message, latitude, longitude, date) VALUES ('\(message.text)', '\(locValue.latitude)', '\(locValue.longitude)', '\(date)')"
//            
//            let result = tipsyDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
//            
//            if !result {
//                println("Failed to checkin")
//                println("Error: \(tipsyDB.lastErrorMessage())")
//            }
//            else {
//                println("Checkin successful!")
//                message.text = ""
//                println("date \(date)")
//                println("human date \(humanLocalDate)")
//                println("latitude \(locValue.latitude) longitude \(locValue.longitude)")
//                println("Everything's fine: \(tipsyDB.databasePath())")
//            }
//        }
//        else {
//            println("Error: \(tipsyDB.lastErrorMessage())")
//        }
    }
}
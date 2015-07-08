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
import MobileCoreServices

class CheckInViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var message: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var imageView: UIImageView?
    
    
    @IBAction func didTapCamera(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as NSString]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
        

    }
    
    
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        println(image)
        imageView!.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        message.endEditing(true)
    }
    
    @IBAction func checkinButtonPressed(sender: AnyObject) {
        var locValue:CLLocationCoordinate2D = self.locationManager.location.coordinate
    
        let user = PFUser.currentUser()
        
        let currentPoint = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        
        let checkInObject = PFObject(className: "CheckIn")
        checkInObject.setObject(message.text, forKey: "message")
        checkInObject.setObject(currentPoint, forKey: "location")
        checkInObject.setObject(user!, forKey: "creatingUser")
        
        if let image = imageView!.image as UIImage? {
            let image = imageView!.image
            let imageData = UIImageJPEGRepresentation(image, 1)
            let imageParseFile: PFFile = PFFile(data: imageData)
            checkInObject.setObject(imageParseFile, forKey: "image")
        }
        
        let readOnlyACL = PFACL()
        readOnlyACL.setPublicReadAccess(true)
        readOnlyACL.setPublicWriteAccess(false)
        checkInObject.ACL = readOnlyACL
        
        checkInObject.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if success == true {
                println("Success")
                let alert = UIAlertController(title: "Success", message: "Your message has been posted successfully!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                println("Fail")
            }
        }
        
        message.resignFirstResponder()
        message.text = ""
        imageView!.image = nil
        
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
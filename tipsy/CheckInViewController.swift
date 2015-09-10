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

let checkinMadeNotificationKey = "checkinMadeNotificationKey"

class CheckInViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var message: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var imageView: UIImageView?
    
    var currentLocation = CLLocation()
    let locationManager = CLLocationManager()
    
    
    
    @IBAction func didTapCamera(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            print("checkin location services enabled")
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
        print("yay loaded!")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        print(image)
        imageView!.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: false)
        self.currentLocation = manager.location!
        
        let locationLat = currentLocation.coordinate.latitude
        let locationLong = currentLocation.coordinate.longitude
        
        print("locations = \(locationLat) \(locationLong) \(currentLocation.coordinate.latitude) \(currentLocation.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
    }
    

    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        message.endEditing(true)
    }
    
    @IBAction func checkinButtonPressed(sender: AnyObject) {
        var locValue:CLLocationCoordinate2D = self.locationManager.location!.coordinate
    
        let user = PFUser.currentUser()
        
        let currentPoint = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        
        let checkInObject = PFObject(className: "CheckIn")
        checkInObject.setObject(message.text!, forKey: "message")
        checkInObject.setObject(currentPoint, forKey: "location")
        checkInObject.setObject(user!, forKey: "creatingUser")
        
        if let image = imageView!.image as UIImage? {
            let image = imageView!.image
            let imageData = UIImageJPEGRepresentation(image!, 1)
            let imageParseFile: PFFile = PFFile(data: imageData!)
            checkInObject.setObject(imageParseFile, forKey: "image")
        }
        
        let ACL = PFACL()
        ACL.setPublicReadAccess(true)
        ACL.setPublicWriteAccess(true)
        checkInObject.ACL = ACL
        
        checkInObject.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if success == true {
                print("Success")
                let alert = UIAlertController(title: "Success", message: "Your message has been posted successfully!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                print("Fail")
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(checkinMadeNotificationKey, object: self)
        
        message.resignFirstResponder()
        message.text = ""
        imageView!.image = nil
        
    }
}
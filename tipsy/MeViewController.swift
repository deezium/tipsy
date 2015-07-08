//
//  MeViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/7/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import DateTools

class MeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var latestCheckin: MKMapView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var checkinLabel: UILabel!
    
    let kcellIdentifier: String = "ProfileCell"
    let user = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileName.text = user!.username!
        
        self.profileTable!.delegate = self
        self.profileTable!.dataSource = self
        self.latestCheckin.delegate = self
        
        self.drawLatestCheckin()
        
        
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
        
    func queryForAllPostsByUser(user: PFUser) -> [PFObject] {
        
        //        println("fuck my balls did this work \(currentLocation)")
        //var locValue:CLLocationCoordinate2D = currentLocation.coordinate
        
        var query = PFQuery(className: "CheckIn")
        
        query.whereKey("creatingUser", equalTo: user)
        query.includeKey("creatingUser")
        query.orderByDescending("createdAt")
        query.limit = 20
        var checkins: NSMutableArray = []
        
        var objects = query.findObjects() as! [PFObject]
        
        println(objects)
        
        return objects
        
    }
    
    func drawLatestCheckin() {
        var objects = queryForAllPostsByUser(user!)
        
        if let objects = objects as? [PFObject] {
            let object = objects[0]
            let point = object.objectForKey("location") as? PFGeoPoint
            let coordinate = CLLocationCoordinate2D(latitude: point!.latitude, longitude: point!.longitude)
            
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.latestCheckin.setRegion(region, animated: true)
            
            var checkinPin = MKPointAnnotation()
            checkinPin.coordinate = coordinate
            
            self.latestCheckin.removeAnnotation(checkinPin)
            self.latestCheckin.addAnnotation(checkinPin)
            
            
            
        }
    }
    
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
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var objects = queryForAllPostsByUser(user!)
        println(objects.count)
        return objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kcellIdentifier) as! UITableViewCell
        //let album = self.albums[indexPath.row]
        
        
        var objects = queryForAllPostsByUser(user!)
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
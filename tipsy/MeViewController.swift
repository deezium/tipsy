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
        
        self.profileName.text = user!.objectForKey("fullname") as? String
        
        self.profileTable!.delegate = self
        self.profileTable!.dataSource = self
        self.latestCheckin.delegate = self
        
        self.drawLatestCheckin()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
        
    func queryForAllPostsByUser(user: PFUser) -> [PFObject] {
        
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
        var objects = queryForAllPostsByUser(user!)
        let object = objects[indexPath.row]
        
        if (object.objectForKey("image") != nil) {
            return profilePictureCellAtIndexPath(tableView, withObject: object)
        }
        else {
            return profileTextCellAtIndexPath(tableView, withObject: object)
        }
    }
    
    func profileTextCellAtIndexPath(tableView: UITableView, withObject object: PFObject) -> FeedTextCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileTextCell") as! FeedTextCell
        
        let user = object.objectForKey("creatingUser") as! PFUser
        let createdAt = object.createdAt
        let timeAgo = createdAt!.shortTimeAgoSinceNow()
        let message = object.objectForKey("message") as! String
        let username = user.objectForKey("fullname") as? String
        
        cell.username.text = username
        cell.timestamp.text = timeAgo
        cell.message.text = message
        return cell
    }
    
    func profilePictureCellAtIndexPath(tableView: UITableView, withObject object: PFObject) -> FeedPictureCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfilePictureCell") as! FeedPictureCell
        
        let user = object.objectForKey("creatingUser") as! PFUser
        let createdAt = object.createdAt
        let timeAgo = createdAt!.shortTimeAgoSinceNow()
        let message = object.objectForKey("message") as! String
        let username = user.objectForKey("fullname") as? String
        
        
        if let postImage = object.objectForKey("image") as? PFFile {
            let imageData = postImage.getData()
            let image = UIImage(data: imageData!)
            cell.postImage.image = image
            
        }
        
        cell.username.text = username
        cell.timestamp.text = timeAgo
        cell.message.text = message
        //cell.postImage.image = image
        return cell
        
        
    }

    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kcellIdentifier) as! UITableViewCell
//        
//        var objects = queryForAllPostsByUser(user!)
//        var count = objects.count
//        
//        if (count == 0) {
//            println("no objects found")
//        }
//        else {
//            let object = objects[indexPath.row]
//            
//            println(object)
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
//                    let user = object.objectForKey("creatingUser") as! PFUser
//                    let createdAt = object.createdAt
//                    let timeAgo = createdAt!.shortTimeAgoSinceNow()
//                    let message = object.objectForKey("message") as! String
//                    
//                    cellToUpdate.textLabel?.text = user.username! as String
//                    
//                    cellToUpdate.detailTextLabel?.text = "\(message), \(timeAgo)"
//                    
//                }
//            })
//        }
//        
//        return cell
//    }

    
}
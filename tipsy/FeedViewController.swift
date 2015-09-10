//
//  FeedViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/6/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, QueryControllerProtocol {
    
    @IBOutlet weak var feedTableView: UITableView!
    let kcellIdentifier: String = "FeedCell"
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let user = PFUser.currentUser()
    let searchRadiusKilometers = CLLocationAccuracy()
    let feedTextCellIdentifier: String = "FeedTextCell"
    
    var query = QueryController()
    var queryObjects = [PFObject]()
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.feedTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query.delegate = self
        self.configureTableView()
        query.queryPosts("")
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            print("location services enabled")
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: checkinMadeNotificationKey, object: nil)        

        
        self.feedTableView!.delegate = self
        self.feedTableView!.dataSource = self
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    }
    
    func refreshPosts() {
        query.queryPosts("")
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
  //      println("locationManager \(manager.location)")
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        
        self.currentLocation = manager.location!
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
        let locValue:CLLocationCoordinate2D = currentLocation.coordinate
        
        let query = PFQuery(className: "CheckIn")
        
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        
        //query.whereKey("location", nearGeoPoint: point, withinKilometers: 10)
        query.includeKey("creatingUser")
        query.orderByDescending("createdAt")
        query.limit = 20
        var checkins: NSMutableArray = []
        
        let objects = query.findObjects() as! [PFObject]
 
 //       println(objects)
        
        return objects
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var objects = queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 10)
//        println(objects.count)
//        return objects.count
        
        print(queryObjects.count)
        return queryObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        var objects = queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 10)
//        let object = objects[indexPath.row]
//        
//        if (object.objectForKey("image") != nil) {
//            return feedPictureCellAtIndexPath(tableView, withObject: object)
//        }
//        else {
//            return feedTextCellAtIndexPath(tableView, withObject: object)
//        }
        
        let queryObject = queryObjects[indexPath.row]
        
        if (queryObject.objectForKey("image") != nil) {
            return feedPictureCellAtIndexPath(tableView, withObject: queryObject)
        }
        else {
            return feedTextCellAtIndexPath(tableView, withObject: queryObject)
        }
    }

    func feedTextCellAtIndexPath(tableView: UITableView, withObject object: PFObject) -> FeedTextCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedTextCell") as! FeedTextCell
        
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
    
    func configureTableView() {
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = 160.0
    }
    
    func feedPictureCellAtIndexPath(tableView: UITableView, withObject object: PFObject) -> FeedPictureCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedPictureCell") as! FeedPictureCell
        
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
//        //let album = self.albums[indexPath.row]
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell") as! UITableViewCell
//        
//        
//        var objects = queryForAllPostsNearLocation(currentLocation, withNearbyDistance: 10)
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
//            if (object.objectForKey("image") != nil) {
//                let cell = tableView.dequeueReusableCellWithIdentifier("PictureCell") as! PictureCell
//                    
//                dispatch_async(dispatch_get_main_queue(), {
//                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
//                        let user = object.objectForKey("creatingUser") as! PFUser
//                        let createdAt = object.createdAt
//                        let timeAgo = createdAt!.shortTimeAgoSinceNow()
//                        let message = object.objectForKey("message") as! String
//                        
//                        cellToUpdate.textLabel?.text = user.username! as String
//                        
//                        cellToUpdate.detailTextLabel?.text = "\(message), \(timeAgo)"
//                        
//                    }
//                })
//
//            }
//            
//            else {
//                let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("FeedCell") as! UITableViewCell
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
//                        let user = object.objectForKey("creatingUser") as! PFUser
//                        let createdAt = object.createdAt
//                        let timeAgo = createdAt!.shortTimeAgoSinceNow()
//                        let message = object.objectForKey("message") as! String
//                        
//                        cellToUpdate.textLabel?.text = user.username! as String
//                        
//                        cellToUpdate.detailTextLabel?.text = "\(message), \(timeAgo)"
//                        
//                    }
//                })
//
//            }
//            
//           // cell.detailTextLabel?.text = object.username
//           // cell.textLabel?.text = object.message
//        }
//        
//        
//        return cell
//    }
}

    

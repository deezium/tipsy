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

class MeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var latestCheckin: MKMapView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileTable: UITableView!
    
    
    let kcellIdentifier: String = "ProfileCell"
    let user = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileName.text = user!.username!
        
        self.profileTable!.delegate = self
        self.profileTable!.dataSource = self
        
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
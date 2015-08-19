//
//  MyFriendsViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/18/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class MyFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    let currentUser = PFUser.currentUser()!
    
    var query = QueryController()
    var queryObjects = [PFObject]()
    
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        query.delegate = self
        query.queryUserIdsForFriends()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var finalCell: UITableViewCell!
        let cell = tableView.dequeueReusableCellWithIdentifier("MyFriendsCell") as! MyFriendsCell
        
        
        let friend = queryObjects[indexPath.row]
        
        let friendName = friend.objectForKey("fullname") as! String
        
        if let profileImage = friend.objectForKey("profileImage") as? PFFile {
            let imageData = profileImage.getData()
            let image = UIImage(data: imageData!)
            cell.profilePicture.image = image
            
        }
        
        cell.nameLabel.text = friendName
        
        finalCell = cell
        
        return finalCell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryObjects.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let attendee = queryObjects[indexPath.row] as? PFUser
        println("user picture tapped! \(attendee)")
        let profileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PlanProfileViewController") as! PlanProfileViewController
        profileViewController.user = attendee
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
}
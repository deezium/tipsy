//
//  MyFriendsViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/18/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import Amplitude_iOS

class MyFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    let currentUser = PFUser.currentUser()!
    
    
    
    @IBOutlet weak var noFriendsLabel: UILabel!
    
    @IBOutlet weak var inviteLabel: UILabel!
    
    
    @IBOutlet weak var inviteButton: UIButton!
    
    var query = QueryController()
    var queryObjects = [PFObject]()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.activityIndicator.stopAnimating()
            
            if self.queryObjects.count == 0 {
                self.tableView.hidden = true
                self.noFriendsLabel.hidden = false
                self.inviteLabel.hidden = false
                self.inviteButton.hidden = false
                print("you have no friends wa wa")
            }
        })
    }

    
    @IBAction func didTapInvite(sender: AnyObject) {
        
        let textToShare = "Are you getting Tipsy?"
        
        if let website = NSURL(string: "http://www.everybodygettipsy.com/") {
            let objectsToShare = [textToShare, website]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }

        Amplitude.instance().logEvent("tipsyInviteTapped")

        
    }
    
    override func viewDidAppear(animated: Bool) {
        Amplitude.instance().logEvent("myFriendsViewed")

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noFriendsLabel.hidden = true
        inviteLabel.hidden = true
        inviteButton.hidden = true
        
        activityIndicator.startAnimating()
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
            
            profileImage.getDataInBackgroundWithBlock({
                (imageData,error) -> Void in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        let image = UIImage(data: imageData!)
                        cell.profilePicture.image = image
                    }
                }
                else {
                    print("image retrieval error")
                }
            })
            
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
        let profileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PlanProfileViewController") as! PlanProfileViewController
        profileViewController.user = attendee
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
}
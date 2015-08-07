//
//  PlanDetailViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/23/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

let commentMadeNotificationKey = "commentMadeNotificationKey"

class PlanDetailViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol, UITextFieldDelegate {
    

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var commentEntry: UITextField!
    
    @IBOutlet weak var commentTable: UITableView!
    
    @IBOutlet weak var editButton: UIButton!
  
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var currentUser = PFUser.currentUser()
    var planObjects = [PFObject]()
    
    var query = QueryController()
    var queryObjects = [PFObject]()

    var attendeeQueryObjects = [PFObject]()

    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.commentTable!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func didReceiveSecondQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.attendeeQueryObjects = objects
            self.commentTable!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentTable.delegate = self
        self.commentTable.dataSource = self
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        commentEntry.delegate = self
        
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
//            mapView.myLocationEnabled = true
//            mapView.settings.myLocationButton = true
        }
        
        
        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            if let location = locations.first as? CLLocation {
//                mapView.camera=GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                self.locationManager.stopUpdatingLocation()
            }
        }
    

        let plan = planObjects.first
        let creatingUser = plan!.objectForKey("creatingUser") as! PFObject
        let fullname = creatingUser.objectForKey("fullname") as? String
        let firstname = fullname!.componentsSeparatedByString(" ")[0]
        
        let startTime = plan!.objectForKey("startTime") as? NSDate
        let endTime = plan!.objectForKey("endTime") as? NSDate
        let placeName = plan!.objectForKey("googlePlaceName") as? String

        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, hh:mm a"
        
        let startTimeString = dateFormatter.stringFromDate(startTime!)
        let endTimeString = dateFormatter.stringFromDate(endTime!)

        
        if (currentUser?.objectId == creatingUser.objectId) {
            editButton.hidden = false
        }
        else {
            editButton.hidden = true
        }
        
        messageLabel.text = plan!.objectForKey("message") as! String
        nameLabel.text = firstname
        locationLabel.text = placeName
        timeLabel.text = "\(startTimeString) to \(endTimeString)"
        
        if let postImage = creatingUser.objectForKey("profileImage") as? PFFile {
            let imageData = postImage.getData()
            let image = UIImage(data: imageData!)
            self.profileImage.image = image
            
        }

        
        
        
        let planGeoPoint = plan!.objectForKey("googlePlaceCoordinate") as? PFGeoPoint
        
        if let planGeoPoint = planGeoPoint {
            let latitude = planGeoPoint.latitude
            let longitude = planGeoPoint.longitude
            
            let planCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
//            mapView.camera=GMSCameraPosition(target: planCoordinate, zoom: 15, bearing: 0, viewingAngle: 0)
 //           var marker = GMSMarker(position: planCoordinate)
  //          marker.map = self.mapView

        }
        
        query.delegate = self
        query.queryComments(plan!)
        query.queryAttendingUsersForPlan(plan!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHidden:"), name:UIKeyboardWillHideNotification, object: nil);

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshComments", name: commentMadeNotificationKey, object: nil)


        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.animateWithDuration(1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height - 50
        })
    }

    func keyboardWasHidden(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.bottomConstraint.constant = 0
        })
    }

    
    
    func refreshComments() {
        let plan = planObjects.first
        query.queryComments(plan!)
        query.queryAttendingUsersForPlan(plan!)

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        commentEntry.resignFirstResponder()
        return true
    }
    
    @IBAction func didTapHeartButton(sender: AnyObject) {
        let heartButton: UIButton = sender as! UIButton
        
        let cell = heartButton.superview?.superview as! PlanDetailInteractionCell
        
        
        //        println(cell)
        
        let index = self.commentTable.indexPathForCell(cell)!
        
        let plan = planObjects.first!
        //        println("selectedPlan \(plan)")
        
        var heartState = Bool()
        
        let heartingUsers = plan.objectForKey("heartingUsers") as? [String]
        
        if let hearts = heartingUsers {
            println("dem hearts \(hearts)")
            println("dat user \(currentUser!.objectId!)")
            if contains(hearts, currentUser!.objectId!) {
                //println ("plan \(queryObject) is hearted by \(currentUser!.objectId!)")
                heartState = true
            }
            else {
                heartState = false
            }
        }
        
        if heartState == false {
            plan.addUniqueObject(currentUser!.objectId!, forKey: "heartingUsers")
            
            heartState = !heartState
            
            let originalHeartingUserCount = heartingUsers?.count ?? 0
            
            let newHeartingUserCount = originalHeartingUserCount + 1
            
            let newHeartingUserCountString = String(newHeartingUserCount)
            
            cell.heartButton.setImage(UIImage(named: "LikeFilled.png"), forState: UIControlState.Normal)
            cell.heartButton.setTitle(newHeartingUserCountString, forState: UIControlState.Normal)
            println("hearted! \(heartState)")
            
        }
        else {
            plan.removeObject(currentUser!.objectId!, forKey: "heartingUsers")
            
            heartState = !heartState
            
            let originalHeartingUserCount = heartingUsers?.count ?? 0
            
            let newHeartingUserCount = originalHeartingUserCount - 1
            
            let newHeartingUserCountString = String(newHeartingUserCount)
            
            cell.heartButton.setImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
            cell.heartButton.setTitle(newHeartingUserCountString, forState: UIControlState.Normal)
            println("unhearted! \(heartState)")
        }
        
        
        plan.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                println("Success")
            }
            else {
                println("error \(error)")
            }
        }

    }
    
    
    
    @IBAction func didTapCommentHeart(sender: AnyObject) {
        println("Comment hearted!")
        
        let heartButton: UIButton = sender as! UIButton
        
        let cell = heartButton.superview?.superview as! CommentCell
        
        
        //        println(cell)
        
        
        let index = self.commentTable.indexPathForCell(cell)!
        
        let comment = queryObjects[index.row-3]
        
        
        var heartState = Bool()
        
        let heartingUsers = comment.objectForKey("heartingUsers") as? [String]
        
        if let hearts = heartingUsers {
            println("dem hearts \(hearts)")
            println("dat user \(currentUser!.objectId!)")
            if contains(hearts, currentUser!.objectId!) {
                //println ("plan \(queryObject) is hearted by \(currentUser!.objectId!)")
                heartState = true
            }
            else {
                heartState = false
            }
        }
        
        if heartState == false {
            comment.addUniqueObject(currentUser!.objectId!, forKey: "heartingUsers")
            
            heartState = !heartState
            
            let originalHeartingUserCount = heartingUsers?.count ?? 0
            
            let newHeartingUserCount = originalHeartingUserCount + 1
            
            let newHeartingUserCountString = String(newHeartingUserCount)
            
            cell.heartButton.setImage(UIImage(named: "LikeFilled.png"), forState: UIControlState.Normal)
            cell.heartButton.setTitle(newHeartingUserCountString, forState: UIControlState.Normal)
            println("hearted! \(heartState)")
            
        }
        else {
            comment.removeObject(currentUser!.objectId!, forKey: "heartingUsers")
            
            heartState = !heartState
            
            let originalHeartingUserCount = heartingUsers?.count ?? 0
            
            let newHeartingUserCount = originalHeartingUserCount - 1
            
            let newHeartingUserCountString = String(newHeartingUserCount)
            
            cell.heartButton.setImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
            cell.heartButton.setTitle(newHeartingUserCountString, forState: UIControlState.Normal)
            println("unhearted! \(heartState)")
        }
        
        
        comment.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                println("Success")
            }
            else {
                println("error \(error)")
            }
        }
        

        
    }
    
    @IBAction func didTapJoinButton(sender: AnyObject) {
        
        let joinButton: UIButton = sender as! UIButton
        
        let cell = joinButton.superview?.superview as! PlanDetailInteractionCell
        
        
        let index = self.commentTable.indexPathForCell(cell)!
        
        
        
        let plan = planObjects.first!
        
        var attendanceState = Bool()
        
        let attendingUsers = plan.objectForKey("attendingUsers") as? [String]
        
        if let attendees = attendingUsers {
            println("dem attendees \(attendees)")
            println("dat user \(currentUser!.objectId!)")
            if contains(attendees, currentUser!.objectId!) {
                //println ("plan \(queryObject) is hearted by \(currentUser!.objectId!)")
                attendanceState = true
            }
            else {
                attendanceState = false
            }
        }
        
        
        if attendanceState == false {
            plan.addUniqueObject(currentUser!.objectId!, forKey: "attendingUsers")
            
            attendanceState = !attendanceState
            
            
            cell.joinButton.setImage(UIImage(named: "GenderNeutralUserFilled.png"), forState: UIControlState.Normal)
            cell.joinButton.setTitle("Joined!", forState: UIControlState.Normal)
            println("joined! \(attendanceState)")
            
        }
        else {
            plan.removeObject(currentUser!.objectId!, forKey: "attendingUsers")
            
            attendanceState = !attendanceState
            
            
            cell.joinButton.setImage(UIImage(named: "AddUser.png"), forState: UIControlState.Normal)
            cell.joinButton.setTitle("Join", forState: UIControlState.Normal)
            println("left! \(attendanceState)")
        }
        
        
        plan.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                println("Success")
            }
            else {
                println("error \(error)")
            }
        }

    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(queryObjects.count)
        return queryObjects.count + 3
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var finalCell: UITableViewCell?
        
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PlanDetailAddressCell") as? PlanDetailAddressCell
            let placeAddress = planObjects.first?.objectForKey("googlePlaceFormattedAddress") as? String
            
            cell?.addressLabel.text = placeAddress
            
            
//            let shortAddressLabel = shortAddress[0]
            
            
            finalCell = cell
        }
        
        else if indexPath.row == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PlanDetailInteractionCell") as? PlanDetailInteractionCell
            
            var heartState: Bool? = false
            
            let plan = planObjects.first!
            
            let heartingUsers = plan.objectForKey("heartingUsers") as? [String]
            let countHeartingUsers = heartingUsers?.count
            
            if let hearts = heartingUsers {
                println("dem hearts \(hearts)")
                println("dat user \(currentUser!.objectId!)")
                if contains(hearts, currentUser!.objectId!) {
                    println ("plan \(plan.objectId) is hearted by \(currentUser!.objectId!)")
                    heartState = true
                }
            }
            
            var attendanceState: Bool? = false
            
            let attendingUsers = plan.objectForKey("attendingUsers") as? [String]
            let countAttendingUsers = attendingUsers?.count
            
            if let attendees = attendingUsers {
                println("dem hearts \(attendees)")
                println("dat user \(currentUser!.objectId!)")
                if contains(attendees, currentUser!.objectId!) {
                    println ("plan \(plan.objectId) is being attended by \(currentUser!.objectId!)")
                    attendanceState = true
                }
            }
            
            if (heartState == true) {
                cell?.heartButton.setImage(UIImage(named: "LikeFilled.png"), forState: UIControlState.Normal)
            }
            else {
                cell?.heartButton.setImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
                
            }
            
            cell?.heartButton.setTitle(heartingUsers?.count.description, forState: UIControlState.Normal)
            
            if (attendanceState == true) {
                cell?.joinButton.setImage(UIImage(named: "GenderNeutralUserFilled.png"), forState: UIControlState.Normal)
                cell?.joinButton.setTitle("Joined!", forState: UIControlState.Normal)
                
            }
            else {
                cell?.joinButton.setImage(UIImage(named: "AddUser.png"), forState: UIControlState.Normal)
                cell?.joinButton.setTitle("Join", forState: UIControlState.Normal)
                
                
            }


            
            finalCell = cell

        }
        
        else if indexPath.row == 2 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PlanDetailAttendingCell") as! PlanDetailAttendingCell
            
            let plan = planObjects.first!
            let creatingUser = plan.objectForKey("creatingUser") as! PFObject
            
            var attendeeImageArray = [UIImage?]()
            
            for attendee in attendeeQueryObjects {
                if let postImage = attendee.objectForKey("profileImage") as? PFFile {
                    let imageData = postImage.getData()
                    let image = UIImage(data: imageData!)
                    attendeeImageArray.append(image!)
                }
            }
            
            println("first attendee \(attendeeImageArray.first)")
            
            if let postImage = creatingUser.objectForKey("profileImage") as? PFFile {
                let imageData = postImage.getData()
                let image = UIImage(data: imageData!)
                cell.firstAttendee.setImage(image, forState: UIControlState.Normal)
                cell.firstAttendee.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.firstAttendee.tag = 0
                
            }
            
            for (index, image) in enumerate(attendeeImageArray) {
                if index == 0 {
                    cell.secondAttendee.setImage(image, forState: UIControlState.Normal)
                    cell.secondAttendee.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                    cell.secondAttendee.tag = index+1
                }
                if index == 1 {
                    cell.thirdAttendee.setImage(image, forState: UIControlState.Normal)
                    cell.thirdAttendee.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                    cell.thirdAttendee.tag = index+1

                }
                if index == 2 {
                    cell.fourthAttendee.setImage(image, forState: UIControlState.Normal)
                    cell.fourthAttendee.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                    cell.fourthAttendee.tag = index+1
                }
                if index == 3 {
                    cell.fifthAttendee.setImage(image, forState: UIControlState.Normal)
                    cell.fifthAttendee.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                    cell.fifthAttendee.tag = index+1
                }

            }
            
//            if let attendee = attendeeImageArray[0] {
//                cell.secondAttendee.image = attendeeImageArray[0]
//            }
            
//            cell.firstAttendee.image = attendeeImageArray[0]
            
            
            finalCell = cell
            
        }
        
//        else if indexPath.row == 3 {
//            var cell = tableView.dequeueReusableCellWithIdentifier("PlanDetailHeaderCell") as? UITableViewCell
//            finalCell = cell
//            
//        }
        
        else {
            var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
            let commentObject = queryObjects[indexPath.row-3]
            var heartState: Bool? = false

            let user = commentObject.objectForKey("commentingUser") as! PFUser
            let fullname = user.objectForKey("fullname") as? String
            let firstname = fullname?.componentsSeparatedByString(" ")[0]
            let timeAgo = commentObject.createdAt!.shortTimeAgoSinceNow()
            let commentBody = commentObject.objectForKey("body") as? String
            
            if let postImage = user.objectForKey("profileImage") as? PFFile {
                let imageData = postImage.getData()
                let image = UIImage(data: imageData!)
                cell.profileImage.image = image
                
            }
            
            cell.nameLabel.text = firstname
//            cell.messageLabel.text = commentBody
            cell.newCommentTextField.text = commentBody
            cell.timeLabel.text = timeAgo
            
            let heartingUsers = commentObject.objectForKey("heartingUsers") as? [String]
            let countHeartingUsers = heartingUsers?.count
            
            if let hearts = heartingUsers {
                println("dem hearts \(hearts)")
                println("dat user \(currentUser!.objectId!)")
                if contains(hearts, currentUser!.objectId!) {
                    println ("plan \(commentObject.objectId) is hearted by \(currentUser!.objectId!)")
                    heartState = true
                }
            }
            
            if (heartState == true) {
                cell.heartButton.setImage(UIImage(named: "LikeFilled.png"), forState: UIControlState.Normal)
            }
            else {
                cell.heartButton.setImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
                
            }
            
            cell.heartButton.setTitle(heartingUsers?.count.description, forState: UIControlState.Normal)
            

            
            finalCell = cell
            
        }
        

        
        return finalCell!

    }
    
    func didTapUserProfileImage(sender: UIButton!) {
        var attendee: PFUser?
        if sender.tag == 0 {
            attendee = planObjects.first?.objectForKey("creatingUser") as? PFUser
            println("user picture tapped! \(attendee)")
            let profileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PlanProfileViewController") as! PlanProfileViewController
            profileViewController.user = attendee
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
        else {
            attendee = attendeeQueryObjects[sender.tag-1] as? PFUser
            println("user picture tapped! \(attendee)")
            let profileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PlanProfileViewController") as! PlanProfileViewController
            profileViewController.user = attendee
            self.navigationController?.pushViewController(profileViewController, animated: true)

        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    
    @IBAction func didTapCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowEditFromDetail" {
            var selectedPlans = [PFObject]()
            let plan = planObjects.first

            
            let planCreationViewController = segue.destinationViewController as! PlanCreationViewController
            
            selectedPlans.append(plan!)
            
            planCreationViewController.plans = selectedPlans
            
        }
        
    }

    
    @IBAction func didTapPostButton(sender: AnyObject) {
        
        let commentObject = PFObject(className: "Comment")
        commentObject.setObject(commentEntry.text, forKey: "body")
        commentObject.setObject(PFUser.currentUser()!, forKey: "commentingUser")
        commentObject.setObject(planObjects.first!, forKey: "commentedPlan")
        
        
        let ACL = PFACL()
        ACL.setPublicReadAccess(true)
        ACL.setPublicWriteAccess(true)
        commentObject.ACL = ACL
        
        commentObject.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if success == true {
                println("Success")
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject(self.planObjects.first!.objectId!, forKey: "channels")
                currentInstallation.saveInBackground()
                println("registered installation for pushes")
                
                self.planObjects.first?.addObject(commentObject.objectId!, forKey: "comments")
                self.planObjects.first?.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if success == true {
                        println("comment added to plan")
                    }
                    else {
                        println("comment not added to plan")
                    }
                }

                let alert = UIAlertController(title: "Success", message: "Comment posted!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.commentEntry.text = ""
                NSNotificationCenter.defaultCenter().postNotificationName(commentMadeNotificationKey, object: self)
            }
            else {
                let alert = UIAlertController(title: "Sorry!", message: "We had trouble posting your comment.  Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }

    }
}
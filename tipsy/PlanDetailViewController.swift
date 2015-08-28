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
import Amplitude_iOS

let commentMadeNotificationKey = "commentMadeNotificationKey"
let planInteractedNotificationKey = "planInteractedNotificationKey"

class PlanDetailViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol, UITextFieldDelegate {
    
    @IBOutlet weak var postButton: UIButton!

    @IBOutlet weak var profileImageButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageLabel: UILabel!
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
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func didReceiveSecondQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.attendeeQueryObjects = objects
            self.commentTable!.reloadData()
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func dismissKeyboard(){
        println("dismissKeyboard called")
        commentEntry.endEditing(true)
    }

    func configureTableView() {
        commentTable.rowHeight = UITableViewAutomaticDimension
        commentTable.estimatedRowHeight = 70.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        self.commentTable.delegate = self
        self.commentTable.dataSource = self
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        commentEntry.delegate = self
        
        self.navigationController?.navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Book", size: 15)!], forState: UIControlState.Normal)
        
        profileImageButton.imageView!.layer.cornerRadius = profileImageButton.imageView!.frame.size.width / 2
        profileImageButton.imageView!.clipsToBounds = true
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
//            mapView.myLocationEnabled = true
//            mapView.settings.myLocationButton = true
        }
        
        
//        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//            if let location = locations.first as? CLLocation {
//                mapView.camera=GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
//                self.locationManager.stopUpdatingLocation()
//            }
//        }
    
        configureTableView()
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)


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
            
            profileImageButton.setImage(image, forState: UIControlState.Normal)
            profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)

            
        }

        
        
        
        let planGeoPoint = plan!.objectForKey("googlePlaceCoordinate") as? PFGeoPoint
        
        if let planGeoPoint = planGeoPoint {
            let latitude = planGeoPoint.latitude
            let longitude = planGeoPoint.longitude
            
            let planCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            

        }
        
        query.delegate = self
        query.queryComments(plan!)
        query.queryAttendingUsersForPlan(plan!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHidden:"), name:UIKeyboardWillHideNotification, object: nil);

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshComments", name: commentMadeNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planInteractedNotificationKey, object: nil)
        
        var viewedPlanDetailProperties = NSDictionary(object: planObjects.first!.objectId!, forKey: "planId") as? [NSObject : AnyObject]
        
        
        Amplitude.instance().logEvent("viewedPlanDetail", withEventProperties: viewedPlanDetailProperties)

        
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
                NSNotificationCenter.defaultCenter().postNotificationName(planInteractedNotificationKey, object: self)

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
        
        
        if (plan.objectForKey("creatingUser")?.objectId == PFUser.currentUser()?.objectId) {
            cell.joinButton.hidden = true
        }
        else if attendanceState == false {
            plan.addUniqueObject(currentUser!.objectId!, forKey: "attendingUsers")
            //currentUser?.addUniqueObject(plan.objectId!, forKey: "attendedPlans")

            attendanceState = !attendanceState
            
            
            cell.joinButton.setImage(UIImage(named: "GenderNeutralUserFilled.png"), forState: UIControlState.Normal)
            cell.joinButton.setTitle("Joined!", forState: UIControlState.Normal)
            println("joined! \(attendanceState)")
            
        }
        else {
            plan.removeObject(currentUser!.objectId!, forKey: "attendingUsers")
            //currentUser?.removeObject(plan.objectId!, forKey: "attendedPlans")
            
            
            attendanceState = !attendanceState
            
            
            cell.joinButton.setImage(UIImage(named: "AddUser.png"), forState: UIControlState.Normal)
            cell.joinButton.setTitle("Join", forState: UIControlState.Normal)
            println("left! \(attendanceState)")
        }
        
        
        plan.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                println("Success")
                let joinChannel = "join-" + plan.objectId!
                let commentsChannel = "comments-" + plan.objectId!
                
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject(joinChannel, forKey: "channels")
                currentInstallation.addUniqueObject(commentsChannel, forKey: "channels")
                currentInstallation.saveInBackground()
                println("registered installation for pushes")
                NSNotificationCenter.defaultCenter().postNotificationName(planInteractedNotificationKey, object: self)


            }
            else {
                println("error \(error)")
            }
        }

    }
    
    
    @IBAction func didTapInviteButton(sender: AnyObject) {
        
        let plan = planObjects.first!
        let message = plan.objectForKey("message") as? String
        let creatingUser = plan.objectForKey("creatingUser") as! PFUser
        
        var textToShare = "Hey, I just planned \(message!) on Tipsy. Check it out!"
        
        if (currentUser != creatingUser) {
            let creatingUserName = creatingUser.objectForKey("fullname") as? String
            let firstname = creatingUserName?.componentsSeparatedByString(" ")[0]
            textToShare = "Hey, \(firstname!) just posted \(message!) on Tipsy. Check it out!"

        }
        
        
        if let website = NSURL(string: "http://www.everybodygettipsy.com/") {
            let objectsToShare = [textToShare, website]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
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
            
            let formattedAddressSlice = placeAddress?.componentsSeparatedByString(", ")[0..<3]

            let formattedAddress = formattedAddressSlice![0] + ", " + formattedAddressSlice![1] + ", " + formattedAddressSlice![2]
            

            
            cell?.addressLabel.text = formattedAddress
            
            
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
            
            if heartingUsers?.count == 0 {
                cell?.heartButton.setTitle("0", forState: UIControlState.Normal)
            }
            else {
                cell?.heartButton.setTitle(heartingUsers?.count.description, forState: UIControlState.Normal)
            }

            
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
                
                cell.firstAttendee.layer.cornerRadius = cell.firstAttendee.frame.size.width / 2
                cell.firstAttendee.clipsToBounds = true
                
            }
            
            for (index, image) in enumerate(attendeeImageArray) {
                if index == 0 {
                    cell.secondAttendee.setImage(image, forState: UIControlState.Normal)
                    cell.secondAttendee.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                    cell.secondAttendee.tag = index+1
                    
                    cell.secondAttendee.layer.cornerRadius = cell.secondAttendee.frame.size.width / 2
                    cell.secondAttendee.clipsToBounds = true

                }
                if index == 1 {
                    cell.thirdAttendee.setImage(image, forState: UIControlState.Normal)
                    cell.thirdAttendee.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                    cell.thirdAttendee.tag = index+1

                    cell.thirdAttendee.layer.cornerRadius = cell.thirdAttendee.frame.size.width / 2
                    cell.thirdAttendee.clipsToBounds = true

                }
                if index == 2 {
                    cell.fourthAttendee.setImage(image, forState: UIControlState.Normal)
                    cell.fourthAttendee.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                    cell.fourthAttendee.tag = index+1

                    cell.fourthAttendee.layer.cornerRadius = cell.fourthAttendee.frame.size.width / 2
                    cell.fourthAttendee.clipsToBounds = true

                }
                if index == 3 {
                    cell.fifthAttendee.setImage(image, forState: UIControlState.Normal)
                    cell.fifthAttendee.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                    cell.fifthAttendee.tag = index+1

                    cell.fifthAttendee.layer.cornerRadius = cell.fifthAttendee.frame.size.width / 2
                    cell.fifthAttendee.clipsToBounds = true

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
                cell.profileImageButton.setImage(image, forState: UIControlState.Normal)
                cell.profileImageButton.tag = indexPath.row-3+100
                cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                
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
            
            println("comment hearting users \(heartingUsers)")
            if heartingUsers?.count == 0 {
                cell.heartButton.setTitle("0", forState: UIControlState.Normal)
            }
            else {
                cell.heartButton.setTitle(heartingUsers?.count.description, forState: UIControlState.Normal)
            }


            
            finalCell = cell
            
        }
        

        
        return finalCell!

    }
    
    func didTapUserProfileImage(sender: UIButton!) {
        var attendee: PFUser?
        
        
        
        if (sender.tag == 0) {
            attendee = planObjects.first?.objectForKey("creatingUser") as? PFUser
            println("user picture tapped! \(attendee)")
            let profileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PlanProfileViewController") as! PlanProfileViewController
            profileViewController.user = attendee
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
        else if (sender.tag < 100) {
            attendee = attendeeQueryObjects[sender.tag-1] as? PFUser
            println("user picture tapped! \(attendee)")
            let profileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PlanProfileViewController") as! PlanProfileViewController
            profileViewController.user = attendee
            self.navigationController?.pushViewController(profileViewController, animated: true)

        }
        else {
            let object = queryObjects[sender.tag-100] as? PFObject
            attendee = object?.objectForKey("commentingUser") as? PFUser
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
        
//        if segue.identifier == "ShowFullAttendees" {
//            
//            let attendeeViewController = segue.destinationViewController as! MyFriendsViewController
//            
//            attendeeViewController.queryObjects = attendeeQueryObjects
//        }
        
    }
    
    func tableViewScrollToBottom() {
        let lastRow = queryObjects.count + 3
        let indexPath = NSIndexPath(forRow: lastRow, inSection: 0)
        commentTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }

    
    @IBAction func didTapPostButton(sender: AnyObject) {
        
        if commentEntry.text == "" {
            let alert = UIAlertController(title: "Sorry!", message: "You can't post a blank comment!  Say something wonderful.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Gotcha!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }
        else {
            
            activityIndicator.startAnimating()
            postButton.enabled = false
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
                    
                    let pushChannel = "comments-" + self.planObjects.first!.objectId!
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation.addUniqueObject(pushChannel, forKey: "channels")
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
                    
                    let alert = UIAlertController(title: "Great success!", message: "Your comment has been posted!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    let plan = self.planObjects.first
                    self.query.queryComments(plan!)
                    
                    self.activityIndicator.stopAnimating()
                    
                    self.commentEntry.text = ""
                    self.postButton.enabled = true
                    self.commentEntry.endEditing(true)
                    self.tableViewScrollToBottom()

                    NSNotificationCenter.defaultCenter().postNotificationName(commentMadeNotificationKey, object: self)
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.postButton.enabled = true
                    let alert = UIAlertController(title: "Sorry!", message: "Ope, we had trouble posting your comment.  Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
            }

            
        }
        

    }
}
//
//  ActivityViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/18/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import DateTools
import Amplitude_iOS

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QueryControllerProtocol, CLLocationManagerDelegate {
    
    @IBOutlet weak var tipsyTurtle: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var query = QueryController()
    var newQueryObjects = [PFObject]()
    var hotQueryObjects = [PFObject]()
    var ongoingQueryObjects = [PFObject]()
    var userFriendsQueryObjects = [PFObject]()

    var newQueryPage = 0
    
    let locationManager = CLLocationManager()
    var refreshControl = UIRefreshControl()
    let currentUser = PFUser.currentUser()
    var currentLocation = CLLocation()

    func refreshPosts() {
        let locValue:CLLocationCoordinate2D = self.currentLocation.coordinate
        
        
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        self.query.queryHotPlansForActivity(self.userFriendsQueryObjects, point: point)
        self.query.queryNewPlansForActivity(self.userFriendsQueryObjects, point: point)
        self.query.queryOngoingPlansForActivity(self.userFriendsQueryObjects, point: point)
        self.refreshControl.endRefreshing()
    }

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.currentLocation = manager.location!
        print("didUpdateLocations currentLocation \(self.currentLocation)")
        
  //      query.queryUserIdsForFriends()
  }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveFacebookData()
        
        segmentedControl.selectedSegmentIndex = 1
        
        
        activityIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.backgroundColor = UIColor(red:15/255, green: 65/255, blue: 79/255, alpha: 1)
        refreshControl.addTarget(self, action: "refreshPosts", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        locationManager.delegate = self
        query.delegate = self
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
//        if CLLocationManager.authorizationStatus() == .Denied {
//            activityIndicator.stopAnimating()
//            tableView.hidden = true
//            segmentedControl.hidden = true
//            tipsyTurtle.hidden = false
//            locationLabel.hidden = false
//        }
        
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            if (locationManager.location != nil) {
                self.currentLocation = locationManager.location!
                print("locationManager not nil \(self.currentLocation)")
            }
            
            query.queryUserIdsForFriends()
            print("queriedLocation \(currentLocation)")
        }

        var locValue:CLLocationCoordinate2D = self.currentLocation.coordinate


        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        
        
//        query.queryUserIdsForFriends()
        
        Amplitude.instance().setUserId(PFUser.currentUser()?.objectId)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planInteractedNotificationKey, object: nil)
        
        self.setUserLocation()
        
    }
    
    
    func setUserLocation() {
        if (locationManager.location != nil) {
            
            let locValue = locationManager.location!.coordinate
            
            let latestLocation = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
            
            PFUser.currentUser()?.setObject(latestLocation, forKey: "latestLocation")
            PFInstallation.currentInstallation().setObject(latestLocation, forKey: "latestLocation")
            
            PFUser.currentUser()?.saveInBackground()
            PFInstallation.currentInstallation().saveInBackground()
        }
        
        
    }
    
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()

            
            if (locationManager.location != nil) {
                self.currentLocation = locationManager.location!
            }
            print("didChangeAuthorizationStatus \(currentLocation)")
            query.queryUserIdsForFriends()
        }
        else if status == .Denied {
            activityIndicator.stopAnimating()
            tableView.hidden = true
            segmentedControl.hidden = true
            tipsyTurtle.hidden = false
            locationLabel.hidden = false
        }
    }

    
    func saveFacebookData() {
        if (PFUser.currentUser() != nil && PFUser.currentUser()?.objectForKey("fullname") == nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                print("has access token")
                let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        print("OOPS")
                    }
                    else {
                        print("me fetch result \(result)")
                        
                        if result["name"] != nil {
                            PFUser.currentUser()?.setObject(result["name"], forKey: "fullname")
                            PFUser.currentUser()?.saveInBackground()
                        }
                    }
                })
            }
            
        }
                
        
        if (PFUser.currentUser() != nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                print("has access token")
                let pictureRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/picture?width=100&height=100&redirect=false", parameters: nil)
                pictureRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        print("OOPS")
                    }
                    else {
                        print(result["data"]?["url"])
                        if let pictureString = result["data"]?["url"] as? String {
                            let pictureURL = NSURL(string: pictureString) as NSURL?
                            
                            if pictureURL != nil {
                                let pictureData = NSData(contentsOfURL: pictureURL!)
                                print("pictureData \(pictureData)")
                                
                                if pictureData != nil {
                                    let pictureFile = PFFile(data: pictureData!)
                                    PFUser.currentUser()?.setObject(pictureFile, forKey: "profileImage")
                                    PFUser.currentUser()?.saveInBackground()
                                    print("facebook profile picture saved")
                                    
                                }
                            }
                            
                        }
                        
                    }
                })
            }
            
        }
        
        if (PFUser.currentUser() != nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil ) {
                var friendsArray = [String]()
                PFUser.currentUser()?.setObject(friendsArray, forKey: "friendsUsingTipsy")
                PFUser.currentUser()?.saveInBackground()
                let userFriendsRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
                userFriendsRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        print("Oops, friend fetch failed")
                    }
                    else {
                        
                        
                        print(result?["data"]?[0]["id"])
                        
                        if let resultArray = result.objectForKey("data") as? NSArray {
                            print("facebook id data \(result)")
                            for i in resultArray {
                                if let id = i.objectForKey("id") as? String {
                                    friendsArray.append(id)                                    
                                }
                            }
                            
                        }
                        
                        PFUser.currentUser()?.setObject(friendsArray, forKey: "friendsUsingTipsy")
                        PFInstallation.currentInstallation().setObject(friendsArray, forKey: "friendsUsingTipsy")
                        
                        PFInstallation.currentInstallation().saveInBackground()
                        PFUser.currentUser()?.saveInBackground()
                    }
                })
            }
        }
        
        if (PFUser.currentUser() != nil) {
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                let userIDRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                userIDRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        print("Oops, id fetch failed")
                    }
                    else {
                        print("idrequest")
                        print(result["id"])
                        
                        if (result["id"] != nil) {
                            PFUser.currentUser()?.setObject(result["id"], forKey: "facebookID")
                            PFUser.currentUser()?.saveInBackground()
                        }
                    }
                })
                
                let userEmailRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/email", parameters: nil)
                userIDRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        print("Oops, id fetch failed")
                    }
                    else {
                        print("emailrequest")
                        print(result["email"])
                        
                        if (result["email"] != nil) {
                            PFUser.currentUser()?.setObject(result["email"], forKey: "facebookEmail")
                            PFUser.currentUser()?.saveInBackground()
                        }
                        
                    }
                })
                
            }
        }
    }

    
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.userFriendsQueryObjects = objects
            self.userFriendsQueryObjects.append(self.currentUser!)
            //self.createFriendIdArrays(objects)
            
            let locValue:CLLocationCoordinate2D = self.currentLocation.coordinate
            
            
            let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
            
            self.query.queryHotPlansForActivity(self.userFriendsQueryObjects, point: point)
            self.query.queryNewPlansForActivity(self.userFriendsQueryObjects, point: point)
            self.query.queryOngoingPlansForActivity(self.userFriendsQueryObjects, point: point)
            
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    
    func didReceiveSecondQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.hotQueryObjects = objects
            self.tableView.reloadData()

            self.activityIndicator.stopAnimating()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func didReceiveThirdQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.newQueryObjects = objects
            self.tableView.reloadData()
            
            
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func didReceiveFourthQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.ongoingQueryObjects = objects
            self.tableView.reloadData()
            
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    
    @IBAction func didChangeSegment(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("hot")
            Amplitude.instance().logEvent("activityFeedViewedHot")
            
        case 1:
            print("new")
            Amplitude.instance().logEvent("activityFeedViewedNew")

        case 2:
            print("ongoing")
            Amplitude.instance().logEvent("activityFeedViewedOngoing")

        default:
            break;
        }
        self.tableView.reloadData()
    }
    
    func didTapUserProfileImage(sender: UIButton!) {
        var user: PFUser?
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let object = hotQueryObjects[sender.tag]
            user = object.objectForKey("creatingUser") as? PFUser
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            let object = newQueryObjects[sender.tag]
            user = object.objectForKey("creatingUser") as? PFUser
        }
        else if segmentedControl.selectedSegmentIndex == 2 {
            let object = ongoingQueryObjects[sender.tag]
            user = object.objectForKey("creatingUser") as? PFUser
        }

        let profileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PlanProfileViewController") as! PlanProfileViewController
        profileViewController.user = user
        self.navigationController?.pushViewController(profileViewController, animated: true)
        
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return hotQueryObjects.count
            
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            return newQueryObjects.count
        }
        else if segmentedControl.selectedSegmentIndex == 2 {
            return ongoingQueryObjects.count
        }
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var finalCell: UITableViewCell?

        
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ActivityHotCell") as! ActivityHotCell
            
            let queryObject = hotQueryObjects[indexPath.row]
            
            let user = queryObject.objectForKey("creatingUser") as! PFUser
            let fullname = user.objectForKey("fullname") as? String
            let firstname = fullname?.componentsSeparatedByString(" ")[0]
            
            let message = queryObject.objectForKey("message") as? String
            let createdAt = queryObject.createdAt
            let placeName = queryObject.objectForKey("googlePlaceName") as? String
            let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
            let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
            let heartCount = queryObject.objectForKey("heartCount") as? Int
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM d, hh:mm a"
            
            var heartState: Bool? = false
            
            let timeAgo = createdAt!.shortTimeAgoSinceNow()
            
            var placeLabel: String?
            
            if let placeName = placeName {
                placeLabel = placeName
            }
            
            
            
            print("heartCount \(heartCount)")
            
            
            if let postImage = user.objectForKey("profileImage") as? PFFile {
                print("postImage \(postImage)")
//                let oldImageData = postImage.getData()
                
                postImage.getDataInBackgroundWithBlock({
                    (imageData,error) -> Void in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            let image = UIImage(data: imageData!)
                            cell.profileButton.setImage(image, forState: UIControlState.Normal)
                            // cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                            cell.profileButton.tag = indexPath.row
                            cell.profileButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                            
                        }
                    }
                    else {
                        print("image retrieval error")
                    }
                })
                
//                let image = UIImage(data: imageData!)
//                cell.profileButton.setImage(image, forState: UIControlState.Normal)
//                // cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
//                cell.profileButton.tag = indexPath.row
//                cell.profileButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)

                
            }
            
            cell.nameLabel.text = firstname
            cell.messageLabel.text = message
            cell.locationLabel.text = placeName
            
            let heartingUsers = queryObject.objectForKey("heartingUsers") as? [String]
            let countHeartingUsers = heartingUsers?.count
            
            if let hearts = heartingUsers {
                print("dem hearts \(hearts)")
                print("dat user \(currentUser!.objectId!)")
                if hearts.contains((currentUser!.objectId!)) {
                    heartState = true
                }
            }
            
            if (heartState == true) {
                cell.heartButton.setImage(UIImage(named: "LikeFilled.png"), forState: UIControlState.Normal)
            }
            else {
                cell.heartButton.setImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
                
            }
            
            
            if heartCount == 0 {
                cell.heartButton.setTitle(" ", forState: UIControlState.Normal)
            }
            else {
                cell.heartButton.setTitle(heartCount?.description, forState: UIControlState.Normal)
            }

            
            if (indexPath.row == newQueryObjects.count - 1) {
                print("reached bottom")
            }
            
            finalCell = cell
        }

        else if segmentedControl.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ActivityNewCell") as! ActivityNewCell
            
            let queryObject = newQueryObjects[indexPath.row]
            
            let user = queryObject.objectForKey("creatingUser") as! PFUser
            let fullname = user.objectForKey("fullname") as? String
            let firstname = fullname?.componentsSeparatedByString(" ")[0]

            let message = queryObject.objectForKey("message") as? String
            let createdAt = queryObject.createdAt
            let placeName = queryObject.objectForKey("googlePlaceName") as? String
            let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
            let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM d, hh:mm a"
            

            let timeAgo = createdAt!.shortTimeAgoSinceNow()
            
            var placeLabel: String?
            
            if let placeName = placeName {
                placeLabel = placeName
            }

            
            
            if let postImage = user.objectForKey("profileImage") as? PFFile {
                print("postImage \(postImage)")
                
                postImage.getDataInBackgroundWithBlock({
                    (imageData,error) -> Void in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            let image = UIImage(data: imageData!)
                            cell.profileButton.setImage(image, forState: UIControlState.Normal)
                            // cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                            cell.profileButton.tag = indexPath.row
                            cell.profileButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                            
                        }
                    }
                    else {
                        print("image retrieval error")
                    }
                })

                
            }

            cell.nameLabel.text = firstname
            cell.messageLabel.text = message
            cell.locationLabel.text = placeName
            cell.timeLabel.text = timeAgo

            
            if (indexPath.row == newQueryObjects.count - 1) {
                print("reached bottom")
            }
            
            finalCell = cell
        }

        else if segmentedControl.selectedSegmentIndex == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ActivityOngoingCell") as! ActivityOngoingCell
            
            let queryObject = ongoingQueryObjects[indexPath.row]
            
            let user = queryObject.objectForKey("creatingUser") as! PFUser
            let fullname = user.objectForKey("fullname") as? String
            let firstname = fullname?.componentsSeparatedByString(" ")[0]
            
            let message = queryObject.objectForKey("message") as? String
            let createdAt = queryObject.objectForKey("createdAt") as? String
            let placeName = queryObject.objectForKey("googlePlaceName") as? String
            let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
            let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
            
            let startTime = queryObject.objectForKey("startTime") as? NSDate
            let endTime = queryObject.objectForKey("endTime") as? NSDate
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM d, hh:mm a"
            
            let startTimeString = dateFormatter.stringFromDate(startTime!)
            let endTimeString = dateFormatter.stringFromDate(endTime!)

            
            
            var placeLabel: String?
            
            if let placeName = placeName {
                placeLabel = placeName
            }
            
            
            if let postImage = user.objectForKey("profileImage") as? PFFile {
                print("postImage \(postImage)")
                //                let oldImageData = postImage.getData()
                
                postImage.getDataInBackgroundWithBlock({
                    (imageData,error) -> Void in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            let image = UIImage(data: imageData!)
                            cell.profileButton.setImage(image, forState: UIControlState.Normal)
                            // cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                            cell.profileButton.tag = indexPath.row
                            cell.profileButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                            
                        }
                    }
                    else {
                        print("image retrieval error")
                    }
                })
                
                //                let image = UIImage(data: imageData!)
                //                cell.profileButton.setImage(image, forState: UIControlState.Normal)
                //                // cell.profileImageButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                //                cell.profileButton.tag = indexPath.row
                //                cell.profileButton.addTarget(self, action: "didTapUserProfileImage:", forControlEvents: UIControlEvents.TouchUpInside)
                
                
            }
            
            cell.nameLabel.text = firstname
            cell.messageLabel.text = message
            cell.locationLabel.text = placeName
            
            if (indexPath.row == ongoingQueryObjects.count - 1) {
                print("reached bottom")
            }


        finalCell = cell
        }
        

        return finalCell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("ActivityHeaderCell") as! CalendarHeaderCell
        
        
        if segmentedControl.selectedSegmentIndex == 0 {
            headerCell.headerLabel.text =  "Popular around you"
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            headerCell.headerLabel.text =  "Recently created"
        }
        else if segmentedControl.selectedSegmentIndex == 2 {
            headerCell.headerLabel.text =  "Happening now"
        }

        
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowPlanDetailsFromActivity", sender: nil)
        
    }
    
//    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        activityIndicator.startAnimating()
//        return indexPath
//        
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        activityIndicator.stopAnimating()
//    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowPlanDetailsFromActivity" {
            var selectedPlans = [PFObject]()
            
            let planDetailViewController = segue.destinationViewController as! PlanDetailViewController
            
            let index = self.tableView.indexPathForSelectedRow!
        
            var queryObject: PFObject
            
            if segmentedControl.selectedSegmentIndex == 0 {
                queryObject = hotQueryObjects[index.row]
            }
            else if segmentedControl.selectedSegmentIndex == 1 {
                queryObject = newQueryObjects[index.row]
            }
            else  {
                queryObject = ongoingQueryObjects[index.row]
            }

            selectedPlans.append(queryObject)
            print("selected plan \(selectedPlans)")
            planDetailViewController.planObjects = selectedPlans
        }
        
        
    }

    
    @IBAction func didTapHeart(sender: AnyObject) {
        
        let heartButton: UIButton = sender as! UIButton
        
        let cell = heartButton.superview?.superview as! ActivityHotCell
        
        
        //        println(cell)
        
        let index = self.tableView.indexPathForCell(cell)!
        
        var plan: PFObject
        
        if segmentedControl.selectedSegmentIndex == 0 {
            plan = hotQueryObjects[index.row]
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            plan = newQueryObjects[index.row]
        }
        else  {
            plan = ongoingQueryObjects[index.row]
        }
        
        //        println("selectedPlan \(plan)")
        
        var heartState = Bool()
        
        let heartingUsers = plan.objectForKey("heartingUsers") as? [String]
        
        if let hearts = heartingUsers {
            print("dem hearts \(hearts)")
            print("dat user \(currentUser!.objectId!)")
            if hearts.contains((currentUser!.objectId!)) {
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
            print("hearted! \(heartState)")
            
        }
        else {
            plan.removeObject(currentUser!.objectId!, forKey: "heartingUsers")
            
            heartState = !heartState
            
            let originalHeartingUserCount = heartingUsers?.count ?? 0
            
            let newHeartingUserCount = originalHeartingUserCount - 1
            
            let newHeartingUserCountString = String(newHeartingUserCount)
            
            cell.heartButton.setImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
            cell.heartButton.setTitle(newHeartingUserCountString, forState: UIControlState.Normal)
            print("unhearted! \(heartState)")
        }
        
        
        plan.saveInBackgroundWithBlock {
            (success,error) -> Void in
            if success == true {
                print("Success")
                NSNotificationCenter.defaultCenter().postNotificationName(planInteractedNotificationKey, object: self)
                
                var heartedPlanProperties = NSDictionary(object: plan.objectId!, forKey: "planId") as? [NSObject : AnyObject]
                
                Amplitude.instance().logEvent("planHearted", withEventProperties: heartedPlanProperties)


            }
            else {
                print("error \(error)")
            }
        }
    }
    
}
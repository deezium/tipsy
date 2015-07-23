//
//  PlanProfileViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/21/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class PlanProfileViewController: UIViewController, QueryControllerProtocol, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var planTableView: UITableView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
        
    @IBAction func didChangeSegment(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                println("upcoming")
            case 1:
                println("past")
            default:
                break;
        }
        self.planTableView.reloadData()
    }
    
    let user = PFUser.currentUser()
    
    var query = QueryController()
    var queryObjects = [PFObject]()
    var pastPlans = [PFObject]()
    var pastPlansOriginal = [PFObject]()
    var upcomingPlans = [PFObject]()
 
    func didReceiveQueryResults(objects: [PFObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.queryObjects = objects
            self.createPlanArrays(objects)
            self.planTableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let planCreationViewController = segue.destinationViewController as! PlanCreationViewController
            
            var selectedPlans = [PFObject]()

            
//            if let selectedRow = sender as? UITableViewCell {
//                let index = selectedRow[indexPath.row]
//                let selectedPlan = upcomingPlans[index]
//                selectedPlans.append(selectedPlan)
//                planCreationViewController.plans = selectedPlans
//                println(planCreationViewController.plans)
//            }
//            
            
            if let selectedEditButton = sender as? UIButton {
            
                let index = selectedEditButton.tag
                let selectedPlan = upcomingPlans[index]
                
                // There's probably a better way to do this
                
                selectedPlans.append(selectedPlan)
                planCreationViewController.plans = selectedPlans
                println("pcvc plans\(planCreationViewController.plans)")
            }
            
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ShowEdit" {
//            var planCreationViewController = segue.destinationViewController as! PlanCreationViewController
//            planCreationViewController.plans = selectedPlans
//        }
//    }
//
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let planCreationViewController = PlanCreationViewController()
//        
//    
//        let selectedPlan = pastPlans[indexPath.row]
//        selectedPlans.append(selectedPlan)
//        planCreationViewController.plans = selectedPlans
//        println(planCreationViewController.plans)
//        
//        planCreationViewController.performSegueWithIdentifier("ShowEdit", sender: self)
//    }
//    
    func createPlanArrays(objects: [PFObject]) {
        
        upcomingPlans = [PFObject]()
        pastPlansOriginal = [PFObject]()
        
        for object in objects {
            
            let endTime = object.objectForKey("endTime") as? NSDate
            let currentTime = NSDate()
            
            if currentTime.isEarlierThan(endTime) {
                upcomingPlans.append(object)
            }
            else {
                pastPlansOriginal.append(object)
            }
        }
        pastPlans = pastPlansOriginal.reverse()
        println("upcomingPlans \(upcomingPlans)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        query.delegate = self
        query.queryProfilePlans("creatingUser")

        self.username.text = user!.objectForKey("fullname") as? String
        
        if let profileImage = user!.objectForKey("profileImage") as? PFFile {
            let imageData = profileImage.getData()
            let image = UIImage(data: imageData!)
            self.profileImage.image = image
            
        }
        
        self.planTableView!.delegate = self
        self.planTableView!.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPosts", name: planMadeNotificationKey, object: nil)

        
    }
    
    func refreshPosts() {
        query.queryProfilePlans("creatingUser")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            return upcomingPlans.count
        }
        else {
            return pastPlans.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var queryObject: PFObject
        let cell = tableView.dequeueReusableCellWithIdentifier("PlanProfileCell") as! PlanProfileCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            queryObject = upcomingPlans[indexPath.row]
            cell.editButton.hidden = false
        }
        else {
            queryObject = pastPlans[indexPath.row]
            cell.editButton.hidden = true
        }
        
        
        let user = queryObject.objectForKey("creatingUser") as! PFUser
        let username = user.objectForKey("fullname") as? String
        let startTime = queryObject.objectForKey("startTime") as? NSDate
        let endTime = queryObject.objectForKey("endTime") as? NSDate
        let placeName = queryObject.objectForKey("googlePlaceName") as? String
        let placeAddress = queryObject.objectForKey("googlePlaceFormattedAddress") as? String
        let shortAddress = placeAddress?.componentsSeparatedByString(",")[0]
        var placeLabel: String?
        var addressLabel: String?
        
        if let placeName = placeName {
            placeLabel = placeName
        }
        
        if let shortAddress = shortAddress {
            addressLabel = shortAddress
        }

        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, hh:mm a"
        
        let startTimeString = dateFormatter.stringFromDate(startTime!)
        let endTimeString = dateFormatter.stringFromDate(endTime!)

        cell.startTime.text = startTimeString
        cell.endTime.text = endTimeString
        cell.location.text = placeLabel
        cell.addressLabel.text = shortAddress
        cell.editButton.tag = indexPath.row
        
        return cell
    }
    
}
//
//  MoreViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/18/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import Amplitude_iOS

class MoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        Amplitude.instance().logEvent("moreViewed")
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var finalCell: UITableViewCell!
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreTableCell") as! MoreTableCell
            cell.titleLabel.text = "My Friends"
            cell.iconImage.image = UIImage(named: "UserGroup.png")
            
            finalCell = cell
        }
        
//        if indexPath.row == 1 {
//            let cell = tableView.dequeueReusableCellWithIdentifier("MoreTableCell") as! MoreTableCell
//            cell.titleLabel.text = "Notifications"
//            cell.iconImage.image = UIImage(named: "Megaphone.png")
//            
//            finalCell = cell
//        }

        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreTableCell") as! MoreTableCell
            cell.titleLabel.text = "Feedback"
            cell.iconImage.image = UIImage(named: "VoicePresentation.png")
            
            finalCell = cell
        }

        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreTableCell") as! MoreTableCell
            cell.titleLabel.text = "FAQ"
            cell.iconImage.image = UIImage(named: "Help.png")
            
            finalCell = cell
        }

        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreTableCell") as! MoreTableCell
            cell.titleLabel.text = "About"
            cell.iconImage.image = UIImage(named: "Info.png")
            
            finalCell = cell
        }

        
        return finalCell

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            performSegueWithIdentifier("ShowMyFriendsFromMore", sender: nil)
        }
        
//        if indexPath.row == 1 {
//            performSegueWithIdentifier("ShowNotificationsFromMore", sender: nil)
//        }
        
        if indexPath.row == 1 {
            performSegueWithIdentifier("ShowFeedbackFromMore", sender: nil)
        }
        
        if indexPath.row == 2 {
            performSegueWithIdentifier("ShowFAQFromMore", sender: nil)
        }
        
        if indexPath.row == 3 {
            performSegueWithIdentifier("ShowAboutFromMore", sender: nil)
        }
    }
    
}
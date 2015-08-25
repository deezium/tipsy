//
//  PlanFeedCell.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/20/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class PlanFeedCell: UITableViewCell {
    
//    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
//    @IBOutlet weak var startTime: UILabel!
//   @IBOutlet weak var endTime: UILabel!

    
    @IBOutlet weak var fullTime: UILabel!

    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var profileImageButton: UIButton!
    
    
    @IBOutlet weak var happeningNowBadge: UILabel!
    

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageButton.imageView!.layer.cornerRadius = profileImageButton.imageView!.frame.size.width / 2
        profileImageButton.imageView!.clipsToBounds = true
    }
    

    
    
}
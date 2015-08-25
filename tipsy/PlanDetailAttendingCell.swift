//
//  PlanDetailAttendingCell.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/5/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class PlanDetailAttendingCell: UITableViewCell {
    
    @IBOutlet weak var firstAttendee: UIButton!
    

    @IBOutlet weak var secondAttendee: UIButton!
 
    
    @IBOutlet weak var thirdAttendee: UIButton!
    
    
    @IBOutlet weak var fourthAttendee: UIButton!
    
    @IBOutlet weak var fifthAttendee: UIButton!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        firstAttendee.imageView!.layer.cornerRadius = firstAttendee.imageView!.frame.size.width / 2
        firstAttendee.imageView!.clipsToBounds = true

        secondAttendee.imageView!.layer.cornerRadius = secondAttendee.imageView!.frame.size.width / 2
        secondAttendee.imageView!.clipsToBounds = true

        thirdAttendee.imageView!.layer.cornerRadius = thirdAttendee.imageView!.frame.size.width / 2
        thirdAttendee.imageView!.clipsToBounds = true
    
        fourthAttendee.imageView!.layer.cornerRadius = fourthAttendee.imageView!.frame.size.width / 2
        fourthAttendee.imageView!.clipsToBounds = true
    
        fifthAttendee.imageView!.layer.cornerRadius = fifthAttendee.imageView!.frame.size.width / 2
        fifthAttendee.imageView!.clipsToBounds = true
    
    }
}
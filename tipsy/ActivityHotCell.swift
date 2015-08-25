//
//  ActivityHotCell.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/19/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

class ActivityHotCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var profileButton: UIButton!
    
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileButton.imageView!.layer.cornerRadius = profileButton.imageView!.frame.size.width / 2
        profileButton.imageView!.clipsToBounds = true
    }
}
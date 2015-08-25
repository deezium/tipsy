//
//  MyFriendsCell.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/18/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

class MyFriendsCell: UITableViewCell {
    
    
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
    }
    
}
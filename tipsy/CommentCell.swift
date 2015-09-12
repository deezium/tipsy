//
//  CommentCell.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/24/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImageButton: UIButton!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var newCommentTextField: UITextView!
    @IBOutlet weak var heartButton: UIButton!
 
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        newCommentTextField.editable = false
//        newCommentTextField.dataDetectorTypes = UIDataDetectorTypes.All
//        newCommentTextField.setContentOffset(CGPointZero, animated: false)
//    
//    }
//    
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        profileImageButton.imageView!.layer.cornerRadius = profileImageButton.imageView!.frame.size.width / 2
//        profileImageButton.imageView!.clipsToBounds = true
//    }
//
//    
    
}
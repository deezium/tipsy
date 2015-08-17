//
//  PlanCreationActivityCell.swift
//  
//
//  Created by Debarshi Chaudhuri on 8/4/15.
//
//

import Foundation
import UIKit

class PlanCreationActivityCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var messageLabel: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.delegate = self
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        messageLabel.resignFirstResponder()
        return true
    }
    
    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        println("touchesBegan called")
//        messageLabel.endEditing(true)
//    }
}

//
//  PlanCreationTextField.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/23/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation

class PlanCreationTextField : UITextField {
    var leftTextMargin : CGFloat = 0.0
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftTextMargin
        return newBounds
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftTextMargin
        return newBounds
    }
}


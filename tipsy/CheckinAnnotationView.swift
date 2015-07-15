//
//  CheckinAnnotationView.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/4/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CheckinAnnotationView: MKAnnotationView {
    class var reuseIdentifier:String {
        return "mapPin"
    }
    
    private var calloutView:CheckinCallout?
    private var hitOutside:Bool = true
    
    var preventDeselection:Bool {
        return !hitOutside
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation, reuseIdentifier: String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let checkinAnnotation = self.annotation as! CheckinAnnotation
        canShowCallout = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        let calloutViewAdded = calloutView?.superview != nil
        
        if (selected || !selected && hitOutside) {
            super.setSelected(selected, animated: animated)
        }
        
        self.superview?.bringSubviewToFront(self)
        
        if (calloutView == nil) {
            calloutView = CheckinCallout(frame: CGRectMake(-100, -220, 200, 200))
        }
        
        if (self.selected && !calloutViewAdded) {
            addSubview(calloutView!)
        }
        
        if (!self.selected) {
            calloutView?.removeFromSuperview()
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, withEvent: event)
        
        if let callout = calloutView {
            if (hitView == nil && self.selected) {
                hitView = callout.hitTest(point, withEvent: event)
            }
        }
        
        hitOutside = hitView == nil
        return hitView
    }
    
    
}
//
//  MapPinCallout.swift
//  
//
//  Created by Debarshi Chaudhuri on 7/14/15.
//
//

import Foundation

class MapPinCallout: UIView {
    override func hitTest(var point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        
        let isInsideView = pointInside(viewPoint, withEvent: event)
        
        var view = super.hitTest(viewPoint, withEvent: event)
        
        return view
    }
    
//    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
//        return CG
//    }
}
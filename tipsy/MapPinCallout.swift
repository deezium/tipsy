//
//  MapPinCallout.swift
//  
//
//  Created by Debarshi Chaudhuri on 7/14/15.
//
//

import Foundation

class MapPinCallout: UIView {
    
    override func drawRect(rect: CGRect) {
        println("my rectangle dis big \(rect)")
        var path = UIBezierPath(rect: rect)
        UIColor.greenColor().setFill()
        path.fill()
    }
    
    override func hitTest(var point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        
        let isInsideView = pointInside(viewPoint, withEvent: event)
        
        var view = super.hitTest(viewPoint, withEvent: event)
        
        return view
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGRectContainsPoint(bounds, point)
    }
}
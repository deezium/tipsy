//
//  MapPinCallout.swift
//  
//
//  Created by Debarshi Chaudhuri on 7/14/15.
//
//

import Foundation

class CheckinCallout: UIView {
    
    override func drawRect(rect: CGRect) {
        print("my rectangle dis big \(rect)")
        let path = UIBezierPath(rect: rect)
        UIColor.whiteColor().setFill()
        path.fill()
        
        let imageView = UIImageView(frame: CGRectMake(10, 10, 180, 100))
//        imageView.layer.borderColor = UIColor.blackColor() as! CGColor
//        imageView.layer.borderWidth = 1.0
        imageView.image = UIImage(named: "Edit-25")
        self.addSubview(imageView)
        
        let nameLabel = UILabel(frame: CGRectMake(10,130,130,20))
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 15)
        nameLabel.text = "Test Name"
        self.addSubview(nameLabel)
        
        let timeLabel = UILabel(frame: CGRectMake(140, 130, 50, 20))
        timeLabel.textAlignment = NSTextAlignment.Left
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.font = UIFont(name: timeLabel.font.fontName, size: 11)
        timeLabel.text = "3d ago"
        self.addSubview(timeLabel)

        let messageLabel = UILabel(frame: CGRectMake(10, 150, 180, 40))
        messageLabel.textAlignment = NSTextAlignment.Left
        messageLabel.font = UIFont(name: messageLabel.font.fontName, size: 11)
        messageLabel.numberOfLines = 0
        messageLabel.text = "This is a sweet test message telling you what the dillio is in this area.  So much cool stuff is happening!"
        self.addSubview(messageLabel)
        
    }
    
    
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        
        let isInsideView = pointInside(viewPoint, withEvent: event)
        
        let view = super.hitTest(viewPoint, withEvent: event)
        
        return view
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGRectContainsPoint(bounds, point)
    }
}
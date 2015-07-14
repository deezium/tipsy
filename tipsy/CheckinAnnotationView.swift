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
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation, reuseIdentifier: String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let checkinAnnotation = self.annotation as! CheckinAnnotation
//        image = UIImage(named: "Edit-25")
//        if checkinAnnotation.type == .CheckinTwitter {
//            image = UIImage(named: "Edit-25")
//        }
//        switch (checkinAnnotation.type) {
//        case .CheckinTwitter:
//            image = UIImage(named: "DClinkedin")
//        default:
//            image = UIImage(named: "Edit-25")
//        }
        
    }
}
//
//  CheckinAnnotation.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/1/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum CheckinType: Int {
    case CheckinDefault = 0
    case CheckinTwitter
}

class CheckinAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    //var image: UIImage
    var type: CheckinType
    var posterImage: UIImage
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: CheckinType, posterImage: UIImage) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
      //  self.image = image
        self.type = type
        self.posterImage = posterImage
    }
}

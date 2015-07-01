//
//  Checkin.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/29/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import SQLite

class Checkin {
    let message: String
    let latitude: Float
    let longitude: Float
    
    init(message: String, latitude: Float, longitude: Float) {
        self.message = message
        self.latitude = latitude
        self.longitude = longitude
    }
}
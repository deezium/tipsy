//
//  FeedbackViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/28/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import Amplitude_iOS

class FeedbackViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        Amplitude.instance().logEvent("feedbackViewed")
        
    }
    
}
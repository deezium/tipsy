//
//  TabBarController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/7/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        print("tabbar view loaded")
     
    }
    
    

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {

        if let newViewController = viewController as? UINavigationController {
            newViewController.popToRootViewControllerAnimated(false)
            
        }
    }
}
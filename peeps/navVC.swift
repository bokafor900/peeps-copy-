//
//  navVC.swift
//  peeps
//
//  Created by Bryan Okafor on 3/15/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit

class navVC: UINavigationController {

    // defaul function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // color of title at the top
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        // color of button in navigation controller
        self.navigationBar.tintColor = .whiteColor()
        
        // color of background of navigation controller
        self.navigationBar.barTintColor = UIColor(red: 215.0 / 255.0, green: 129.0 / 255.0, blue: 20.0 / 255.0, alpha: 1)
        
        // unable tanslucent
        self.navigationBar.translucent = false
 
    }
    
    // white status bar function
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


}

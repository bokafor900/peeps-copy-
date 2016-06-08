//
//  resetPasswordVC.swift
//  peeps
//
//  Created by Bryan Okafor on 2/18/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

class resetPasswordVC: UIViewController {
    
    // Textfields
    @IBOutlet weak var emailTxt: UITextField!
    
    // Buttons
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alignment
        emailTxt.frame = CGRectMake(10, 120, self.view.frame.size.width - 20, 30)
        resetBtn.frame = CGRectMake(20, emailTxt.frame.origin.y + 50, self.view.frame.size.width / 4, 30)
        cancelBtn.frame = CGRectMake(self.view.frame.size.width - self.view.frame.size.width / 4 - 20, resetBtn.frame.origin.y, self.view.frame.size.width / 4, 30)
        
        // background
        let bg = UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
    }
    
    // click reset button
    @IBAction func resetBtnClick(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if emailTxt.text!.isEmpty {
            
            // show alert message
            let alert = UIAlertController(title: "Email Field", message: "is empty", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // request for reseting password
        PFUser.requestPasswordResetForEmailInBackground(emailTxt.text!) { (success:Bool, error:NSError?) -> Void in
            if success{
                
                //show alert message
                let alert = UIAlertController(title: "Email for reseting password", message: "has been sent to texted email", preferredStyle: UIAlertControllerStyle.Alert)
                
                // if pressed OK call self.dismiss.. function
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    // click to cancel
    @IBAction func cancelBtnClick(sender: AnyObject) {
        
        // hide keyboard when cancel is pressed
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    
}

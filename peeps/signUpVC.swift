//
//  signUpVC.swift
//  peeps
//
//  Created by Bryan Okafor on 2/18/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

class signUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // profile image
    @IBOutlet weak var profileImg: UIImageView!
    
    // Textfields
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var employerTxt: UITextField!
    @IBOutlet weak var positionTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    
    // buttons
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    // scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    
    // reset default size
    var scrollViewHeight : CGFloat = 0
    
    // keyboard frame size
    var keyboard = CGRect()
    
    // Default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // scrollview frame size
        scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        // check notifications if keyboard is showing or not
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        
        // declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: "hideKeyboardTap:")
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // round profile image
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        // declare select image tap
        let profileTap = UITapGestureRecognizer(target: self, action: "loadImg:")
        profileTap.numberOfTapsRequired = 1
        profileImg.userInteractionEnabled = true
        profileImg.addGestureRecognizer(profileTap)
        
        // alignment
        profileImg.frame = CGRectMake(self.view.frame.width / 2 - 40, 40, 80, 80)
        usernameTxt.frame = CGRectMake(10, profileImg.frame.origin.y + 90, self.view.frame.size.width - 20, 30)
        fullnameTxt.frame = CGRectMake(10, usernameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        employerTxt.frame = CGRectMake(10, fullnameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        positionTxt.frame = CGRectMake(10, employerTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        emailTxt.frame = CGRectMake(10, positionTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        passwordTxt.frame = CGRectMake(10, emailTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        repeatPasswordTxt.frame = CGRectMake(10, passwordTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 30)
        
        signUpBtn.frame = CGRectMake(20, repeatPasswordTxt.frame.origin.y + 50, self.view.frame.size.width / 4, 30)
        cancelBtn.frame = CGRectMake(self.view.frame.size.width - self.view.frame.size.width / 4 - 20, signUpBtn.frame.origin.y, self.view.frame.size.width / 4, 30)
        
        // background
        let bg = UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
    }
    
    // call picker to slect image
    func loadImg(recongnizer:UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // connect selected image to our image view
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        profileImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // hide keyboard if tapped
    func hideKeyboardTap(recognizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // show keyboard func
    func showKeyboard(notification:NSNotification){
        
        // define keyboard size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        // move up UI
        UIView.animateWithDuration(0.4) { () -> Void in
            
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
        }
    }
    
    // hide keyboard func
    func hideKeyboard(notification:NSNotification) {
        
        // move down UI
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }
    

    // click and sign up
    @IBAction func signUpBtnClick(sender: AnyObject) {
        print("sign up pressed")
        
        // dismiss keyboard
        self.view.endEditing(true)
        
        // if fields are empty
        if (usernameTxt.text!.isEmpty || fullnameTxt.text!.isEmpty || employerTxt.text!.isEmpty || positionTxt.text!.isEmpty || emailTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPasswordTxt.text!.isEmpty) {
            
            // alert message
            let alert = UIAlertController(title: "PLEASE", message: "fill all fields", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
            
        }
        
        // if different passwords
        if passwordTxt.text != repeatPasswordTxt.text {
            
            // alert message
            let alert = UIAlertController(title: "PASSWORD", message: "do not match", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        // send data to server to related collums
        let user = PFUser()
        user.username = usernameTxt.text
        user["fullname"] = fullnameTxt.text
        user["employer"] = employerTxt.text
        user["position"] = positionTxt.text
        user.email = emailTxt.text?.lowercaseString
        user.password = passwordTxt.text
        // in Edit Profile its going to be assigned
        user["tel"] = ""
        user["gender"] = ""
        
        // convert our image for sending to the server
        let profileData = UIImageJPEGRepresentation(profileImg.image!, 0.5)
        let profileFile = PFFile(name: "profile.jpg", data: profileData!)
        user["profile"] = profileFile
        
        // save in data server
        user.signUpInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if success {
                print("registered")
                
                // remember loged user
                NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // call login function from appdelegate.swift class
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.login()
                
            }else {
                
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }

        
        
    }
    
    // click and cancel
    @IBAction func cancelBtnClick(sender: AnyObject) {
        
        // hide keyboard when cancel is pressed
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

 

}

//
//  editVC.swift
//  peeps
//
//  Created by Bryan Okafor on 3/8/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

class editVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // UI objects
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var employerTxt: UITextField!
    @IBOutlet weak var positionTxt: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    
    // pickerView and pickerData
    var genderPicker : UIPickerView!
    let genders = ["male","female"]
    
    // value to hold keyboard frame size
    var keyboard = CGRect()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create picker
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackgroundColor()
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)

        // tap to chose image
        let profileTap = UITapGestureRecognizer(target: self, action: "loadImg:")
        profileTap.numberOfTapsRequired = 1
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(profileTap)
        
        // call alignment func
        alignment()
        
        // call information func
        information()
    }
    
    // func to hide keyboard
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // define keyboard framesize
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.contentSize.height = self.view.frame.size.height + self.keyboard.height / 2
        }
    }
    
    // func when keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        
        // move down with animation
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.contentSize.height = 0
        }
    }
    
    // func to call picker UIImagePickerController
    func loadImg (recognizer : UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // method to finalize action it with Image picker view controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        profileImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // alignment func
    func alignment() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        scrollView.frame = CGRectMake(0, 0, width, height)
        
        profileImage.frame = CGRectMake(width - 68 - 10, 15, 68, 68)
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        fullnameTxt.frame = CGRectMake(10, profileImage.frame.origin.y, width - profileImage.frame.size.width - 30, 30)
        usernameTxt.frame = CGRectMake(10, fullnameTxt.frame.origin.y + 40, width - profileImage.frame.size.width - 30, 30)
        employerTxt.frame = CGRectMake(10, usernameTxt.frame.origin.y + 40, width - 20, 30)
        
        positionTxt.frame = CGRectMake(10, employerTxt.frame.origin.y + 40, width - 20, 60)
        positionTxt.layer.borderWidth = 1
        positionTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
        positionTxt.layer.cornerRadius = positionTxt.frame.size.width / 50
        positionTxt.clipsToBounds = true
        
        emailTxt.frame = CGRectMake(10, positionTxt.frame.origin.y + 100, width - 20, 30)
        telTxt.frame = CGRectMake(10, emailTxt.frame.origin.y + 40, width - 20, 30)
        genderTxt.frame = CGRectMake(10, telTxt.frame.origin.y + 40, width - 20, 30)
        
        titleLabel.frame = CGRectMake(15, emailTxt.frame.origin.y - 30, width - 20, 30)
        
    }
    
    // user information func
    func information() {
        
        let profile = PFUser.currentUser()?.objectForKey("profile") as! PFFile
        profile.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            self.profileImage.image = UIImage(data: data!)
        }
        
        // recieve text info
        usernameTxt.text = PFUser.currentUser()?.username
        fullnameTxt.text = PFUser.currentUser()?.objectForKey("fullname") as? String
        employerTxt.text = PFUser.currentUser()?.objectForKey("employer") as? String
        positionTxt.text = PFUser.currentUser()?.objectForKey("position") as? String
        
        emailTxt.text = PFUser.currentUser()?.email
        telTxt.text = PFUser.currentUser()?.objectForKey("tel") as? String
        genderTxt.text = PFUser.currentUser()?.objectForKey("gender") as? String
        
    }
    
    func validateEmail (email : String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.rangeOfString(regex, options: .RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
    }
    
    // regex restriction for web textfield
    /*func validateWeb (web : String) -> Bool {
        let regex = "www.+[A-Z0-9a-z._%+-]+.[A-Za-z]{2}"
        let range = web.rangeOfString(regex, options: .RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
    }
    */
    
    // alert message for function
    func alert (error: String, message : String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // cancel click button
    @IBAction func cancelClicked(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // click save button
    @IBAction func saveClicked(sender: AnyObject) {
        // if incorrect email
        if !validateEmail(emailTxt.text!){
            alert("Incorrect Email", message: "please provide correct email address")
            return
        }
        // if incorrect webtext
        /*if !validateWeb(webTxt.text!) {
            alert("Incorrect web link", message: "please provide correct web link")
            return
        }*/
        
        // save filled in information
        let user = PFUser.currentUser()!
        user.username = usernameTxt.text?.lowercaseString
        user.email = emailTxt.text?.lowercaseString
        user["fullname"] = fullnameTxt.text?.lowercaseString
        user["employer"] = employerTxt.text?.lowercaseString
        user["position"] = positionTxt.text
        
        // if "tel" is empty send empty data, else enter data
        if telTxt.text!.isEmpty {
            user["tel"] = ""
        } else {
            user["tel"] = telTxt.text
        }
        
        // if "gender" is empty, send empty data, else enter data
        if genderTxt.text!.isEmpty {
            user["gender"] = ""
        } else {
            user["gender"] = genderTxt.text
        }
        
        // send profile picture
        let profileData = UIImageJPEGRepresentation(profileImage.image!, 0.5)
        let profileFile = PFFile(name: "profile.jpg", data: profileData!)
        user["profile"] = profileFile
        
        // send filled information to server
        user.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
            if success{
                
                // hide keyboard
                self.view.endEditing(true)
                
                // dismiss editVC
                self.dismissViewControllerAnimated(true, completion: nil)
                
                NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
    // PICKER VIEW METHOD
    // picker number on component
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // picker text number
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    //picker text config
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }

    // picker did selected some value from it
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }

}

//
//  uploadVC.swift
//  peeps
//
//  Created by Bryan Okafor on 3/9/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // user interface objects
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    // default function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable publish btn
        publishBtn.enabled = false
        publishBtn.backgroundColor = .lightGrayColor()
        
        // hide remove button
        removeBtn.hidden = true
        
        // standard UI containt
        picImg.image = UIImage(named: "pbg.jpg")
        
        // hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: "hideKeyboardTap")
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // select image tap
        let picTap = UITapGestureRecognizer(target: self, action: "selectImg")
        picTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(picTap)
        
 
    }
    
    // preload func
    override func viewWillAppear(animated: Bool) {
        // call alignment function
        alignment()
    }
    
    // hide keyboard function
    func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    // func to call pickerViewcontroller
    func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // enable publish button
        publishBtn.enabled = true
        publishBtn.backgroundColor = UIColor(red: 245.0/255.0, green: 166.0/255.0, blue: 35.0/255.0, alpha: 1)
        
        // unhide remove button
        removeBtn.hidden = false
        
        // implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: "zoomImg")
        zoomTap.numberOfTapsRequired = 1
        picImg.userInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    // zooming in and out function
    func zoomImg() {
        
        // define frame of zoomed image
        let zoomed = CGRectMake(0, self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, self.view.frame.size.width, self.view.frame.size.width)
        
        // frame of unzoomed (small) image
        let unzoomed = CGRectMake(15, 15, self.view.frame.size.width / 4.5, self.view.frame.size.width / 4.5)
        
        // if picture is unzoomed, zoom it
        if picImg.frame == unzoomed {
            
            // with aninimation
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                // resize image frame
                self.picImg.frame = zoomed
                
                // hide objects from background
                self.view.backgroundColor = .blackColor()
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
        // to unzoom
        } else {
            
           // with animation
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                //resize image frame
                self.picImg.frame = unzoomed
                
                // unhide objects from background
                self.view.backgroundColor = .whiteColor()
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
            })
        }
            
        
    }
    

    // aligment
    func alignment() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        picImg.frame = CGRectMake(15, 15, width / 4.5, width / 4.5)
        titleTxt.frame = CGRectMake(picImg.frame.size.width + 25, picImg.frame.origin.y, width - titleTxt.frame.origin.x - 15, picImg.frame.size.height)
        publishBtn.frame = CGRectMake(0, height / 1.09, width, width / 8)
        removeBtn.frame = CGRectMake(picImg.frame.origin.x, picImg.frame.origin.y + picImg.frame.size.height, picImg.frame.size.width, 20)
        
    }
    
    // clicked published button
    @IBAction func publishBtnClicked(sender: AnyObject) {
        
        // dismiss keyboard
        self.view.endEditing(true)
        
        //send data to server to "posts" class in Parse
       let object = PFObject(className: "posts")
        object["username"] = PFUser.currentUser()!.username
        object["profile"] = PFUser.currentUser()!.valueForKey("profile") as! PFFile
        
        let uuid = NSUUID().UUIDString
        object["uuid"] = "\(PFUser.currentUser()!.username) \(uuid)"
        
        if titleTxt.text.isEmpty {
            object["title"] = ""
        } else {
            object["title"] = titleTxt.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        // Send pic to server after converting file
        let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let imageFile = PFFile(name: "post.jpg", data:  imageData!)
        object["pic"] = imageFile
        
        // Send #hashtag to server
        let words: [String] = titleTxt.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // define taged word
        for var word in words {
            
            // save #hashtag in server
            if word.hasPrefix("#") {
                
                // cut symbol
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = uuid
                hashtagObj["by"] = PFUser.currentUser()?.username
                hashtagObj["hashtag"] = word.lowercaseString
                hashtagObj["comment"] = titleTxt.text
                hashtagObj.saveInBackgroundWithBlock ({ (success:Bool, error:NSError?) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        // finally save information
        object.saveInBackgroundWithBlock ({ (success:Bool, error:NSError?) -> Void in
            if error == nil {
                
                // send notification that picture is uploaded
                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                
                // switch to another ViewController at 0 index of tabbar
                self.tabBarController!.selectedIndex = 0
                
                // reset everything
                self.viewDidLoad()
                self.titleTxt.text = ""
            }
        })
        
        
    }
    // clicked removed button
    @IBAction func removeBtnClicked(sender: AnyObject) {
        self.viewDidLoad()
    }

}

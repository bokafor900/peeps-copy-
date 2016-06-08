//
//  headerView.swift
//  peeps
//
//  Created by Bryan Okafor on 2/20/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

class headerView: UICollectionReusableView {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var fullnameLable: UILabel!
    @IBOutlet weak var employerTxt: UITextView!
    @IBOutlet weak var positionLabel: UILabel!



    
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var peepers: UILabel!
    @IBOutlet weak var peeps: UILabel!
    
    @IBOutlet weak var postsTitle: UILabel!
    @IBOutlet weak var peepersTitle: UILabel!
    @IBOutlet weak var peepsTitle: UILabel!

    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // alignment
        let width = UIScreen.mainScreen().bounds.width
        
        profileImg.frame = CGRectMake(width / 16, width / 16, width / 4, width / 4)
        
        posts.frame = CGRectMake(width / 2.5, profileImg.frame.origin.y, 50, 30)
        peepers.frame = CGRectMake(width / 1.7, profileImg.frame.origin.y, 50, 30)
        peeps.frame = CGRectMake(width / 1.25, profileImg.frame.origin.y, 50, 30)
        
        postsTitle.center = CGPointMake(posts.center.x, posts.center.y + 20)
        peepersTitle.center = CGPointMake(peepers.center.x, peepers.center.y + 20)
        peepsTitle.center = CGPointMake(peeps.center.x, peeps.center.y + 20)
        
        button.frame = CGRectMake(postsTitle.frame.origin.x, postsTitle.center.y + 20, width - postsTitle.frame.origin.x - 10, 30)
        button.layer.cornerRadius = button.frame.size.width / 50
        
        fullnameLable.frame = CGRectMake(profileImg.frame.origin.x, profileImg.frame.origin.y + profileImg.frame.size.height, width - 30, 30)
        employerTxt.frame = CGRectMake(profileImg.frame.origin.x - 5, fullnameLable.frame.origin.y + 15, width - 30, 30)
        positionLabel.frame = CGRectMake(profileImg.frame.origin.x, employerTxt.frame.origin.y + 30, width - 30, 30)
        
        // round ava
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
    }

    // clicked link button from guest view controller
    @IBAction func linkBtnClicked(sender: AnyObject) {
        
        let title = button.titleForState(.Normal)
        
        // to link
        if title == "LINK" {
            let object = PFObject(className: "peeps")
            object["peepers"] = PFUser.currentUser()?.username
            object["peeps"] = guestname.last!
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.button.setTitle("LINKING", forState: UIControlState.Normal)
                    self.button.backgroundColor = .orangeColor()
                    
                    // send peep notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.currentUser()?.username
                    newsObj["profile"] = PFUser.currentUser()?.objectForKey("profile") as! PFFile
                    newsObj["to"] = guestname.last
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "peeps"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                    
                } else {
                    print(error?.localizedDescription)
                }
                
            })
            // unlink
        } else {
            let query = PFQuery(className: "peeps")
            query.whereKey("peepers", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("peeps", equalTo: guestname.last!)
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success {
                                self.button.setTitle("LINK", forState: UIControlState.Normal)
                                self.button.backgroundColor = .lightGrayColor()
                                
                                // Delete peeps notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.currentUser()!.username!)
                                newsQuery.whereKey("to", equalTo: guestname.last!)
                                newsQuery.whereKey("type", equalTo: "peeps")
                                newsQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                                
                            } else {
                                print(error?.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription)
                    
                }
            })
        }
    }
        
    
    
    
}

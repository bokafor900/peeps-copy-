//
//  postCell.swift
//  peeps
//
//  Created by Bryan Okafor on 3/14/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

class postCell: UITableViewCell {
    // header objects
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // picture
    @IBOutlet weak var picImage: UIImageView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!

    // labels
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var titleLabel: KILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    
    // default function
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // clear button title color
        likeBtn.setTitleColor(UIColor.clearColor(), forState:  .Normal)
        
        // double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: "likeTap")
        likeTap.numberOfTapsRequired = 2
        picImage.userInteractionEnabled = true
        picImage.addGestureRecognizer(likeTap)
        
        
        // alignment
        let width = UIScreen.mainScreen().bounds.width
        
        // allow constraints
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        picImage.translatesAutoresizingMaskIntoConstraints = false
        
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        commentBtn.translatesAutoresizingMaskIntoConstraints = false
        moreBtn.translatesAutoresizingMaskIntoConstraints = false
        
        likeLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        uuidLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let pictureWidth = width - 20
        
        // constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[profile(30)]-10-[pic(\(pictureWidth))]-5-[like(30)]", options: [], metrics: nil, views: ["profile":profileImage, "pic":picImage, "like":likeBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[username]", options: [], metrics: nil, views: ["username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pic]-5-[comment(30)]", options: [], metrics: nil, views: ["pic":picImage, "comment":commentBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[date]", options: [], metrics: nil, views: ["date":dateLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[like]-5-[title]-5-|", options: [], metrics: nil, views: ["like":likeBtn, "title":titleLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pic]-5-[more(30)]", options: [], metrics: nil, views: ["pic":picImage, "more":moreBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pic]-10-[likes]", options: [], metrics: nil, views: ["pic":picImage, "likes":likeLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[profile(30)]-10-[username]|", options: [], metrics: nil, views: ["profile":profileImage, "username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[pic]-10-|", options: [], metrics: nil, views: ["pic":picImage]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[like(30)]-10-[likes]-20-[comment(30)]", options: [], metrics: nil, views: ["like":likeBtn, "likes":likeLabel, "comment":commentBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[more(30)]-15-|", options: [], metrics: nil, views: ["more":moreBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[title]-15-|", options: [], metrics: nil, views: ["title":titleLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[date]-10-|", options: [], metrics: nil, views: ["date":dateLabel]))
        
        // round profile puic
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        

    }
    
    // double tap to like
    func likeTap() {
        
        // create large like grey heart
        let likePic = UIImageView(image: UIImage(named: "unlike.png"))
        likePic.frame.size.width = picImage.frame.size.width / 1.5
        likePic.frame.size.height = picImage.frame.size.width / 1.5
        likePic.center = picImage.center
        likePic.alpha = 0.8
        self.addSubview(likePic)
        
        // hide likePic with animation and transform to be smaller
        UIView.animateWithDuration(0.4) { () -> Void in
            likePic.alpha = 0
            likePic.transform = CGAffineTransformMakeScale(0.1, 0.1)
        }
        
        // declare title of button
        let title = likeBtn.titleForState(.Normal)
        
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.currentUser()?.username
            object["to"] = uuidLabel.text
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    print("liked")
                    self.likeBtn.setTitle("like", forState: .Normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
                    
                    // send notification if we liked to refresh TableView
                    NSNotificationCenter.defaultCenter().postNotificationName("liked", object: nil)
                    
                    // send notification as like
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.currentUser()?.username
                    newsObj["profile"] = PFUser.currentUser()?.objectForKey("profile") as! PFFile
                    newsObj["to"] = self.usernameBtn.titleLabel!.text
                    newsObj["owner"] = self.usernameBtn.titleLabel!.text
                    newsObj["uuid"] = self.uuidLabel.text
                    newsObj["type"] = "like"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                }
            })
            
            
        }
    }

    // click like button
    @IBAction func likeBtnClicked(sender: AnyObject) {
        
        // declare title of button
        let title = sender.titleForState(.Normal)
        
        // to like
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.currentUser()?.username
            object["to"] = uuidLabel.text
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    print("liked")
                    self.likeBtn.setTitle("like", forState: .Normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
                    
                    // send notification if we liked to refresh TableView
                    NSNotificationCenter.defaultCenter().postNotificationName("liked", object: nil)
                    
                    // send notification as like
                    if self.usernameBtn.titleLabel?.text != PFUser.currentUser()?.username {
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.currentUser()?.username
                        newsObj["profile"] = PFUser.currentUser()?.objectForKey("profile") as! PFFile
                        newsObj["to"] = self.usernameBtn.titleLabel!.text
                        newsObj["owner"] = self.usernameBtn.titleLabel!.text
                        newsObj["uuid"] = self.uuidLabel.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }
                }
        })
            
        // to dislike
        } else {
            
            // request existing like of current user to show post
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("to", equalTo: uuidLabel.text!)
            query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                // find objects = likes
                for object in objects! {
                    
                    // delete found likes
                    object.deleteInBackgroundWithBlock ({ (success:Bool, error:NSError?) -> Void in
                        if success {
                            print("disliked")
                            self.likeBtn.setTitle("unlike", forState: .Normal)
                            self.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), forState: .Normal)
                            
                            // send notification if we liked to refresh TableView
                            NSNotificationCenter.defaultCenter().postNotificationName("liked", object: nil)
                            
                            // Delete like notification
                            let newsQuery = PFQuery(className: "news")
                            newsQuery.whereKey("by", equalTo: PFUser.currentUser()!.username!)
                            newsQuery.whereKey("to", equalTo: self.usernameBtn.titleLabel!.text!)
                            newsQuery.whereKey("uuid", equalTo: self.uuidLabel.text!)
                            newsQuery.whereKey("type", equalTo: "like")
                            newsQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                }
                            })
                        }
                    })
                }
            })
        }
    }

}

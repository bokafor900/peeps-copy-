//
//  postVC.swift
//  peeps
//
//  Created by Bryan Okafor on 3/14/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

var postuuid = [String] ()

class postVC: UITableViewController {
    
    // arrays to hold server information
    var profileArray = [PFFile]()
    var usernameArray = [String]()
    var dateArray = [NSDate?]()
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var titleArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title label at the top
        self.navigationItem.title = "PHOTO"
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back:")
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "liked", object: nil)
        
        //dynamict cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        // find post
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.profileArray.removeAll(keepCapacity: false)
                self.usernameArray.removeAll(keepCapacity: false)
                self.dateArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                self.uuidArray.removeAll(keepCapacity: false)
                self.titleArray.removeAll(keepCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.profileArray.append(object.valueForKey("profile") as! PFFile)
                    self.usernameArray.append(object.valueForKey("username") as! String)
                    self.dateArray.append(object.createdAt)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.titleArray.append(object.valueForKey("title") as! String)
                }
                
                self.tableView.reloadData()
                
            }
            

        })


    }
    
    // refresh function
    func refresh() {
        self.tableView.reloadData()
    }

    // cell number
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! postCell
        
        // connect objects with our information from arrays
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], forState: UIControlState.Normal)
        cell.usernameBtn.sizeToFit()
        cell.uuidLabel.text = uuidArray[indexPath.row]
        cell.titleLabel.text = titleArray[indexPath.row]
        cell.titleLabel.sizeToFit()
        
        // place profile picture
        profileArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.profileImage.image = UIImage(data: data!)
        }
        
        // place post picture
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.picImage.image = UIImage(data: data!)
        }
        
        // calculate post date
        let from = dateArray[indexPath.row]
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from!, toDate:  now, options: [])
        
        // logic what to show: seconds, minutes, hours, days, or weeks
        if difference.second <= 0 {
            cell.dateLabel.text = "now"
        }
        if difference.second > 0 && difference.minute == 0 {
            cell.dateLabel.text = "\(difference.second)s."
        }
        if difference.minute > 0 && difference.hour == 0 {
            cell.dateLabel.text = "\(difference.minute)m."
        }
        if difference.hour > 0 && difference.day == 0 {
            cell.dateLabel.text = "\(difference.hour)h."
        }
        if difference.day > 0 && difference.weekOfMonth == 0 {
            cell.dateLabel.text = "\(difference.day)d."
        }
        if difference.weekOfMonth > 0 {
            cell.dateLabel.text = "\(difference.weekOfMonth)w."
        }
        
        // manipulate like button depending on did user like it or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.currentUser()!.username!)
        didLike.whereKey("to", equalTo: cell.uuidLabel.text!)
        didLike.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            
            // if not any likes are found, else found likes
            if count == 0 {
                cell.likeBtn.setTitle("unlike", forState: .Normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), forState: .Normal)
            } else {
                cell.likeBtn.setTitle("like", forState: .Normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
            }
        })
        
        // count total likes of shown post
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLabel.text!)
        countLikes.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            cell.likeLabel.text = "\(count)"
        })
        
        // assign index
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        // @mention is tapped
        cell.titleLabel.userHandleLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            if mention.lowercaseString == PFUser.currentUser()?.username {
                let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                guestname.append(mention.lowercaseString)
                let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
        }
        
        // #hashtag is tapped
        cell.titleLabel.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercaseString)
            let hashvc = self.storyboard?.instantiateViewControllerWithIdentifier("hashtagsVC") as! hashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
        }

        
        return cell
        
    }
    
    // clicked username button
    @IBAction func usernameBtnClick(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        // call cell to cal further cell data
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        // if user tap on himself go home else go guest
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
    
    // clicked comment button
    @IBAction func commentBtnClick(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        // send related data to global variables
        commentuuid.append(cell.uuidLabel.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        // go to comment present VC
        let comment = self.storyboard?.instantiateViewControllerWithIdentifier("commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
        
        
    }
    
    // click more button
    @IBAction func moreBtnClick(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        // call cell to call further cell date
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        let delete = UIAlertAction(title: "Delete", style: .Default) { (UIAlertAction) -> Void in
            
            // STEP 1. Delete row from tableView
            self.usernameArray.removeAtIndex(i.row)
            self.profileArray.removeAtIndex(i.row)
            self.dateArray.removeAtIndex(i.row)
            self.picArray.removeAtIndex(i.row)
            self.titleArray.removeAtIndex(i.row)
            self.uuidArray.removeAtIndex(i.row)
            
            // STEP 2. Delete post from server
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.uuidLabel.text!)
            postQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success {
                                
                                // send notification to rootViewController to update shown posts
                                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                                
                                // push back
                                self.navigationController?.popViewControllerAnimated(true)
                                
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription)
                }
            })
            
            // STEP 2. Delete likes of post from server
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
            likeQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
            
                    }
                }
            })
            
            //STEP 3. Delete Comments of post from server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
            commentQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            // STEP 4. Delete hashtags of post from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
            hashtagQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
        }
        
        // COMPLAIN ACTION
        let complain = UIAlertAction(title: "Complain", style: .Default) { (UIAlertAction) -> Void in
            
            // send complain to server
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.currentUser()?.username
            complainObj["to"] = cell.uuidLabel.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.alert("Complain has been made successfully", message: "Thank you! We Will consider your complaint")
                } else {
                    self.alert("ERROR", message: error!.localizedDescription)
                }
            })
        
        }
        
        // CANCEL Action
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        // create menu controller
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: .ActionSheet)
        
        // if post belongs to user, he can delete post, else he can't
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username {
            menu.addAction(delete)
            menu.addAction(cancel)
        } else {
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        // show menu
        self.presentViewController(menu, animated: true, completion: nil)
    }
    
    // alert Action
    func alert (error: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // go back functions
    func back(sender: UIBarButtonItem) {
        
        // push back
        self.navigationController?.popViewControllerAnimated(true)
        
        // clean post uuid from last hold
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
    }


}

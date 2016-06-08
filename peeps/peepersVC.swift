//
//  peepersVC.swift
//  peeps
//
//  Created by Bryan Okafor on 2/23/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse


var show = String()
var user = String()

class peepersVC: UITableViewController {
    
    // arrays to hold data receivced from server
    var usernameArray = [String]()
    var profileArray = [PFFile]()
    
    // array showing who do we peep or whose peepers
    var peepsArray = [String]()

    // default func
    override func viewDidLoad() {
        super.viewDidLoad()

        // title at the top
        self.navigationItem.title = show.uppercaseString
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back:")
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        // load peepers if tapped on peepers label
        if show == "peepers" {
            loadPeepers()
        }
        
        // load peepers if tapped on peepers label
        if show == "peeps" {
            loadPeeps()
        }

    }
    
    // loading peepers
    func loadPeeps() {
        
        // Step 1. Find in PEEPS class people that are your peeps
        // find the peepers of user
        let peepsQuery = PFQuery(className: "peeps")
        peepsQuery.whereKey("peeps", equalTo: user)
        peepsQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.peepsArray.removeAll(keepCapacity: false)
                
                // Step 2. Hold received data
                // find related objects depending on query settings
                for object in objects! {
                    self.peepsArray.append(object.valueForKey("peepers") as! String)
                }
                
                // Step 3. Find in USER class data users that are your peeps
                // find user's peeps
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.peepsArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.profileArray.removeAll(keepCapacity: false)
                        
                        // find related objects in User Class of Parse
                        for object in objects! {
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.profileArray.append(object.objectForKey("profile") as! PFFile)
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
            })
        
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    // loading peeps
    func loadPeepers() {
        
        // find the peeps of user
        let peepsQuery = PFQuery(className: "peeps")
        peepsQuery.whereKey("peepers", equalTo: user)
        peepsQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.peepsArray.removeAll(keepCapacity: false)
                
                // find related objects depending on query settings
                for object in objects! {
                    self.peepsArray.append(object.valueForKey("peeps") as! String)
                }
                
                // find user's peeped by user
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.peepsArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.profileArray.removeAll(keepCapacity: false)
                        
                        // find related objects in User Class of Parse
                        for object in objects! {
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.profileArray.append(object.objectForKey("profile") as! PFFile)
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
        
    




    // cell number
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return usernameArray.count
        
    }
    
    // cell height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
    
    
    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! peepersCell
        
        // Step 1.connect data from serv to objects
        cell.usernameLabel.text = usernameArray[indexPath.row]
        profileArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                cell.profileImg.image = UIImage(data: data!)
            }else {
                print(error!.localizedDescription)
            }
        }
        
        // Step 2.show do user peeping or do not
        let query = PFQuery(className: "peeps")
        query.whereKey("peepers", equalTo: PFUser.currentUser()!.username!)
        query.whereKey("peeps", equalTo: cell.usernameLabel.text!)
        query.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                if count == 0 {
                    cell.peepsBtn.setTitle("LINK", forState: UIControlState.Normal)
                    cell.peepsBtn.backgroundColor = .lightGrayColor()
                } else {
                    cell.peepsBtn.setTitle("LINKING", forState: UIControlState.Normal)
                    cell.peepsBtn.backgroundColor = .orangeColor()
                }
            }
        })
        
        // hide peeps button for current user
        if cell.usernameLabel.text == PFUser.currentUser()?.username {
            cell.peepsBtn.hidden = true
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // recall cell to call further cell's data
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! peepersCell
        
        // if tapped on himself, go home, else go guest
        if cell.usernameLabel.text! == PFUser.currentUser()!.username! {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameLabel.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    func back(sender : UITabBarItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }



}

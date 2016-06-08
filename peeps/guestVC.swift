//
//  guestVC.swift
//  peeps
//
//  Created by Bryan Okafor on 3/1/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

var guestname = [String]()


class guestVC: UICollectionViewController {
   
    // UI Object
    var refresher : UIRefreshControl!
    var page : Int = 12
    
    // arrays to hold data from server
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allow vertical scroll
        self.collectionView!.alwaysBounceVertical = true
        
        // background color
        self.collectionView?.backgroundColor = .whiteColor()
        
        // top title
        self.navigationItem.title = guestname.last?.uppercaseString
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back:")
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        // call load posts func
        loadPosts()

    }
    
    // back function
    func back(sender : UIBarButtonItem) {
        
        // push back
        self.navigationController?.popViewControllerAnimated(true)
        
        // clean guest username or default the last guest username from guest name = Array
        if !guestname.isEmpty {
            guestname.removeLast()
        }
    }
    
    // refresh function
    func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    // posts loading function
    func loadPosts() {
        
        // load posts
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestname.last!)
        query.limit = page
        query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                // find related objects
                for object in objects! {
                    
                    // hold found information in arrays
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    // load more while scolling down
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            self.loadMore()
        }
    }
    
    // paging
    func loadMore() {
        
        // if there is more objects
        if page <= picArray.count {
            
            // increase page size
            page = page + 12
            
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: guestname.last!)
            query.limit = page
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    // clean up
                    self.uuidArray.removeAll(keepCapacity: false)
                    self.picArray.removeAll(keepCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.uuidArray.append(object.valueForKey("uuid") as! String)
                        self.picArray.append(object.valueForKey("pic") as! PFFile)
                        
                    }
                    
                    print("loaded +\(self.page)")
                    self.collectionView?.reloadData()
                    
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    // cell number
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath
        indexPath: NSIndexPath) -> CGSize {
            let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
            return size
    }
    
    // cell config
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! pictureCell
        picArray[indexPath.row].getDataInBackgroundWithBlock ({ (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                cell.pictureImage.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        })
    
        return cell
        
    }
    
    // header config
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        // define header
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! headerView
        
        // STEP 1. Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestname.last!)
        infoQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // shown wrong user
                if objects!.isEmpty {
                    // call alert
                    let alert = UIAlertController(title: "\(guestname.last!.uppercaseString)", message: "is not existing", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                })
                alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                
                // find related to user information
                for object in objects! {
                    header.fullnameLable.text = (object.objectForKey("fullname") as? String)?.uppercaseString
                    header.positionLabel.text = object.objectForKey("position") as? String
                    header.positionLabel.sizeToFit()
                    header.employerTxt.text = object.objectForKey("employer") as? String
                    header.employerTxt.sizeToFit()
                    let profileFile : PFFile = (object.objectForKey("profile") as? PFFile)!
                    profileFile.getDataInBackgroundWithBlock ({ (data:NSData?, error:NSError?) -> Void in
                        header.profileImg.image = UIImage(data: data!)
                    })
                }
                
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // STEP 2. Show do current user follow guest or do not
        let peepsQuery = PFQuery(className: "peeps")
        peepsQuery.whereKey("peepers", equalTo: PFUser.currentUser()!.username!)
        peepsQuery.whereKey("peeps", equalTo: guestname.last!)
        peepsQuery.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                if count == 0 {
                    header.button.setTitle("LINK", forState: .Normal)
                    header.positionLabel.backgroundColor = .lightGrayColor()
                } else {
                    header.button.setTitle("LINKING", forState: UIControlState.Normal)
                    header.button.backgroundColor = .orangeColor()
                }
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // STEP 3. Count Statistics
        // count posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestname.last!)
        posts.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.posts.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        
        })
        
        // count peepers
        let peepers = PFQuery(className: "peeps")
        peepers.whereKey("peeper", equalTo: guestname.last!)
        peepers.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.peepers.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // count peeps
        let peeps = PFQuery(className: "peeps")
        peeps.whereKey("peeps", equalTo: guestname.last!)
        peeps.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.peeps.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // STEP 4. Implement tap guesters
        // tap to posts
        let postTap = UITapGestureRecognizer(target: self, action: "postTap")
        postTap.numberOfTapsRequired = 1
        header.posts.userInteractionEnabled = true
        header.posts.addGestureRecognizer(postTap)
        
        // tap to peepers label
        let peepersTap = UITapGestureRecognizer(target: self, action: "peepersTap")
        peepersTap.numberOfTapsRequired = 1
        header.peepers.userInteractionEnabled = true
        header.peepers.addGestureRecognizer(peepersTap)
        
        // tap to peeps label
        let peepsTap = UITapGestureRecognizer(target: self, action: "peepsTap")
        peepsTap.numberOfTapsRequired = 1
        header.peeps.userInteractionEnabled = true
        header.peeps.addGestureRecognizer(peepsTap)
        
        return header
        
    }
    
    // tapped posts label
    func postsTap() {
        
        if !picArray.isEmpty {
            let index = NSIndexPath(forItem: 3, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
        
    }
    
    // tapped peepers label
    func peepersTap() {
        user = guestname.last!
        show = "peepers"
        
        // define peepersVC
        let peepers = self.storyboard?.instantiateViewControllerWithIdentifier("peepersVC") as! peepersVC
        
        // navigate to it
        self.navigationController?.pushViewController(peepers, animated: true)
        
        
    }
    
    // tapped peeps label
    func peepsTap() {
        
        user = guestname.last!
        show = "peeps"
        
        // define peepersVC
        let peeps = self.storyboard?.instantiateViewControllerWithIdentifier("peepersVC") as! peepersVC
        
        // navigate to it
        self.navigationController?.pushViewController(peeps, animated: true)
    }
    
    // go post
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // send post uuid to "postuuid" varible
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to post vC
        let post = storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    

}
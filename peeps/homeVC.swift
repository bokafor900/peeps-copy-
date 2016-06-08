//
//  homeVC.swift
//  peeps
//
//  Created by Bryan Okafor on 2/20/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse



class homeVC: UICollectionViewController {

    // background color
    var refresher : UIRefreshControl!
    
    // title at the top
    var page : Int = 12
    
    // pull to refresh
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // always vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        // background color
        collectionView?.backgroundColor = .whiteColor()
        
        // title at the top
        self.navigationItem.title = PFUser.currentUser()?.username?.uppercaseString
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        // receive notification from editVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:", name: "reload", object: nil)
        

        
        // load posts func
        loadPosts()


    }
    
    // refreshing func
    func refresh() {
        
        // reload data information
        collectionView?.reloadData()
        
        // stop refresher animating
        refresher.endRefreshing()
    }
    
    // reloading func after recieve notification
    func reload(notification:NSNotification) {
        collectionView?.reloadData()
    }
    

    
    // load post func
    func loadPosts() {
        
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.limit = page
        query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                // find objects related to our request
                for object in objects! {
                    
                    // add found data to arrays (holders)
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                    
                }
                
                self.collectionView?.reloadData()
            }else {
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
            query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
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
    


    // cell numb
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
        
        // get picture from the picArray
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                cell.pictureImage.image = UIImage(data: data!)
            }
        }
        
        return cell
            
    }
    
    // header config
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        // define header
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! headerView
        
        // Step 1. Get user data
        // get users data with connections to collums of PFUser class
        header.fullnameLable.text = (PFUser.currentUser()?.objectForKey("fullname") as? String)?.uppercaseString
        header.employerTxt.text = PFUser.currentUser()?.objectForKey("employer") as? String
        header.employerTxt.sizeToFit()
        header.positionLabel.text = PFUser.currentUser()?.objectForKey("position") as? String
        header.positionLabel.sizeToFit()
        header.button.setTitle("edit profile", forState: UIControlState.Normal)
        let profileImgQuery = PFUser.currentUser()!.objectForKey("profile") as! PFFile
        profileImgQuery.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            header.profileImg.image = UIImage(data: data!)
        }
        header.button.setTitle("edit profile", forState: UIControlState.Normal)
        
        // Step.2 count statistics
        //count total posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        posts.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.posts.text = "\(count)"
                
            }
            })
       
        //count total peepers
        let peepers = PFQuery(className: "peeps")
        peepers.whereKey("peepers", equalTo: PFUser.currentUser()!.username!)
        peepers.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.peepers.text = "\(count)"
            }
        })
        
        //count total peeps
        let peeps = PFQuery(className: "peeps")
        peeps.whereKey("peeps", equalTo: PFUser.currentUser()!.username!)
        peeps.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.peeps.text = "\(count)"
            }
        })
        
        // Step 3. Implement tap guesters
        // tap posts
        let postsTap = UITapGestureRecognizer(target:self, action: "postsTap")
        postsTap.numberOfTapsRequired = 1
        header.posts.userInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        // tap peepers
        let peepersTap = UITapGestureRecognizer(target: self, action: "peepersTap")
        peepersTap.numberOfTouchesRequired = 1
        header.peepers.userInteractionEnabled = true
        header.peepers.addGestureRecognizer(peepersTap)
        
        // tap peeps
        let peepsTap = UITapGestureRecognizer(target: self, action: "peepsTap")
        peepsTap.numberOfTouchesRequired = 1
        header.peeps.userInteractionEnabled = true
        header.peeps.addGestureRecognizer(peepsTap)
        
        
        
       return header
    }
    
    // tapped posts label
    func postsTap() {
        
        if picArray.isEmpty {
            
            let index = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
        
    }
    
    // tapped peepers label
    func peepersTap() {
        
        user = PFUser.currentUser()!.username!
        show = "peepers"
        
        // make reference to peepersVC
        let peepers = self.storyboard?.instantiateViewControllerWithIdentifier("peepersVC") as! peepersVC
        // present it
        self.navigationController?.pushViewController(peepers, animated: true)
        
    }
    
    // tapped peeps label
    func peepsTap() {
        
        user = PFUser.currentUser()!.username!
        show = "peeps"
        
        // make reference to peepersVC
        let peepers = self.storyboard?.instantiateViewControllerWithIdentifier("peepersVC") as! peepersVC
        // present it
        self.navigationController?.pushViewController(peepers, animated: true)
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        
        PFUser.logOutInBackgroundWithBlock {(error:NSError?) -> Void in
            if error == nil {
                
                // remove logged in user from app memory
                NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let signin = self.storyboard?.instantiateViewControllerWithIdentifier("signInVC") as! signInVC
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = signin
            }
        }
        
        
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

//
//  hashtagsVC.swift
//  peeps
//
//  Created by Bryan Okafor on 3/28/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse


var hashtag = [String]()

class hashtagsVC: UICollectionViewController {
    
    // UI objects
    var refresher : UIRefreshControl!
    var page : Int = 24
    
    // arrays to hold data from server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var filterArray = [String]()
    

    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        // be able to pull down even if few post
        self.collectionView?.alwaysBounceVertical = true
        
        // title at the top
        self.navigationItem.title = "#" + "\(hashtag.last!.uppercaseString)"
        
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
        
        // call function load hashtag
        loadHashtags()
    }
    
    // back function
    func back(sender : UIBarButtonItem) {
        
        // push back
        self.navigationController?.popViewControllerAnimated(true)
        
        // clean guest username or default the last guest username from guest name = Array
        if !hashtag.isEmpty {
            hashtag.removeLast()
        }
    }
    
    // refreshing func
    func refresh() {
        loadHashtags()
    }
    
    // load hashtags function
    func loadHashtags(){
        
        // STEP 1. Find post related to hashtags
        let hashtagQuery = PFQuery(className: "hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
            
                // clean up
                self.filterArray.removeAll(keepCapacity: false)
            
                // store related posts in filterArray
                for object in objects! {
                self.filterArray.append(object.valueForKey("to") as! String)
                }
                
                // STEP 2. Find post that have uuid appended to filterArray
                let query = PFQuery(className: "posts")
                query.whereKey("uuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.picArray.removeAll(keepCapacity: false)
                        self.uuidArray.removeAll(keepCapacity: false)
                        
                        // fine related objects
                        for object in objects! {
                            self.picArray.append(object.valueForKey("pic") as! PFFile)
                            self.uuidArray.append(object.valueForKey("uuid") as! String)
                            
                        }
                        
                        // reload
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                        
                    } else {
                        print(error?.localizedDescription)
                    }
            })
        
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    // scroll down
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 3 {
            loadMore()
        }
    }
    
    // pagination
    func loadMore() {
        
        if page <= uuidArray.count {
            
            page = page + 15
            
            // STEP 1. Find post related to hashtags
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    // clean up
                    self.filterArray.removeAll(keepCapacity: false)
                    
                    // store related posts in filterArray
                    for object in objects! {
                        self.filterArray.append(object.valueForKey("to") as! String)
                    }
                    
                    // STEP 2. Find post that have uuid appended to filterArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("uuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addAscendingOrder("createdAt")
                    query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.picArray.removeAll(keepCapacity: false)
                            self.uuidArray.removeAll(keepCapacity: false)
                            
                            // fine related objects
                            for object in objects! {
                                self.picArray.append(object.valueForKey("pic") as! PFFile)
                                self.uuidArray.append(object.valueForKey("uuid") as! String)
                                
                            }
                            
                            // reload
                            self.collectionView?.reloadData()
                            
                        } else {
                            print(error?.localizedDescription)
                        }
                    })
                    
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
    
    // go post
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // send post uuid to "postuuid" varible
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to post vC
        let post = storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }



}

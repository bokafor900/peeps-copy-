//
//  usersVC.swift
//  peeps
//
//  Created by Bryan Okafor on 4/3/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

class usersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // declare search bar
    var searchBar = UISearchBar()
    
    // arrays to hold information from server
    var usernameArray = [String]()
    var profileArray = [PFFile]()
    
    // collectioView UI
    var collectionView : UICollectionView!
    
    // collectionView arrays to holde information from server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var page : Int = 24

    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // implement seach bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackgroundColor()
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        // call functions
        loadUsers()
        
        // call colectionView
        collectionViewLaunch()

    }
    
    // SEARCHING CODE
    // load users function
    func loadUsers() {
        
        let usersQuery = PFQuery(className: "_User")
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.usernameArray.removeAll(keepCapacity: false)
                self.profileArray.removeAll(keepCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.usernameArray.append(object.valueForKey("username") as! String)
                    self.profileArray.append(object.valueForKey("profile") as! PFFile)
                }
                
                // reload
                self.tableView.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    // search update
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // find by username
        let userQuery = PFQuery (className: "_User")
        userQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        userQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // if no objects are found according to entered text in username colmn, find by fullname
                if objects!.isEmpty {
                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + self.searchBar.text!)
                    fullnameQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepCapacity: false)
                            self.profileArray.removeAll(keepCapacity: false)
                            
                            // found related objects
                            for object in objects! {
                                self.usernameArray.append(object.valueForKey("username") as! String)
                                self.profileArray.append(object.valueForKey("profile") as! PFFile)
                            }
                            
                            // reload
                            self.tableView.reloadData()
                        }
                    })
                }
                
                // clean up
                self.usernameArray.removeAll(keepCapacity: false)
                self.profileArray.removeAll(keepCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.usernameArray.append(object.objectForKey("username") as! String)
                    self.profileArray.append(object.objectForKey("profile") as! PFFile)
                }
                
                // reload
                self.tableView.reloadData()
            }
        })
        
        return true
    }
    
    // tapped on the searchBar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        // hide collectionView when started search
        collectionView.hidden = true
        
        // show cancel button
        searchBar.showsCancelButton = true
    }
    
    // clicked cancel button
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        // unhide collectioView when uptapped cancel button
        collectionView.hidden = false
        
        // dismiss keyboard
        searchBar.resignFirstResponder()
        
        // hide search bar
        searchBar.showsCancelButton = false
        
        // reset text
        searchBar.text = ""
        
        // reset shown users
        loadUsers()
    }
    

    // TABLEVIEW CODE
    // cell number
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    // cell height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
        
    }
    
    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! peepersCell

        // hide link button
        cell.peepsBtn.hidden = true
        
        // comment cell's objects with received information from server
        cell.usernameLabel.text = usernameArray[indexPath.row]
        profileArray[indexPath.row].getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                cell.profileImg.image = UIImage(data: data!)
            }
        })

        return cell
    }
    

    // selected tableView cell = selected user
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // calling cell again to call cell data
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! peepersCell
        
        // if user tapped on his name go home, else go guest
        if cell.usernameLabel.text! == PFUser.currentUser()?.username {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameLabel.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }

    // COLLECTION VIEW CODE
    func collectionViewLaunch() {
        
        // layout of collectionView
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // item size
        layout.itemSize = CGSizeMake(self.view.frame.size.width / 3, self.view.frame.size.width / 3)
        
        // direcction of scrolling
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        // define frame of collectionView
        let frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - 20)
        
        // declare collectionView
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .whiteColor()
        self.view.addSubview(collectionView)
        
        // define cell for collectionView
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        
        // call function to load post
        loadPosts()
        
    }
    
    // call line spacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // cell inter spacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // cell number
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell config
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        // create picture imageView in cell to show loaded pictures
        let picImg = UIImageView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        cell.addSubview(picImg)
        
        // get loaded images from array
        picArray[indexPath.row].getDataInBackgroundWithBlock({ (data:NSData?, error: NSError?) -> Void in
            if error == nil {
                picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        })
        
        return cell
    }
    
    // cells are selected
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // take relevant unique id of post to load post in postVC
        postuuid.append(uuidArray[indexPath.row])
        
        // prevent postVC programmatically
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    // load posts
    func loadPosts() {
        let query = PFQuery(className: "posts")
        query.limit = page
        query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.picArray.removeAll(keepCapacity: false)
                self.uuidArray.removeAll(keepCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.picArray.append(object.objectForKey("pic") as! PFFile)
                    self.uuidArray.append(object.objectForKey("uuid") as! String)
                }
                
                // reload collectionView to present data
                self.collectionView.reloadData()

                
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    // scolled down
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // scroll down for paging
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            
        }
    }
    
    // pagination
    func loadMore() {
        
        // if more post are unloaded we want to load them
        if page <= picArray.count {
            
            // increase page size
            page = page + 24
            
            // load additional posts
            let query = PFQuery(className: "posts")
            query.limit = page
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    // clean up
                    self.picArray.removeAll(keepCapacity: false)
                    self.uuidArray.removeAll(keepCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.picArray.append(object.objectForKey("pic") as! PFFile)
                        self.uuidArray.append(object.objectForKey("uuid") as! String)
                    }
                    
                    // reload collectionView to present loaded images
                    self.collectionView.reloadData()
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
    }

}

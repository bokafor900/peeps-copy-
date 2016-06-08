//
//  peepersCell.swift
//  peeps
//
//  Created by Bryan Okafor on 2/23/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import Parse

class peepersCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var peepsBtn: UIButton!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // alignment
        let width = UIScreen.mainScreen().bounds.width
        
        profileImg.frame = CGRectMake(10, 10, width / 5.3, width / 5.3)
        usernameLabel.frame = CGRectMake(profileImg.frame.size.width + 20, 25, width / 3.2, 30)
        peepsBtn.frame = CGRectMake(width - width / 3.5 - 10, 30, width / 3.5, 30)

        // round profile pic
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
    }
    
    @IBAction func linkBtnClicked(sender: AnyObject) {
        
        let title = peepsBtn.titleForState(.Normal)
        
        if title == "LINK" {
            let object = PFObject(className: "peeps")
            object["peepers"] = PFUser.currentUser()?.username
            object["peeps"] = usernameLabel.text
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.peepsBtn.setTitle("LINKING", forState: UIControlState.Normal)
                    self.peepsBtn.backgroundColor = .orangeColor()
                } else {
                    print(error?.localizedDescription)
                }
                
                })
        } else {
            let query = PFQuery(className: "peeps")
            query.whereKey("peepers", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("peeps", equalTo: usernameLabel.text!)
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success {
                                self.peepsBtn.setTitle("LINK", forState: UIControlState.Normal)
                                self.peepsBtn.backgroundColor = .lightGrayColor()
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

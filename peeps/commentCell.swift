//
//  commentCell.swift
//  peeps
//
//  Created by Bryan Okafor on 3/17/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {

    // UI Object
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var commentLbl: KILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    // default function
    override func awakeFromNib() {
        super.awakeFromNib()
       
        // alignment
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        commentLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[username]-(-2)-[comment]-5-|", options: [], metrics: nil, views: ["username":usernameBtn, "comment":commentLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[date]", options: [], metrics: nil, views: ["date":dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[profile(40)]", options: [], metrics: nil, views: ["profile":profileImage]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[profile(40)]-13-[comment]-20-|", options: [], metrics: nil, views: ["profile":profileImage, "comment":commentLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[profile]-13-[username]", options: [], metrics: nil, views: ["profile":profileImage, "username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[date]-10-|", options: [], metrics: nil, views: ["date":dateLbl]))
        
        // round profile
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }


}

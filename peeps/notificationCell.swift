//
//  notificationCell.swift
//  peeps
//
//  Created by Bryan Okafor on 4/7/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit

class notificationCell: UITableViewCell {

    // UI objects
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    // default function
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // constraints
        profileImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        infoLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[profile(30)]-10-[username]-7-[info]-10-[date]", options: [], metrics: nil, views: ["profile":profileImg, "username":usernameBtn, "info":infoLbl, "date":dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[profile(30)]-10-|", options: [], metrics: nil, views: ["profile":profileImg]))
        
       self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[username(30)]", options: [], metrics: nil, views: ["username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[info(30)]", options: [], metrics: nil, views: ["info":infoLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[date(30)]", options: [], metrics: nil, views: ["date":dateLbl]))
        
        // round profile
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
    }


}

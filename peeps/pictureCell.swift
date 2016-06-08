//
//  pictureCell.swift
//  peeps
//
//  Created by Bryan Okafor on 2/20/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit

class pictureCell: UICollectionViewCell {
    
    @IBOutlet weak var pictureImage: UIImageView!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // alignment
        let width = UIScreen.mainScreen().bounds.width
        
        pictureImage.frame = CGRectMake(0, 0, width / 3, width / 3)
    }
}

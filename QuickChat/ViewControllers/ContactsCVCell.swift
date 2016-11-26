//
//  ContactsCVCell.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/26/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class ContactsCVCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let size = self.contentView.bounds.width
        self.profilePic.frame = CGRect.init(x: (size * 0.15), y: (size * 0.15), width: (size * 0.7), height: (size * 0.7))
        let radius = (self.profilePic.bounds.width / 2)
        self.profilePic.layer.cornerRadius = radius
        self.profilePic.clipsToBounds = true
        return layoutAttributes
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizesSubviews = true
    }
}

//
//  ConversationsTBCell.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/26/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class ConversationsTBCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let radius = self.profilePic.bounds.height / 2
        self.profilePic.layer.cornerRadius = radius
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderWidth = 2
        self.profilePic.layer.borderColor = GlobalVariables.purple.cgColor
    }

}

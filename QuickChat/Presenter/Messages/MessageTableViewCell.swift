//
//  MessageTableViewCell.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/24/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}


/*
 
 class SenderCell: UITableViewCell {
 
 @IBOutlet weak var profilePic: RoundedImageView!
 @IBOutlet weak var message: UITextView!
 @IBOutlet weak var messageBackground: UIImageView!
 
 func clearCellData()  {
 self.message.text = nil
 self.message.isHidden = false
 self.messageBackground.image = nil
 }
 
 override func awakeFromNib() {
 super.awakeFromNib()
 self.selectionStyle = .none
 self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
 self.messageBackground.layer.cornerRadius = 15
 self.messageBackground.clipsToBounds = true
 }
 }
 
 class ReceiverCell: UITableViewCell {
 
 @IBOutlet weak var message: UITextView!
 @IBOutlet weak var messageBackground: UIImageView!
 
 func clearCellData()  {
 self.message.text = nil
 self.message.isHidden = false
 self.messageBackground.image = nil
 }
 
 override func awakeFromNib() {
 super.awakeFromNib()
 self.selectionStyle = .none
 self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
 self.messageBackground.layer.cornerRadius = 15
 self.messageBackground.clipsToBounds = true
 }
 }
*/

//
//  Conversation.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/26/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import Foundation
import UIKit

class Conversation {
    
    let profilePic: UIImage
    let name: String
    var lastMessage: String
    var time: Date
    var isRead: Bool
    
    init(profilePic: UIImage, name: String, lastMessage: String, time: Date, isRead: Bool) {
        self.profilePic = profilePic
        self.name = name
        self.lastMessage = lastMessage
        self.time = time
        self.isRead = isRead
    }
}

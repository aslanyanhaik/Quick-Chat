//
//  Message.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/31/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import Foundation
import UIKit

class Message {
    
    let type: MessageType
    let content: Any
    let timestamp: Int
    var owner: MessageOwner
    
    init(type: MessageType, content: Any, timestamp: Int, owner: MessageOwner) {
        self.type = type
        self.content = content
        self.timestamp = timestamp
        self.owner = owner
    }
}


enum MessageType {
    case photo
    case text
    //case video
    //case location
}

enum MessageOwner {
    case sender
    case receiver
}

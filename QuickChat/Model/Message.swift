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
    let content: AnyObject?
    let timestamp: Int
    var read: Bool
    
    init(type: MessageType, content: AnyObject?, timestamp: Int, read: Bool) {
        self.type = type
        self.content = content
        self.timestamp = timestamp
        self.read = read
    }
}


enum MessageType {
    case photo
    case text
    case video
    case location
}

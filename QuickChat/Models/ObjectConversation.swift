//
//  ObjectConversation.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/21/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import Foundation

class ObjectConversation: Codable {
  
  var id = UUID().uuidString
  var userIDs = [String]()
  var lastMessage: String?
  var isRead = true
  
}

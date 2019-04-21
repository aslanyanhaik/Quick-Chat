//
//  ObjectMessage.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/21/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import UIKit

class ObjectMessage: Codable {
  
  var id = UUID().uuidString
  var message: String?
  var timestamp: Int
  var location: String?
  var ownerID: String?
  var image: UIImage?
  
}

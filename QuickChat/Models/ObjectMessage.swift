//
//  ObjectMessage.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/21/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import UIKit

class ObjectMessage: FireStorageCodable {
  
  var id = UUID().uuidString
  var message: String?
  var timestamp = Int(Date().timeIntervalSince1970)
  var location: String?
  var ownerID: String?
  var profilePicLink: String?
  var profilePic: UIImage?

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(message, forKey: .message)
    try container.encodeIfPresent(timestamp, forKey: .timestamp)
    try container.encodeIfPresent(location, forKey: .location)
    try container.encodeIfPresent(ownerID, forKey: .ownerID)
    try container.encodeIfPresent(profilePicLink, forKey: .profilePicLink)
  }
  
  init() {}
  
  public required convenience init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    timestamp = try container.decodeIfPresent(Int.self, forKey: .timestamp) ?? Int(Date().timeIntervalSince1970)
    location = try container.decodeIfPresent(String.self, forKey: .location)
    ownerID = try container.decodeIfPresent(String.self, forKey: .ownerID)
    profilePicLink = try container.decodeIfPresent(String.self, forKey: .profilePicLink)
  }
  
}

extension ObjectMessage {
  private enum CodingKeys: String, CodingKey {
    case id
    case message
    case timestamp
    case location
    case ownerID
    case profilePicLink
  }
}

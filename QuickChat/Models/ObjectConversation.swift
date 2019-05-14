//  MIT License

//  Copyright (c) 2019 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

class ObjectConversation: FireCodable {
  
  var id = UUID().uuidString
  var userIDs = [String]()
  var timestamp = Int(Date().timeIntervalSince1970)
  var lastMessage: String?
  var isRead = [String: Bool]()
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(userIDs, forKey: .userIDs)
    try container.encode(timestamp, forKey: .timestamp)
    try container.encodeIfPresent(lastMessage, forKey: .lastMessage)
    try container.encode(isRead, forKey: .isRead)
  }
  
  init() {}
  
  public required convenience init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    userIDs = try container.decode([String].self, forKey: .userIDs)
    timestamp = try container.decode(Int.self, forKey: .timestamp)
    lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
    isRead = try container.decode([String: Bool].self, forKey: .isRead)
  }
}

extension ObjectConversation {
  private enum CodingKeys: String, CodingKey {
    case id
    case userIDs
    case timestamp
    case lastMessage
    case isRead
  }
}

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

class ProfileManager {
  
  static let shared = ProfileManager()
  private var users = [ObjectUser]()
  
  func userData(id: String, _ completion: @escaping CompletionObject<ObjectUser?>) {
    if let user = users.filter({$0.id == id}).first {
      completion(user)
      return
    }
    let query = FirestoreService.DataQuery(key: "id", value: id, mode: .equal)
    FirestoreService().objects(ObjectUser.self, reference: .init(location: .users), parameter: query) {[weak self] results in
      guard let user = results.first else {
        completion(nil)
        return
      }
      self?.users.append(user)
      completion(user)
    }
  }
  
  private init() {}
}

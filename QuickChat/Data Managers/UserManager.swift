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

import FirebaseAuth

class UserManager {
  
  private let service = FirestoreService()
  
  func currentUserID() -> String? {
    return Auth.auth().currentUser?.uid
  }
  
  func currentUserData(_ completion: @escaping CompletionObject<ObjectUser?>) {
    guard let id = Auth.auth().currentUser?.uid else { completion(nil); return }
    let query = FirestoreService.DataQuery(key: "id", value: id, mode: .equal)
    service.objectWithListener(ObjectUser.self, parameter: query, reference: .init(location: .users), completion: { users in
      completion(users.first)
    })
  }
  
  func login(user: ObjectUser, completion: @escaping CompletionObject<FirestoreResponse>) {
    guard let email = user.email, let password = user.password else { completion(.failure); return }
    Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
      if error.isNone {
        completion(.success)
        return
      }
      completion(.failure)
    }
  }
  
  func register(user: ObjectUser, completion: @escaping CompletionObject<FirestoreResponse>) {
    guard let email = user.email, let password = user.password else { completion(.failure); return }
    Auth.auth().createUser(withEmail: email, password: password) {[weak self] (reponse, error) in
      guard error.isNone else { completion(.failure); return }
      user.id = reponse?.user.uid ?? UUID().uuidString
      self?.update(user: user, completion: { result in
        completion(result)
      })
    }
  }
  
  func update(user: ObjectUser, completion: @escaping CompletionObject<FirestoreResponse>) {
    FirestorageService().update(user, reference: .users) { response in
      switch response {
      case .failure: completion(.failure)
      case .success:
        FirestoreService().update(user, reference: .init(location: .users), completion: { result in
          completion(result)
        })
      }
    }
  }
  
  func contacts(_ completion: @escaping CompletionObject<[ObjectUser]>) {
    FirestoreService().objects(ObjectUser.self, reference: .init(location: .users)) { results in
      completion(results)
    }
  }
  
  func userData(for id: String, _ completion: @escaping CompletionObject<ObjectUser?>) {
    let query = FirestoreService.DataQuery(key: "id", value: id, mode: .equal)
    FirestoreService().objects(ObjectUser.self, reference: .init(location: .users), parameter: query) { users in
      completion(users.first)
    }
  }
  
  @discardableResult func logout() -> Bool {
    do {
      try Auth.auth().signOut()
      return true
    } catch {
      return false
    }
  }
}

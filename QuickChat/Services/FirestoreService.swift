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

import FirebaseFirestore

class FirestoreService {
  
  private var listener: ListenerRegistration?
  
  func objects<T>(_ object: T.Type, reference: FirestoreCollectionReference, parameter: (String, Any)? = nil, completion: @escaping CompletionArray<T>) where T: FireCodable {
    let ref = Firestore.firestore().collection(reference.rawValue)
    if let parameter = parameter {
      fetchDocuments(ref.whereField(parameter.0, isEqualTo: parameter.1)) {(results) in
        completion(results)
      }
    } else {
      fetchDocuments(ref) { (results) in
        completion(results)
      }
    }
  }
  
  func objects<T>(_ object: T.Type, reference: FirestoreCollectionReference, key: String, searchValue: String, completion: @escaping CompletionArray<T>) where T: FireCodable {
    let ref = Firestore.firestore().collection(reference.rawValue)
    fetchDocuments(ref.order(by: key).start(at: [searchValue]).end(before: [searchValue + "\u{f8ff}"])) {(results) in
      completion(results)
    }
  }
  
  func update<T>(_ object: T, reference: FirestoreCollectionReference, completion: @escaping FireResponse) where T: FireCodable {
    guard let data = try? FirestoreEncoder().encode(object) else { completion(.failure); return }
    let ref = Firestore.firestore().collection(reference.rawValue)
    ref.document(object.id).setData(data, merge: true) { (error) in
      guard let _ = error else { completion(.success); return }
      completion(.failure)
    }
  }
  
  func delete<T>(_ object: T, reference: FirestoreCollectionReference, completion: @escaping FireResponse) where T: FireCodable {
    let ref = Firestore.firestore().collection(reference.rawValue)
    ref.document(object.id).delete { (error) in
      guard let _ = error else { completion(.success); return }
      completion(.failure)
    }
  }
  
  func delete<T>(_ objects: T.Type, reference: FirestoreCollectionReference, parameter: (String, Any), completion: @escaping FireResponse) where T: FireCodable {
    Firestore.firestore().collection(reference.rawValue).whereField(parameter.0, isEqualTo: parameter.1).getDocuments { (snap, error) in
      guard error == nil else { completion(.failure); return }
      let batch = Firestore.firestore().collection(reference.rawValue).firestore.batch()
      snap?.documents.forEach({ (document) in
        batch.deleteDocument(document.reference)
      })
      batch.commit(completion: { (err) in
        guard err == nil else { completion(.failure); return }
        completion(.success)
      })
    }
  }
  
  func objectWithListener<T>(_ object: T.Type, parameter: (String, Any), reference: FirestoreCollectionReference, completion: @escaping CompletionArray<T>) where T: FireCodable {
    let ref = Firestore.firestore().collection(reference.rawValue).whereField(parameter.0, isEqualTo: parameter.1)
    listener = ref.addSnapshotListener({ (snapshot, _) in
      var objects = [T]()
      snapshot?.documents.forEach({ (document) in
        if let object = try? FirestoreDecoder().decode(T.self, from: document.data()) {
          objects.append(object)
        }
      })
      completion(objects)
    })
  }
  
  func stopObservers() {
    listener?.remove()
  }
  
  private func fetchDocuments<T>(_ ref: Query, completion: @escaping CompletionArray<T>) where T: FireCodable {
    ref.getDocuments { (snapshot, error) in
      var results = [T]()
      snapshot?.documents.forEach({ (document) in
        if let data = try? FirestoreDecoder().decode(T.self, from: document.data()) {
          results.append(data)
        }
      })
      completion(results)
    }
  }
}

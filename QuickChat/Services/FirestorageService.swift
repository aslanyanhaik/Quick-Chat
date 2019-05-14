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

import FirebaseStorage
import UIKit

class FirestorageService {
  
  func update<T>(_ object: T, reference: FirestoreCollectionReference, completion: @escaping CompletionObject<FirestoreResponse>) where T: FireStorageCodable {
    guard let imageData = object.profilePic?.scale(to: CGSize(width: 350, height: 350))?.jpegData(compressionQuality: 0.3) else { completion(.success); return }
    let ref = Storage.storage().reference().child(reference.rawValue).child(object.id).child(object.id + ".jpg")
    let uploadMetadata = StorageMetadata()
    uploadMetadata.contentType = "image/jpg"
    ref.putData(imageData, metadata: uploadMetadata) { (_, error) in
      guard error.isNone else { completion(.failure); return }
      ref.downloadURL(completion: { (url, err) in
        if let downloadURL = url?.absoluteString {
          object.profilePic = nil
          object.profilePicLink = downloadURL
          completion(.success)
          return
        }
        completion(.failure)
      })
    }
  }
}

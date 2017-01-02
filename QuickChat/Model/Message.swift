//
//  Message.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 12/18/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message {
    
    //MARK: Properties
    var owner: MessageOwner
    let type: MessageType
    let content: Any
    private var timeStamp: Int?
    private var toID: String?
    private var fromID: String?
    
    //MARK: Methods
    class func downloadAllMessages(forUserID: String, completion: @escaping (Message) -> Swift.Void) {
        if let currentUserID = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(currentUserID).child("conversations").child(forUserID).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    FIRDatabase.database().reference().child("conversations").child(location).observe(.childAdded, with: { (snap) in
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let type = receivedMessage["type"] as! String
                            switch type {
                            case "text":
                                let content = receivedMessage["content"] as! String
                                let fromID = receivedMessage["toID"] as! String
                                if fromID == currentUserID {
                                    let message = Message.init(type: .text, content: content, owner: .sender)
                                    completion(message)
                                } else {
                                    let message = Message.init(type: .text, content: content, owner: .receiver)
                                    completion(message)
                                }
                            default: break
                            }
                        }
                    })
                }
            })
        }
    }

    class func send(message: Message, toID: String, completion: @escaping (Bool) -> Swift.Void)  {
        if let currentUserID = FIRAuth.auth()?.currentUser?.uid {
            var values = [String: Any]()
            switch message.type {
            case .text:
                values = ["type": "text", "content": message.content, "fromID": currentUserID, "toID": toID, "timestamp": Int(Date().timeIntervalSince1970)]
            case .photo:
                print("missing implementation")
            case .location:
                print("missing implementation")
            case .video:
                print("missing implementation")
            }
           FIRDatabase.database().reference().child("users").child(currentUserID).child("conversations").child(toID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    FIRDatabase.database().reference().child("conversations").child(location).childByAutoId().setValue(values, withCompletionBlock: { (error, _) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    FIRDatabase.database().reference().child("conversations").childByAutoId().childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                        let data = ["location": reference.parent!.key]
                        FIRDatabase.database().reference().child("users").child(currentUserID).child("conversations").child(toID).updateChildValues(data)
                        FIRDatabase.database().reference().child("users").child(toID).child("conversations").child(currentUserID).updateChildValues(data)
                        completion(true)
                    })
                }
            })
        }
    }
    
    //MARK: Inits
    init(type: MessageType, content: Any, owner: MessageOwner) {
        self.type = type
        self.content = content
        self.owner = owner
    }
}


enum MessageType {
    case photo
    case text
    case video
    case location
}

enum MessageOwner {
    case sender
    case receiver
}

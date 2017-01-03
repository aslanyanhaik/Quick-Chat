//
//  Conversation.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 12/18/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Conversation {
    
    //MARK: Properties
    let profilePic: UIImage
    let name: String
    var lastMessage: String
    var isRead: Bool
    var time: Date
    private var iD: String?
    
    //MARK: Methods
    class func showConversations(forUserID: String, completion: @escaping (Conversation) -> Swift.Void) {
        FIRDatabase.database().reference().child("users").child(forUserID).child("conversations").observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                let fromID = snapshot.key
                let data = snapshot.value as! [String: String]
                let location = data["location"]!
                FIRDatabase.database().reference().child("users").child(fromID).child("credentials").observeSingleEvent(of: .value, with: { (snap) in
                    let receivedData = snap.value as! [String: String]
                    let picLink = receivedData["profilePicLink"]!
                    let profilPic = UIImage.downloadImagewith(link: picLink)
                    let name = receivedData["name"]!
                    let conversation = Conversation.init(profilePic: profilPic!, name: name, lastMessage: "some Message", time: Date(), isRead: true)
                    conversation.iD = fromID
                    completion(conversation)
                })
            }
        })
    }
    
    func currentConversationUser() -> User? {
        var user: User?
        FIRDatabase.database().reference().child("users").child(self.iD!).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as! [String: String]
            let name = data["name"]!
            let email = data["email"]!
            let id = snapshot.key
            let profilePicLink = UIImage.downloadImagewith(link: data["profilePicLink"]!)
            user = User.init(name: name, email: email, id: id, profilePic: profilePicLink!)
        })
        return user
    }
    
    //MARK: Inits
    init(profilePic: UIImage, name: String, lastMessage: String, time: Date, isRead: Bool) {
        self.profilePic = profilePic
        self.name = name
        self.lastMessage = lastMessage
        self.time = time
        self.isRead = isRead
    }
}

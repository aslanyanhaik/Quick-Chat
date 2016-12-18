//
//  GlobalVariables.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 9/12/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct GlobalVariables {
    static let blue = UIColor.rbg(r: 129, g: 144, b: 255)
    static let purple = UIColor.rbg(r: 161, g: 114, b: 255)
    static let users = FIRDatabase.database().reference().child("users")
    static let conversations = FIRDatabase.database().reference().child("conversations")
    static let storageUsers = FIRStorage.storage().reference().child("usersProfilePics")
}

enum ViewControllerType {
    case welcome
    case conversations
}

enum PhotoSource {
    case library
    case camera
}

enum ShowExtraView {
    case contacts
    case profile
    case preview
}

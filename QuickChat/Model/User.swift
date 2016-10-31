//
//  User.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/17/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import Foundation
import UIKit

class User {
    let name: String
    let email: String
    let profilePicLink: URL
    let profilePic: UIImage
    
    init(name: String, email: String, profilePicLink: URL, profilePic: UIImage) {
        self.name = name
        self.email = email
        self.profilePicLink = profilePicLink
        self.profilePic = profilePic
    }
}

//
//  DictionaryExtension.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/21/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import Foundation

extension Dictionary {
  
  var data: Data? {
    return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
  }
}

//
//  EncodableExtension.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/21/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import Foundation

extension Encodable {
  var values: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

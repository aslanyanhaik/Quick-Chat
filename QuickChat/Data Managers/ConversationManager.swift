//
//  ConversationManager.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/21/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import Foundation

class ConversationManager {
  
  let service = FirestoreService()
  
  func currentConversations(_ completion: @escaping CompletionObject<[ObjectConversation]>) {
    guard let userID = UserManager().currentUserID() else { return }
    let query = FirestoreService.DataQuery(key: "userIDs", value: userID, mode: .contains)
    service.objectWithListener(ObjectConversation.self, parameter: query, reference: .init(location: .conversations)) { results in
      completion(results)
    }
  }
  
  func create(_ conversation: ObjectConversation, _ completion: CompletionObject<FirestoreResponse>? = nil) {
    FirestoreService().update(conversation, reference: .init(location: .conversations)) { response in
      completion?(response)
    }
  }
}

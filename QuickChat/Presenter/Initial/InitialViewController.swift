//
//  InitialViewController.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/21/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    present(UIStoryboard.initial(storyboard: UserManager().currentUserID().isNone ? .auth : .conversations), animated: true, completion: nil)
  }
}

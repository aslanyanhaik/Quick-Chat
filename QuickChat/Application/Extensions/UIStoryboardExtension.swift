//
//  UIStoryboardExtensiomn.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/21/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import UIKit

extension UIStoryboard {
  
  class func controller<T: UIViewController>(storyboard: StoryboardEnum) -> T {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil).instantiateViewController(withIdentifier: T.className) as! T
  }
  
  class func initial<T: UIViewController>(storyboard: StoryboardEnum) -> T {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil).instantiateInitialViewController() as! T
  }
}

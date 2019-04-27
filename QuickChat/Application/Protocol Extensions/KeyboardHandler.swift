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

import UIKit

protocol KeyboardHandler {
  var tableView: UITableView! { get }
  var barBottomConstraint: NSLayoutConstraint! { get }
  var bottomInset: CGFloat { get }
}

extension KeyboardHandler where Self: UIViewController {
  func addKeyboardObservers() {
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) {[weak self] (notification) in
      self?.handleKeyboard(notification: notification)
    }
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) {[weak self] (notification) in
      self?.handleKeyboard(notification: notification)
    }
  }
  
  private func handleKeyboard(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
    tableView.setContentOffset(notification.name == UIResponder.keyboardWillHideNotification ? .zero : CGPoint(x: 0, y: keyboardFrame.height + bottomInset), animated: true)
    tableView.scrollIndicatorInsets.bottom = notification.name == UIResponder.keyboardWillHideNotification ? 0 : keyboardFrame.height + bottomInset
    barBottomConstraint.constant = notification.name == UIResponder.keyboardWillHideNotification ? 0 : keyboardFrame.height - view.safeAreaInsets.bottom
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
}

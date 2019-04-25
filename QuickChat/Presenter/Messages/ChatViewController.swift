//
//  ChatViewController.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/24/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
  
  @IBOutlet var inputBar: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var inputTextField: UITextField!
  @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
  
//
//  override var inputAccessoryView: UIView? {
//    get {
//      self.inputBar.frame.size.height = self.barHeight
//      self.inputBar.clipsToBounds = true
//      return self.inputBar
//    }
//  }
//  override var canBecomeFirstResponder: Bool{
//    return true
//  }
//
//
  
}

/*
 
 class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
 
 //MARK: Properties
 
 l
 
 //Downloads messages
 func fetchData() {
 Message.downloadAllMessages(forUserID: self.currentUser!.id, completion: {[weak weakSelf = self] (message) in
 weakSelf?.items.append(message)
 weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
 DispatchQueue.main.async {
 if let state = weakSelf?.items.isEmpty, state == false {
 weakSelf?.tableView.reloadData()
 weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
 }
 }
 })
 Message.markMessagesRead(forUserID: self.currentUser!.id)
 }
 
 //Hides current viewcontroller
 @objc func dismissSelf() {
 if let navController = self.navigationController {
 navController.popViewController(animated: true)
 }
 }
 
 func composeMessage(type: MessageType, content: Any)  {
 let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
 Message.send(message: message, toID: self.currentUser!.id, completion: {(_) in
 })
 }
 
 
 
 @IBAction func sendMessage(_ sender: Any) {
 if let text = self.inputTextField.text {
 if text.count > 0 {
 self.composeMessage(type: .text, content: self.inputTextField.text!)
 self.inputTextField.text = ""
 }
 }
 }
 
 //MARK: NotificationCenter handlers
 @objc func showKeyboard(notification: Notification) {
 if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
 let height = frame.cgRectValue.height
 self.tableView.contentInset.bottom = height
 self.tableView.scrollIndicatorInsets.bottom = height
 if self.items.count > 0 {
 self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
 }
 }
 }
 
 //MARK: Delegates
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return self.items.count
 }
 
 func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 if tableView.isDragging {
 cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
 UIView.animate(withDuration: 0.3, animations: {
 cell.transform = CGAffineTransform.identity
 })
 }
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 switch self.items[indexPath.row].owner {
 case .receiver:
 let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
 cell.clearCellData()
 switch self.items[indexPath.row].type {
 case .text:
 cell.message.text = self.items[indexPath.row].content as! String
 case .photo:
 if let image = self.items[indexPath.row].image {
 cell.messageBackground.image = image
 cell.message.isHidden = true
 } else {
 cell.messageBackground.image = UIImage.init(named: "loading")
 self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
 if state == true {
 DispatchQueue.main.async {
 self.tableView.reloadData()
 }
 }
 })
 }
 case .location:
 cell.messageBackground.image = UIImage.init(named: "location")
 cell.message.isHidden = true
 }
 return cell
 case .sender:
 let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
 cell.clearCellData()
 cell.profilePic.image = self.currentUser?.profilePic
 switch self.items[indexPath.row].type {
 case .text:
 cell.message.text = self.items[indexPath.row].content as! String
 case .photo:
 if let image = self.items[indexPath.row].image {
 cell.messageBackground.image = image
 cell.message.isHidden = true
 } else {
 cell.messageBackground.image = UIImage.init(named: "loading")
 self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
 if state == true {
 DispatchQueue.main.async {
 self.tableView.reloadData()
 }
 }
 })
 }
 case .location:
 cell.messageBackground.image = UIImage.init(named: "location")
 cell.message.isHidden = true
 }
 return cell
 }
 }
 
 
 */

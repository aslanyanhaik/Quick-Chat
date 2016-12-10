//
//  ChatVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/28/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    override var inputAccessoryView: UIView? {
        get {
            self.inputBar.frame.size.height = 50
            return self.inputBar
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    var userName = ""
    var items = [Message]()
    
    //MARK: Methods
    func customization() {
        self.tableView.contentInset.bottom = 50
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.title = self.userName
        self.navigationItem.setHidesBackButton(true, animated: false)
        let icon = UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(ChatVC.dismissSelf))
        self.navigationItem.leftBarButtonItem = rightButton
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        self.inputTextField.resignFirstResponder()
    }
    
    @IBAction func selectPic(_ sender: Any) {

    }
    
    func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    //MARK: Notification handlers
    func keyboardAppear(notification: Notification)  {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height {
           let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize, 0)
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    func keyboardDisappear(notification: Notification)  {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform.identity
        })
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
            let photo  = self.items[indexPath.row].content as! UIImage
            cell.messageBackground.image = photo
            }
            return cell
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            cell.clearCellData()
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
            case .photo:
                let photo  = self.items[indexPath.row].content as! UIImage
                cell.messageBackground.image = photo
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //show picture
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.items.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputBar.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.keyboardAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.keyboardDisappear(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0...10 {
            let item = Message.init(type: .text, content: "Hello there" as NSString, timestamp: 20, owner: .sender)
            self.items.append(item)
        }
        for _ in 0...10 {
            let item = Message.init(type: .text, content: "Hello there" as NSString, timestamp: 20, owner: .receiver)
            self.items.append(item)
        }
        self.tableView.reloadData()
        self.customization()
    }
}

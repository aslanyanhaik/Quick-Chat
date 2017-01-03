//
//  ChatVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 12/18/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Photos
import Firebase

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    override var inputAccessoryView: UIView? {
        get {
            self.inputBar.frame.size.height = self.barHeight
            self.inputBar.clipsToBounds = true
            return self.inputBar
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    var items = [Message]()
    let imagePicker = UIImagePickerController()
    let barHeight: CGFloat = 50
    var currentUser: User?

    //MARK: Methods
    func customization() {
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.navigationItem.title = self.currentUser?.name
        self.navigationItem.setHidesBackButton(true, animated: false)
        let icon = UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(self.dismissSelf))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
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
    func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func composeMessage(type: MessageType, content: Any)  {
        let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
        Message.send(message: message, toID: self.currentUser!.id, completion: {(_) in
        })
    }
    
    @IBAction func showMessage(_ sender: Any) {
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { 
            self.inputBar.layoutIfNeeded()
        }
    }
    
    @IBAction func selectGallery(_ sender: Any) {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectCamera(_ sender: Any) {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectLocation(_ sender: Any) {
        
    }
    
    @IBAction func showOptions(_ sender: Any) {
        self.bottomConstraint.constant = -50
        UIView.animate(withDuration: 0.3) {
            self.inputBar.layoutIfNeeded()
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.characters.count > 0 {
                self.composeMessage(type: .text, content: self.inputTextField.text!)
                self.inputTextField.text = ""
            }
        }
    }
    
    //MARK: NotificationCenter handlers
    func showKeyboard(notification: Notification) {
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
                let photo  = self.items[indexPath.row].content as! UIImage
                cell.messageBackground.image = photo
                cell.message.isHidden = true
            default: break
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
                let photo  = self.items[indexPath.row].content as! UIImage
                cell.messageBackground.image = photo
                cell.message.isHidden = true
            default: break
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.inputTextField.resignFirstResponder()
        if self.items[indexPath.row].type == .photo {
            let info = ["viewType" : ShowExtraView.preview, "pic": self.items[indexPath.row].content]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
            self.inputAccessoryView?.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.composeMessage(type: .photo, content: pickedImage)
        } else {
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.composeMessage(type: .photo, content: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputBar.backgroundColor = UIColor.clear
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        Message.markMessagesRead(forUserID: self.currentUser!.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchData()
    }
}

class SenderCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
}

class ReceiverCell: UITableViewCell {
    
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
}


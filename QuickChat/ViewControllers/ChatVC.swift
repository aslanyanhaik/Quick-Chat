//
//  ChatVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/28/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Photos
import AudioToolbox

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    override var inputAccessoryView: UIView? {
        get {
            self.inputBar.frame.size.height = self.barHeight
            return self.inputBar
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    var userName = ""
    var items = [Message]()
    let imagePicker = UIImagePickerController()
    let barHeight: CGFloat = 50

    //MARK: Methods
    func customization() {
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.navigationItem.title = self.userName
        self.navigationItem.setHidesBackButton(true, animated: false)
        let icon = UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(self.dismissSelf))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func fetchData()  {
        for _ in 0...10 {
            let item = Message.init(type: .text, content: "Hello there", timestamp: 20, owner: .sender)
            self.items.append(item)
        }
        for _ in 0...10 {
            let item = Message.init(type: .text, content: "Hello there", timestamp: 20, owner: .receiver)
            self.items.append(item)
        }
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func playSound()  {
        var soundURL: NSURL?
        var soundID:SystemSoundID = 0
        let filePath = Bundle.main.path(forResource: "sentMessage", ofType: "wav")
        soundURL = NSURL(fileURLWithPath: filePath!)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.characters.count > 0 {
                let message = Message.init(type: .text, content: self.inputTextField.text!, timestamp: 20, owner: .sender)
                self.inputTextField.text = nil
                self.items.append(message)
                self.tableView.insertRows(at: [IndexPath.init(row: self.items.count - 1, section: 0)], with: .none)
                let bottomOffset = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.bounds.size.height + self.tableView.contentInset.bottom)
                self.tableView.setContentOffset(bottomOffset, animated: true)
                self.playSound()
                // self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func selectPic(_ sender: Any) {
        //self.inputTextField.resignFirstResponder()
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK: NotificationCenter handlers
    func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.tableView.contentInset.bottom = height
            self.tableView.scrollIndicatorInsets.bottom = height
            self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
        }
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
            cell.message.isHidden = true
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
                cell.message.isHidden = true
            }
            return cell
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.inputTextField.resignFirstResponder()
        if self.items[indexPath.row].type == .photo {
            let info = ["viewType" : ShowExtraView.preview, "pic": self.items[indexPath.row].content]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
            self.inputAccessoryView?.isHidden = true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let item = Message.init(type: .photo, content: pickedImage, timestamp: 20, owner: .receiver)
            self.items.append(item)
            self.tableView.insertRows(at: [IndexPath.init(row: self.items.count - 1, section: 0)], with: .automatic)
        } else {
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                let item = Message.init(type: .photo, content: pickedImage, timestamp: 20, owner: .receiver)
                self.items.append(item)
            self.tableView.insertRows(at: [IndexPath.init(row: self.items.count - 1, section: 0)], with: .automatic)
           self.playSound()
        }
        picker.dismiss(animated: true, completion: {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
        })
    }

    //MARK: ViewController lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.items.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputBar.backgroundColor = UIColor.clear
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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


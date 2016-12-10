//
//  ChatVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/28/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Photos

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
    let imagePicker = UIImagePickerController()

    //MARK: Methods
    func customization() {
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = 50
        self.tableView.scrollIndicatorInsets.bottom = 50
        self.navigationItem.title = self.userName
        self.navigationItem.setHidesBackButton(true, animated: false)
        let icon = UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(ChatVC.dismissSelf))
        self.navigationItem.leftBarButtonItem = rightButton
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
    }
    
    func openPhotoPickerWith(source: PhotoSource) {
        switch source {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .camera;
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        case .library:
            let status = PHPhotoLibrary.authorizationStatus()
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .savedPhotosAlbum;
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.characters.count > 0 {
                let message = Message.init(type: .text, content: self.inputTextField.text!, timestamp: 20, owner: .receiver)
                self.inputTextField.text = nil
                self.items.append(message)
                self.tableView.insertRows(at: [IndexPath.init(row: self.items.count - 1, section: 0)], with: .automatic)
                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
            else {
                self.inputTextField.resignFirstResponder()
            }
        }
    }
    
    @IBAction func selectPic(_ sender: Any) {
        self.inputTextField.resignFirstResponder()
        let sheet = UIAlertController(title: nil, message: "Select the source", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .camera)
        })
        let photoAction = UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .library)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cameraAction)
        sheet.addAction(photoAction)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
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
        }
        picker.dismiss(animated: true, completion: {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
        })
    }

    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputBar.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchData()
    }
}

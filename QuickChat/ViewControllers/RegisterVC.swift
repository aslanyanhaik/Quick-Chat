//
//  RegisterVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/1/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Photos
import Firebase

class RegisterVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    let imagePicker = UIImagePickerController()
    var delegate: SuccessfulAuthentication?
    
    //MARK: Methods
    func customization()  {
        self.imagePicker.delegate = self
        self.errorLabel.alpha = 0
        self.submitButton.layer.cornerRadius = 20
        self.submitButton.clipsToBounds = true
        self.profilePic.layer.cornerRadius = 35
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderWidth = 1
        self.profilePic.layer.borderColor = GlobalVariables.blue.cgColor
    }
    
    @IBAction func selectPic(_ sender: Any) {
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
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func registerUser(_ sender: Any) {
        self.nameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        FIRAuth.auth()?.createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user: FIRUser?, error) in
            if error == nil {
                let storageRef = GlobalVariables.storageUsers.child(user!.uid)
                let data  = UIImageJPEGRepresentation(self.profilePic.image!, 0.5)
                storageRef.put(data!, metadata: nil, completion: { (metadata, storageError) in
                    let path  = metadata?.downloadURL()?.absoluteString
                    let values = ["name" : self.emailTextField.text!, "email" : self.passwordTextField.text!, "profilePicLink" : path!]
                    GlobalVariables.users.child((user?.uid)!).updateChildValues(values)
                    let userInfo = ["email" : self.emailTextField.text!, "password" : self.passwordTextField.text!]
                    UserDefaults.standard.set(userInfo, forKey: "userInformation")
                    self.delegate?.didAuthenticate()
                })
            } else {
                self.errorLabel.alpha = 1
            }
        })
    }
   
    //MARK: Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.errorLabel.alpha = 0
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePic.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}

enum PhotoSource {
    case library
    case camera
}

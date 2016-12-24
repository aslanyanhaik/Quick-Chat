//
//  LoginVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 9/12/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Photos
import Firebase

class WelcomeVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //MARK: Properties
    @IBOutlet var registerView: UIView!
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var profilePicView: RoundedImageView!
    @IBOutlet weak var registerNameField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var waringLabel: UILabel!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var cloudsViewLeading: NSLayoutConstraint!
    let imagePicker = UIImagePickerController()
    var loginViewTopConstraint: NSLayoutConstraint!
    var registerTopConstraint: NSLayoutConstraint!
    var isLoginViewVisible = true
    
    //MARK: Methods
    func customization()  {
        self.imagePicker.delegate = self
        //LoginView customization
        self.view.insertSubview(self.loginView, belowSubview: self.cloudsView)
        self.loginView.translatesAutoresizingMaskIntoConstraints = false
        self.loginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.loginViewTopConstraint = NSLayoutConstraint.init(item: self.loginView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.loginViewTopConstraint.isActive = true
        let loginRatio = NSLayoutConstraint.init(item: self.loginView, attribute: .width, relatedBy: .equal, toItem: self.loginView, attribute: .height, multiplier: 0.8, constant: 0)
        loginRatio.isActive = true
        let loginHeight = UIScreen.main.bounds.width - 50
        self.loginView.heightAnchor.constraint(equalToConstant: loginHeight).isActive = true
        self.loginView.layer.cornerRadius = 8
        //RegisterView Customization
        self.view.insertSubview(self.registerView, belowSubview: self.cloudsView)
        self.registerView.translatesAutoresizingMaskIntoConstraints = false
        self.registerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.registerTopConstraint = NSLayoutConstraint.init(item: self.registerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 20)
        self.registerTopConstraint.isActive = true
        let registerRatio = NSLayoutConstraint.init(item: self.registerView, attribute: .width, relatedBy: .equal, toItem: self.registerView, attribute: .height, multiplier: 0.8, constant: 0)
        registerRatio.isActive = true
        let registerHeight = UIScreen.main.bounds.width - 50
        self.loginView.heightAnchor.constraint(equalToConstant: registerHeight).isActive = true
        self.loginView.layer.cornerRadius = 8
    }
   
    func cloundsAnimation() {
        let distance = -(self.cloudsView.bounds.width - UIScreen.main.bounds.width)
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.cloudsViewLeading.constant = distance
            self.view.layoutIfNeeded()
        })
    }
    
    func pushTomainView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Navigation") as! NavVC
        self.show(vc, sender: nil)
    }
    
    func openPhotoPickerWith(source: PhotoSource) {
        switch source {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        case .library:
            let status = PHPhotoLibrary.authorizationStatus()
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func switchViews(_ sender: UIButton) {
        if self.isLoginViewVisible {
            self.isLoginViewVisible = false
            sender.setTitle("Login", for: .normal)
            self.loginViewTopConstraint.constant = 1000
            self.registerTopConstraint.constant = 20
        } else {
            self.isLoginViewVisible = true
            sender.setTitle("Create New Account", for: .normal)
            self.loginViewTopConstraint.constant = 20
            self.registerTopConstraint.constant = 1000
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func register(_ sender: Any) {
        FIRAuth.auth()?.createUser(withEmail: self.registerEmailField.text!, password: self.registerPasswordField.text!, completion: { (user: FIRUser?, error) in
            if error == nil {
                let storageRef = GlobalVariables.storageUsers.child(user!.uid)
                let data  = UIImageJPEGRepresentation(self.profilePicView.image!, 0.5)
                storageRef.put(data!, metadata: nil, completion: { (metadata, storageError) in
                    let path  = metadata?.downloadURL()?.absoluteString
                    let values = ["name" : self.registerEmailField.text!, "email" : self.registerPasswordField.text!, "profilePicLink" : path!]
                    GlobalVariables.users.child((user?.uid)!).updateChildValues(values)
                    let userInfo = ["email" : self.registerEmailField.text!, "password" : self.registerPasswordField.text!]
                    UserDefaults.standard.set(userInfo, forKey: "userInformation")
                    self.pushTomainView()
                })
            } else {
                self.waringLabel.isHidden = false
            }
        })
    }
    
    @IBAction func login(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: self.loginEmailField.text!, password: self.loginPasswordField.text!, completion: { (user, error) in
            if error == nil {
                let userInfo = ["email" : self.loginEmailField.text!, "password" : self.loginPasswordField.text!]
                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                self.pushTomainView()
            } else {
                self.waringLabel.isHidden = false
            }
        })
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
    
    //MARK: Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        //animate and dismiss
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePicView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        //implement clounds view visibility
        self.cloudsView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cloundsAnimation()
    }
}

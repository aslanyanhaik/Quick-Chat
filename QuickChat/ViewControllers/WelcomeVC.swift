//
//  LoginVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 12/18/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Photos

class WelcomeVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //MARK: Properties
    @IBOutlet var registerView: UIView!
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var profilePicView: RoundedImageView!
    @IBOutlet weak var registerNameField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet var waringLabels: [UILabel]!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var cloudsViewLeading: NSLayoutConstraint!
    var loginViewTopConstraint: NSLayoutConstraint!
    var registerTopConstraint: NSLayoutConstraint!
    let imagePicker = UIImagePickerController()
    var isLoginViewVisible = true
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    //MARK: Methods
    func customization()  {
        self.imagePicker.delegate = self
        self.profilePicView.layer.borderColor = GlobalVariables.blue.cgColor
        self.profilePicView.layer.borderWidth = 2
        //LoginView customization
        self.view.insertSubview(self.loginView, belowSubview: self.cloudsView)
        self.loginView.translatesAutoresizingMaskIntoConstraints = false
        self.loginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.loginViewTopConstraint = NSLayoutConstraint.init(item: self.loginView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 60)
        self.loginViewTopConstraint.isActive = true
        self.loginView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45).isActive = true
        self.loginView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.loginView.layer.cornerRadius = 8
        //RegisterView Customization
        self.view.insertSubview(self.registerView, belowSubview: self.cloudsView)
        self.registerView.translatesAutoresizingMaskIntoConstraints = false
        self.registerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.registerTopConstraint = NSLayoutConstraint.init(item: self.registerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.registerTopConstraint.isActive = true
        self.registerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.6).isActive = true
        self.registerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.registerView.layer.cornerRadius = 8
    }
   
    func cloundsAnimation() {
        let distance = self.view.bounds.width - self.cloudsView.bounds.width
        self.cloudsViewLeading.constant = distance
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
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
            self.registerTopConstraint.constant = 60
        } else {
            self.isLoginViewVisible = true
            sender.setTitle("Create New Account", for: .normal)
            self.loginViewTopConstraint.constant = 60
            self.registerTopConstraint.constant = 1000
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        for item in self.waringLabels {
            item.isHidden = true
        }
    }
    
    @IBAction func register(_ sender: Any) {
        User.registerUser(withName: self.registerNameField.text!, email: self.registerEmailField.text!, password: self.registerPasswordField.text!, profilePic: self.profilePicView.image!) { [weak weakSelf = self] (status) in
            DispatchQueue.main.async {
                if status == true {
                    weakSelf?.pushTomainView()
                } else {
                    for item in (weakSelf?.waringLabels)! {
                        item.isHidden = false
                    }
                }
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        User.loginUser(withEmail: self.loginEmailField.text!, password: self.loginPasswordField.text!) { [weak weakSelf = self](status) in
            DispatchQueue.main.async {
                if status == true {
                    weakSelf?.pushTomainView()
                } else {
                    for item in (weakSelf?.waringLabels)! {
                        item.isHidden = false
                    }
                }
                weakSelf = nil
            }
        }
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        for item in self.waringLabels {
            item.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePicView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cloundsAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cloudsViewLeading.constant = 0
        self.cloudsView.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
    }
}

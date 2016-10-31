//
//  LoginVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 9/12/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase
import Photos

class WelcomeVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var pointerView: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var registerContainer: UIView!
    @IBOutlet weak var loginContainer: UIView!
    @IBOutlet weak var registerNameTextField: UITextField!
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPassWordTextField: UITextField!
    @IBOutlet weak var profilePicView: UIImageView!
    let imagePicker = UIImagePickerController()
    var isContainerVisible = true
    var currentState: State = .login
    var profilePic: UIImage! {
        didSet {
            self.profilePicView.image = profilePic
        }
    }
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    //MARK: Methods
    func customization()  {
        self.imagePicker.delegate = self
        self.submitButton.layer.cornerRadius = 20
        self.submitButton.clipsToBounds = true
        self.profilePicView.layer.cornerRadius = 50
        self.profilePicView.clipsToBounds = true
        self.profilePicView.layer.borderWidth = 2
        self.profilePicView.layer.borderColor = GlobalVariables.blue.cgColor
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        switch self.currentState {
        case .login:
            FIRAuth.auth()?.signIn(withEmail: self.loginEmailTextField.text!, password: self.loginPasswordTextField.text!, completion: { (user, error) in
                if error == nil {
                    let userInfo = ["email" : self.loginEmailTextField.text!, "password" : self.loginPasswordTextField.text!]
                    UserDefaults.standard.set(userInfo, forKey: "userInformation")
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let rootController = storyboard.instantiateViewController(withIdentifier: "Conversations") as! ConversationsTB
                    let navigationController  = UINavigationController.init(rootViewController: rootController)
                    self.show(navigationController, sender: nil)
                }
            })
        case .register:
            FIRAuth.auth()?.createUser(withEmail: self.registerEmailTextField.text!, password: self.registerPassWordTextField.text!, completion: { (user: FIRUser?, error) in
                if error == nil {
                    let stodateRef = FIRStorage.storage().reference().child("usersProfilePics").child((user?.uid)!)
                    let data = UIImagePNGRepresentation(self.profilePicView.image!)
                    stodateRef.put(data!, metadata: nil, completion: { (metadata, error) in
                        let path  = metadata?.downloadURL()?.absoluteString
                        let values = ["name" : self.registerNameTextField.text!, "email" : self.registerEmailTextField.text!, "profilePicLink" : path!]
                        GlobalVariables.users.child((user?.uid)!).updateChildValues(values)
                        let userInfo = ["email" : self.registerPassWordTextField.text!, "password" : self.registerPassWordTextField.text!]
                        UserDefaults.standard.set(userInfo, forKey: "userInformation")
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let rootController = storyboard.instantiateViewController(withIdentifier: "Conversations") as! ConversationsTB
                        let navigationController  = UINavigationController.init(rootViewController: rootController)
                        self.show(navigationController, sender: nil)
                    })
                }
            })
        }
    }
    
    @IBAction func selectPic(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    
    }
    
    @IBAction func login(_ sender: AnyObject) {
        self.currentState = .login
        self.registerButton.setTitleColor(UIColor.lightGray, for: .normal)
        self.loginButton.setTitleColor(GlobalVariables.purple, for: .normal)
        self.submitButton.setTitle("Login", for: .normal)
        self.animate()
    }
   
    @IBAction func register(_ sender: AnyObject) {
        self.currentState = .register
        self.loginButton.setTitleColor(UIColor.lightGray, for: .normal)
        self.registerButton.setTitleColor(GlobalVariables.purple, for: .normal)
        self.submitButton.setTitle("Register", for: .normal)
        self.animate()
    }
    
    func animate() {
        switch self.currentState {
        case .login:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                self.registerContainer.alpha = 0
                self.loginContainer.alpha = 1
                self.pointerView.frame.origin.x = UIScreen.main.bounds.width/4
                }, completion: { (true) in
                    self.loginContainer.isHidden = false
                    self.registerContainer.isHidden = true
            })
        case .register:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                self.registerContainer.alpha = 1
                self.loginContainer.alpha = 0
                self.pointerView.frame.origin.x = UIScreen.main.bounds.width/4 * 3
                }, completion: { (true) in
                    self.loginContainer.isHidden = true
                    self.registerContainer.isHidden = false
            })
        }
    }
    
    func cloundsAnimation() {
        let distance = -(self.cloudsView.bounds.width - UIScreen.main.bounds.width)
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.cloudsView.frame.origin.x = distance
        })
        UIView.animate(withDuration: 3, delay: 2, options: [.curveLinear, .autoreverse, .repeat], animations: {
            self.logoView.frame.origin.y += 8
        })
    }
    
    func animateHorizontal() {
        self.viewDidLayoutSubviews()
        switch self.isContainerVisible {
        case true:
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.frame.origin.y = -150
                self.loginContainer.frame.origin.y = 50
                self.registerContainer.frame.origin.y = 50
                self.submitButton.frame.origin.y -= 150
            })
        case false:
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.frame.origin.y = 0
                self.loginContainer.frame.origin.y = 200
                self.registerContainer.frame.origin.y = 200
                self.submitButton.frame.origin.y += 150
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        switch self.isContainerVisible {
        case true:
            self.containerView.frame.origin.y = 0
            self.loginContainer.frame.origin.y = 200
            self.registerContainer.frame.origin.y = 200
            self.submitButton.frame.origin.y = 567

        case false:
            self.containerView.frame.origin.y = -150
            self.loginContainer.frame.origin.y = 50
            self.registerContainer.frame.origin.y = 50
            self.submitButton.frame.origin.y = 417
        }
    }
    
    //MARK: Delegates
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.isContainerVisible {
            self.animateHorizontal()
            self.isContainerVisible = false
        }
        return true
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.animateHorizontal()
        self.isContainerVisible = true
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profilePicView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
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
}

enum State {
    case login
    case register
}

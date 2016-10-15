//
//  LoginVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 9/12/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class WelcomeVC: UIViewController, UITextFieldDelegate {

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
    @IBOutlet weak var profilePicButton: UIButton!
    @IBOutlet weak var registerNameTextField: UITextField!
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPassWordTextField: UITextField!
    var isContainerVisible = true
    var currentState: State = .register
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    //MARK: Methods
    func customization()  {
        self.submitButton.layer.cornerRadius = 20
        self.submitButton.clipsToBounds = true
        self.profilePicButton.layer.cornerRadius = 35
        self.profilePicButton.clipsToBounds = true
    }
    
    
    @IBAction func submit(_ sender: AnyObject) {
        
    }
    
    @IBAction func selectPic(_ sender: AnyObject) {
        
    }
    
    @IBAction func login(_ sender: AnyObject) {
        self.currentState = .login
        self.registerButton.setTitleColor(UIColor.lightGray, for: .normal)
        self.loginButton.setTitleColor(Colors.purple, for: .normal)
        self.submitButton.setTitle("Login", for: .normal)
        self.animate()
    }
   
    @IBAction func register(_ sender: AnyObject) {
        self.currentState = .register
        self.loginButton.setTitleColor(UIColor.lightGray, for: .normal)
        self.registerButton.setTitleColor(Colors.purple, for: .normal)
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
        switch self.isContainerVisible {
        case true:
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.frame.origin.y = -150
                self.loginContainer.frame.origin.y = 50
                self.registerContainer.frame.origin.y = 50
            })
        case false:
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.frame.origin.y = 0
                self.loginContainer.frame.origin.y = 200
                self.registerContainer.frame.origin.y = 200
            })
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
        self.isContainerVisible = false
        self.animateHorizontal()
        return true
    }
    
    
    
    
    func loginUser() {
        FIRAuth.auth()?.signIn(withEmail: "sdsdgs", password: "sdgsdg", completion: nil)
    }
    
    func registerUser()  {
        FIRAuth.auth()?.createUser(withEmail: "sdsdg", password: "sdgsdg", completion: { (user: FIRUser?, error) in
            let ref = FIRDatabase.database().reference(fromURL: "https://quick-chat-60662.firebaseio.com/").child("users").child((user?.uid)!)
            let values = ["name" : "sdgsd", "email" : "dgsdg"]
            ref.updateChildValues(values)
        })
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

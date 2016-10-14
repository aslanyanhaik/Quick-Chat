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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var pointerView: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    var isContainerVisible = true
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    //MARK: Methods
    func customization()  {
       
    
    }
    
    
    @IBAction func submit(_ sender: AnyObject) {
        
           }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.isContainerVisible {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.y = -150
            })
            self.isContainerVisible = false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.isContainerVisible == false {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.y = 0
            })
            self.isContainerVisible = true
        }
    }
    
    func animation() {
        let distance = -(self.cloudsView.bounds.width - UIScreen.main.bounds.width)
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.cloudsView.frame.origin.x = distance
        })
        UIView.animate(withDuration: 3, delay: 2, options: [.curveLinear, .autoreverse, .repeat], animations: {
            self.logoView.frame.origin.y += 8
        })
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
        self.animation()
    }
}





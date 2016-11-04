//
//  LoginVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/1/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var delegate: SuccessfulAuthentication?
    
    //MARK: Methods
    func customization()  {
        self.errorLabel.alpha = 0
        self.submitButton.layer.cornerRadius = 20
        self.submitButton.clipsToBounds = true
    }
    
    @IBAction func login(_ sender: Any) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
            if error == nil {
                let userInfo = ["email" : self.emailTextField.text!, "password" : self.passwordTextField.text!]
                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                self.delegate?.didAuthenticate()
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
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}

//
//  LoginVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/1/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    var delegate: SuccessfulAuthentication?
    
    //MARK: Methods
    func customization()  {
        self.submitButton.layer.cornerRadius = 20
        self.submitButton.clipsToBounds = true
    }
    
    @IBAction func login(_ sender: Any) {
        self.delegate?.didAuthenticate()
    }
    
    //MARK: Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}

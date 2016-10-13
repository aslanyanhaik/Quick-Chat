//
//  LoginVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 9/12/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    //MARK: Properties
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var stateSegment: UISegmentedControl!
    
    
    //MARK: Methods
    func customization()  {
        self.view.backgroundColor = Colors.yellow
        self.whiteView.layer.cornerRadius = 8
        self.whiteView.layer.masksToBounds = true
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.layer.masksToBounds = true
    }
    
    @IBAction func login(_ sender: UIButton) {
        if self.stateSegment.selectedSegmentIndex == 0 {
            self.loginUser()
        } else {
            self.registerUser()
        }
    }
    
    func loginUser() {
        FIRAuth.auth()?.signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: nil)
    }
    
    func registerUser()  {
        FIRAuth.auth()?.createUser(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user: FIRUser?, error) in
            let ref = FIRDatabase.database().reference(fromURL: "https://quick-chat-60662.firebaseio.com/").child("users").child((user?.uid)!)
            let values = ["name" : self.nameField.text!, "email" : self.emailField.text!]
            ref.updateChildValues(values)
        })
    }
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}





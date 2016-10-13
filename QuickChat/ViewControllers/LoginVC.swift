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
    let nameTF: UITextField = {
        let name = UITextField.init(frame: CGRect.init(x: 0, y: 0, width: 120, height: 30))
        name.backgroundColor = UIColor.red
        return name
    }()
    
    //MARK: Methods
    func customization()  {
        self.view.backgroundColor = Colors.yellow
        self.whiteView.layer.cornerRadius = 8
        self.whiteView.layer.masksToBounds = true
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.layer.masksToBounds = true
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        FIRAuth.auth()?.createUser(withEmail: "hello@mail.com", password: "hayastan", completion: { (user: FIRUser?, error) in
            
            let ref = FIRDatabase.database().reference(fromURL: "https://quick-chat-60662.firebaseio.com/")
            let values = ["name" : "William", "email" : "hello@mail.com"]
            ref.updateChildValues(values)
        })
        
        
    }
    
   
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}





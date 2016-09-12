//
//  LoginVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 9/12/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    //MARK: Properties
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: Methods
    func customization()  {
        self.view.backgroundColor = Colors.yellow
        self.whiteView.layer.cornerRadius = 8
        self.whiteView.layer.masksToBounds = true
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.layer.masksToBounds = true
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.resignFirstResponder()
    }
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}

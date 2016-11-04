//
//  RegisterVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/1/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

    //MARK: Properties
    @IBOutlet weak var profilePic: UIImageView!
    
    
    var delegate: SuccessfulAuthentication?
    
    @IBAction func register(_ sender: Any) {
        self.delegate?.didAuthenticate()
    }
    
    
    //MARK: Methods
    
    //MARK: Delegates
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

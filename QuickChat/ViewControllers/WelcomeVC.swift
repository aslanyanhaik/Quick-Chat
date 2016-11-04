//
//  LoginVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 9/12/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

protocol SuccessfulAuthentication {
    func didAuthenticate()
}

class WelcomeVC: UIViewController, SuccessfulAuthentication {

    //MARK: Properties
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var cloudsViewLeading: NSLayoutConstraint!
    lazy var loginView: UIView = {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginVC
        self.addChildViewController(vc)
        vc.delegate = self
        vc.view.frame = CGRect.init(x: (UIScreen.main.bounds.width * 0.1), y: (UIScreen.main.bounds.height * 0.08), width: (UIScreen.main.bounds.width * 0.8), height: (UIScreen.main.bounds.height * 0.5))
        vc.didMove(toParentViewController: self)
        return vc.view
    }()
    lazy var registerView: UIView = {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Register") as! RegisterVC
        self.addChildViewController(vc)
        vc.delegate = self
        vc.view.frame = CGRect.init(x: (UIScreen.main.bounds.width * 0.1), y: UIScreen.main.bounds.height, width: (UIScreen.main.bounds.width * 0.8), height: (UIScreen.main.bounds.height * 0.7))
        vc.didMove(toParentViewController: self)
        return vc.view
    }()
    var isLoginViewVisible = true
    
    //MARK: Methods
    func customization()  {
        self.loginView.layer.cornerRadius = 8
        self.view.insertSubview(self.loginView, belowSubview: self.cloudsView)
        self.registerView.layer.cornerRadius = 8
        self.view.insertSubview(self.registerView, belowSubview: self.cloudsView)
    }
   
    func cloundsAnimation() {
        let distance = -(self.cloudsView.bounds.width - UIScreen.main.bounds.width)
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.cloudsViewLeading.constant = distance
            self.view.layoutIfNeeded()
        })
    }
    
    func animateViews() {
        switch self.isLoginViewVisible {
        case true:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.loginView.frame.origin.y = (UIScreen.main.bounds.height * 0.08)
                self.registerView.frame.origin.y = UIScreen.main.bounds.height
            })
        case false:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.loginView.frame.origin.y = UIScreen.main.bounds.height
                self.registerView.frame.origin.y = (UIScreen.main.bounds.height * 0.08)
            })
        }
    }
    
    @IBAction func switchViews(_ sender: UIButton) {
        if self.isLoginViewVisible {
            self.isLoginViewVisible = false
            sender.setTitle("Login", for: .normal)
        } else {
            self.isLoginViewVisible = true
            sender.setTitle("Create New Account", for: .normal)
        }
        self.animateViews()
    }
    
    //MARK: Delegates
    func didAuthenticate() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Conversations") as! ConversationsVC
        let navigationController  = UINavigationController.init(rootViewController: vc)
        self.show(navigationController, sender: nil)
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

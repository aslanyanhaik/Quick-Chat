//
//  NavVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/27/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {

    //MARK: Properties
    var profileVC: ProfileVC!
    var contactsVC: ContactsVC!
    var isProfileVCDataFetched = false
    var isContactsVCDataFetched = false
    let darkView: UIView = {
        let view = UIView.init(frame: UIScreen.main.bounds)
        view.frame.origin.y = UIScreen.main.bounds.height
        view.backgroundColor = UIColor.black
        view.alpha = 0
        return view
    }()
    
    //MARK: Methods
    func customization()  {
        self.view.addSubview(self.darkView)
        //profile view init
        self.profileVC = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! ProfileVC
        self.addChildViewController(self.profileVC)
        self.profileVC.view.frame = CGRect.init(x: (UIScreen.main.bounds.width * 0.1), y: (UIScreen.main.bounds.height + 100), width: (UIScreen.main.bounds.width * 0.8), height: (UIScreen.main.bounds.height * 0.65))
        self.profileVC.view.layer.cornerRadius = 5
        self.view.addSubview(self.profileVC.view)
        profileVC.didMove(toParentViewController: self)
        //contacts view init
        self.contactsVC = self.storyboard?.instantiateViewController(withIdentifier: "Contacts") as! ContactsVC
        self.addChildViewController(self.contactsVC)
        self.contactsVC.view.frame = CGRect.init(x: 0, y: (UIScreen.main.bounds.height + 100), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.addSubview(self.contactsVC.view)
        contactsVC.didMove(toParentViewController: self)
        //conversations VC
        let conversationsVC = self.storyboard?.instantiateViewController(withIdentifier: "Conversations")
        self.show(conversationsVC!, sender: self)
        //Notification setup
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissVC(notification:)), name: NSNotification.Name(rawValue: "dismissVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showVC(notification:)), name: NSNotification.Name(rawValue: "showVC"), object: nil)
    }
    
    //dismiss contacts/profile ViewControllers
    func dismissVC(notification: NSNotification) {
        if let type = notification.userInfo?["isContactsVC"] as? Bool {
            switch type {
            case true:
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    self.darkView.alpha = 0
                    self.contactsVC.view.frame.origin.y = (UIScreen.main.bounds.height + 100)
                    self.view.transform = CGAffineTransform.identity
                }, completion:  { (true) in
                    self.darkView.frame.origin.y = UIScreen.main.bounds.height
                })
            case false:
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    self.darkView.alpha = 0
                    self.profileVC.view.frame.origin.y = (UIScreen.main.bounds.height + 100)
                    self.view.transform = CGAffineTransform.identity
                }, completion:  { (true) in
                    self.darkView.frame.origin.y = UIScreen.main.bounds.height
                })
            }
        }
    }
    
    //show contacts/profile ViewControllers
    func showVC(notification: NSNotification)  {
        let transform = CGAffineTransform.init(scaleX: 0.94, y: 0.94)
        self.darkView.frame.origin.y = 0
        if let type = notification.userInfo?["isContactsVC"] as? Bool {
            switch type {
            case true:
                if self.isContactsVCDataFetched == false {
                    self.contactsVC.fetchUsers()
                }
                self.isContactsVCDataFetched = true
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.darkView.alpha = 0.8
                    self.contactsVC.view.frame.origin.y = 0
                    self.view.transform = transform
                })
            case false:
                if self.isProfileVCDataFetched == false {
                    self.profileVC.fetchUserInfo()
                }
                self.isProfileVCDataFetched = true
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.darkView.alpha = 0.8
                    self.profileVC.view.frame.origin.y = 100
                    self.view.transform = transform
                })
            }
        }
    }

    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()        
    }
}

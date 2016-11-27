//
//  ProfileVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/17/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var logOutButton: UIButton!
    
    //MARK: Methods
    func customization() {
        let radius = self.profilePicView.bounds.width / 2
        self.profilePicView.layer.cornerRadius = radius
        self.profilePicView.clipsToBounds = true
        self.profilePicView.layer.borderColor = GlobalVariables.purple.cgColor
        self.profilePicView.layer.borderWidth = 3
        self.logOutButton.layer.cornerRadius = 20
        self.logOutButton.clipsToBounds = true
    }
    
    func fetchUserInfo() {
        if let id  = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(id).observe(.value, with: { (snapshot) in
                let value = snapshot.value as! [String : String]
                self.nameLabel.text = value["email"]
                self.emailLabel.text = value["name"]
                let profilePicURL = URL.init(string: value["profilePicLink"]!)
                let imageData = try! Data.init(contentsOf: profilePicURL!)
                let profilePic = UIImage.init(data: imageData)
                self.profilePicView.image = profilePic
            })
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        if let _ = FIRAuth.auth()?.currentUser?.uid {
            do {
                try FIRAuth.auth()?.signOut()
                UserDefaults.standard.removeObject(forKey: "userInformation")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeVC
                self.present(vc, animated: true, completion: {
                })
            } catch _ {
                print("something went wrong")
            }
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        let info = ["isContactsVC" : false]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissVC"), object: nil, userInfo: info)    }
    
    //MARK: ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}

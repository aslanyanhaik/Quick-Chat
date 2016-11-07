//
//  ProfileVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/17/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

protocol ProfileVCDelegate {
    func dismissVC()
}

class ProfileVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var logOutButton: UIButton!
    var delegate: ProfileVCDelegate?
    
    //MARK: Methods
    func customization() {
        self.profilePicView.layer.cornerRadius = 75
        self.profilePicView.clipsToBounds = true
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
        self.delegate?.dismissVC()
    }
    
    //MARK: ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchUserInfo()
    }
}

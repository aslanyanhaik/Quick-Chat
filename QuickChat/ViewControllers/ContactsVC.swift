//
//  ContactsVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/26/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class ContactsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    var isTableEmpty: Bool!
    var items = [User]()
    
    //MARK: Methods
    func customization() {
        self.collectionView?.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        self.closeButton.layer.cornerRadius = 20
        self.closeButton.clipsToBounds = true
    }
    
    func fetchUsers()  {
        self.items.removeAll()
        GlobalVariables.users.observe(.childAdded, with: { (snapshot) in
            let output = snapshot.value as! [String: String]
            let name = output["name"]!
            let email = output["email"]!
            let profilePicLink = output["profilePicLink"]!
            let link = URL.init(string: profilePicLink)
            let data = try! Data.init(contentsOf: link!)
            let profilePic = UIImage.init(data: data)!
            let user = User.init(name: name, email: email, id: snapshot.key, profilePicLink: link!, profilePic: profilePic)
            self.items.append(user)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    @IBAction func closeVC(_ sender: Any) {
        let info = ["isContactsVC" : true]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissVC"), object: nil, userInfo: info)
    }
    
    //MARK: Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.items.count == 0 {
            self.isTableEmpty = true
            return 1
        } else {
            self.isTableEmpty = false
        return self.items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.isTableEmpty {
        case true:
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "Empty Cell", for: indexPath)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ContactsCVCell
            cell.profilePic.image = self.items[indexPath.row].profilePic
            cell.nameLabel.text = self.items[indexPath.row].name
            cell.profilePic.layer.cornerRadius = (UIScreen.main.bounds.width * 0.12)
            cell.profilePic.clipsToBounds = true
            cell.profilePic.layer.borderWidth = 2
            cell.profilePic.layer.borderColor = GlobalVariables.purple.cgColor
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.items.count > 0 {
            let info = ["isContactsVC" : true]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissVC"), object: nil, userInfo: info)
            let userInfo = ["username": String(indexPath.row)]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showUserMessages"), object: nil, userInfo: userInfo)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.items.count == 0 {
            return self.collectionView.bounds.size
        } else {
            let width = (0.3 * UIScreen.main.bounds.width)
            let height = width + 30
            return CGSize.init(width: width, height: height)
        }
    }
    
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}


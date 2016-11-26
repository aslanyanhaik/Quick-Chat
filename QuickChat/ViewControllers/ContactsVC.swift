//
//  ContactsVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/26/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//
protocol DismissVCDelegate {
    func dismissVC(withSelectedUser: String?)
}

import UIKit

class ContactsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    var items = [User]()
    var delegate: DismissVCDelegate?
    
    //MARK: Methods
    func customization() {
        self.closeButton.layer.cornerRadius = 20
        self.closeButton.clipsToBounds = true
    }
    
    func fetchUsers()  {
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
        self.delegate?.dismissVC(withSelectedUser: nil)
    }
    
    //MARK: Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 60
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ContactsCVCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width * 0.3
        let height = width + 30
        return CGSize.init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.dismissVC(withSelectedUser: String(indexPath.row))
    }
    
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
       // self.fetchUsers()
    }
}


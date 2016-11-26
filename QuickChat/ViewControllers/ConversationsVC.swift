//
//  ConversationsVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/4/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class ConversationsVC: UIViewController,UITableViewDelegate, UITableViewDataSource, DismissVCDelegate {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var items = [Conversation]()
    lazy var leftButton: UIBarButtonItem = {
        let image = UIImage.init(named: "default profile")?.withRenderingMode(.alwaysOriginal)
        let button  = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(ConversationsVC.viewUserProfile))
        return button
    }()
    lazy var profileView: UIView = {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! ProfileVC
        vc.delegate = self
        self.navigationController!.addChildViewController(vc)
        vc.view.frame = CGRect.init(x: (UIScreen.main.bounds.width * 0.1), y: UIScreen.main.bounds.height, width: (UIScreen.main.bounds.width * 0.8), height: (UIScreen.main.bounds.height * 0.65))
        vc.view.layer.cornerRadius = 5
        vc.didMove(toParentViewController: self.navigationController!)
        return vc.view
    }()
    lazy var contactsView: UIView = {
       let vc = self.storyboard?.instantiateViewController(withIdentifier: "Contacts") as! ContactsVC
        vc.delegate = self
        self.navigationController!.addChildViewController(vc)
        vc.view.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        vc.didMove(toParentViewController: self.navigationController!)
        return vc.view
    }()
    let darkView: UIView = {
        let view = UIView.init(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0
        return view
    }()
    
    //MARK: Methods
    func customization()  {
        self.randomData()
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "button")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        let icon = UIImage.init(named: "compose")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(ConversationsVC.compose))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem = self.leftButton
        self.tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        if let id  = FIRAuth.auth()?.currentUser?.uid {
            GlobalVariables.users.child(id).observe(.value, with: { (snapshot) in
                let value = snapshot.value as! [String : String]
                let image = UIImage.downloadImagewith(link: value["profilePicLink"]!)
                DispatchQueue.main.async {
                    let contentSize = CGSize.init(width: 30, height: 30)
                    UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
                    let _  = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: contentSize), cornerRadius: 14).addClip()
                    image.draw(in: CGRect(origin: CGPoint(x: 0, y :0), size: contentSize))
                    let path = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: contentSize), cornerRadius: 14)
                    path.lineWidth = 3
                    UIColor.white.setStroke()
                    path.stroke()
                    let finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
                    UIGraphicsEndImageContext()
                    self.leftButton.image = finalImage
                }
            })
        }
    }
    
    func randomData() {
        let item = Conversation.init(profilePic: UIImage.init(named: "1")!, name: "Steve Jobs", lastMessage: "Hello there, how are you doing", time: Date.init(timeIntervalSinceNow: 10), isRead: true)
        let item2 = Conversation.init(profilePic: UIImage.init(named: "2")!, name: "William Brown", lastMessage: "Wonderful day, how is it there?", time: Date.init(timeIntervalSinceNow: 15), isRead: false)
        let item3 = Conversation.init(profilePic: UIImage.init(named: "3")!, name: "Conan", lastMessage: "random text", time: Date.init(timeIntervalSinceNow: 15), isRead: true)
        self.items.append(item)
        self.items.append(item2)
        self.items.append(item3)
        self.tableView.reloadData()
    }
    
    func viewUserProfile() {
        let transform = CGAffineTransform.init(scaleX: 0.98, y: 0.98)
        if let nav = self.navigationController {
            nav.view.addSubview(self.darkView)
            nav.view.addSubview(self.profileView)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.darkView.alpha = 0.8
                self.profileView.frame.origin.y = 100
                nav.view.transform = transform
            })
        }
    }
    
    func compose() {
        let transform = CGAffineTransform.init(scaleX: 0.98, y: 0.98)
        if let nav = self.navigationController {
            nav.view.addSubview(self.darkView)
            nav.view.addSubview(self.contactsView)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.darkView.alpha = 0.8
                self.contactsView.frame.origin.y = 0
                nav.view.transform = transform
            })
        }
    }
    
    //MARK: Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConversationsTBCell
        cell.profilePic.image = self.items[indexPath.row].profilePic
        cell.nameLabel.text = self.items[indexPath.row].name
        cell.messageLabel.text = self.items[indexPath.row].lastMessage
        let dataformatter = DateFormatter.init()
        dataformatter.timeStyle = .short
        let date = dataformatter.string(from: self.items[indexPath.row].time)
        cell.timeLabel.text = date
        if self.items[indexPath.row].isRead == false {
            cell.nameLabel.font = UIFont(name:"AvenirNext-DemiBold", size: 17.0)
            cell.messageLabel.font = UIFont(name:"AvenirNext-DemiBold", size: 14.0)
            cell.timeLabel.font = UIFont(name:"AvenirNext-DemiBold", size: 13.0)
            cell.profilePic.layer.borderColor = GlobalVariables.blue.cgColor
            cell.messageLabel.textColor = GlobalVariables.purple
        }
        return cell
    }
    
    func dismissVC(withSelectedUser: String?) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.darkView.alpha = 0
            self.profileView.frame.origin.y = UIScreen.main.bounds.height
            self.contactsView.frame.origin.y = UIScreen.main.bounds.height
            self.navigationController?.view.transform = CGAffineTransform.identity
        }, completion:  { (true) in
            self.darkView.removeFromSuperview()
            self.contactsView.removeFromSuperview()
            self.profileView.removeFromSuperview()
            if let user = withSelectedUser {
                print(user)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Chat")
                self.present(vc!, animated: true, completion: nil)
            }
        })
    }
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }

}

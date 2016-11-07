//
//  ConversationsVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/4/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class ConversationsVC: UIViewController,UITableViewDelegate, UITableViewDataSource, ComposeVCDelegate, ProfileVCDelegate {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var items = ["Hello", "Welcome"]
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
    lazy var darkView: UIView = {
        let view = UIView.init(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0
        return view
    }()
    
    //MARK: Methods
    func customization()  {
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "button")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        let icon = UIImage.init(named: "compose")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(ConversationsVC.compose))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem = self.leftButton
        if let id  = FIRAuth.auth()?.currentUser?.uid {
            GlobalVariables.users.child(id).observe(.value, with: { (snapshot) in
                let value = snapshot.value as! [String : String]
                let image = UIImage.downloadImagewith(link: value["profilePicLink"]!)
                DispatchQueue.main.async {
                    let contentSize = CGSize.init(width: 28, height: 28)
                    UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
                    let _  = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: 28, height: 28), cornerRadius: 14).addClip()
                    image.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: contentSize))
                    let finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
                    UIGraphicsEndImageContext()
                    self.leftButton.image = finalImage
                }
            })
        }
    }
    
    func viewUserProfile() {
        if let nav = self.navigationController {
            nav.view.addSubview(self.darkView)
            nav.view.addSubview(self.profileView)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.darkView.alpha = 0.5
            self.profileView.frame.origin.y = 100
        })
    }
    
    func compose() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Compose") as! ComposeTB
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    
    func id(id: String) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Chat") as! ChatVC
        vc.id = id
        print(id)
        self.show(vc, sender: nil)
    }
    
    func dismissVC() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.darkView.alpha = 0
            self.profileView.frame.origin.y = UIScreen.main.bounds.height
        }, completion:  { (true) in
            self.darkView.removeFromSuperview()
            self.profileView.removeFromSuperview()
        })
    }
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }

}

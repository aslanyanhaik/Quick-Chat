//
//  ConversationsVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/4/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class ConversationsVC: UIViewController,UITableViewDelegate, UITableViewDataSource, ComposeVCDelegate {
    
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
        //vc.delegate = self
        self.addChildViewController(vc)
        vc.view.frame = CGRect.init(x: 20, y: 20, width: 100, height: 200)
        vc.didMove(toParentViewController: self)
        return vc.view
    }()
    
    //MARK: Methods
    func customization()  {
        self.view.addSubview(self.profileView)
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
        UIView.animate(withDuration: 0.3, animations: {
            self.profileView.frame.origin.y = 100
        })
        
    }
    
    func hideUserProfile()  {
        UIView.animate(withDuration: 0.3, animations: {
            self.profileView.frame.origin.y = 500
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
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }

}

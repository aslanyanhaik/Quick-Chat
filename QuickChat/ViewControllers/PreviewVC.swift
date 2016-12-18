//
//  PreviewVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 12/11/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class PreviewVC: UIViewController, UIScrollViewDelegate {
    
    //MARK: Properties
    var profilePic: UIImage?
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: Methods
    func customization() {
        UIApplication.shared.isStatusBarHidden = true
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        self.profilePicView.image = profilePic
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        UIApplication.shared.isStatusBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    //MAARK: Delegates
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.profilePicView
    }
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}

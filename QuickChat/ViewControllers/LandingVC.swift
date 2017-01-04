//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit


class LandingVC: UIViewController {
    
    //MARK: Properties
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }

    //MARK: Push to relevant ViewController
    func pushTo(viewController: ViewControllerType)  {
        switch viewController {
        case .conversations:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Navigation") as! NavVC
            self.present(vc, animated: false, completion: nil)
        case .welcome:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeVC
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
            let email = userInformation["email"] as! String
            let password = userInformation["password"] as! String
            User.loginUser(withEmail: email, password: password, completion: { [weak weakSelf = self] (status) in
                DispatchQueue.main.async {
                    if status == true {
                        weakSelf?.pushTo(viewController: .conversations)
                    } else {
                        weakSelf?.pushTo(viewController: .welcome)
                    }
                    weakSelf = nil
                }
            })
        } else {
            self.pushTo(viewController: .welcome)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

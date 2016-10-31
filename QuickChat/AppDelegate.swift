//
//  AppDelegate.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 8/9/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
            let email = userInformation["email"] as! String
            let password = userInformation["password"] as! String
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    self.pushTo(viewController: .conversations)
                } else {
                    self.pushTo(viewController: .welcome)
                }
            })
        } else {
            self.pushTo(viewController: .welcome)
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func pushTo(viewController: ViewControllerType)  {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch viewController {
        case .conversations:
            let rootController = storyboard.instantiateViewController(withIdentifier: "Conversations") as! ConversationsTB
            self.window?.rootViewController = UINavigationController.init(rootViewController: rootController)
            self.window?.makeKeyAndVisible()
        case .welcome:
            let rootController = storyboard.instantiateViewController(withIdentifier: "Welcome")
            self.window?.rootViewController = rootController
            self.window?.makeKeyAndVisible()
        }
    }
}


enum ViewControllerType {
    case welcome
    case conversations
}




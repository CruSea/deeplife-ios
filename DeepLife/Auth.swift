//
//  Auth.swift
//  DeepLife
//
//  Created by Gwinyai on 12/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

import RealmSwift

import Alamofire

public class LocalDatabaseManager {
    
    static var realm: Realm? {
        
        get {
            
            do {
                let realm = try Realm()
                
                return realm
            }
            catch {
                
                return nil
                
            }
            
        }
        
    }
    
}

class Auth {
    
    static let auth = Auth()
    
    var currentUserId: String?
    
    var currentSessionId: String?
    
    var profile: User?
    
    private func setDefaultRealmForUser(userId: String) {
        
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(userId).realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
    }
    
    func checkForLoggedUser() -> (userId: String?, sessionId: String?) {
        
        //return "606"
        
        guard let realm = LocalDatabaseManager.realm else { return (nil, nil) }
        
        if let loggedUser = realm.objects(LocalUser.self).filter("isLoggedIn == true").first {
            
            return ("\(loggedUser.id)", loggedUser.sessionId)
            
        }
        
        return (nil, nil)
        
    }
    
    func createSession(userId: String, sessionId: String) -> UITabBarController {
        
        if let realm = LocalDatabaseManager.realm,
            let userIdAsInt = Int(userId) {
            
            let newUser = LocalUser()
            
            newUser.id = userIdAsInt
            
            newUser.isLoggedIn = true
            
            newUser.sessionId = sessionId
            
            do {
            
                try realm.write {
                    
                    realm.add(newUser, update: .modified)
                    
                    //deprecated
                    //realm.add(newUser, update: true)
                    
                }
                
            } catch let error as NSError {
                
                print(error.localizedDescription)
                
            }
            
        }
        
        //setDefaultRealmForUser(userId: userId)
        
        currentUserId = userId
        
        currentSessionId = sessionId
        
        let tabController = UITabBarController()
        
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        
        let tasksStoryboard = UIStoryboard(name: "Tasks", bundle: nil)
        
        let exposureStoryboard = UIStoryboard(name: "Exposure", bundle: nil)
        
        let treeStoryboard = UIStoryboard(name: "Tree", bundle: nil)
        
        let homeVC = homeStoryboard.instantiateViewController(withIdentifier: "homeVC") as! HomeViewController
        
        let tasksVC = tasksStoryboard.instantiateViewController(withIdentifier: "tasksVC") as! TasksViewController
        
        let exposureVC = exposureStoryboard.instantiateViewController(withIdentifier: "exposureVC") as! ExposureViewController
        
        let treeVC = treeStoryboard.instantiateViewController(withIdentifier: "treeVC") as! TreeViewController
        
        
        let vcData: [(UIViewController, UIImage, String)] = [
            (homeVC, UIImage(named: "home_icon")!, "home"),
            (tasksVC, UIImage(named: "tasks_icon")!, "tasks"),
            (exposureVC, UIImage(named: "exposure_icon")!, "exposure"),
            (treeVC, UIImage(named: "tree_icon")!, "tree")
        ]
        
        UINavigationBar.appearance().tintColor = UIColor.black
        
        UINavigationBar.appearance().largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor:UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 30)!]
        
        let vcs = vcData.map { (vc, image, title) -> UIViewController in
            
            if title == "tasks" || title == "exposure" || title == "tree" {
                
                let nav = UINavigationController(rootViewController: vc)
                
                nav.tabBarItem.image = image
                
                nav.navigationBar.prefersLargeTitles = true
                
                nav.navigationItem.largeTitleDisplayMode = .never
                
                nav.title = ""
                
                return nav
                
            }
            
            vc.tabBarItem.image = image
            
            vc.title = ""
            
            return vc
            
        }
        
        tabController.viewControllers = vcs
        
        tabController.tabBar.barTintColor = UIColor(hexString: "#FFFFFF")
        
        tabController.tabBar.tintColor = UIColor(hexString: "#000000")
        
        tabController.tabBar.isTranslucent = false
        
        //tabController.delegate = tabBarDelegate
        
        if let items = tabController.tabBar.items {
            
            for item in items {
                
                if let image = item.image {
                    
                    item.image = image.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                    
                    item.title = ""
                    
                    item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
                }
                
            }
            
        }
        
        return tabController
        
    }
    
    /*
    func logout() {
        
        guard let userId = Auth.auth.currentUserId else { return }
        
        let session: String = "iossession"
        
        let parameters: Parameters = [
            "user_id" : userId,
            "s" : session as String
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.logoutURL(), method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            
            
        }
        
    }
    */
    
    func cancelSession() -> UIViewController? {
        
        guard let realm = LocalDatabaseManager.realm else { return nil }
        
        let users = realm.objects(LocalUser.self)
        
        do {
        
            try realm.write {
                
                users.setValue(false, forKeyPath: "isLoggedIn")
                
            }
            
        }
        catch let error as NSError {
            
            print(error.localizedDescription)
            
            return nil
            
        }
        
        let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
        
        return loginStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        
    }
    
    
}



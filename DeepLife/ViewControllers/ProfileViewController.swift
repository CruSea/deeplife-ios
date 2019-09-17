//
//  ProfileViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 14/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    func getProfile() {
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let dataParameters: Parameters = [
            "user_id" : currentUserId
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.getProfile() + "?user_id=" + currentUserId, method: .get, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            UIViewController.removeSpinner(spinner: sv)
            
            guard let strongSelf = self else { return }
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let userData = jsonData["user_data"].dictionaryObject {
                    
                    DispatchQueue.main.async {
                        
                        strongSelf.followersCountLabel.text = userData["followers_count"] as? String ?? "0"
                        
                        strongSelf.followersCountLabel.text = userData["following_count"] as? String ?? "0"
                        
                        strongSelf.nameLabel.text = userData["username"] as? String ?? ""
                        
                        if let profileImage = userData["avatar"] as? String {
                        
                            let profileImageURL = URL(string: "https://deeplife.africa/\(profileImage.trimmingCharacters(in: .whitespacesAndNewlines))")!
                            
                            strongSelf.profileImageView.af_setImage(withURL: profileImageURL)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func switchToDashboardButtonDidTouch(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        guard let window = appDelegate.window else {
            
            print("could not get window")
            
            return
            
        }
        
        window.rootViewController = Auth.auth.getDashboardWindowRoot()
    
    }
    
    @IBAction func logoutButtonDidTouch(_ sender: Any) {
        
        if let logoutVC = Auth.auth.cancelSession() {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            guard let window = appDelegate.window else {
                
                print("could not get window")
                
                return
                
            }
            
            window.rootViewController = logoutVC
            
        }
        
    }

}

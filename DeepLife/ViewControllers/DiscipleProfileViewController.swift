//
//  DiscipleProfileViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 21/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

import Alamofire

import AlamofireImage

import SwiftyJSON

class DiscipleProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var primaryCountLabel: UILabel!
    
    @IBOutlet weak var generationalCountLabel: UILabel!
    
    @IBOutlet weak var gospelCountLabel: UILabel!
    
    @IBOutlet weak var stageSegmentedControl: UISegmentedControl!
    
    var followerdId: Int?
    
    var disciple: User!
    
    weak var delegate: DisciplesProfileDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.masksToBounds = true
        
        getDiscipleData()
        
        getDiscipleCountData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
    }
    
    func getDiscipleData() {
        
        guard let followerId = followerdId else { return }
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        guard let currentUserIdAsInt = Int(currentUserId) else { return }
        
        if followerId == currentUserIdAsInt {
            
            return
            
        }
        
        let userDataParameters: Parameters = [
            "user_id" : followerId
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.getUserDataURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                var firstName: String = ""
                
                var lastName: String = ""
                
                if let _firstName = jsonData["user_data"]["first_name"].string {
                    
                    firstName = "\(_firstName) "
                    
                }
                
                if let _lastName = jsonData["user_data"]["last_name"].string {
                    
                    lastName = "\(_lastName) "
                    
                }
                
                let fullName: String = "\(firstName)\(lastName)"
                
                DispatchQueue.main.async {
                    
                    strongSelf.nameLabel.text = fullName
                    
                }
                
                if let avatarPath = jsonData["user_data"]["avatar"].string {
                    
                    let url = URL(string: "https://deeplife.africa/\(avatarPath)")!
                    
                    strongSelf.profileImageView.af_setImage(withURL: url)
                    
                }
                
                var deepStage: DeepStageType = DeepStageType.Win
                
                if let _deepStage = jsonData["user_data"]["deep_stage"].string {
                    
                    if _deepStage == "Win" {
                        
                        deepStage = DeepStageType.Win
                        
                    }
                    else if _deepStage == "Build" {
                        
                        deepStage = DeepStageType.Build
                        
                    }
                    else if _deepStage == "Send" {
                        
                        deepStage = DeepStageType.Send
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        strongSelf.stageSegmentedControl.selectedSegmentIndex = deepStage.rawValue
                        
                    }
                    
                }
                else {
                    
                    strongSelf.stageSegmentedControl.isUserInteractionEnabled = false
                    
                }
                
                let disciple = User(id: followerId, name: fullName, profileImage: jsonData["user_data"]["avatar"].string, stage: deepStage)
                
                strongSelf.disciple = disciple
                
            }
            else {
                
                print("could not get data")
                
            }
            
        }
        
    }
    
    func getDiscipleCountData() {
        
        guard let followerId = followerdId else { return }
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        guard let currentUserIdAsInt = Int(currentUserId) else { return }
        
        if followerId == currentUserIdAsInt {
            
            return
            
        }
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        let disciplesParameters: Parameters = [
            "user_id" : followerId
        ]
        
        Alamofire.request(APIRoute.shared.getDiscipleCountURL(), method: .post, parameters: disciplesParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                DispatchQueue.main.async {
                    
                    if let countDetails = jsonData["count_details"].dictionaryObject {
                        
                        var primaryCount: Int = 0
                        
                        var secondaryCount: Int = 0
                        
                        var exposureCount: Int = 0
                        
                        if let _primaryCount = countDetails["primary_count"] as? Int {
                            
                            primaryCount = _primaryCount
                            
                        }
                        
                        if let _secondaryCount = countDetails["secondary_count"] as? Int {
                            
                            secondaryCount = _secondaryCount
                            
                        }
                        
                        if let _exposureCount = countDetails["exposure_count"] as? Int {
                            
                            exposureCount = _exposureCount
                            
                        }
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.primaryCountLabel.text = "\(primaryCount)"
                            
                            strongSelf.generationalCountLabel.text = "\(secondaryCount)"
                            
                            strongSelf.gospelCountLabel.text = "\(exposureCount)"
                            
                        }
                        
                    }
                    
                }
                
            }
            else {
                
                print("could not get data")
                
            }
            
        }
        
    }
    
    func changeDiscipleDeep(stage: DeepStageType, alert: UIAlertController) {
        
        alert.dismiss(animated: true, completion: nil)
        
        guard let _followerId = followerdId else { return }
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let dataParameters: Parameters = [
            
            "user_id": _followerId,
            
            "deep_stage": stage.getDescription()
            
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.updateDeepStageURL(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Deep stage update failed.")
                    
                }
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let success = jsonData["api_text"].string {
                    
                    if success == "success" {
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.delegate?.refreshTableViews()
                            
                            strongSelf.stageSegmentedControl.selectedSegmentIndex = stage.rawValue
                            
                        }
                        
                    }
                    else {
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.reportError(message: "Deep stage update failed.")
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func reportError(message: String) {
        
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            errorAlert.dismiss(animated: true, completion: nil)
            
        }
        
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addGenerationalDiscipleSegue" {
            
            if let _disciple = disciple {
                
                guard let destinationVC = segue.destination as? NewDiscipleViewController else { return }
                
                destinationVC.mentor = _disciple
                
            }
            
        }
        
    }
    
    @IBAction func addDiscipleButtonDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "addGenerationalDiscipleSegue", sender: nil)
        
    }
    
    @IBAction func stageSegmentedControlDidTouch(_ sender: Any) {
        
        let index = stageSegmentedControl.selectedSegmentIndex
        
        guard let newDeepStage = DeepStageType(rawValue: index) else { return }
        
        guard let userDeepStage = disciple else { return }
        
        guard let currentDeepStage = DeepStageType(rawValue: userDeepStage.stage.rawValue) else { return }
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you would like to change this disciples' deep stage?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            self.changeDiscipleDeep(stage: newDeepStage, alert: alert)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
            self.stageSegmentedControl.selectedSegmentIndex = currentDeepStage.rawValue
            
            alert.dismiss(animated: true, completion: nil)
            
        }
        
        alert.addAction(cancelAction)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    

}

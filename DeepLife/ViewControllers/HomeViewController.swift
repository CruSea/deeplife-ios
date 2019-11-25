//
//  HomeViewController.swift
//  DeepLife
//
//

import UIKit

import AVFoundation

import Alamofire

import SwiftyJSON

import AlamofireImage

protocol SettingsDelegate: class {
    
    func logoutButtonDidTouch()
    
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var primaryDisciplesCountLabel: UILabel!
    
    @IBOutlet weak var generationalDisciplesCountLabel: UILabel!
    
    @IBOutlet weak var gospelDisciplesCountLabel: UILabel!
    
    @IBOutlet weak var disciplesView: UIView!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var disciplesButton: UIButton!
    
    @IBOutlet weak var discipleGraph: DiscipleBarGraph!
    
    let viewCoverOverlay = UIView()
    
    var customView: SettingsMenuView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Countries.shared.loadCountries()
        
        if let currentUserId = Auth.auth.currentUserId {
            
            print("current user id \(currentUserId)")
            
        }
        
        nameLabel.text = "--"
        
        profileImageView.image = nil

        interfaceSetup()
        
        //let disciplesViewTap = UITapGestureRecognizer(target: self, action: #selector(disciplesViewDidTap))
        
        //disciplesView.addGestureRecognizer(disciplesViewTap)
        
        //disciplesView.isUserInteractionEnabled = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        disciplesButton.layer.cornerRadius = CGFloat(5.0)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        createOverlays()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserData()
        
        getDiscipleCountData()
        
    }
    
    func interfaceSetup() {
        
        profileImageView.layer.masksToBounds = true
        
        infoView.layer.shadowOpacity = 0.2
        
        infoView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        disciplesView.layer.shadowOpacity = 0.2
        
        disciplesView.layer.shadowOffset = CGSize.zero
        
        disciplesView.layer.cornerRadius = CGFloat(5.0)
        
    }
    
    func createOverlays() {
        
        let settingsButtonFrame = settingsButton.frame
        
        viewCoverOverlay.backgroundColor = UIColor.black
        
        viewCoverOverlay.alpha = 0.0
        
        viewCoverOverlay.frame = CGRect(x: 0, y: 0, width: (view.window?.rootViewController?.view.frame.width)!, height: (view.window?.rootViewController?.view.frame.height)!)
        
        viewCoverOverlay.tag = 10110
        
        let viewOverlayTapped = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        
        viewCoverOverlay.addGestureRecognizer(viewOverlayTapped)
        
        customView = Bundle.main.loadNibNamed("SettingsMenuView", owner: self, options: nil)?.first as? SettingsMenuView
        
        customView?.tag = 20110
        
        customView?.delegate = self
        
        customView?.frame = CGRect(x: settingsButtonFrame.maxX - 200, y: settingsButtonFrame.maxY + 20, width: 200, height: 150)
        
        customView?.backgroundColor = UIColor.white
        
    }
    
    func getUserData() {
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        let userDataParameters: Parameters = [
            "user_id" : currentUserId
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
                
                DispatchQueue.main.async {
                    
                    if let userName = jsonData["user_data"]["username"].string {
                    
                        strongSelf.nameLabel.text = userName
                        
                    }
                    
                    if let firstName = jsonData["user_data"]["first_name"].string,
                        let deepStage = jsonData["userData"]["deep_stage"].string {
                        
                        var deepStageType = DeepStageType.Win
                        
                        if deepStage == "Win" {
                            
                            deepStageType = DeepStageType.Win
                            
                        }
                        else if deepStage == "Build" {
                            
                            deepStageType = DeepStageType.Build
                            
                        }
                        else if deepStage == "Send" {
                            
                            deepStageType = DeepStageType.Send
                            
                        }
                    
                        let profile = User(id: Int(currentUserId)!, name: firstName, profileImage: nil, stage: deepStageType)
                        
                        Auth.auth.profile = profile
                        
                    }
                    
                }
                
                if let avatarPath = jsonData["user_data"]["avatar"].string {
                    
                    let url = URL(string: "https://deeplife.africa/\(avatarPath)")!
                    
                    strongSelf.profileImageView.af_setImage(withURL: url)
                    
                    if let profile = Auth.auth.profile {
                        
                        profile.profileImage = "http://deeplife.africa/\(avatarPath)"
                        
                    }
                    
                }
                
            }
            else {
                
                print("could not get data")
                
            }
            
        }
        
    }
    
    func getDiscipleCountData() {
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        let disciplesParameters: Parameters = [
            "user_id" : currentUserId
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
                            
                            strongSelf.primaryDisciplesCountLabel.text = "\(primaryCount)"
                            
                            strongSelf.generationalDisciplesCountLabel.text = "\(secondaryCount)"
                            
                            strongSelf.gospelDisciplesCountLabel.text = "\(exposureCount)"
                            
                        }
                        
                        var primaryWinCount: Int = 0
                        
                        var secondaryWinCount: Int = 0
                        
                        var primaryBuildCount: Int = 0
                        
                        var secondaryBuildCount: Int = 0
                        
                        var primarySendCount: Int = 0
                        
                        var secondarySendCount: Int = 0
                        
                        if let _primaryWinCount = countDetails["primary_win_count"] as? Int {
                            
                            primaryWinCount = _primaryWinCount
                            
                        }
                        
                        if let _secondaryWinCount = countDetails["secondary_win_count"] as? Int {
                            
                            secondaryWinCount = _secondaryWinCount
                            
                        }
                        
                        if let _primaryBuildCount = countDetails["primary_build_count"] as? Int {
                            
                            primaryBuildCount = _primaryBuildCount
                            
                        }
                        
                        if let _secondaryBuildCount = countDetails["secondary_build_count"] as? Int {
                            
                            secondaryBuildCount = _secondaryBuildCount
                            
                        }
                        
                        if let _primarySendCount = countDetails["primary_send_count"] as? Int {
                            
                            primarySendCount = _primarySendCount
                            
                        }
                        
                        if let _secondarySendCount = countDetails["secondary_send_count"] as? Int {
                            
                            secondarySendCount = _secondarySendCount
                            
                        }
                        
                        let barGraphData: [BarGraphData] = [BarGraphData(label: "Win", primaryValue: Double(primaryWinCount), generationalValue: Double(secondaryWinCount)),
                                        BarGraphData(label: "Build", primaryValue: Double(primaryBuildCount), generationalValue: Double(secondaryBuildCount)),
                                        BarGraphData(label: "Send", primaryValue: Double(primarySendCount), generationalValue: Double(secondarySendCount))]
                        
                        strongSelf.discipleGraph.barGraphData = barGraphData
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.discipleGraph.renderGraph()
                            
                        }
                        
                    }
                    
                }
                
            }
            else {
                
                print("could not get data")
                
            }
            
        }
        
    }
    
    @objc func dismissMenu() {
        
        viewCoverOverlay.removeFromSuperview()
        
        self.customView?.removeFromSuperview()
        
    }
    
    /*
    @objc func disciplesViewDidTap() {
        
        performSegue(withIdentifier: "disciplesViewTapSegue", sender: nil)
        
    }
    */
    
    @IBAction func settingsButtonDidTouch(_ sender: Any) {
        
        view.window?.rootViewController?.view.addSubview(viewCoverOverlay)
        
        customView?.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        view.window?.rootViewController?.view.addSubview(customView!)
        
        let soundURL = Bundle.main.url(forResource: "click_08", withExtension: "wav")
        
        var soundID : SystemSoundID = 0
        
        AudioServicesCreateSystemSoundID(soundURL! as CFURL, &soundID)
        
        AudioServicesPlaySystemSound(soundID)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: [.curveEaseOut], animations: {
            self.customView?.transform = CGAffineTransform.identity
            self.viewCoverOverlay.alpha = 0.4
        }, completion: nil)
        
    }
    
    
//    @IBAction func addDiscipleButtonDidTouch(_ sender: Any) {
//
//        performSegue(withIdentifier: "addDisciplesSegue", sender: nil)
//
//    }
    
    @IBAction func disciplesButtonDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "disciplesViewTapSegue", sender: nil)
        
    }
    
    func reportError(message: String) {
        
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            errorAlert.dismiss(animated: true, completion: nil)
            
        }
        
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
        
    }
    
}

extension HomeViewController: SettingsDelegate {
    
    func logoutButtonDidTouch() {
        
        dismissMenu()
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        let session: String = "iossession"
        
        let userDataParameters: Parameters = [
            "user_id" : currentUserId,
            "s": session
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        Alamofire.request(APIRoute.shared.getUserDataURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Logout is not working right now. Please try later.")
                    
                }
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let apiText = jsonData["api_text"].string {
                    
                    if apiText == "success" {
                        
                        DispatchQueue.main.async {
                            
                            if let logoutVC = Auth.auth.cancelSession() {
                                
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                
                                guard let window = appDelegate.window else {
                                    
                                    DispatchQueue.main.async {
                                        
                                        strongSelf.reportError(message: "Something went wrong during login. Please try again.")
                                        
                                    }
                                    
                                    return
                                    
                                }
                                
                                window.rootViewController = logoutVC
                                
                            }
                            else {
                                
                                strongSelf.reportError(message: "Something went wrong while logging out. Please try again later.")
                                
                            }
                            
                        }
                        
                    }
                    else if apiText == "failed" {
                        
                        print("failed")
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.reportError(message: "Logout is not working right now. Please try later.")
                            
                        }
                        
                    }
                    
                }
                
            }
            else {
                
                print("could not get data")
                
            }
            
        }

    }
    
}

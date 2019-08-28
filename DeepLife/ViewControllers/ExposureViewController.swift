//
//  ExposureViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 12/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

import Alamofire

import SwiftyJSON

protocol ExposureDelegate: class {
    
    func refreshUI()
    
}

class ExposureViewController: UIViewController {
    
    @IBOutlet weak var radioTVView: UIView!
    
    @IBOutlet weak var crusadeView: UIView!
    
    @IBOutlet weak var oneOnOneView: UIView!
    
    @IBOutlet weak var jesusFilmView: UIView!
    
    @IBOutlet weak var socialMediaView: UIView!
    
    @IBOutlet weak var otherView: UIView!
    
    @IBOutlet weak var radioTVCountLabel: UILabel!
    
    @IBOutlet weak var crusadeCountLabel: UILabel!
    
    @IBOutlet weak var oneOnOneCountLabel: UILabel!
    
    @IBOutlet weak var jesusFilmCountLabel: UILabel!
    
    @IBOutlet weak var socialMediaCountLabel: UILabel!
    
    @IBOutlet weak var otherCountLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var allViews: [UIView] = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Exposure"
        
        allViews = [radioTVView, crusadeView, oneOnOneView, jesusFilmView, socialMediaView, otherView]
        
        for singleView in allViews {
            
            singleView.layer.cornerRadius = CGFloat(8.0)
            
            singleView.layer.borderColor = UIColor(hexString: "#979797").cgColor
            
            singleView.layer.borderWidth = CGFloat(1.0)
            
        }
        
        getExposure()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.removeTabbarItemsText()
        
    }
    
    @IBAction func addExposureButtonDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "addExposureSegue", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addExposureSegue" {
            
            guard let exposureVC = segue.destination as? NewExposureViewController else { return }
            
            exposureVC.delegate = self
            
        }
        
    }
    
    func getExposure() {
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        let userDataParameters: Parameters = [
            
            "user_id" : currentUserId
            
        ]
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        Alamofire.request(APIRoute.shared.getExposureURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Oops! Something went wrong. Please try again later.")
                    
                }
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let exposure = jsonData["exposure"].dictionaryObject {
                    
                    var radioTVCount: Int = 0
                    
                    if let _radioTVCount = exposure["radio_count"] as? Int {
                        
                        radioTVCount = _radioTVCount
                        
                    }
                    
                    var crusadeCount: Int = 0
                    
                    if let _crusadeCount = exposure["crusade_count"] as? Int {
                        
                        crusadeCount = _crusadeCount
                        
                    }
                    
                    var oneOnOneCount: Int = 0
                    
                    if let _oneOnOneCount = exposure["one_on_one_count"] as? Int {
                        
                        oneOnOneCount = _oneOnOneCount
                        
                    }
                    
                    var jesusFilmCount = 0
                    
                    if let _jesusFilmCount = exposure["jesus_count"] as? Int {
                        
                        jesusFilmCount = _jesusFilmCount
                        
                    }
                    
                    var otherCount: Int = 0
                    
                    if let _otherCount = exposure["other_count"] as? Int {
                        
                        otherCount = _otherCount
                        
                    }
                    
                    var socialMediaCount: Int = 0
                    
                    if let _socialMediaCount = exposure["social_count"] as? Int {
                        
                        socialMediaCount = _socialMediaCount
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        strongSelf.radioTVCountLabel.text = "\(radioTVCount)"
                        
                        strongSelf.crusadeCountLabel.text = "\(crusadeCount)"
                        
                        strongSelf.oneOnOneCountLabel.text = "\(oneOnOneCount)"
                        
                        strongSelf.jesusFilmCountLabel.text = "\(jesusFilmCount)"
                        
                        strongSelf.socialMediaCountLabel.text = "\(socialMediaCount)"
                        
                        strongSelf.otherCountLabel.text = "\(otherCount)"
                        
                    }
                    
                }
                
            }
            else {
                
                print("could not get data")
                
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
    

}

extension ExposureViewController: ExposureDelegate {
    
    func refreshUI() {

        getExposure()
        
    }
    
}

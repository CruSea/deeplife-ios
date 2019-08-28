//
//  SettingsMenuView.swift
//  DeepLife
//
//  Created by Gwinyai on 23/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class SettingsMenuView: UIView {
    
    @IBOutlet weak var termsButton: UIButton!
    
    @IBOutlet weak var privacyButton: UIButton!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    weak var delegate: SettingsDelegate?
    
    @IBAction func privacyButtonDidTouch(_ sender: Any) {
        
        guard let url = URL(string: "https://deeplife.africa/terms/privacy-policy") else { return }
        
        UIApplication.shared.open(url)
        
    }
    
    @IBAction func termsButtonDidTouch(_ sender: Any) {
        
        guard let url = URL(string: "https://deeplife.africa/terms/terms") else { return }
        
        UIApplication.shared.open(url)
        
    }
    
    @IBAction func logOutButtonDidTouch(_ sender: Any) {
        
        delegate?.logoutButtonDidTouch()
        
    }

}

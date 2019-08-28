//
//  GenderDataSource.swift
//  DeepLife
//
//  Created by Gwinyai on 15/11/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

enum GenderType: Int {
    
    case male, female
    
    func getDescription() -> String {
        
        switch self {
            
        case .male:
            
            return "male"
            
        case .female:
            
            return "female"
            
        }
        
    }
    
    static func getGenderOptions() -> [GenderType] {
    
        return [GenderType.male, GenderType.female]
    
    }
    
}

struct Gender {
    
    var genderType: GenderType
    
}

class GenderDataSource: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let genderOptions: [GenderType] = GenderType.getGenderOptions()
    
    var textColor: UIColor = UIColor.black
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return genderOptions.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return genderOptions[row].getDescription()
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let titleLabel = view as? UILabel {
            
            titleLabel.text = genderOptions[row].getDescription()
            
            return titleLabel
            
        } else {
            
            let titleLabel = UILabel()
            
            titleLabel.font = UIFont(name: "Roboto-Medium", size: 17)
            
            titleLabel.textAlignment = NSTextAlignment.center
            
            titleLabel.text = genderOptions[row].getDescription()
            
            titleLabel.textColor = textColor
            
            return titleLabel
            
        }
        
    }
    
    
}


//
//  ExposureDataSource.swift
//  DeepLife
//
//  Created by Gwinyai on 22/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

struct Exposure {
    
    var name: String
    
    var code: String
    
}

class ExposureDataSource: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let exposureOptions: [Exposure] = ExposureTypes.shared.getTypes()
    
    var textColor: UIColor = UIColor.black
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return exposureOptions.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return exposureOptions[row].name
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let titleLabel = view as? UILabel {
            
            titleLabel.text = exposureOptions[row].name
            
            return titleLabel
            
        } else {
            
            let titleLabel = UILabel()
            
            titleLabel.font = UIFont(name: "Roboto-Medium", size: 17)
            
            titleLabel.textAlignment = NSTextAlignment.center
            
            titleLabel.text = exposureOptions[row].name
            
            titleLabel.textColor = textColor
            
            return titleLabel
            
        }
        
    }
    
    
}

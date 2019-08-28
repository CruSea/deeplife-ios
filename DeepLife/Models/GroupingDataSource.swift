//
//  GroupingDataSource.swift
//  DeepLife
//
//  Created by Gwinyai on 15/11/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

class GroupingDataSource: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var textColor: UIColor = UIColor.black
    
    let groupingOptions: [String] = ["Student Led Movement", "Leader Impact", "Digital Strategies", "Jesus Film", "Global Church Movement", "Other"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return groupingOptions.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return groupingOptions[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let titleLabel = view as? UILabel {
            
            titleLabel.text = groupingOptions[row]
            
            return titleLabel
            
        } else {
            
            let titleLabel = UILabel()
            
            titleLabel.font = UIFont(name: "Roboto-Medium", size: 17)
            
            titleLabel.textAlignment = NSTextAlignment.center
            
            titleLabel.text = groupingOptions[row]
            
            titleLabel.textColor = textColor
            
            return titleLabel
            
        }
        
    }
    
    
}

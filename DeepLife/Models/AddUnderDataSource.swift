//
//  AddUnderDataSource.swift
//  DeepLife
//
//  Created by Gwinyai on 21/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

struct AddUnder {
    
    var name: String
    
    var followerId: Int
    
}

class AddUnderDataSource: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var addUnderOptions: [AddUnder] = [AddUnder]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return addUnderOptions.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return addUnderOptions[row].name
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let titleLabel = view as? UILabel {
            
            titleLabel.text = addUnderOptions[row].name
            
            return titleLabel
            
        } else {
            
            let titleLabel = UILabel()
            
            titleLabel.font = UIFont(name: "Roboto-Medium", size: 17)
            
            titleLabel.textAlignment = NSTextAlignment.center
            
            titleLabel.text = addUnderOptions[row].name
            
            return titleLabel
            
        }
        
    }
    
}

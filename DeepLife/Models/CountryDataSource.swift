//
//  CountryDataSource.swift
//  DeepLife
//
//

import Foundation

import UIKit

struct Country {
    
    var id: Int
    
    var name: String
    
}

class CountryDataSource: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var countryOptions: [Country] {
    
        return Countries.shared.allCountries
        
    }
    
    var textColor: UIColor = UIColor.black
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return countryOptions.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return countryOptions[row].name
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let titleLabel = view as? UILabel {
            
            titleLabel.text = countryOptions[row].name
            
            return titleLabel
            
        } else {
            
            let titleLabel = UILabel()
            
            titleLabel.font = UIFont(name: "Roboto-Medium", size: 17)
            
            titleLabel.textAlignment = NSTextAlignment.center
            
            titleLabel.textColor = textColor
            
            titleLabel.text = countryOptions[row].name
            
            return titleLabel
            
        }
        
    }
    
    
}

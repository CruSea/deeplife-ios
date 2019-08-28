//
//  Extensions.swift
//  DeepLife
//
//  Created by Gwinyai on 12/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

extension UIColor {
    
    convenience init(hexString:String) {
        
        let hexString:NSString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        
        let scanner            = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            
            scanner.scanLocation = 1
            
        }
        
        var color:UInt32 = 0
        
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        
        let r = Int(color >> 16) & mask
        
        let g = Int(color >> 8) & mask
        
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
}

extension UITabBarController {
    
    func removeTabbarItemsText() {
        
        if let items = tabBar.items {
            
            for item in items {
                
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
                
            }
            
        }
        
    }
    
}

extension UIViewController {
    
    class func displaySpinner(onView : UIView) -> UIView {
        
        let spinnerView = UIView.init(frame: onView.bounds)
        
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        
        ai.startAnimating()
        
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            
            spinnerView.addSubview(ai)
            
            onView.addSubview(spinnerView)
            
        }
        
        return spinnerView
        
    }
    
    class func removeSpinner(spinner: UIView) {
        
        DispatchQueue.main.async {
            
            spinner.removeFromSuperview()
            
        }
        
    }
    
}

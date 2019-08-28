//
//  TabBarDelegate.swift
//  DeepLife
//
//  Created by Gwinyai on 16/11/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

class TabBarDelegate: NSObject, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let selectedViewController = tabBarController.selectedViewController
        
        if selectedViewController == nil || viewController == selectedViewController {
            
            return false
            
        }
        
        guard let controllerIndex = tabBarController.viewControllers?.index(of: viewController) else {
            
            return true
            
        }
        
        guard let fromView = selectedViewController?.view else {
            
            return true
            
        }
        
        guard let toView = viewController.view else {
            
            return true
            
        }
        
        let viewSize: CGRect = fromView.frame
        
        let scrollRight: Bool = controllerIndex > tabBarController.selectedIndex
        
        fromView.superview?.addSubview(toView)
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        
        toView.frame = CGRect(x: scrollRight ? screenWidth : -screenWidth, y: viewSize.origin.y, width: screenWidth, height: viewSize.size.height)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            
            fromView.frame = CGRect(x: scrollRight ? -screenWidth : screenWidth, y: viewSize.origin.y, width: screenWidth, height: viewSize.size.height)
            
            toView.frame = CGRect(x: 0, y: viewSize.origin.y, width: screenWidth, height: viewSize.size.height)
            
        }) { (success) in
            
            if (success) {
                
                fromView.removeFromSuperview()
                
                tabBarController.selectedIndex = controllerIndex
                
            }
            
        }
        
        return false
        
    }
    
}

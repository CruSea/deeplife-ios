//
//  CustomSegmentedControl.swift
//  DeepLife
//
//  Created by Gwinyai on 18/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

protocol DisciplesControlDelegate: class {
    
    func scrollTo(index: Int)
    
}

class CustomSegmentedControl: UIView {
    
    var buttons = [UIButton]()
    
    var selector: UIView!
    
    var selectedSegmentIndex = 0
    
    let buttonTitles: [String] = ["Primary", "Generational"]
    
    let textColor: UIColor = .lightGray
    
    let selectorColor: UIColor = .black
    
    let selectorTextColor: UIColor = .black
    
    weak var delegate: DisciplesControlDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateView()
        
    }
    
    
    func updateView() {
        
        buttons.removeAll()
        
        subviews.forEach { (view) in
            
            view.removeFromSuperview()
            
        }
        
        for buttonTitle in buttonTitles {
            
            let button = UIButton.init(type: .system)
            
            button.setTitle(buttonTitle, for: .normal)
            
            button.setTitleColor(textColor, for: .normal)
            
            button.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 15)
            
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            
            buttons.append(button)
            
        }
        
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
        
        let selectorWidth = frame.width / CGFloat(buttonTitles.count)
        
        let y =  (self.frame.maxY - self.frame.minY) - 2.0
        
        selector = UIView.init(frame: CGRect.init(x: 0, y: y, width: selectorWidth, height: 2.0))
        
        selector.backgroundColor = selectorColor
        
        addSubview(selector)
        
        // Create a StackView
        
        let stackView = UIStackView.init(arrangedSubviews: buttons)
        
        stackView.axis = .horizontal
        
        stackView.alignment = .fill
        
        stackView.distribution = .fillEqually
        
        stackView.spacing = 0.0
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
    }
    
    @objc func buttonTapped(button: UIButton) {
        
        for (buttonIndex,btn) in buttons.enumerated() {
            
            btn.setTitleColor(textColor, for: .normal)
            
            if btn == button {
                
                selectedSegmentIndex = buttonIndex
                
                delegate?.scrollTo(index: selectedSegmentIndex)
                
            }
            
        }
        
    }
    
    
    func updateSegmentedControlSegs(index: Int) {
        
        for btn in buttons {
            
            btn.setTitleColor(textColor, for: .normal)
            
        }
        
        let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(index)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.selector.frame.origin.x = selectorStartPosition
        })
        
        buttons[index].setTitleColor(selectorTextColor, for: .normal)
        
    }
    
}
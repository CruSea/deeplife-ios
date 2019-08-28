//
//  Tasks.swift
//  DeepLife
//
//  Created by Gwinyai on 22/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

enum TaskStatus: Int {
    
    case completed, pending
    
    func taskColor() -> UIColor {
        
        switch self {
            
        case .completed:
            
            return UIColor.red
            
        case .pending:
            
            return UIColor.green
            
        }
        
    }
    
    func taskDescription() -> String {
        
        switch self {
            
        case .completed:
            
            return "Completed"
            
        case .pending:
            
            return "Pending"
            
        }
        
    }
    
}

struct Task {
    
    var taskId: String
    
    var taskTitle: String
    
    var taskDate: String
    
    var taskStatus: TaskStatus
    
    var taskDetails: String
    
}

//
//  DeepStage.swift
//  DeepLife
//
//  Created by Gwinyai on 14/11/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

enum DeepStageType: Int {
    
    case Win, Build, Send
    
    func getDescription() -> String {
        
        switch self {
            
        case .Win:
            
            return "Win"
            
        case .Build:
            
            return "Build"
            
        case .Send:
            
            return "Send"
            
        }
        
    }
    
}

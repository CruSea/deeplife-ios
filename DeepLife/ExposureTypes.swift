//
//  ExposureTypes.swift
//  DeepLife
//
//  Created by Gwinyai on 8/11/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

class ExposureTypes {
    
    static let shared = ExposureTypes()
    
    var allTypes: [Exposure] {
        
        return getTypes()
        
    }
    
    func getTypes() -> [Exposure] {
        
        var exposureList: [Exposure] = [Exposure]()
        
        exposureList.append(Exposure(name: "One on One", code: "one_on_one"))
        
        exposureList.append(Exposure(name: "Crusade", code: "crusade"))
        
        exposureList.append(Exposure(name: "Jesus Film", code: "jesus_film"))
        
        exposureList.append(Exposure(name: "Radio/TV", code: "radio_tv"))
        
        exposureList.append(Exposure(name: "Social Media", code: "social_media"))
        
        return exposureList
        
    }
    
}

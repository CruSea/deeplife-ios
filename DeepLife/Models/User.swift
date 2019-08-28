//
//  User.swift
//  DeepLife
//
//  Created by Gwinyai on 18/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

import RealmSwift

class User {
    
    var id: Int
    
    var name: String
    
    var profileImage: String?
    
    var stage: DeepStageType
    
    init(id: Int, name: String, profileImage: String?, stage: DeepStageType) {
        
        self.id = id
        
        self.name = name
        
        self.profileImage = profileImage
        
        self.stage = stage
        
    }
    
}

class LocalUser: Object {
    
    override static func primaryKey() -> String? {
        
        return "id"
        
    }
    
    @objc dynamic var id = 0
    
    @objc dynamic var isLoggedIn: Bool = false
    
    @objc dynamic var sessionId: String = ""
    
}

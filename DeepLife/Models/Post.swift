//
//  Post.swift
//  DeepLife
//
//  Created by Gwinyai on 14/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

enum PostType {
    case image, text
}

class Post {
    var postId: String
    var description: String
    var createdDate: String
    var imagePath: String
    var authorName: String
    var authorImagePath: String
    var commentsCount: Int
    var likesCount: Int
    var postType: PostType
    var authorId: String
    var isLiked: Bool
    
    init(postId: String, description: String, createdDate: String, imagePath: String, authorName: String, authorImagePath: String, commentsCount: Int, likesCount: Int, postType: PostType, authorId: String, isLiked: Bool) {
        
        self.postId = postId
        self.description = description
        self.createdDate = createdDate
        self.imagePath = imagePath
        self.authorName = authorName
        self.authorImagePath = authorImagePath
        self.commentsCount = commentsCount
        self.likesCount = likesCount
        self.postType = postType
        self .authorId = authorId
        self.isLiked = isLiked
        
    }
    
}

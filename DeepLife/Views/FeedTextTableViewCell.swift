//
//  FeedTextTableViewCell.swift
//  DeepLife
//
//  Created by Gwinyai on 13/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class FeedTextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorNameLabel: UIButton!
    @IBOutlet weak var authorAvatarImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var viewCommentsButton: UIButton!
    @IBOutlet weak var postDateLabel: UILabel!
    var post: Post?
    weak var feedDelegate: FeedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        authorAvatarImageView.layer.cornerRadius = authorAvatarImageView.frame.width / 2
        authorAvatarImageView.layer.masksToBounds = true
        selectionStyle = UITableViewCell.SelectionStyle.none
        likeButton.setImage(UIImage(named: "did_like_icon"), for: .selected)
        likeButton.setImage(UIImage(named: "like_icon"), for: .normal)
    }

    @IBAction func likeButtonDidTouch(_ sender: Any) {
        guard let post = self.post else { return }
        if post.isLiked {
            likeButton.isSelected = false
            post.likesCount -= 1
        } else {
            likeButton.isSelected = true
            post.likesCount += 1
        }
        likeCountLabel.text = "\(post.likesCount) likes"
        feedDelegate?.likeButtonDidTouch(postId: post.postId)
    }
    
    @IBAction func commentsButtonDidTouch(_ sender: Any) {
        guard let post = self.post else { return }
        feedDelegate?.commentsButtonDidTouch(postId: post.postId)
    }
    
    @IBAction func viewCommentsButtonDidTouch(_ sender: Any) {
        guard let post = self.post else { return }
        feedDelegate?.commentsButtonDidTouch(postId: post.postId)
    }
    
    @IBAction func reportButtonDidTouch(_ sender: Any) {
    }
    
}

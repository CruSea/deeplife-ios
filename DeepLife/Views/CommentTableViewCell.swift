//
//  CommentTableViewCell.swift
//  DeepLife
//
//  Created by Gwinyai on 14/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var comment: Comment?
    weak var delegate: CommentsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func reportButtonDidTouch(_ sender: Any) {
    }
    
}

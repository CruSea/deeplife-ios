//
//  GroupTableViewCell.swift
//  DeepLife
//
//  Created by Gwinyai on 15/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    var group: Group?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
}

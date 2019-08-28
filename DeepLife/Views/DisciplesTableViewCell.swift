//
//  DisciplesTableViewCell.swift
//  DeepLife
//
//

import UIKit

class DisciplesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var stageLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.masksToBounds = true
        
        selectionStyle = .none
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
    }
    
}

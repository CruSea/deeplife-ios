//
//  TasksTableViewCell.swift
//  DeepLife
//
//  Created by Gwinyai on 22/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class TasksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskStripView: UIView!
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    @IBOutlet weak var taskDateLabel: UILabel!
    
    @IBOutlet weak var taskCompletionLabel: UILabel!
    
    @IBOutlet weak var taskMainView: UIView!
    
    weak var delegate: TasksDelegate?
    
    var taskId: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        
        taskMainView.layer.shadowOpacity = 0.2
        
        taskMainView.layer.shadowOffset = CGSize.zero
        
        //taskMainView.layer.masksToBounds = true
        
        let taskViewTap = UITapGestureRecognizer(target: self, action: #selector(taskViewDidTap))
        
        taskMainView.addGestureRecognizer(taskViewTap)
        
        taskMainView.isUserInteractionEnabled = true
        
    }
    
    @objc func taskViewDidTap() {
        
        delegate?.taskViewDidTouch(taskId: taskId)
        
    }
    
    func setupCell(task: Task) {
        
        taskStripView.backgroundColor = task.taskStatus.taskColor()
        
        taskTitleLabel.text = task.taskTitle
        
        taskDateLabel.text = task.taskDate
        
        taskCompletionLabel.text = task.taskStatus.taskDescription()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        taskMainView.layer.cornerRadius = CGFloat(5.0)
        
    }
    
}

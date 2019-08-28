//
//  TaskDetailsViewController.swift
//  DeepLife
//
//

import UIKit

import Alamofire

import SwiftyJSON

class TaskDetailsViewController: UIViewController {
    
    var taskId: String = ""
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    @IBOutlet weak var taskStatusLabel: UILabel!
    
    @IBOutlet weak var taskDateLabel: UILabel!
    
    @IBOutlet weak var taskDetailsLabel: UILabel!
    
    @IBOutlet weak var completeTaskButton: UIButton!
    
    weak var delegate: TasksDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        taskTitleLabel.text = ""
        
        taskStatusLabel.text = ""
        
        taskDateLabel.text = ""
        
        completeTaskButton.isUserInteractionEnabled = false
        
        self.navigationItem.backBarButtonItem?.title = ""
        
        title = "Task Details"
        
        getTaskDetails()
        
    }
    
    func getTaskDetails() {
        
        guard let taskId = Int(taskId) else { return }
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let dataParameters: Parameters = [
            
            "task_id" : taskId
            
        ]
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        Alamofire.request(APIRoute.shared.getTaskDetailsURL(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            UIViewController.removeSpinner(spinner: sv)
            
            guard let strongSelf = self else { return }
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let taskDetails = jsonData["task_details"].dictionaryObject {
                    
                    var taskName = "No Task Name"
                    
                    if let name = taskDetails["task_name"] as? String {
                    
                        taskName = name
                        
                    }
                    
                    var taskStartDate = "N/A"
                    
                    var taskEndDate = "N/A"
                    
                    if let startDate = taskDetails["task_start_date"] as? String {
                        
                        taskStartDate = startDate
                        
                    }
                    
                    if let endDate = taskDetails["task_end_date"] as? String {
                        
                        taskEndDate = endDate
                        
                    }
                    
                    let taskDate: String = "From \(taskStartDate) to \(taskEndDate)"
                    
                    var taskStatus: String = "Pending"
                    
                    if let status = taskDetails["status"] as? String {
                        
                        taskStatus = status
                        
                    }
                    
                    var details = "No Details"
                    
                    if let taskDetails = taskDetails["task_details"] as? String {
                        
                        details = taskDetails
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        strongSelf.taskTitleLabel.text = taskName
                        
                        strongSelf.taskDateLabel.text = taskDate
                        
                        strongSelf.taskStatusLabel.text = taskStatus
                        
                        strongSelf.taskStatusLabel.textColor = taskStatus == "Pending" ? TaskStatus.pending.taskColor() : TaskStatus.completed.taskColor()
                        
                        if taskStatus == TaskStatus.completed.taskDescription() {
                            
                            strongSelf.completeTaskButton.isUserInteractionEnabled = false
                            
                            strongSelf.completeTaskButton.backgroundColor = UIColor(hexString: "#D8D8D8")
                            
                        }
                        else {
                            
                            strongSelf.completeTaskButton.isUserInteractionEnabled = true
                            
                        }
                        
                        strongSelf.taskDetailsLabel.text = details
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func markCompleteButtonDidTouch(_ sender: Any) {
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you would like to mark this task as completed?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            self.completeTask(alert: alert)
            
        }
        
        let noAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }
        
        alert.addAction(okAction)
        
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func completeTask(alert: UIAlertController) {
        
        alert.dismiss(animated: true, completion: nil)
        
        guard let taskId = Int(taskId) else { return }
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let dataParameters: Parameters = [
            
            "task_id": taskId,
            
            "status": "Completed"
            
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.updateTaskStatusURL(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let success = jsonData["api_text"].string {
                    
                    if success == "success" {
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.delegate?.refreshUI()
                            
                            strongSelf.taskStatusLabel.text = TaskStatus.completed.taskDescription()
                            
                            strongSelf.taskStatusLabel.textColor = TaskStatus.completed.taskColor()
                            
                            strongSelf.completeTaskButton.isUserInteractionEnabled = false
                            
                            strongSelf.completeTaskButton.backgroundColor = UIColor(hexString: "#D8D8D8")
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    

}

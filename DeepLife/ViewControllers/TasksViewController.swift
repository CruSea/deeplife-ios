//
//  TasksViewController.swift
//  DeepLife
//
//

import UIKit

import Alamofire

import SwiftyJSON

protocol TasksDelegate: class {
    
    func taskViewDidTouch(taskId: String)
    
    func refreshUI()
    
}

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    /*
    lazy var data: [Task] = {
        
        let taskMockData = TaskMockData()
        
        return taskMockData.data
        
    }()
     */
    
    var data: [Task] = [Task]()
    
    var activeField: UITextField?
    
    private final let BORDER_WIDTH: CGFloat = CGFloat(1.0)
    
    var nonActiveBorder: CALayer {
        
        get {
            
            let layer = CALayer()
            
            layer.borderColor = UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0).cgColor
            
            layer.borderWidth = BORDER_WIDTH
            
            layer.name = "1234"
            
            return layer
            
        }
        
    }
    
    var activeBorder: CALayer {
        
        get {
            
            let layer = CALayer()
            
            layer.borderColor = Colors.themeYellow?.cgColor
            
            layer.borderWidth = BORDER_WIDTH
            
            layer.name = "5678"
            
            return layer
            
        }
        
    }
    
    var textFieldsAndLabels: [(UITextField, UILabel)] = [(UITextField, UILabel)]()
    
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(TasksViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "TasksTableViewCell", bundle: nil), forCellReuseIdentifier: "TasksTableViewCell")
        
        tableView.tableFooterView = UIView()
        
        tableView.separatorStyle = .none
        
        tableView.addSubview(self.refreshControl)
        
        title = "Tasks"
        
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        
        self.navigationController?.navigationItem.backBarButtonItem?.title = ""
        
        getTasks()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.removeTabbarItemsText()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(146.0)
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "taskDetailsSegue", sender: data[indexPath.row].taskId)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksTableViewCell") as! TasksTableViewCell
        
        cell.setupCell(task: data[indexPath.row])
        
        cell.taskId = data[indexPath.row].taskId
        
        cell.delegate = self
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "taskDetailsSegue" {
            
            guard let taskDetailsVC = segue.destination as? TaskDetailsViewController else { return }
            
            guard let taskId = sender as? String else { return }
            
            taskDetailsVC.taskId = taskId
            
            taskDetailsVC.delegate = self
            
        }
        else if segue.identifier == "addTaskSegue" {
            
            guard let addTaskVC = segue.destination as? AddTaskViewController else { return }
            
            addTaskVC.delegate = self
            
        }
        
    }
    
    func getTasks() {
        
        guard let currentUserId = Auth.auth.currentUserId else {
            
            if refreshControl.isRefreshing {
                
                refreshControl.endRefreshing()
                
            }
            
            return
            
        }
        
        if !refreshControl.isRefreshing {
            
            refreshControl.beginRefreshing()
            
        }
        
        let userDataParameters: Parameters = [
            
            "user_id" : currentUserId
            
        ]
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        Alamofire.request(APIRoute.shared.getTaskListURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            if strongSelf.refreshControl.isRefreshing {
                
                DispatchQueue.main.async {
                    
                    strongSelf.refreshControl.endRefreshing()
                    
                }
                
            }
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let taskList = jsonData["task_list"].arrayObject {
                    
                    strongSelf.data = [Task]()
                    
                    for taskItem in taskList {
                        
                        guard let task = taskItem as? [String: Any] else {
                            
                            continue
                            
                        }
                        
                        guard let id = task["id"] as? String else { continue }
                        
                        var taskName: String = ""
                        
                        var taskStartDate: String = ""
                        
                        var taskEndDate: String = ""
                        
                        var taskStatus: String = ""
                        
                        var taskDetails: String = ""
                        
                        if let name = task["task_name"] as? String {
                            
                            taskName = name
                            
                        }
                        
                        if let startDate = task["task_start_date"] as? String {
                            
                            taskStartDate = startDate
                            
                        }
                        
                        if let endDate = task["task_end_date"] as? String {
                            
                            taskEndDate = endDate
                            
                        }
                        
                        if let status = task["status"] as? String {
                            
                            taskStatus = status
                            
                        }
                        
                        if let details = task["details"] as? String {
                            
                            taskDetails = details
                            
                        }
                        
                        var status: TaskStatus = TaskStatus.completed
                        
                        if taskStatus == "Completed" {
                            
                            status = TaskStatus.completed
                            
                        }
                        else {
                            
                            status = TaskStatus.pending
                            
                        }
                        
                        let newTask = Task(taskId: id, taskTitle: taskName, taskDate: "\(taskStartDate) to \(taskEndDate)", taskStatus: status, taskDetails: taskDetails)
                        
                        strongSelf.data.append(newTask)
                        
                    }
                    
                }
                
                DispatchQueue.main.async {
                    
                    strongSelf.tableView.reloadData()
                    
                }
                
            }
            else {
                
                print("could not get data")
                
            }
            
        }
        
    }
    
    @IBAction func addButtonDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "addTaskSegue", sender: nil)
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        getTasks()
        
    }

}

extension TasksViewController: TasksDelegate {
    
    func taskViewDidTouch(taskId: String) {
        
        performSegue(withIdentifier: "taskDetailsSegue", sender: taskId)
        
    }
    
    func refreshUI() {
        
        DispatchQueue.main.async {
            
            self.getTasks()
            
        }
        
    }
    
}

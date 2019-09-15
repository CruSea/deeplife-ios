//
//  GroupsViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 14/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GroupsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(GroupsViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
        
    }()
    
    var groups: [Group] = [Group]()
    var shouldRefresh: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = CGFloat(88.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        title = "Groups"
        getGroups()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getGroups()
    }
    
    func getGroups() {
        
        guard let currentUserId = Auth.auth.currentUserId else {
            return
        }
        
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
//        let userDataParameters: Parameters = [
//            "user_id" : currentUserId
//        ]
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        Alamofire.request(APIRoute.shared.getGroupsURL() + "?user_id=" + currentUserId, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
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
                if let groupList = jsonData["user_group"].arrayObject {
                    strongSelf.groups = [Group]()
                    for groupItem in groupList {
                        guard let group = groupItem as? [String: Any] else {
                            continue
                        }
                        guard let groupId = group["id"] as? String else { continue }
                        let groupTitle: String = group["group_title"] as? String ?? ""
                        let avatar: String = group["avatar"] as? String ?? ""
                        let active: Int = Int(group["active"] as? String ?? "0")!
                        let newGroup = Group(groupId: groupId, groupName: groupTitle, memberCount: active, imagePath: avatar)
                        strongSelf.groups.append(newGroup)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GroupDetailSegue" {
            let destinationVC = segue.destination as! GroupChatViewController
            guard let group = sender as? Group else { return }
            destinationVC.groupId = group.groupId
        }
    }

}

extension GroupsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGroup = groups[indexPath.row]
        performSegue(withIdentifier: "GroupDetailSegue", sender: selectedGroup)
    }
    
}

extension GroupsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = groups[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell
        cell.groupNameLabel.text = group.groupName
        let groupImageURL = URL(string: "https://deeplife.africa/\(group.imagePath.trimmingCharacters(in: .whitespacesAndNewlines))")!
        cell.groupImageView.af_setImage(withURL: groupImageURL)
        cell.memberCountLabel.text = "\(group.memberCount) members"
        return cell
    }
    
}

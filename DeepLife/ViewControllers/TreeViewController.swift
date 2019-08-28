//
//  TreeViewController.swift
//  DeepLife
//
//

import UIKit

import Alamofire

import SwiftyJSON

class TreeViewController: UIViewController {
    
    @IBOutlet weak var treeView: TreeView!
    
    var rootNode: Node!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tree"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getTreeData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.removeTabbarItemsText()
        
    }
    
    func getTreeData() {
        
        if let profile = Auth.auth.profile {
            
            rootNode = Node(label: profile.name, profile: profile)
            
        }
        else {
            
            var userId: Int = 0
            
            if let currentUserId = Auth.auth.currentUserId,
                let _currentUserId = Int(currentUserId) {
                
                userId = _currentUserId
                
            }
            
            let mockProfile = User(id: userId, name: "Me", profileImage: nil, stage: DeepStageType.Win)
            
            rootNode = Node(label: "Me", profile: mockProfile)
            
        }
        
        guard let currentUserId = Auth.auth.currentUserId else {
            
            return
            
        }
        
        let dataParameters: Parameters = [
            
            "user_id" : currentUserId
            
        ]
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        Alamofire.request(APIRoute.shared.getTreeURL(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                var i = 1
                
                var previousNodes: [Node] = [Node]()
                
                while(true) {
                    
                    guard let nodes = jsonData["tree"]["\(i)"].arrayObject else {
                        
                        break
                        
                    }
                    
                    var newPreviousNodes: [Node] = [Node]()
                    
                    if i == 1 {
                        
                        //primary level. All nodes parent is the root node
                        for nodeItem in nodes {
                            
                            guard let node = nodeItem as? [String: Any] else {
                                
                                continue
                                
                            }
                            
                            if let id = node["follower_id"] as? String,
                                let deepStage = node["deep_stage"] as? String,
                                let name = node["first_name"] as? String {
                                
                                var deepStageType = DeepStageType.Win
                                
                                if deepStage == "Win" {
                                    
                                    deepStageType = DeepStageType.Win
                                    
                                }
                                else if deepStage == "Build" {
                                    
                                    deepStageType = DeepStageType.Build
                                    
                                }
                                else if deepStage == "Send" {
                                    
                                    deepStageType = DeepStageType.Send
                                    
                                }
                                
                                let profile = User(id: Int(id)!, name: name, profileImage: node["avatar"] as? String, stage: deepStageType)
                                
                                let finalNode = Node(label: name, profile: profile)
                                
                                strongSelf.rootNode.children.append(finalNode)
                                
                                newPreviousNodes.append(finalNode)
                                
                            }
                            
                        }
                        
                    }
                    else {
                        //generational level. Find the correct parent node
                        
                        for nodeItem in nodes {
                            
                            guard let node = nodeItem as? [String: Any] else {
                                
                                continue
                                
                            }
                            
                            if let id = node["follower_id"] as? String,
                                let deepStage = node["deep_stage"] as? String,
                                let name = node["first_name"] as? String,
                                let followingId = node["following_id"] as? String,
                                let mentorId = Int(followingId) {
                                
                                var deepStageType = DeepStageType.Win
                                
                                if deepStage == "Win" {
                                    
                                    deepStageType = DeepStageType.Win
                                    
                                }
                                else if deepStage == "Build" {
                                    
                                    deepStageType = DeepStageType.Build
                                    
                                }
                                else if deepStage == "Send" {
                                    
                                    deepStageType = DeepStageType.Send
                                    
                                }
                                
                                let profile = User(id: Int(id)!, name: name, profileImage: node["avatar"] as? String, stage: deepStageType)
                                
                                let finalNode = Node(label: name, profile: profile)
                                
                                newPreviousNodes.append(finalNode)
                                
                                if let parentNode = previousNodes.first(where: { (node) -> Bool in
                                    
                                    return node.profile.id == mentorId
                                    
                                }) {
                                    
                                    parentNode.children.append(finalNode)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    previousNodes.removeAll()
                    
                    previousNodes = newPreviousNodes
                    
                    i += 1
                    
                }
                
                DispatchQueue.main.async {
                    
                    strongSelf.treeView.renderTree(node: strongSelf.rootNode)
                    
                }
                
            }
            else {
                
                print("could not get data")
                
            }
            
        }
        
        
    }

}

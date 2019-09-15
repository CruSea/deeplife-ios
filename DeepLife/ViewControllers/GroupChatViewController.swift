//
//  GroupChatViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 15/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GroupChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var groupId: String?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(GroupChatViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
        
    }()
    
    var posts: [Post] = [Post]()
    var shouldRefresh: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = CGFloat(88.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "FeedImageTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedImageTableViewCell")
        tableView.register(UINib(nibName: "FeedTextTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTextTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        title = "Group Chat"
        getPosts()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getPosts()
    }
    
    func getPosts() {
        
        guard let groupId = self.groupId else { return }
        
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.getGroupPostsURL() + "?group_id=" + groupId, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
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
                if let postList = jsonData["user_group"].arrayObject {
                    strongSelf.posts = [Post]()
                    for postItem in postList {
                        guard let post = postItem as? [String: Any] else {
                            continue
                        }
                        guard let postId = post["id"] as? String else { continue }
                        let postText: String = post["postText"] as? String ?? ""
                        var postType: PostType = PostType.text
                        var postImagePath: String = ""
                        if let postFile = post["postFile"] as? String,
                            postFile != "" {
                            postImagePath = postFile
                            postType = .image
                        }
                        
                        let postAuthorName: String = post["username"] as? String ?? ""
                        let postAuthorAvatar: String = post["avatar"] as? String ?? ""
                        let commentCount: Int = Int(post["comments_count"] as? String ?? "0")!
                        let likesCount: Int = Int(post["like_count"] as? String ?? "0")!
                        let createdDate: String = post["registered"] as? String ?? ""
                        let authorId: String = ""
                        let isLiked: Bool = post["is_liked"] as? Bool ?? false
                        
                        let newPost = Post(postId: postId,
                                           description: postText,
                                           createdDate: createdDate,
                                           imagePath: postImagePath,
                                           authorName: postAuthorName,
                                           authorImagePath: postAuthorAvatar,
                                           commentsCount: commentCount,
                                           likesCount: likesCount,
                                           postType: postType,
                                           authorId: authorId,
                                           isLiked: isLiked)
                        
                        strongSelf.posts.append(newPost)
                        
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
    
}

extension GroupChatViewController: UITableViewDelegate {
    
    
    
}

extension GroupChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        switch post.postType {
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageTableViewCell") as! FeedImageTableViewCell
            cell.authorNameLabel.setTitle(post.authorName, for: .normal)
            let authorAvatarUrl = URL(string: "https://deeplife.africa/\(post.authorImagePath)")!
            cell.authorAvatarImageView.af_setImage(withURL: authorAvatarUrl)
            let postImageUrl = URL(string: "https://deeplife.africa/\(post.imagePath)")!
            cell.postImageView.af_setImage(withURL: postImageUrl)
            let commentsCount = post.commentsCount
            let commentTitle = post.commentsCount > 0 ? "View \(commentsCount) comments" : "View comments"
            cell.viewCommentsButton.setTitle(commentTitle, for: .normal)
            cell.commentLabel.text = post.description
            cell.likeCountLabel.text = "\(post.likesCount) likes"
            cell.postDateLabel.text = post.createdDate
            cell.feedDelegate = self
            cell.post = post
            if post.isLiked {
                cell.likeButton.isSelected = true
            } else {
                cell.likeButton.isSelected = false
            }
            return cell
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTextTableViewCell") as! FeedTextTableViewCell
            cell.authorNameLabel.setTitle(post.authorName, for: .normal)
            let authorAvatarUrl = URL(string: "https://deeplife.africa/\(post.authorImagePath)")!
            cell.authorAvatarImageView.af_setImage(withURL: authorAvatarUrl)
            let commentsCount = post.commentsCount
            let commentTitle = post.commentsCount > 0 ? "View \(commentsCount) comments" : "View comments"
            cell.viewCommentsButton.setTitle(commentTitle, for: .normal)
            cell.commentLabel.text = post.description
            cell.likeCountLabel.text = "\(post.likesCount) likes"
            cell.postDateLabel.text = post.createdDate
            cell.feedDelegate = self
            cell.post = post
            if post.isLiked {
                cell.likeButton.isSelected = true
            } else {
                cell.likeButton.isSelected = false
            }
            return cell
        }
    }
    
}

extension GroupChatViewController: FeedDelegate {
    
    func commentsButtonDidTouch(postId: String) {
        let feedStoryboard = UIStoryboard(name: "Feed", bundle: nil)
        let commentsVC = feedStoryboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsViewController
        commentsVC.postId = postId
        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func likeButtonDidTouch(postId: String) {
        guard let currentUserId = Auth.auth.currentUserId else {
            return
        }
        //        let userDataParameters: Parameters = [
        //            "user_id" : currentUserId
        //        ]
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        Alamofire.request(APIRoute.shared.getLikeURL() + "?user_id=" + currentUserId + "&post_id=" + postId, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (data) in
            if let error = data.error {
                print("an error occured")
                print(error.localizedDescription)
                return
            }
        }
    }
    
}

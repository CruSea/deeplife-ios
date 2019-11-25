//
//  FeedViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 13/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol FeedDelegate: class {
    func likeButtonDidTouch(postId: String)
    func commentsButtonDidTouch(postId: String)
}

class FeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeedViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.black
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
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
//        var leftBarItemImage = UIImage(named: "camera_nav_icon")
//        leftBarItemImage = leftBarItemImage?.withRenderingMode(.alwaysOriginal)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarItemImage, style: .plain, target: self, action: #selector(newPostButtonDidTouch))
        title = "Social"
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = Colors.themeYellow
        getPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldRefresh {
            shouldRefresh = false
            getPosts()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.removeTabbarItemsText()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getPosts()
    }
    
    func getPosts() {
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
        Alamofire.request(APIRoute.shared.getFeedURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
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
                if let postList = jsonData["data"].arrayObject {
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
                        let authorId: String = currentUserId
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
    
//    @objc func newPostButtonDidTouch() {
//        let newPostStoryboard = UIStoryboard(name: "NewPost", bundle: nil)
//        let newPostVC = newPostStoryboard.instantiateViewController(withIdentifier: "NewPost") as! NewPostViewController
//        let navController = UINavigationController(rootViewController: newPostVC)
//        self.shouldRefresh = true
//        self.present(navController, animated: true, completion: nil)
//    }

}

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension FeedViewController: UITableViewDataSource {
    
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

extension FeedViewController: FeedDelegate {
    
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

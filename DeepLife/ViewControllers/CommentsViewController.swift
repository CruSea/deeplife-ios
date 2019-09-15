//
//  CommentsViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 14/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol CommentsDelegate: class {
    func reportButtonDidTouch(commentId: String)
}

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    var comments: [Comment] = [Comment]()
    var postId: String?
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(CommentsViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.addSubview(self.refreshControl)
        title = "Comments"
        fetchComments()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        fetchComments()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        let rect:CGRect = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let duration = ((notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        self.keyboardConstraint.constant = rect.height - tabBarHeight
        UIView.animate(withDuration: duration!, animations: {
            self.view.layoutSubviews()
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let duration = ((notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        self.keyboardConstraint.constant = 0
        UIView.animate(withDuration: duration!, animations: {
            self.view.layoutSubviews()
        })
    }
    
    func fetchComments() {
        guard let postId = postId else { return }
        guard let currentUserId = Auth.auth.currentUserId else {
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
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
        Alamofire.request(APIRoute.shared.getCommentsURL() + "?post_id=" + postId, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
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
                if let commentList = jsonData["post_data"].arrayObject {
                    strongSelf.comments = [Comment]()
                    for commentItem in commentList {
                        guard let comment = commentItem as? [String: Any] else {
                            continue
                        }
                        guard let commentId = comment["id"] as? String else { continue }
                        let username: String = comment["username"] as? String ?? ""
                        let commentText: String = comment["text"] as? String ?? ""
                        let commentAuthorAvatar: String = comment["avatar"] as? String ?? ""
                        let commentDate: String = comment["time"] as? String ?? ""
                        
                        let newComment = Comment(commentId: commentId,
                                                 caption: commentText,
                                                 date: commentDate,
                                                 authorName: username,
                                                 authorImage: commentAuthorAvatar,
                                                 userId: currentUserId)
                        
                        strongSelf.comments.append(newComment)
                        
                    }
                    
                    strongSelf.comments.reverse()
                    
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
    
    @IBAction func postButtonDidTouch(_ sender: Any) {
        
        guard let postId = postId else { return }
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        guard let commentText = commentsTextView.text else { return }
        if commentText.count <= 10 {
            let alert = UIAlertController(title: "Incomplete Comment", message: "Please make your comment more than 10 characters long", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let dataParameters: Parameters = [
            "user_id": currentUserId,
            "text": commentText,
            "post_id": postId
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.getCreateCommentURL(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            UIViewController.removeSpinner(spinner: sv)
            if let error = data.error {
                print("an error occured")
                print(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.commentsTextView.text = nil
                strongSelf.fetchComments()
            }
            
        }
        
    }

}

extension CommentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension CommentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
        cell.commentLabel.text = comment.caption
        let authorImageURL = URL(string: "https://deeplife.africa/\(comment.authorImage)")!
        cell.profileImageView.af_setImage(withURL: authorImageURL)
        cell.usernameButton.setTitle(comment.authorName, for: .normal)
        cell.comment = comment
        cell.delegate = self
        return cell
    }
    
}

extension CommentsViewController: CommentsDelegate {
    func reportButtonDidTouch(commentId: String) {
        
    }
}

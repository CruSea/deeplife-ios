//
//  CreatePostViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 15/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import Alamofire

class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postCaptionTextView: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var postImage: UIImage!
    
    var activeTextView: UITextView?
    
    var keyboardNotification: NSNotification?
    
    lazy var touchView: UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha: 0.0)
        
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        _touchView.addGestureRecognizer(touchViewTapped)
        
        _touchView.isUserInteractionEnabled = true
        
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        return _touchView
        
    }()
    
    lazy var progressIndicator: UIProgressView = {
        
        let _progressIndicator = UIProgressView()
        
        _progressIndicator.trackTintColor = UIColor.lightGray
        
        _progressIndicator.progressTintColor = UIColor.black
        
        _progressIndicator.progress = Float(0)
        
        _progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return _progressIndicator
        
    }()
    
    lazy var cancelButton: UIButton = {
        
        let _cancelButton = UIButton()
        
        _cancelButton.setTitle("Cancel Upload", for: .normal)
        
        _cancelButton.setTitleColor(UIColor.black, for: .normal)
        
        _cancelButton.addTarget(self, action: #selector(cancelUpload), for: .touchUpInside)
        
        _cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        return _cancelButton
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        postImageView.image = postImage
        
        postCaptionTextView.layer.borderWidth = CGFloat(0.5)
        
        postCaptionTextView.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0).cgColor
        
        postCaptionTextView.layer.cornerRadius = CGFloat(3.0)
        
        postCaptionTextView.delegate = self
        
        view.addSubview(progressIndicator)
        
        view.addSubview(cancelButton)
        
        let constraints: [NSLayoutConstraint] = [
            
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            
            progressIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            progressIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            
            cancelButton.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 5)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        progressIndicator.isHidden = true
        
        cancelButton.isHidden = true
        
    }
    
    @objc func cancelUpload() {
        
        progressIndicator.isHidden = true
        
        cancelButton.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotification()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deregisterFromKeyboardNotification()
        
    }
    
    func registerForKeyboardNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    func deregisterFromKeyboardNotification() {
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        
        view.addSubview(touchView)
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 10.0), right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = UIScreen.main.bounds
        
        aRect.size.height -= keyboardSize!.height
        
        if activeTextView != nil {
            
            if (aRect.contains(activeTextView!.frame.origin)) {
                
                self.scrollView.scrollRectToVisible(activeTextView!.frame, animated: true)
                
            }
            
        }
        
    }
    
    @objc func keyboardWasHidden(notification: NSNotification) {
        
        touchView.removeFromSuperview()
        
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    
    @IBAction func postButtonDidTouch(_ sender: Any) {
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        guard let caption = postCaptionTextView.text,
            !caption.isEmpty else { return }
        
        guard let userId = Auth.auth.currentUserId else {
            return
        }
        
        guard let resizedImage = postImage.resized(toWidth: 900) else {
            print("could not resize image")
            return
        }
        
        guard let postImageData = resizedImage.jpegData(compressionQuality: 0.75) else {
            print("could not create image data")
            return
        }
        
        let imageId: String = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "_")
        
        let imageName = "\(imageId).jpg"
        
        uploadImage(imageName: imageName, postImage: postImageData) { (success) in
            
            UIViewController.removeSpinner(spinner: sv)
            
            if success {
                
                let dataParameters: Parameters = [
                    "user_id": userId,
                    "post_text": caption,
                    "post_file": "api/phone/gn_api/upload/photos/mobileuploads/" + imageName,
                    "post_type": "2"
                ]
                
                let headers: HTTPHeaders = [
                    "Accept": "application/json; charset=utf-8"
                ]
                
                Alamofire.request(APIRoute.shared.createPostURL(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
                    
                    guard let strongSelf = self else { return }
                    
                    UIViewController.removeSpinner(spinner: sv)
                    
//                    if let error = data.error {
//
//                        print("an error occured")
//
//                        print(error.localizedDescription)
//
//                        return
//
//                    }
                    
                    DispatchQueue.main.async {
                        
                        strongSelf.dismiss(animated: true, completion: nil)
                        
                    }
                    
                }
                
            } else {
                
                print("error on upload")
                
            }
            
        }
    }
    
    func uploadImage(imageName: String, postImage: Data, completion: @escaping ((Bool) -> Void)) {
        
        let dataParameters: Parameters = [
            "name": imageName,
            "image": postImage.base64EncodedString()
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.createUploadURL(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { (data) in
            
            if let error = data.error {

                print("an error occured")

                print(error.localizedDescription)

                completion(false)

                return

            }
            
            completion(true)
            
        }
        
    }
    
}

extension CreatePostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        activeTextView = textView
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        activeTextView = nil
        
    }
    
}

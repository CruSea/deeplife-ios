//
//  ViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 5/10/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

import Alamofire

import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    var activeField: UITextField?
    
    private final let BORDER_WIDTH: CGFloat = CGFloat(2.0)
    
    let toolbarDone = UIToolbar.init()
    
    var nonActiveBorder: CALayer {
        
        get {
            
            let layer = CALayer()
            
            layer.borderColor = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0).cgColor
            
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
    
    lazy var touchView: UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha: 0.0)
        
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        _touchView.addGestureRecognizer(touchViewTapped)
        
        _touchView.isUserInteractionEnabled = true
        
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        return _touchView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        
        passwordTextField.delegate = self
        
        emailTextField.layer.masksToBounds = true
        
        passwordTextField.layer.masksToBounds = true
        
        emailTextField.layer.addSublayer(nonActiveBorder)
        
        passwordTextField.layer.addSublayer(nonActiveBorder)
        
        toolbarDone.sizeToFit()
        
        toolbarDone.barTintColor = Colors.themeYellow
        
        toolbarDone.tintColor = UIColor.white
        
        toolbarDone.isTranslucent = false
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let barBtnDone = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneButtonTapped))
        
        barBtnDone.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 17)!, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        toolbarDone.items = [flexSpace, barBtnDone, flexSpace]
        
        emailTextField.inputAccessoryView = toolbarDone
        
        passwordTextField.inputAccessoryView = toolbarDone
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loginButton.layer.cornerRadius = CGFloat(5.0)
        
        if let sublayers = emailTextField.layer.sublayers {
            
            for layer in sublayers {
                
                if layer.name == "1234" || layer.name == "5678" {
                    
                    layer.frame = CGRect(x: 0,
                                         y: emailTextField.frame.size.height - BORDER_WIDTH,
                                         width:  emailTextField.frame.size.width,
                                         height: emailTextField.frame.size.height)
                    
                }
                
            }
            
        }
        
        if let sublayers = passwordTextField.layer.sublayers {
            
            for layer in sublayers {
                
                if layer.name == "1234" || layer.name == "5678" {
                    
                    layer.frame = CGRect(x: 0,
                                         y: passwordTextField.frame.size.height - BORDER_WIDTH,
                                         width:  passwordTextField.frame.size.width,
                                         height: passwordTextField.frame.size.height)
                    
                    
                }
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        registerForKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        deregisterFromKeyboardNotifications()
        
    }
    
    func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    func deregisterFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        
        view.addSubview(touchView)
        
        //Need to calculate keyboard exact size due to Apple suggestions
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 20 + toolbarDone.frame.size.height + 32), right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        
        aRect.size.height -= keyboardSize!.height
        
        if activeField != nil {
            
            if (!aRect.contains(activeField!.frame.origin)) {
                
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                
            }
            
        }
        
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        
        touchView.removeFromSuperview()
        
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        self.view.endEditing(true)
        
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    @objc func doneButtonTapped() {
        
        view.endEditing(true)
        
    }
    
    @IBAction func forgotPasswordButtonDidTouch(_ sender: Any) {
        
        guard let url = URL(string: "https://deeplife.africa/forgot-password") else { return }
        
        UIApplication.shared.open(url)
        
    }
    
    
    @IBAction func createAccountButtonDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "createaccountsegue", sender: nil)
        
    }
    
    
    @IBAction func loginButtonDidTouch(_ sender: Any) {
        
        let usernameValidation = emailTextField.isStringValid()
        
        if !usernameValidation.isValid {
            
            shakeLogin()
            
            reportError(message: "Username is required")
            
            return
            
        }
        
        let passwordValidation = passwordTextField.isStringValid()
        
        if !passwordValidation.isValid {
            
            shakeLogin()
            
            reportError(message: "Password is required")
            
            return
            
        }
        
        guard let username: String = emailTextField.text else { return }
        
        guard let password: String = passwordTextField.text else { return }
        
        let session: String = randomString(length: 10)
        
        let parameters: Parameters = [
            "username" : username as String,
            "password" : password as String,
            "s" : session as String
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        Alamofire.request(APIRoute.shared.loginURL(), method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    strongSelf.shakeLogin()
                    
                    strongSelf.reportError(message: "Something went wrong during login. Please try again.")
                    
                }
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let userId = jsonData["user_id"].string {
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    guard let window = appDelegate.window else {
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.shakeLogin()
                            
                            strongSelf.reportError(message: "Something went wrong during login. Please try again.")
                            
                        }
                        
                        return
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        window.rootViewController = Auth.auth.createSession(userId: userId, sessionId: session)
                        
                    }
                    
                }
                else {
                    
                    if let errorText = jsonData["errors"]["error_text"].string {
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.shakeLogin()
                            
                            strongSelf.reportError(message: errorText)
                            
                        }
                        
                    }
                    else {
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.shakeLogin()
                            
                            strongSelf.reportError(message: "Something went wrong during login. Please try again.")
                            
                        }
                        
                    }
                    
                }
                
            }
            else {
                
                DispatchQueue.main.async {
                    
                    strongSelf.shakeLogin()
                    
                    strongSelf.reportError(message: "Something went wrong during login. Please try again.")
                    
                }
                
            }
            
        }
        
    }
    
    func shakeLogin() {
        
        let shakeAnimation = CAKeyframeAnimation(keyPath: "position.x")
        
        shakeAnimation.values = [0, -15, 15, -15, 15, 0]
        
        shakeAnimation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
        
        shakeAnimation.duration = 0.4
        
        shakeAnimation.isAdditive = true
        
        loginView.layer.add(shakeAnimation, forKey: nil)
        
    }
    
    func reportError(message: String) {
        
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            errorAlert.dismiss(animated: true, completion: nil)
            
        }
        
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
        
    }
    
    func randomString(length: Int) -> String {
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        return String((0...length-1).map{ _ in letters.randomElement()! })
        
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeField = nil
        
        for layer in textField.layer.sublayers! {
            
            if (layer.name == "5678") {
                
                layer.removeFromSuperlayer()
                
            }
            
        }
        
        let newNonActiveBorder = nonActiveBorder
        
        newNonActiveBorder.frame = CGRect(x: 0,
                                          y: textField.frame.size.height - BORDER_WIDTH,
                                          width:  textField.frame.size.width,
                                          height: textField.frame.size.height)
        
        textField.layer.addSublayer(newNonActiveBorder)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        
        for layer in textField.layer.sublayers! {
            
            if (layer.name == "1234") {
                
                layer.removeFromSuperlayer()
                
            }
            
        }
        
        let newActiveBorder = activeBorder
        
        newActiveBorder.frame = CGRect(x: 0,
                                       y: textField.frame.size.height - BORDER_WIDTH,
                                       width:  textField.frame.size.width,
                                       height: textField.frame.size.height)
        
        textField.layer.addSublayer(newActiveBorder)
        
    }
    
}


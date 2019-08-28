//
//  SignupViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 20/11/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

import Alamofire

import SwiftyJSON

class SignupViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var surnameLabel: UILabel!
    
    @IBOutlet weak var surnameTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var genderPickerView: UIPickerView!
    
    @IBOutlet weak var groupingPickerView: UIPickerView!
    
    @IBOutlet weak var countryPickerView: UIPickerView!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var termsAndPrivacyTextView: UITextView!
    
    lazy var touchView: UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha: 0.0)
        
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        _touchView.addGestureRecognizer(touchViewTapped)
        
        _touchView.isUserInteractionEnabled = true
        
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        return _touchView
        
    }()
    
    var activeField: UITextField?
    
    private final let BORDER_WIDTH: CGFloat = CGFloat(2.0)
    
    lazy var genderSource: GenderDataSource = {
        
        let source = GenderDataSource()
        
        source.textColor = UIColor.white
        
        return source
        
    }()
    
    lazy var groupingSource: GroupingDataSource = {
        
        let source = GroupingDataSource()
        
        source.textColor = UIColor.white
        
        return source
        
    }()
    
    lazy var countrySource: CountryDataSource = {
        
        let source = CountryDataSource()
        
        source.textColor = UIColor.white
        
        return source
        
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryPickerView.delegate = countrySource
        
        countryPickerView.dataSource = countrySource
        
        genderPickerView.delegate = genderSource
        
        genderPickerView.dataSource = genderSource
        
        groupingPickerView.delegate = groupingSource
        
        groupingPickerView.dataSource = groupingSource

        emailTextField.delegate = self
        
        passwordTextField.delegate = self
        
        phoneTextField.delegate = self
        
        nameTextField.delegate = self
        
        surnameTextField.delegate = self
        
        emailTextField.layer.masksToBounds = true
        
        passwordTextField.layer.masksToBounds = true
        
        phoneTextField.layer.masksToBounds = true
        
        nameTextField.layer.masksToBounds = true
        
        surnameTextField.layer.masksToBounds = true
        
        emailTextField.layer.addSublayer(nonActiveBorder)
        
        passwordTextField.layer.addSublayer(nonActiveBorder)
        
        phoneTextField.layer.addSublayer(nonActiveBorder)
        
        nameTextField.layer.addSublayer(nonActiveBorder)
        
        surnameTextField.layer.addSublayer(nonActiveBorder)
        
        let toolbarDone = UIToolbar.init()
        
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
        
        phoneTextField.inputAccessoryView = toolbarDone
        
        nameTextField.inputAccessoryView = toolbarDone
        
        surnameTextField.inputAccessoryView = toolbarDone
        
        if #available(iOS 12.0, *) {
            
            passwordTextField.textContentType = .oneTimeCode
            
        }
        
        let paragraph = NSMutableParagraphStyle()
        
        paragraph.alignment = .center
        
        let firstAttributedString = NSMutableAttributedString(string: "By signing up, you agree to the Terms and Privacy Policy", attributes: [NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 14) ?? UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraph])
        
        let termsLinkRange = (firstAttributedString.string as NSString).range(of: "Terms")
        
        firstAttributedString.addAttribute(NSAttributedString.Key.link, value: "https://deeplife.africa/terms/terms", range: termsLinkRange)
        
        firstAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14), range: termsLinkRange)
        
        let privacyLinkRange = (firstAttributedString.string as NSString).range(of: "Privacy Policy")
        
        firstAttributedString.addAttribute(NSAttributedString.Key.link, value: "https://deeplife.africa/terms/privacy-policy", range: privacyLinkRange)
        
        firstAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14), range: privacyLinkRange)
        
        termsAndPrivacyTextView.textAlignment = .center
        
        termsAndPrivacyTextView.delegate = self
        
        termsAndPrivacyTextView.isSelectable = true
        
        termsAndPrivacyTextView.dataDetectorTypes = .link
        
        termsAndPrivacyTextView.isUserInteractionEnabled = true
        
        termsAndPrivacyTextView.attributedText = firstAttributedString
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createAccountButton.layer.cornerRadius = CGFloat(5.0)
        
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
        
        if let sublayers = surnameTextField.layer.sublayers {
            
            for layer in sublayers {
                
                if layer.name == "1234" || layer.name == "5678" {
                    
                    layer.frame = CGRect(x: 0,
                                         y: surnameTextField.frame.size.height - BORDER_WIDTH,
                                         width:  surnameTextField.frame.size.width,
                                         height: surnameTextField.frame.size.height)
                    
                }
                
            }
            
        }
        
        if let sublayers = nameTextField.layer.sublayers {
            
            for layer in sublayers {
                
                if layer.name == "1234" || layer.name == "5678" {
                    
                    layer.frame = CGRect(x: 0,
                                         y: nameTextField.frame.size.height - BORDER_WIDTH,
                                         width:  nameTextField.frame.size.width,
                                         height: nameTextField.frame.size.height)
                    
                }
                
            }
            
        }
        
        if let sublayers = phoneTextField.layer.sublayers {
            
            for layer in sublayers {
                
                if layer.name == "1234" || layer.name == "5678" {
                    
                    layer.frame = CGRect(x: 0,
                                         y: phoneTextField.frame.size.height - BORDER_WIDTH,
                                         width:  phoneTextField.frame.size.width,
                                         height: phoneTextField.frame.size.height)
                    
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
        
        getCountries()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        deregisterFromKeyboardNotifications()
        
    }
    
    func getCountries() {
        
        self.createAccountButton.isEnabled = false
        
        self.createAccountButton.backgroundColor = UIColor(hexString: "#D8D8D8")
        
        if Countries.shared.allCountries.count > 2 {
            
            self.createAccountButton.isEnabled = true
            
            self.createAccountButton.backgroundColor = Colors.themeYellow
            
            return
            
        }
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        Alamofire.request(APIRoute.shared.getCountriesListURL(), method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Could not load countries")
                    
                }
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let countriesList = jsonData["countries"].dictionaryObject {
                    
                    Countries.shared.allCountries.removeAll()
                    
                    for (_ , country) in countriesList.enumerated() {
                        
                        guard let countryValue = country.value as? String else { continue }
                        
                        guard let countryKey = Int(country.key) else { continue }
                        
                        Countries.shared.allCountries.append(Country(id: countryKey, name: countryValue))
                        
                    }
                    
                    Countries.shared.allCountries.sort(by: { $0.name < $1.name })
                    
                    DispatchQueue.main.async {
                        
                        strongSelf.countryPickerView.reloadAllComponents()
                        
                        strongSelf.createAccountButton.isEnabled = true
                        
                        strongSelf.createAccountButton.backgroundColor = Colors.themeYellow
                        
                    }
                    
                }
                
            }
            
        }
        
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
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
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
        //let info : NSDictionary = notification.userInfo! as NSDictionary
        
        //let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets.zero
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        self.view.endEditing(true)
        
    }
    
    @objc func doneButtonTapped() {
        
        view.endEditing(true)
        
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    @IBAction func createAccountButtonDidTouch(_ sender: Any) {
        
        
        
        let nameValidation = nameTextField.isStringValid()
        
        if !nameValidation.isValid {
            
            reportError(message: "Name is not valid")
            
            return
            
        }
        
        let surnameValidation = surnameTextField.isStringValid()
        
        if !surnameValidation.isValid {
            
            reportError(message: "Surname is not valid")
            
            return
            
        }
        
        let phoneValidation = phoneTextField.isStringValid()
        
        if !phoneValidation.isValid {
            
            reportError(message: "Phone number is not valid")
            
            return
            
        }
        
        let passwordValidation = passwordTextField.isStringValid()
        
        if !passwordValidation.isValid {
            
            reportError(message: "Phone number is not valid")
            
            return
            
        }
        
        let emailValidation = emailTextField.isStringValid()
        
        if !emailValidation.isValid {
            
            reportError(message: "Email is not valid")
            
            return
            
        }
        
        let phoneNumber = phoneTextField.text!
        
        let name = nameTextField.text!
        
        let surname = surnameTextField.text!
        
        let email = emailTextField.text!
        
        let password = passwordTextField.text!
        
        let countryId = countrySource.countryOptions[countryPickerView.selectedRow(inComponent: 0)].id
        
        if countryId == 9999 {
            
            reportError(message: "Signup cannot continue because countries list failed to load. Please check your internet connection.")
            
            return
            
        }
        
        let genderOption = genderSource.genderOptions[genderPickerView.selectedRow(inComponent: 0)].getDescription()
        
        let session: String = randomString(length: 10)
        
        let userDataParameters: Parameters = [
            "phone_num" : phoneNumber,
            "name": name,
            "surname": surname,
            "email": email,
            "country": countryId,
            "gender": genderOption,
            "password": password,
            "session": session
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        Alamofire.request(APIRoute.shared.getCreateAccountURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Oops! Something went wrong. Please try again later.")
                    
                }
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let apiText = jsonData["api_text"].string {
                    
                    if let userId = jsonData["user_id"].string,
                        apiText == "success" {
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        
                        guard let window = appDelegate.window else {
                            
                            DispatchQueue.main.async {
                                
                                strongSelf.reportError(message: "Something went wrong. Please try again.")
                                
                            }
                            
                            return
                            
                        }
                        
                        DispatchQueue.main.async {
                            
                            window.rootViewController = Auth.auth.createSession(userId: userId, sessionId: session)
                            
                        }
                        
                    }
                    else if apiText == "failed" {
                        
                        var errorText: String = "We could not create a new account at this time."
                        
                        if let _errorText = jsonData["errors"]["error_text"].string {
                            
                            errorText = _errorText
                            
                        }
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.reportError(message: errorText)
                            
                        }
                        
                    }
                    
                }
                
            }
            else {
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Account creation error")
                    
                }
                
            }
            
        }
        
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
    
    @IBAction func loginButtonDidTouch(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    

}

extension SignupViewController: UITextFieldDelegate {
    
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

extension SignupViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        return false
        
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        return true
        
    }
    
}

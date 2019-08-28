//
//  NewDiscipleViewController.swift
//  DeepLife
//
//

import UIKit

import Alamofire

import SwiftyJSON

class NewDiscipleViewController: UIViewController {
    
    var mentor: User?
    
    @IBOutlet weak var addUnderPickerView: UIPickerView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var surnameLabel: UILabel!
    
    @IBOutlet weak var surnameTextField: UITextField!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var genderPickerView: UIPickerView!
    
    @IBOutlet weak var groupingLabel: UILabel!
    
    @IBOutlet weak var groupingPickerView: UIPickerView!
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var countryPickerView: UIPickerView!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var countrySource: CountryDataSource = {
        
        return CountryDataSource()
        
    }()
    
    lazy var addUnderSource: AddUnderDataSource = {
        
        return AddUnderDataSource()
        
    }()
    
    lazy var genderSource: GenderDataSource = {
        
        return GenderDataSource()
        
    }()
    
    lazy var groupingSource: GroupingDataSource = {
        
       return GroupingDataSource()
        
    }()
    
    var activeField: UITextField?
    
    private final let BORDER_WIDTH: CGFloat = CGFloat(1.0)
    
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
    
    var textFieldsAndLabels: [(UITextField, UILabel)] = [(UITextField, UILabel)]()
    
    var originalInsets: UIEdgeInsets!
    
    let toolbarDone = UIToolbar.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalInsets = scrollView.contentInset
        
        addUnderPickerView.delegate = addUnderSource
        
        addUnderPickerView.dataSource = addUnderSource
        
        countryPickerView.delegate = countrySource
        
        countryPickerView.dataSource = countrySource
        
        genderPickerView.delegate = genderSource
        
        genderPickerView.dataSource = genderSource
        
        groupingPickerView.delegate = groupingSource
        
        groupingPickerView.dataSource = groupingSource
        
        toolbarDone.sizeToFit()
        
        toolbarDone.barTintColor = Colors.themeYellow
        
        toolbarDone.tintColor = UIColor.white
        
        toolbarDone.isTranslucent = false
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let barBtnDone = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneButtonTapped))
        
        barBtnDone.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 17)!, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        toolbarDone.items = [flexSpace, barBtnDone, flexSpace]
        
        textFieldsAndLabels = [(nameTextField!, nameLabel!), (surnameTextField!, surnameLabel!), ( phoneNumberTextField!, phoneNumberLabel!), (emailTextField!, emailLabel!)]
        
        for item in textFieldsAndLabels {
            
            item.0.delegate = self
            
            item.0.layer.masksToBounds = true
            
            item.0.layer.addSublayer(nonActiveBorder)
            
            item.0.inputAccessoryView = toolbarDone
            
        }
        
        disableCreateButton()
        
        if let _mentor = mentor {
        
            addUnderSource.addUnderOptions.append(AddUnder(name: _mentor.name, followerId: _mentor.id))
            
            addUnderPickerView.reloadAllComponents()
            
        }
        else {
            
            getDisciplesList()
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createButton.layer.cornerRadius = CGFloat(5.0)
        
        for item in textFieldsAndLabels {
            
            if let sublayers = item.0.layer.sublayers {
                
                for layer in sublayers {
                    
                    if layer.name == "1234" || layer.name == "5678" {
                        
                        layer.frame = CGRect(x: 0,
                                             y: item.0.frame.size.height - BORDER_WIDTH,
                                             width:  item.0.frame.size.width,
                                             height: item.0.frame.size.height)
                        
                    }
                    
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
        
        /*
        let info: NSDictionary = notification.userInfo! as NSDictionary
        
        var keyboardFrame = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        
        keyboardFrame!.size.height = 20
        
        keyboardFrame = self.view.convert(keyboardFrame!, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        
        contentInset.bottom = keyboardFrame!.size.height
        
        scrollView.contentInset = contentInset
        */
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        
        //Once keyboard disappears, restore original positions
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets.zero
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        self.view.endEditing(true)
        
        /*
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        scrollView.contentInset = contentInset
         */
        
    }
    
    @objc func doneButtonTapped() {
        
        view.endEditing(true)
        
    }
    
    func disableCreateButton() {
        
        createButton.isEnabled = false
        
        createButton.backgroundColor = UIColor(hexString: "#D8D8D8")
        
    }
    
    func enableCreateButton() {
        
        createButton.isEnabled = true
        
        createButton.backgroundColor = UIColor.black
        
    }

    @IBAction func cancelButtonDidTouch(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func createButtonDidTouch(_ sender: Any) {
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
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
        
        let phoneValidation = phoneNumberTextField.isStringValid()
        
        if !phoneValidation.isValid {
            
            reportError(message: "Phone number is not valid")
            
            return
            
        }
        
        let emailValidation = emailTextField.isStringValid()
        
        if !emailValidation.isValid {
            
            reportError(message: "Email is not valid")
            
            return
            
        }
        
        let phoneNumber = phoneNumberTextField.text!
        
        let name = nameTextField.text!
        
        let surname = surnameTextField.text!
        
        let email = emailTextField.text!
        
        let countryId = countrySource.countryOptions[countryPickerView.selectedRow(inComponent: 0)].id
        
        if countryId == 9999 {
            
            reportError(message: "Countries list failed to load. Please check your internet connection.")
            
            return
            
        }
        
        let genderOption = genderSource.genderOptions[genderPickerView.selectedRow(inComponent: 0)].getDescription()
        
        let userDataParameters: Parameters = [
            "phone_num" : phoneNumber,
            "name": name,
            "surname": surname,
            "mentor_id": currentUserId,
            "email": email,
            "country": countryId,
            "gender": genderOption
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        Alamofire.request(APIRoute.shared.addDiscipleURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Oops! Something went wrong. Please try again later.")
                    
                }
                
                return
                
            }
                
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let apiText = jsonData["api_text"].string {
                    
                    if apiText == "success" {
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.dismiss(animated: true, completion: nil)
                            
                        }
                        
                    }
                    else if apiText == "failed" {
                        
                        var errorText: String = "We could not create a new disciple at this time."
                        
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
                
                print("could not get data")
                
            }
            
        }
        
    }
    
    func getDisciplesList() {
        
        guard let authUserId = Auth.auth.currentUserId else {
            
            return
            
        }
        
        guard let currentUserId: Int = Int(authUserId) else { return }
        
        let userDataParameters: Parameters = [
            
            "user_id" : currentUserId
            
        ]
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        Alamofire.request(APIRoute.shared.getDiscipleListURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Could not load disciple list")
                    
                }
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                strongSelf.addUnderSource.addUnderOptions.removeAll()
                
                strongSelf.addUnderSource.addUnderOptions.append(AddUnder(name: "Self", followerId: currentUserId))
                
                if let primaryList = jsonData["primary_disciples_list"].arrayObject {
                    
                    for primaryItem in primaryList {
                        
                        guard let primary = primaryItem as? [String: Any] else {
                            
                            continue
                            
                        }
                        
                        guard let _followerId = primary["follower_id"] as? String,
                            let followerId = Int(_followerId) else {
                                
                                continue
                                
                        }
                        
                        var firstName: String = ""
                        
                        var lastName: String = ""
                        
                        if let _firstName = primary["first_name"] as? String {
                            
                            firstName = "\(_firstName) "
                            
                        }
                        
                        if let _lastName = primary["last_name"] as? String {
                            
                            lastName = _lastName
                            
                        }
                        
                        let fullName: String = "\(firstName)\(lastName)"
                        
                        let newAddUnder = AddUnder(name: fullName, followerId: followerId)
                        
                        strongSelf.addUnderSource.addUnderOptions.append(newAddUnder)
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        strongSelf.addUnderPickerView.reloadAllComponents()
                        
                    }
                    
                    strongSelf.checkForCountries(sv: sv)
                    
                }
                
            }
            
        }
        
    }
    
    func checkForCountries(sv: UIView) {
        
        if Countries.shared.allCountries.count > 2 {
            
            UIViewController.removeSpinner(spinner: sv)
            
            DispatchQueue.main.async {
            
                self.enableCreateButton()
                
            }
            
            return
            
        }
        
        guard let currentUserId = Auth.auth.currentUserId else {
            
            return
            
        }
        
        let userDataParameters: Parameters = [
            
            "user_id" : currentUserId
            
        ]
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        Alamofire.request(APIRoute.shared.getCountriesListURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
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
                        
                        strongSelf.enableCreateButton()
                        
                    }
                    
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

}

extension NewDiscipleViewController: UITextFieldDelegate {
    
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

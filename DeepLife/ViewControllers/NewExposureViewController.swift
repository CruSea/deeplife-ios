//
//  NewExposureViewController.swift
//  DeepLife
//
//

import UIKit

import Alamofire

import SwiftyJSON

class NewExposureViewController: UIViewController {
    
    @IBOutlet weak var exposureTypePickerView: UIPickerView!
    
    @IBOutlet weak var areaLabel: UILabel!
    
    @IBOutlet weak var areaTextField: UITextField!
    
    @IBOutlet weak var numberOfPeopleLabel: UILabel!
    
    @IBOutlet weak var numberOfPeopleTextField: UITextField!
    
    @IBOutlet weak var numberOfSoulsWonLabel: UILabel!
    
    @IBOutlet weak var numberOfSoulsWonTextField: UITextField!
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var countryPickerView: UIPickerView!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: ExposureDelegate?
    
    lazy var countrySource: CountryDataSource = {
        
       return CountryDataSource()
        
    }()
    
    lazy var exposureSource: ExposureDataSource = {
        
        return ExposureDataSource()
        
    }()
    
    var activeField: UITextField?
    
    private final let BORDER_WIDTH: CGFloat = CGFloat(1.0)
    
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
    
    var textFieldsAndLabels: [(UITextField, UILabel)] = [(UITextField, UILabel)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbarDone.sizeToFit()
        
        toolbarDone.barTintColor = Colors.themeYellow
        
        toolbarDone.tintColor = UIColor.white
        
        toolbarDone.isTranslucent = false
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let barBtnDone = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneButtonTapped))
        
        barBtnDone.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 17)!, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        toolbarDone.items = [flexSpace, barBtnDone, flexSpace]
        
        textFieldsAndLabels = [(areaTextField, areaLabel), (numberOfPeopleTextField, numberOfPeopleLabel), (numberOfSoulsWonTextField, numberOfSoulsWonLabel)]
        
        for item in textFieldsAndLabels {
            
            item.0.delegate = self
            
            item.0.layer.masksToBounds = true
            
            item.0.layer.addSublayer(nonActiveBorder)
            
            item.0.inputAccessoryView = toolbarDone
            
        }

        countryPickerView.delegate = countrySource
        
        countryPickerView.dataSource = countrySource
        
        exposureTypePickerView.delegate = exposureSource
        
        exposureTypePickerView.dataSource = exposureSource
        
        disableCreateButton()
        
        getCountries()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
        
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 20 + toolbarDone.frame.size.height + 32), right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        self.view.endEditing(true)
        
    }
    
    func disableCreateButton() {
        
        createButton.isEnabled = false
        
        createButton.backgroundColor = UIColor(hexString: "#D8D8D8")
        
    }
    
    func enableCreateButton() {
        
        createButton.isEnabled = true
        
        createButton.backgroundColor = UIColor.black
        
    }
    
    func getCountries() {
        
        if Countries.shared.allCountries.count > 2 {
            
            self.enableCreateButton()
            
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
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        Alamofire.request(APIRoute.shared.getCountriesListURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
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
                        
                        strongSelf.enableCreateButton()
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @objc func doneButtonTapped() {
        
        view.endEditing(true)
        
    }
    
    @IBAction func cancelButtonDidTouch(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }

    @IBAction func createButtonDidTouch(_ sender: Any) {
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        guard let mentorId = Int(currentUserId) else { return }
        
        let areaValidation = areaTextField.isStringValid()
        
        if !areaValidation.isValid {
            
            reportError(message: "Area is not valid")
            
            return
            
        }
        
        let numberOfPeopleValidation = numberOfPeopleTextField.isNumberValid()
        
        if !numberOfPeopleValidation.isValid {
            
            reportError(message: "Number of people is not valid")
            
            return
            
        }
        
        let soulsWonValidation = numberOfSoulsWonTextField.isNumberValid()
        
        if !soulsWonValidation.isValid {
            
            reportError(message: "Number of souls won is not valid")
            
            return
            
        }
        
        let area = areaTextField.text!
        
        guard let numberOfPeople = Int(numberOfPeopleTextField.text!) else {
            
            reportError(message: "Number of people is not valid")
            
            return
            
        }
        
        guard let soulsWon = Int(numberOfSoulsWonTextField.text!) else {
            
            reportError(message: "Number of souls won is not valid")
            
            return
            
        }
        
        let countryId = countrySource.countryOptions[countryPickerView.selectedRow(inComponent: 0)].id
        
        if countryId == 9999 {
            
            reportError(message: "Countries list failed to load. Please check your internet connection.")
            
            return
            
        }
        
        let exposureType = exposureSource.exposureOptions[exposureTypePickerView.selectedRow(inComponent: 0)].code
        
        let date = Date()
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        let currentDate = formatter.string(from: date)
        
        let userDataParameters: Parameters = [
            "user_id" : mentorId,
            "exposure_type": exposureType,
            "date": currentDate,
            "number_of_people": numberOfPeople,
            "number_of_winned_souls": soulsWon,
            "country_id": countryId,
            "area": area
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.getAddExposureURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in 
            
            guard let strongSelf = self else { return }
            
            print(data)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Oops! Something went wrong. Please try again later.")
                    
                }
                
                return
                
            }
            else {
                
                DispatchQueue.main.async {
                    
                    strongSelf.delegate?.refreshUI()
                    
                    strongSelf.dismiss(animated: true, completion: nil)
                    
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

extension NewExposureViewController: UITextFieldDelegate {
    
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

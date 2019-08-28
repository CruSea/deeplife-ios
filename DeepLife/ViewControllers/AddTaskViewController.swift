//
//  AddTaskViewController.swift
//  DeepLife
//

import UIKit

import Alamofire

import SwiftyJSON

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    
    @IBOutlet weak var taskDetailsLabel: UILabel!
    
    @IBOutlet weak var taskDetailsTextView: UITextView!
    
    @IBOutlet weak var taskStartDateLabel: UILabel!
    
    @IBOutlet weak var taskStartDatePicker: UIDatePicker!
    
    @IBOutlet weak var taskEndDateLabel: UILabel!
    
    @IBOutlet weak var taskEndDatePicker: UIDatePicker!
    
    @IBOutlet weak var createTaskButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeField: UITextField?
    
    private final let BORDER_WIDTH: CGFloat = CGFloat(1.0)
    
    weak var delegate: TasksDelegate?
    
    lazy var touchView: UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha: 0.0)
        
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        _touchView.addGestureRecognizer(touchViewTapped)
        
        _touchView.isUserInteractionEnabled = true
        
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        return _touchView
        
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
    
     let toolbarDone = UIToolbar.init()
    
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
        
        textFieldsAndLabels = [(taskTitleTextField, taskTitleLabel)]
        
        for item in textFieldsAndLabels {
            
            item.0.delegate = self
            
            item.0.layer.masksToBounds = true
            
            item.0.layer.addSublayer(nonActiveBorder)
            
            item.0.inputAccessoryView = toolbarDone
            
        }
        
        self.taskDetailsTextView.layer.cornerRadius = CGFloat(5.0)
        
        self.taskDetailsTextView.layer.borderColor = UIColor(hexString: "#D8D8D8").cgColor
        
        self.taskDetailsTextView.layer.borderWidth = CGFloat(1.0)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createTaskButton.layer.cornerRadius = CGFloat(5.0)
        
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
    
    @objc func doneButtonTapped() {
        
        view.endEditing(true)
        
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    @IBAction func cancelButtonDidTouch(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func createTaskButtonDidTouch(_ sender: Any) {
        
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        let taskNameValidation = taskTitleTextField.isStringValid()
        
        if !taskNameValidation.isValid {
            
            reportError(message: "Task title is not valid")
            
            return
            
        }
        
        let taskDetailsValidation = taskDetailsTextView.isStringValid()
        
        if !taskDetailsValidation.isValid {
            
            reportError(message: "Task details is not valid.")
            
            return
            
        }
        
        let taskName: String = taskTitleTextField.text!
        
        let taskDetails: String = taskDetailsTextView.text!
        
        let taskStartDate = taskStartDatePicker.date
        
        let taskEndDate = taskEndDatePicker.date
        
        if taskStartDate > taskEndDate {
            
            reportError(message: "Task start date needs to be earlier than task end date.")
            
            return
            
        }
        
        if taskStartDate < Date() {
            
            reportError(message: "Task start date must be set in the future.")
            
            return
            
        }
        
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        let selectedTaskStartDate = formatter.string(from: taskStartDate)
        
        let taskStartHour = calendar.component(.hour, from: taskStartDate)
        
        let taskStartMins = calendar.component(.minute, from: taskStartDate)
        
        let taskStartTime = "\(taskStartHour):\(taskStartMins)"
        
        let selectedTaskEndDate = formatter.string(from: taskEndDate)
        
        let taskEndHour = calendar.component(.hour, from: taskEndDate)
        
        let taskEndMins = calendar.component(.minute, from: taskEndDate)
        
        let taskEndTime = "\(taskEndHour):\(taskEndMins)"
        
        let dataParameters: Parameters = [
            "user_id" : currentUserId,
            "task_name": taskName,
            "task_details": taskDetails,
            "task_start_date" : selectedTaskStartDate,
            "task_start_time": taskStartTime,
            "task_end_date": selectedTaskEndDate,
            "task_end_time": taskEndTime
        ]
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        Alamofire.request(APIRoute.shared.addTaskURL(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    strongSelf.reportError(message: "Oops. Something went wrong. Please try again.")
                    
                }
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let apiText = jsonData["api_text"].string {
                    
                    if apiText == "success" {
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.delegate?.refreshUI()
                            
                            strongSelf.dismiss(animated: true, completion: nil)
                            
                        }
                        
                    }
                    else if apiText == "failed" {
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.reportError(message: "We could not create a task at this time. Please try later.")
                            
                        }
                        
                    }
                    
                }
                
            }
            else {
                
                print("could not get data")
                
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

extension AddTaskViewController: UITextFieldDelegate {
    
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

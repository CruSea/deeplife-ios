//
//  EventDetailViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 16/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var attendEventButton: UIButton!
    @IBOutlet weak var eventDescription: UILabel!
    var event: Event?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        attendEventButton.isUserInteractionEnabled = false
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let event = self.event {
            let eventImageURL = URL(string: "https://deeplife.africa/\(event.cover.trimmingCharacters(in: .whitespacesAndNewlines))")!
            coverImageView.af_setImage(withURL: eventImageURL)
            eventNameLabel.text = event.name
            title = event.name
            eventLocationLabel.text = event.location
            eventDateLabel.text = "From \(event.startDate) to \(event.endDate)"
            eventDescription.text = event.description
        }
        
        fetchEventAttendance()
        
    }
    
    func fetchEventAttendance() {
        
        guard let event = self.event else { return }
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let dataParameters: Parameters = [
            "event_id": event.id,
            "user_id": currentUserId
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.getEventAttendanceURL(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let success = jsonData["api_text"].string {
                    
                    if success == "success" {
                        
                        DispatchQueue.main.async {
                            strongSelf.attendEventButton.isUserInteractionEnabled = true
                        }
                        
                        if let eventDetails = jsonData["attendance"].dictionaryObject {
                            
                            let isAttending: Bool = eventDetails["going"] as? Bool ?? false
                            
                            if isAttending {
                                DispatchQueue.main.async {
                                    strongSelf.attendEventButton.setTitle("You Are Going", for: .normal)
                                    strongSelf.attendEventButton.backgroundColor = UIColor(hexString: "#2196F3")
                                }
                            } else {
                                DispatchQueue.main.async {
                                    strongSelf.attendEventButton.setTitle("Attend Event", for: .normal)
                                    strongSelf.attendEventButton.backgroundColor = UIColor.red
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
    
        }
        
    }
    
    @IBAction func attendEventButtonDidTouch(_ sender: Any) {
        
        guard let event = self.event else { return }
        guard let currentUserId = Auth.auth.currentUserId else { return }
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let dataParameters: Parameters = [
            "event_id": event.id,
            "user_id": currentUserId
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(APIRoute.shared.toggleEventAttendance(), method: .post, parameters: dataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            UIViewController.removeSpinner(spinner: sv)
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let success = jsonData["api_text"].string {
                    
                    if success == "success" {
                        
                        if let eventDetails = jsonData["attendance"].dictionaryObject {
                            
                            let isAttending: Bool = eventDetails["going"] as? Bool ?? false
                            
                            if isAttending {
                                DispatchQueue.main.async {
                                    strongSelf.attendEventButton.setTitle("You Are Going", for: .normal)
                                    strongSelf.attendEventButton.backgroundColor = UIColor(hexString: "#2196F3")
                                }
                            } else {
                                DispatchQueue.main.async {
                                    strongSelf.attendEventButton.setTitle("Attend Event", for: .normal)
                                    strongSelf.attendEventButton.backgroundColor = UIColor.red
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

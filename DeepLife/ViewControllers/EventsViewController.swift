//
//  EventsViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 14/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EventsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(EventsViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
        
    }()
    
    var events: [Event] = [Event]()
    var shouldRefresh: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = CGFloat(88.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "EventTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        title = "Events"
        getEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getEvents()
    }
    
    func getEvents() {
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        Alamofire.request(APIRoute.shared.getEventsURL(), method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
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
                print("json data \(jsonData)")
                if let eventsList = jsonData["events_list"].arrayObject {
                    strongSelf.events = [Event]()
                    for eventItem in eventsList {
                        guard let event = eventItem as? [String: Any] else {
                            continue
                        }
                        guard let eventId = event["id"] as? String else { continue }
                        let eventName: String = event["name"] as? String ?? ""
                        let eventCover: String = event["cover"] as? String ?? ""
                        let eventLocation: String = event["location"] as? String ?? ""
                        let startDate: String = event["start_date"] as? String ?? ""
                        let endDate: String = event["end_date"] as? String ?? ""
                        let description: String = event["description"] as? String ?? ""
                        let newEvent = Event(id: eventId,
                                             name: eventName,
                                             cover: eventCover,
                                             location: eventLocation,
                                             startDate: startDate,
                                             endDate: endDate,
                                             description: description)
                        strongSelf.events.append(newEvent)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventDetailSegue" {
            let destinationVC = segue.destination as! EventDetailViewController
            guard let event = sender as? Event else { return }
            destinationVC.event = event
        }
    }

}

extension EventsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent = events[indexPath.row]
        performSegue(withIdentifier: "EventDetailSegue", sender: selectedEvent)
    }
    
}

extension EventsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell") as! EventTableViewCell
        let eventImageURL = URL(string: "https://deeplife.africa/\(event.cover.trimmingCharacters(in: .whitespacesAndNewlines))")!
        cell.eventImageView.af_setImage(withURL: eventImageURL)
        cell.eventLocationLabel.text = event.location
        cell.eventNameLabel.text = event.name
        return cell
    }
    
}

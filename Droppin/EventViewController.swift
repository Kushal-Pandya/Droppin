//
//  EventViewController.swift
//  Droppin
//
//  Created by Syed Ahmed on 2018-09-28.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFunctions

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var hostedList = [String]()
    var invitedList = [String]()
    var responseList = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var createEventButton: UIButton!
    
    lazy var functions = Functions.functions()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return hostedList.count
        case 1:
            return invitedList.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cell.textLabel?.text = hostedList[indexPath.row]
            cell.detailTextLabel?.text = ""
        case 1:
            cell.textLabel?.text = invitedList[indexPath.row]
            cell.detailTextLabel?.text = responseList[indexPath.row]

        default:
            break
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let eventTitle = cell?.textLabel?.text!
        
        let data = ["eventName": eventTitle]
        
        var eventDescription: String = ""
        var eventDate: String = ""
        var eventCategory: String = ""
        var eventLocation: String = ""
        var eventInvites: String = ""
        var eventAccepted: [String] = [""]
        
        functions.httpsCallable("getEventDetails").call(data) { (result, error) in
            if let error = error as NSError? {
                let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let theEventDetails = ((result?.data as? [String:Any])?["eventList"] as? [Any])!
            
            for event in theEventDetails {
                if let theEvent = event as? [String:Any] {
                    if let description = theEvent["description"] as? String {
                        eventDescription = description
                    }
                    if let date = theEvent["dateStart"] as? String {
                        eventDate = date
                    }
                    if let category = theEvent["category"] as? String {
                        eventCategory = category
                    }
                    if let location = theEvent["address"] as? String {
                        eventLocation = location
                    }
                    if let invites = theEvent["invites"] as? String {
                        eventInvites = invites
                    }
                    if let checkString = theEvent["accepted"] as? [String] {
                        eventAccepted = checkString
                    }
                    
                }
            }
            
            if let eventDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
                withIdentifier: "eventDetailsViewController") as? EventDetailsViewController {
                
                eventDetailsViewController.textTitle = eventTitle!
                eventDetailsViewController.textDescription = eventDescription
                eventDetailsViewController.textDate = eventDate
                eventDetailsViewController.textCategory = eventCategory
                eventDetailsViewController.textLocation = eventLocation
                eventDetailsViewController.invites = eventInvites
                eventDetailsViewController.accepted = eventAccepted
                
                self.present(eventDetailsViewController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
                let cell = tableView.cellForRow(at: index)
                let cellTitle = cell?.textLabel?.text
                
                if let editEventViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
                    withIdentifier: "editEventViewController") as? EditEventViewController {
                    
                    editEventViewController.eventName = cellTitle!
                    self.present(editEventViewController, animated: true, completion: nil)
                }
            }
            
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                let cell = tableView.cellForRow(at: index)
                let cellTitle = cell?.textLabel?.text!
                let data = ["eventName": cellTitle]
                
                // Activity Indicator
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.startAnimating()
                
                let alert = UIAlertController(
                    title: "Are you sure you want to delete " + cellTitle! + " ?",
                    message: "This will permanently delete the event and notify all attendees.",
                    preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(
                    title: "Delete",
                    style: .destructive,
                    handler: { action in
                        
                        self.view.addSubview(activityIndicator)
                        self.functions.httpsCallable("removeEvent").call(data) { (result, error) in
                            if let error = error as NSError? {
                                let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                        }
                        self.hostedList.remove(at: index.row)
                        self.tableView.reloadData()
                        activityIndicator.stopAnimating()
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            return [delete, edit]
                
        case 1:
            let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                
                // Activity Indicator
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.startAnimating()
                self.view.addSubview(activityIndicator)
                
                let cell = tableView.cellForRow(at: index)
                let cellTitle = cell?.textLabel?.text
                
                let host = UserDefaults.standard.object(forKey: "email") as! String
                let data = ["user": host, "eventName": cellTitle!]
                self.functions.httpsCallable("acceptInvite").call(data) { (result, error) in
                    if let error = error as NSError? {
                        let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                
                let alert = UIAlertController(
                    title: "Accepted Event!",
                    message: "Congrats you are going to " + cellTitle!,
                    preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                activityIndicator.stopAnimating()
                self.present(alert, animated: true, completion: nil)
                cell?.detailTextLabel?.text = "accepted"
            }
            accept.backgroundColor = .blue
            
            let tentative = UITableViewRowAction(style: .normal, title: "Tentative") { action, index in
                
                // Activity Indicator
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.startAnimating()
                self.view.addSubview(activityIndicator)
                
                let cell = tableView.cellForRow(at: index)
                let cellTitle = cell?.textLabel?.text
                
                let host = UserDefaults.standard.object(forKey: "email") as! String
                let data = ["user": host, "eventName": cellTitle!]
                self.functions.httpsCallable("tentativeInvite").call(data) { (result, error) in
                    if let error = error as NSError? {
                        let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                
                let alert = UIAlertController(
                    title: "Tentative Event",
                    message: "You might be going to " + cellTitle!,
                    preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                activityIndicator.stopAnimating()
                self.present(alert, animated: true, completion: nil)
                cell?.detailTextLabel?.text = "tentative"
            }
            
            let decline = UITableViewRowAction(style: .destructive, title: "Decline") { action, index in
        
                // Activity Indicator
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.startAnimating()
                self.view.addSubview(activityIndicator)
                
                let cell = tableView.cellForRow(at: index)
                let cellTitle = cell?.textLabel?.text
                
                let host = UserDefaults.standard.object(forKey: "email") as! String
                let data = ["user": host, "eventName": cellTitle!]
                self.functions.httpsCallable("declineInvite").call(data) { (result, error) in
                    if let error = error as NSError? {
                        let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                
                let alert = UIAlertController(
                    title: "Declined Event",
                    message: "You have declined your invitation to " + cellTitle!,
                    preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                activityIndicator.stopAnimating()
                self.present(alert, animated: true, completion: nil)
                cell?.detailTextLabel?.text = "declined"
            }
            
            return [decline, tentative, accept]
        default:
            break
        }
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        segmentedControl.selectedSegmentIndex = 0
        refreshData()
    }
    
    func refreshData() {
        // Activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        hostedList.removeAll()
        invitedList.removeAll()
        responseList.removeAll()
        
        let host = UserDefaults.standard.object(forKey: "email") as! String
        let data = ["host": host]
        functions.httpsCallable("getHostedEvents").call(data) { (result, error) in
            if let error = error as NSError? {
                let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let hostedEvents = ((result?.data as? [String:Any])?["eventList"] as? [Any])!
            self.getList(eventList: hostedEvents, listType: "hosted")
            self.tableView.reloadData()
        }
        
        functions.httpsCallable("getInvitedEvents").call(data) { (result, error) in
            if let error = error as NSError? {
                let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let invitedEvents = ((result?.data as? [String:Any])?["eventList"] as? [Any])!
            self.getList(eventList: invitedEvents, listType: "invited")
        }
        
        activityIndicator.stopAnimating()
    }
    
    func getList(eventList: [Any], listType: String) {
        for event in eventList {
            if let theEvent = event as? [String:Any] {
                if let eventTitle = theEvent["eventName"] as? String {
                    switch listType {
                    case "hosted":
                        hostedList.append(eventTitle)
                    case "invited":
                        invitedList.append(eventTitle)
                        
                        let host = UserDefaults.standard.object(forKey: "email") as! String
                        let data = ["user": host, "eventName": eventTitle]
                        functions.httpsCallable("getResponse").call(data) { (result, error) in
                            if let error = error as NSError? {
                                let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                            
                            let response = ((result?.data as? [String:String])?["response"])!
                            self.responseList.append(response)
                        }
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    @IBAction func SwitchSegmentedControl(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }

}

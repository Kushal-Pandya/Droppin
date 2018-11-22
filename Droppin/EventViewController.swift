//
//  EventViewController.swift
//  Droppin
//
//  Created by Syed Ahmed on 2018-09-28.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit
import FirebaseFunctions

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var hostedList = [String]()
    var invitedList = [String]()
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
        case 1:
            cell.textLabel?.text = invitedList[indexPath.row]
        default:
            break
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add event details page here, will need to make API call
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
                
            }
            
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                let cell = tableView.cellForRow(at: index)
                let cellTitle = cell?.textLabel?.text
                
                let alert = UIAlertController(
                    title: "Are you sure you want to delete " + cellTitle! + " ?",
                    message: "This will permanently delete the event and notify all attendees.",
                    preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(
                    title: "Delete",
                    style: .destructive,
                    handler: { action in
                        // Delete API call here
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            return [delete, edit]
        case 1:
            let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                let cell = tableView.cellForRow(at: index)
                let cellTitle = cell?.textLabel?.text
                
                let alert = UIAlertController(
                    title: "Accepted Event!",
                    message: "Congrats you are going to " + cellTitle!,
                    preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            accept.backgroundColor = .blue
            
            let tentative = UITableViewRowAction(style: .normal, title: "Tentative") { action, index in
                let cell = tableView.cellForRow(at: index)
                let cellTitle = cell?.textLabel?.text
                
                let alert = UIAlertController(
                    title: "Tentative Event",
                    message: "You might be going to " + cellTitle!,
                    preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            let decline = UITableViewRowAction(style: .destructive, title: "Decline") { action, index in
                let cell = tableView.cellForRow(at: index)
                let cellTitle = cell?.textLabel?.text
                
                let alert = UIAlertController(
                    title: "Declined Event",
                    message: "You have declined your invitation to " + cellTitle!,
                    preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
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
        
        hostedList.removeAll()
        invitedList.removeAll()
        
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
            self.tableView.reloadData()
        }
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

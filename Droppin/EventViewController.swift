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
            print("-----hosted-----")
            print(result?.data)
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
            print("-----invited-----")
            print(result?.data)
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

//
//  EventViewController.swift
//  Droppin
//
//  Created by Syed Ahmed on 2018-09-28.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let cars = ["BMW", "Mercedes", "Honda", "Toyota", "Ferrari"]
    let fruits = ["Mango", "Banana", "Apples", "Oranges", "Blueberries"]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var createEventButton: UIButton!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return cars.count
        case 1:
            return fruits.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cell.textLabel?.text = cars[indexPath.row]
        case 1:
            cell.textLabel?.text = fruits[indexPath.row]
        default:
            break
        }
        return cell
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func SwitchSegmentedControl(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

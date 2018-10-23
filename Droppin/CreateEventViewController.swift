//
//  CreateEventViewController.swift
//  Droppin
//
//  Created by Kushal Pandya on 2018-10-17.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var eventAddressField: UITextField!
    @IBOutlet weak var eventStartTime: UIDatePicker!
    @IBOutlet weak var eventCategoryPicker: UIPickerView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var submitEventButton: UIButton!
    
    let eventCategories = ["Sports & Fitness", "Fun & Parties", "Recreation & Leisure", "Education", "Socialwork","Casual", "Arts & Culture", "Corporate", "Political"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventCategoryPicker.delegate = self
        self.eventCategoryPicker.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventCategories[row]
    }
    
    @IBAction func dropEventTapped(_ sender: Any) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}

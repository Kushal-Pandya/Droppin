//
//  FiltersViewController.swift
//  Droppin
//
//  Created by Kushal Pandya on 2018-10-26.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFunctions

protocol FiltersDelegate {
    func didTapApplyFilters(eventList: [Any])
}

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var mode: UISegmentedControl!
    @IBOutlet weak var closeModalButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    
    var filtersDelegate: FiltersDelegate!
    var eventList: [Any] = []
    
    lazy var functions = Functions.functions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCategoryPicker()
        createDatePicker()
    }
    
    @IBAction func backgroundButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {

        var categoryIndex = ""
        if let theIndex = eventCategories.firstIndex(of: categoryTextField.text!) {
            categoryIndex = String(theIndex)
        }
        
        let data = ["categoryID": categoryIndex, "eventDate": dateTextField.text!, "eventType": mode.titleForSegment(at: mode.selectedSegmentIndex)!]
            functions.httpsCallable("searchByFilters").call(data) { (result, error) in
                if let error = error as NSError? {
                    let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.eventList = ((result?.data as? [String:Any])?["eventList"] as? [Any])!
            }

        dismiss(animated: true) {
            self.filtersDelegate.didTapApplyFilters(eventList: self.eventList)
        }
    }
}

// Category Picker
extension FiltersViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func createCategoryPicker() {
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        
        categoryTextField.inputView = categoryPicker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = eventCategories[row]
    }
}

// Date Picker
extension FiltersViewController {
    
    func createDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        dateTextField.inputView = datePicker
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
}

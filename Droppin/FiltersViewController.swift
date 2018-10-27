//
//  FiltersViewController.swift
//  Droppin
//
//  Created by Kushal Pandya on 2018-10-26.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var mode: UISegmentedControl!
    @IBOutlet weak var closeModalButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var tabButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCategoryPicker()
        createDatePicker()
    }
    
    @IBAction func tapButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        // change this to perform API call for filters
        dismiss(animated: true, completion: nil)
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
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
}

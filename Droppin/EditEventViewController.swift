//
//  EditEventViewController.swift
//  Droppin
//
//  Created by Kushal Pandya on 2018-11-22.
//

import FirebaseFunctions
import UIKit

class EditEventViewController: UIViewController {

    @IBOutlet weak var eventType: UISegmentedControl!
    @IBOutlet weak var eventDateField: UITextField!
    @IBOutlet weak var eventDescriptionField: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var eventName: String = ""
    lazy var functions = Functions.functions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let data = [
            "eventName": eventName,
            "eventType": eventType.titleForSegment(at: eventType.selectedSegmentIndex)!,
            "dateStart": eventDateField.text!,
            "description": eventDescriptionField.text!
        ]
        
        // Activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        functions.httpsCallable("editEvent").call(data) { (result, error) in
            if let error = error as NSError? {
                let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            activityIndicator.stopAnimating()
            
            let alert = UIAlertController(
                title: "Success",
                message: self.eventName + " has been updated.",
                preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// Date Picker
extension EditEventViewController {
    
    func createDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        eventDateField.inputView = datePicker
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        eventDateField.text = datePicker.date.description
    }
}

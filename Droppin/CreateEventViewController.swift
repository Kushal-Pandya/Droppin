//
//  CreateEventViewController.swift
//  Droppin
//
//  Created by Kushal Pandya on 2018-10-17.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit
import MapKit

class CreateEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var useCurrentLocation: UISwitch!
    @IBOutlet weak var eventAddressField: UITextField!
    @IBOutlet weak var eventStartTime: UIDatePicker!
    @IBOutlet weak var eventCategoryPicker: UIPickerView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var submitEventButton: UIButton!
    
    var eventCategory: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventCategoryPicker.delegate = self
        self.eventCategoryPicker.dataSource = self
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
        self.eventCategory = row
    }

    @IBAction func currentLocationToggled(_ sender: UISwitch) {
        if (sender.isOn == true) {
            eventAddressField.isUserInteractionEnabled = false
            let addressObject = UserDefaults.standard.object(forKey: "address")
            if let address = addressObject as? String {
                eventAddressField.text = String(address)
            }
        } else {
            eventAddressField.isUserInteractionEnabled = true
            eventAddressField.text = ""
        }
    }
    
    @IBAction func createEventPressed(_ sender: UIButton) {
        if (useCurrentLocation.isOn) {
            //use current location
            eventAddressField.text = "custom"
        }
        else if (eventAddressField.text!.isEmpty) {
            // Alert if address empty
            let alert = UIAlertController(title: "Error", message: "Address Field Empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Ignore user actions since this will a blocking call
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        // Create the search request
        let searchRequest = MKLocalSearch.Request()
        // this will be "custom" if toggled switch
        searchRequest.naturalLanguageQuery = eventAddressField.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                // Alert if no location found
                let alert = UIAlertController(title: "Location Not Found", message: "Please Try Again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                // Get Data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                let parameters = [
                    "eventName": self.eventNameField.text!,
                    "address": self.eventAddressField.text!,
                    "description": self.eventDescription.text!,
                    "dateStart": self.eventStartTime.date.description,
                    "category": String(self.eventCategory),
                    "latitude": "\(String(describing: latitude!))",
                    "longitude": "\(String(describing: longitude!))"]
                
                Client.addEvent(parameters) { (results:[Any]) in
                    if results[0] as? Int == 200 {
                        //success
                        let alert = UIAlertController(title: "Success", message: "Event Created", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        //error
                        let alert = UIAlertController(title: "Failure", message: "Failed to Create Event", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
//        if let navigationController = self.navigationController {
//            navigationController.popViewController(animated: true)
//        }
    }
}

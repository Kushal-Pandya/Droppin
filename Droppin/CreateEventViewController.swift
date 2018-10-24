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
    
    @IBAction func dropEventTapped(_ sender: Any) {
        if (!eventAddressField.text!.isEmpty) {
            
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
                    
                    let parameters = ["eventName": self.eventNameField.text!,
                                      "latitude": "\(String(describing: latitude!))",
                        "longitude": "\(String(describing: longitude!))"]
                    
                    Client.addEvent(parameters) { (results:[Any]) in
                        if results[0] as? Int == 200 {
                            //success
                            print("successfully added an event with id \(results[1] as? String)")
                            
                        } else {
                            //error
                            print("successfully added an event")
                        }
                    }
                
                }
            }
            
            
        }
        
        if let navigationController = self.navigationController {
            let alert = UIAlertController(title: "Success", message: "Event Created", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            navigationController.popViewController(animated: true)
        }
    }
}

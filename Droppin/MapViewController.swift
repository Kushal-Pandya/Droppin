//
//  MapViewController.swift
//  Droppin
//
//  Created by Syed Ahmed on 2018-09-28.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        searchBar.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadEvents()
    }
}

extension MapViewController {
    func loadEvents() {
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        Client.getEvents() { (results:[Any]) in
            if results[0] as? Int == 200 {
                
                if let theResults = results[1] as? [String:Any] {
                    for (_, value) in theResults{
                        
                        let annotation = MKPointAnnotation()
                        
                        if let eventData = value as? [String:Any] {
                            
                            if let eventTitle = eventData["eventName"] as? String {
                                annotation.title = eventTitle
                            }
                            if let description = eventData["description"] as? String {
                                annotation.subtitle = description
                            }
                            
                            let theLatitude = Double((eventData["latitude"] as! NSString).floatValue)
                            let theLongitude = Double((eventData["longitude"] as! NSString).floatValue)
                            
                            annotation.coordinate = CLLocationCoordinate2DMake(theLatitude, theLongitude)
                            self.mapView.addAnnotation(annotation)
                        }
                    }
                }
                
            } else {
                // Alert if failed to obtain events
                let alert = UIAlertController(title: "Failure", message: "Failed to Obtain Events.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

        activityIndicator.stopAnimating()
    }
}


extension MapViewController: UISearchBarDelegate {
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        if let filtersViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: "filtersViewController") as? FiltersViewController {
            self.present(filtersViewController, animated: true, completion: nil)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Ignore user actions since this will a blocking call
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        searchBar.resignFirstResponder()
        
        // Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
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
                
                // Zooming in
                let coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                // 0.1 Delta is standard according to docs
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
}

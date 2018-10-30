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
    private let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    @IBAction func relocateButtonTapped(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    override func viewDidLoad() {
        searchBar.delegate = self
        mapView.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        super.viewDidLoad()
        checkLocationServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadEvents()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
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
                            if let dateStart = eventData["dateStart"] as? String {
                                annotation.subtitle = annotation.subtitle! + "\n  Date: " + dateStart
                            }
                            if let categoryIndex = eventData["category"] as? String {
                                let category = eventCategories[Int(categoryIndex)!]
                                annotation.subtitle = annotation.subtitle! + "\n Category: " + category
                            }
                            
                            let theLatitude = Double((eventData["latitude"] as! NSString).floatValue)
                            let theLongitude = Double((eventData["longitude"] as! NSString).floatValue)
                            
                            annotation.coordinate = CLLocationCoordinate2DMake(theLatitude, theLongitude)
                            
                            let eventCategory = eventData["category"] as? String
                            let eventDate = eventData["dateStart"] as? String
                            let eventLocation = eventData["address"] as? String
                            
                            
                            
                            // show artwork on map
                            let artwork = Artwork(title: annotation.title!,
                                                  subtitle: annotation.subtitle!,
                                                  date: eventDate!,
                                                  category: eventCategory!,
                                                  location: eventLocation!,
                                                  coordinate: CLLocationCoordinate2D(latitude: theLatitude, longitude: theLongitude))
                            //mapView.addAnnotation(artwork)
                            
                            self.mapView.addAnnotation(artwork)
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
            
            filtersViewController.filtersDelegate = self
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

extension MapViewController: FiltersDelegate {
    func didTapApplyFilters(eventList: [Any]) {
        self.mapView.removeAnnotations(self.mapView.annotations)

        for event in eventList {
            let annotation = MKPointAnnotation()
            annotation.subtitle = ""

            if let theEvent = event as? [String:Any] {
                let latitude = Double((theEvent["latitude"] as! NSString).floatValue)
                let longitude = Double((theEvent["longitude"] as! NSString).floatValue)
                
                if let eventTitle = theEvent["eventName"] as? String {
                    annotation.title = eventTitle
                }
                if let description = theEvent["description"] as? String {
                    annotation.subtitle = description
                }
                if let dateStart = theEvent["dateStart"] as? String {
                    annotation.subtitle = annotation.subtitle! + "\n Date: " + dateStart
                }
                if let categoryIndex = theEvent["category"] as? String {
                    let category = eventCategories[Int(categoryIndex)!]
                    annotation.subtitle = annotation.subtitle! + "\n Category: " + category
                }
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let _ = error {
                //TODO: Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                //TODO: Show alert informing the user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let postalCode = placemark.postalCode ?? ""
            let city = placemark.locality ?? ""
            let province = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""
            // let countryCode = placemark.isoCountryCode ?? ""
            
            let address = "\(streetNumber) \(streetName), \(postalCode), \(city), \(province), \(country)";
            print(address)
            
            UserDefaults.standard.set(address, forKey: "address")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Artwork else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! Artwork
        if let eventDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: "eventDetailsViewController") as? EventDetailsViewController {
            eventDetailsViewController.textTitle = ((annotation.title)!)
            eventDetailsViewController.textDescription = ((annotation.subtitle)!)
            eventDetailsViewController.textDate = annotation.date!
            eventDetailsViewController.textCategory = annotation.category!
            eventDetailsViewController.textLocation = annotation.location!
            self.present(eventDetailsViewController, animated: true, completion: nil)
            
        }
    }
}

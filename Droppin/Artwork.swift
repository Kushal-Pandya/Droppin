//
//  Artwork.swift
//  Droppin
//
//  Created by Syed Ahmed on 2018-10-30.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import Foundation
import MapKit

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let date: String?
    let text: String?
    let location: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, date: String, text: String, location: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.text = text
        self.location = location
        self.coordinate = coordinate
        
        super.init()
    }
    

}

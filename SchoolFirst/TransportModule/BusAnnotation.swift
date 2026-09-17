//
//  BusAnnotation.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 10/08/26.
//

import MapKit

class BusAnnotation: NSObject, MKAnnotation {

    // ✅ @objc dynamic → Required for smooth MapKit coordinate animation
    @objc dynamic var coordinate: CLLocationCoordinate2D

    var title    : String? = "School Bus"
    var subtitle : String? = "Live Tracking"

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

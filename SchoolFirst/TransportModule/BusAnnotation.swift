//
//  BusAnnotation.swift
//  SchoolFirst
//

import MapKit

class BusAnnotation: NSObject, MKAnnotation {

    @objc dynamic var coordinate: CLLocationCoordinate2D

    var title    : String? = "School Bus"
    var subtitle : String? = "Live Tracking"

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

//
//  BusAnnotation.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 10/08/26.
//


import MapKit

class BusAnnotation: NSObject, MKAnnotation {

    // ✅ @objc dynamic → MapKit coordinate change animation supports
    @objc dynamic var coordinate: CLLocationCoordinate2D

    var title    : String? = "School Bus"
    var subtitle : String? = "Route A"

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

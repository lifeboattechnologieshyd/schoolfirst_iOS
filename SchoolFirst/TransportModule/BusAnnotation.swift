//
//  BusAnnotation.swift
//  SchoolFirst
//

import MapKit
import UIKit

final class BusAnnotation: NSObject, MKAnnotation {

    // MARK: - Properties
    @objc dynamic var coordinate: CLLocationCoordinate2D
    @objc dynamic var heading: Double = 0.0 // Direction in degrees (0 - 360)

    var title: String? = "School Bus"
    var subtitle: String? = "Live Tracking"

    // MARK: - Animation State
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var animationDuration: TimeInterval = 1.5 // Default duration in seconds
    private var startCoordinate: CLLocationCoordinate2D
    private var targetCoordinate: CLLocationCoordinate2D

    // MARK: - Init
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.startCoordinate = coordinate
        self.targetCoordinate = coordinate
        super.init()
    }

    deinit {
        displayLink?.invalidate()
    }

    // MARK: - Smooth Movement API
    /// Call this method whenever a new coordinate is received (e.g. from Socket/Firebase/API)
    func updateCoordinate(to newCoordinate: CLLocationCoordinate2D, duration: TimeInterval = 1.5) {
        // Prevent unnecessary animations if coordinate hasn't changed
        guard newCoordinate.latitude != coordinate.latitude || newCoordinate.longitude != coordinate.longitude else {
            return
        }

        // Calculate heading (bearing) towards the new coordinate
        self.heading = calculateHeading(from: self.coordinate, to: newCoordinate)

        // Setup interpolation
        self.startCoordinate = self.coordinate
        self.targetCoordinate = newCoordinate
        self.animationDuration = duration
        self.startTime = CACurrentMediaTime()

        // Restart display link
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(handleAnimationStep))
        displayLink?.add(to: .main, forMode: .common)
    }

    // MARK: - Frame-by-Frame Interpolation (60/120 FPS)
    @objc private func handleAnimationStep() {
        let elapsed = CACurrentMediaTime() - startTime
        var progress = elapsed / animationDuration

        if progress >= 1.0 {
            progress = 1.0
            displayLink?.invalidate()
            displayLink = nil
        }

        // Linear interpolation (Lerp)
        let currentLat = startCoordinate.latitude + (targetCoordinate.latitude - startCoordinate.latitude) * progress
        let currentLng = startCoordinate.longitude + (targetCoordinate.longitude - startCoordinate.longitude) * progress

        // KVO notification triggers MKMapView to update position smoothly
        self.coordinate = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLng)
    }

    // MARK: - Helper: Bearing / Heading Calculation
    private func calculateHeading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude.toRadians()
        let lon1 = from.longitude.toRadians()
        let lat2 = to.latitude.toRadians()
        let lon2 = to.longitude.toRadians()

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return (radiansBearing.toDegrees() + 360).truncatingRemainder(dividingBy: 360)
    }
}

// MARK: - Degree / Radian Helpers
private extension Double {
    func toRadians() -> Double { self * .pi / 180.0 }
    func toDegrees() -> Double { self * 180.0 / .pi }
}

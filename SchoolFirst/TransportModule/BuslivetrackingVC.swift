//
//  BuslivetrackingVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 31/07/26.
//

import UIKit
import MapKit

class BuslivetrackingVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var Mapview    : MKMapView!
    @IBOutlet weak var BackButton : UIButton!

    // MARK: - Private
    private var busAnnotation  : BusAnnotation?
    private var movementTimer  : Timer?
    private var currentIndex   : Int = 0

    // ✅ Simulated bus route coordinates (Hyderabad path)
    // Replace with your city coordinates or actual API later
    private let routeCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 17.3850, longitude: 78.4867),  // Start
        CLLocationCoordinate2D(latitude: 17.3870, longitude: 78.4880),
        CLLocationCoordinate2D(latitude: 17.3890, longitude: 78.4895),
        CLLocationCoordinate2D(latitude: 17.3910, longitude: 78.4910),
        CLLocationCoordinate2D(latitude: 17.3930, longitude: 78.4925),
        CLLocationCoordinate2D(latitude: 17.3950, longitude: 78.4940),
        CLLocationCoordinate2D(latitude: 17.3970, longitude: 78.4955),
        CLLocationCoordinate2D(latitude: 17.3990, longitude: 78.4970),
        CLLocationCoordinate2D(latitude: 17.4010, longitude: 78.4985),
        CLLocationCoordinate2D(latitude: 17.4030, longitude: 78.5000),
        CLLocationCoordinate2D(latitude: 17.4050, longitude: 78.5015),
        CLLocationCoordinate2D(latitude: 17.4070, longitude: 78.5030),
        CLLocationCoordinate2D(latitude: 17.4090, longitude: 78.5045),
        CLLocationCoordinate2D(latitude: 17.4110, longitude: 78.5060)   // End
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("📌 BuslivetrackingVC — viewDidLoad")
        setupMapView()
        addBusAnnotation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startBusSimulation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBusSimulation()
    }

    // MARK: - Setup MapView
    private func setupMapView() {
        Mapview.delegate          = self
        Mapview.mapType           = .standard
        Mapview.showsUserLocation = false
        Mapview.showsCompass      = true
        Mapview.showsScale        = true

        // Zoom to route start point
        let startCoord = routeCoordinates.first ?? CLLocationCoordinate2D(
            latitude:  17.3850,
            longitude: 78.4867
        )
        let region = MKCoordinateRegion(
            center             : startCoord,
            latitudinalMeters  : 3000,
            longitudinalMeters : 3000
        )
        Mapview.setRegion(region, animated: false)
        print("✅ MapView setup done")
    }

    // MARK: - Add Bus Annotation at Start Position
    private func addBusAnnotation() {
        guard let startCoord = routeCoordinates.first else { return }

        let annotation      = BusAnnotation(coordinate: startCoord)
        annotation.title    = "🚌 School Bus"
        annotation.subtitle = "Route A - Kukatpally"

        busAnnotation = annotation
        Mapview.addAnnotation(annotation)
        print("✅ Bus annotation added at start")
    }

    // MARK: - Start Simulated Bus Movement
    private func startBusSimulation() {
        print("🚌 Starting bus simulation...")

        // Move bus every 2 seconds
        movementTimer = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: true
        ) { [weak self] _ in
            self?.moveBusToNextPoint()
        }
    }

    // MARK: - Stop Simulation
    private func stopBusSimulation() {
        movementTimer?.invalidate()
        movementTimer = nil
        print("🛑 Bus simulation stopped")
    }

    // MARK: - Move Bus to Next Point in Route
    private func moveBusToNextPoint() {
        guard let annotation = busAnnotation else { return }

        // Increment index, loop back to start when reached end
        currentIndex += 1
        if currentIndex >= routeCoordinates.count {
            currentIndex = 0
            print("🔄 Route completed — restarting from beginning")
        }

        let nextCoord = routeCoordinates[currentIndex]

        // ── Calculate heading (direction) for bus rotation ──────
        let heading = calculateHeading(
            from: annotation.coordinate,
            to:   nextCoord
        )

        // ── Animate coordinate change (smooth movement) ─────────
        UIView.animate(withDuration: 1.8) {
            annotation.coordinate = nextCoord
        }

        // ── Rotate bus icon towards direction ───────────────────
        if let annotationView = Mapview.view(for: annotation) as? BusAnnotationView {
            annotationView.rotate(degrees: heading)
        }

        print("🚌 Bus moved to point \(currentIndex + 1)/\(routeCoordinates.count)")
        print("   lat: \(nextCoord.latitude) | lng: \(nextCoord.longitude)")
        print("   heading: \(Int(heading))°")

        // Optional: keep bus visible in map view
        // Mapview.setCenter(nextCoord, animated: true)
    }

    // MARK: - Calculate Heading Between Two Coordinates
    private func calculateHeading(
        from: CLLocationCoordinate2D,
        to  : CLLocationCoordinate2D
    ) -> Double {
        let deltaLon = to.longitude - from.longitude
        let y        = sin(deltaLon) * cos(to.latitude)
        let x        = cos(from.latitude) * sin(to.latitude) -
                       sin(from.latitude) * cos(to.latitude) * cos(deltaLon)

        var radians  = atan2(y, x)
        var degrees  = radians * 180.0 / .pi

        // Normalize to 0-360
        degrees = (degrees + 360).truncatingRemainder(dividingBy: 360)
        return degrees
    }

    // MARK: - Actions

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        stopBusSimulation()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension BuslivetrackingVC: MKMapViewDelegate {

    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {

        // Only customize BusAnnotation
        guard annotation is BusAnnotation else { return nil }

        let reuseID = "BusAnnotationView"

        if let existing = mapView.dequeueReusableAnnotationView(
            withIdentifier: reuseID
        ) as? BusAnnotationView {
            existing.annotation = annotation
            return existing
        }

        return BusAnnotationView(
            annotation      : annotation,
            reuseIdentifier : reuseID
        )
    }
}

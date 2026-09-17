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

    // MARK: - Private Properties
    private var busAnnotation  : BusAnnotation?
    private var lastCoordinate : CLLocationCoordinate2D?
    private var locationTimer  : Timer?
    private let refreshInterval: TimeInterval = 5.0 // Fetch live location every 5 seconds

    // Native Activity Indicator
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
        setupMapView()
        fetchLiveLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLiveLocationTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLiveLocationTracking()
    }

    // MARK: - Setup Loader
    private func setupLoader() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Setup MapView
    private func setupMapView() {
        Mapview.delegate          = self
        Mapview.mapType           = .standard
        Mapview.showsUserLocation = false
        Mapview.showsCompass      = true
        Mapview.showsScale        = true
    }

    // MARK: - Fetch Live Location API
    private func fetchLiveLocation() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty else {
            print("❌ Student ID is empty")
            self.showErrorAlert(message: "Student configuration is missing.")
            return
        }

        guard !schoolId.isEmpty else {
            print("❌ School ID is empty")
            self.showErrorAlert(message: "School configuration is missing.")
            return
        }

        activityIndicator.startAnimating()

        NetworkManager.shared.request(
            urlString: API.TRANSPORT_LIVELOCATION,
            method: .GET,
            requiresAuth: true,
            parameters: [
                "student_id": studentId
            ],
            headers: [
                "X-School-Id": schoolId
            ]
        ) { [weak self] (result: Result<APIResponse<TransportLiveLocationData>, NetworkError>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()

                switch result {
                case .success(let response):
                    if response.success, let data = response.data {

                        // Check if live location is available
                        if data.isAvailable == false {
                            self.showErrorAlert(message: "Bus live location is not available at this moment.")
                            return
                        }

                        // Check if location data exists
                        guard let location = data.location,
                              let latitude = location.latitude,
                              let longitude = location.longitude else {
                            self.showErrorAlert(message: "Live location coordinates not found.")
                            return
                        }

                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let vehicleNumber = data.vehicle?.vehicleNumber ?? "School Bus"
                        let tripStatus = data.trip?.status ?? "Active"
                        let speed = location.speed ?? 0.0
                        let heading = location.heading

                        self.updateBusLocation(
                            coordinate: coordinate,
                            vehicleNumber: vehicleNumber,
                            tripStatus: tripStatus,
                            speed: speed,
                            heading: heading
                        )

                    } else {
                        let errorMsg = response.description.isEmpty ? "Failed to fetch live location." : response.description
                        self.showErrorAlert(message: errorMsg)
                    }

                case .failure(let error):
                    switch error {
                    case .noaccess:
                        print("❌ Session expired")
                    case .noInternet:
                        print("❌ No internet connection")
                    case .serverError(let message):
                        self.showErrorAlert(message: message)
                    case .decodingError(let message):
                        print("❌ Decoding Error: \(message)")
                        self.showErrorAlert(message: "Failed to parse live location data.")
                    case .invalidURL:
                        self.showErrorAlert(message: "Invalid Request URL.")
                    case .noData:
                        self.showErrorAlert(message: "No data received from server.")
                    }
                }
            }
        }
    }

    // MARK: - Update Bus Location on Map (Rapido/Swiggy Like Smooth Animation)
    private func updateBusLocation(coordinate: CLLocationCoordinate2D,
                                   vehicleNumber: String,
                                   tripStatus: String,
                                   speed: Double,
                                   heading: Int?) {

        let busHeading = Double(heading ?? 0)

        // If annotation does not exist, add it for the first time
        if busAnnotation == nil {
            let annotation = BusAnnotation(coordinate: coordinate)
            annotation.title = "🚌 \(vehicleNumber)"
            annotation.subtitle = "Trip: \(tripStatus.capitalized)"

            busAnnotation = annotation
            Mapview.addAnnotation(annotation)
            lastCoordinate = coordinate

            // Zoom and center map to current bus location
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            Mapview.setRegion(region, animated: true)
            print("✅ Bus annotation added at: \(coordinate.latitude), \(coordinate.longitude)")
            return
        }

        guard let annotation = busAnnotation else { return }

        let previousCoordinate = lastCoordinate ?? annotation.coordinate

        // Calculate heading if API doesn't provide valid heading (0 can be North)
        var directionDegrees = busHeading
        if heading == nil {
            directionDegrees = calculateHeading(from: previousCoordinate, to: coordinate)
        }

        // Smoothly animate bus movement
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut]) {
            annotation.coordinate = coordinate
        }

        // Update Callout Info
        annotation.title = "🚌 \(vehicleNumber)"
        annotation.subtitle = "Trip: \(tripStatus.capitalized)"

        // Rotate Bus Icon based on Direction
        if let annotationView = Mapview.view(for: annotation) as? BusAnnotationView {
            annotationView.rotate(degrees: directionDegrees)
        }

        // Smoothly follow bus on map (Like Rapido/Swiggy)
        Mapview.setCenter(coordinate, animated: true)

        lastCoordinate = coordinate

        print("🚌 Bus Live Location Updated → Lat: \(String(format: "%.6f", coordinate.latitude)), Lng: \(String(format: "%.6f", coordinate.longitude)), Speed: \(String(format: "%.2f", speed)) km/h, Heading: \(Int(directionDegrees))°")
    }

    // MARK: - Calculate Heading Between Two Coordinates
    private func calculateHeading(from: CLLocationCoordinate2D,
                                  to: CLLocationCoordinate2D) -> Double {
        let deltaLon = to.longitude - from.longitude
        let y = sin(deltaLon) * cos(to.latitude)
        let x = cos(from.latitude) * sin(to.latitude) -
        sin(from.latitude) * cos(to.latitude) * cos(deltaLon)

        var radians = atan2(y, x)
        var degrees = radians * 180.0 / .pi

        // Normalize to 0 - 360 degrees
        degrees = (degrees + 360).truncatingRemainder(dividingBy: 360)
        return degrees
    }

    // MARK: - Start Live Location Tracking (Auto Refresh)
    private func startLiveLocationTracking() {
        // Invalidate existing timer if any
        locationTimer?.invalidate()

        // Poll live location every 5 seconds
        locationTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval,
                                             repeats: true) { [weak self] _ in
            self?.fetchLiveLocation()
        }
        print("🔄 Live location tracking started (Refresh every \(Int(refreshInterval))s)")
    }

    // MARK: - Stop Live Location Tracking
    private func stopLiveLocationTracking() {
        locationTimer?.invalidate()
        locationTimer = nil
        print("🛑 Live location tracking stopped")
    }

    // MARK: - Error Alert
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Live Bus Tracking",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.fetchLiveLocation()
        }))
        self.present(alert, animated: true)
    }

    // MARK: - Back Button Action
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        stopLiveLocationTracking()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension BuslivetrackingVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

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
            annotation: annotation,
            reuseIdentifier: reuseID
        )
    }
}

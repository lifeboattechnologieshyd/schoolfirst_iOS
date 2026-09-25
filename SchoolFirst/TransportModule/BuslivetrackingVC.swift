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
    @IBOutlet weak var Topview: UIView!
    @IBOutlet weak var LivetrackingLabel: UILabel!
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
    
    // MARK: - Attractive "Not Started" Overlay
    private var notStartedOverlay: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
        setupMapView()
        setupNotStartedOverlay()
        fetchLiveLocation()
        setupFonts()
        setupTopViewShadow()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLiveLocationTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLiveLocationTracking()
    }
    
    private func setupTopViewShadow() {
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }
    
    private func setupFonts() {
        LivetrackingLabel?.font = .hankenBold(size: 16)
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
    
    // MARK: - Setup Attractive Not Started Popup
    private func setupNotStartedOverlay() {
        // Dark translucent background
        notStartedOverlay = UIView()
        notStartedOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        notStartedOverlay.translatesAutoresizingMaskIntoConstraints = false
        notStartedOverlay.isHidden = true
        notStartedOverlay.alpha = 0
        view.addSubview(notStartedOverlay)
        
        // White Card
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 15
        cardView.translatesAutoresizingMaskIntoConstraints = false
        notStartedOverlay.addSubview(cardView)
        
        // Bus/Clock Icon
        let iconView = UIImageView(image: UIImage(systemName: "clock.badge.exclamationmark"))
        iconView.tintColor = .systemOrange
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Trip Not Started Yet"
        titleLabel.font = .hankenBold(size: 20)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Message Label
        let messageLabel = UILabel()
        messageLabel.text = "The driver hasn't initiated the trip yet.\nStay on this screen, we are actively checking. Tracking will begin automatically once started."
        messageLabel.font = .hankenRegular(size: 14)
        messageLabel.textColor = .darkGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Go Back Button
        let backBtn = UIButton(type: .system)
        backBtn.setTitle("Go Back", for: .normal)
        backBtn.titleLabel?.font = .hankenBold(size: 16)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.backgroundColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1) // App Blue
        backBtn.layer.cornerRadius = 12
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.addTarget(self, action: #selector(BackButtonTapped(_:)), for: .touchUpInside)
        
        // Add subviews to card
        cardView.addSubview(iconView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(backBtn)
        
        // Constraints
        NSLayoutConstraint.activate([
            notStartedOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            notStartedOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            notStartedOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notStartedOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            cardView.centerXAnchor.constraint(equalTo: notStartedOverlay.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: notStartedOverlay.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: notStartedOverlay.widthAnchor, constant: -60),
            
            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            iconView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            backBtn.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            backBtn.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            backBtn.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            backBtn.heightAnchor.constraint(equalToConstant: 48),
            backBtn.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24)
        ])
    }

    private func showNotStartedPopup() {
        guard notStartedOverlay.isHidden else { return }
        notStartedOverlay.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.notStartedOverlay.alpha = 1
        }
    }
    
    private func hideNotStartedPopup() {
        guard !notStartedOverlay.isHidden else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.notStartedOverlay.alpha = 0
        }) { _ in
            self.notStartedOverlay.isHidden = true
        }
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

        guard !studentId.isEmpty else { return }
        guard !schoolId.isEmpty else { return }

        // Only show activity indicator on first load
        if busAnnotation == nil && notStartedOverlay.isHidden {
            activityIndicator.startAnimating()
        }

        NetworkManager.shared.request(
            urlString: API.TRANSPORT_LIVELOCATION,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<TransportLiveLocationData>, NetworkError>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()

                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        
                        let tripStatus = data.trip?.status?.lowercased() ?? ""
                        let isActive = ["active", "started", "live", "running", "on_route"].contains(tripStatus)
                        
                        // ✅ IF NOT STARTED: Show popup, but keep polling!
                        if !isActive {
                            self.showNotStartedPopup()
                            return
                        }
                        
                        // ✅ IF STARTED: Hide popup, process location
                        self.hideNotStartedPopup()

                        // Check if live location is available
                        if data.isAvailable == false {
                            self.showErrorAlert(message: "Bus live location is not available at this moment.")
                            return
                        }

                        // Check if location data exists
                        guard let location = data.location,
                              let latitude = location.latitude,
                              let longitude = location.longitude else {
                            return
                        }

                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let vehicleNumber = data.vehicle?.vehicleNumber ?? "School Bus"
                        let speed = location.speed ?? 0.0
                        let heading = location.heading

                        self.updateBusLocation(
                            coordinate: coordinate,
                            vehicleNumber: vehicleNumber,
                            tripStatus: tripStatus,
                            speed: speed,
                            heading: heading
                        )
                    }

                case .failure(_):
                    // Keep polling silently in background if error occurs (e.g. temporary network drop)
                    break
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
        locationTimer?.invalidate()
        locationTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval,
                                             repeats: true) { [weak self] _ in
            self?.fetchLiveLocation()
        }
    }

    // MARK: - Stop Live Location Tracking
    private func stopLiveLocationTracking() {
        locationTimer?.invalidate()
        locationTimer = nil
    }

    // MARK: - Error Alert
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Live Bus Tracking",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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

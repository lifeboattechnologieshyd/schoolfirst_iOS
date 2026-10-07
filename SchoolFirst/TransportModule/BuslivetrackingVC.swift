//
//  BuslivetrackingVC.swift
//  SchoolFirst
//

import UIKit
import MapKit
import Kingfisher

// MARK: - Stop Annotation (Pickup / Drop / Intermediate)
final class StopAnnotation: NSObject, MKAnnotation {
    enum Kind { case school, student, normal, pickup, drop }

    let coordinate: CLLocationCoordinate2D
    let title: String?
    let kind: Kind
    let stopId: String?
    var isReached: Bool
    private let timeText: String?

    var subtitle: String? {
        var parts: [String] = []
        if let t = timeText, !t.isEmpty { parts.append(t) }
        parts.append(isReached ? "Reached" : "Upcoming")
        return parts.joined(separator: " • ")
    }

    init(coordinate: CLLocationCoordinate2D,
         title: String?,
         subtitle: String?,
         kind: Kind,
         stopId: String? = nil,
         isReached: Bool = false) {
        self.coordinate = coordinate
        self.title = title
        self.timeText = subtitle
        self.kind = kind
        self.stopId = stopId
        self.isReached = isReached
        super.init()
    }
}

// MARK: - Route Progress View
final class RouteProgressView: UIView {

    enum State { case done, current, pending }
    struct Step { let title: String; let subtitle: String; let state: State }

    private let line = UIView()
    private let activeLine = UIView()
    private let stack = UIStackView()
    private var circles: [UIView] = []
    private let blue = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        line.backgroundColor = .systemGray4
        activeLine.backgroundColor = blue
        line.translatesAutoresizingMaskIntoConstraints = false
        activeLine.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(line)
        addSubview(activeLine)
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(steps: [Step]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        circles.removeAll()
        line.constraints.forEach { line.removeConstraint($0) }
        NSLayoutConstraint.deactivate(line.superview?.constraints.filter { $0.firstItem === line || $0.secondItem === line || $0.firstItem === activeLine || $0.secondItem === activeLine } ?? [])

        for (i, s) in steps.enumerated() {
            let col = UIStackView()
            col.axis = .vertical
            col.alignment = .center
            col.spacing = 6 // Figma spacing

            let iconContainer = UIView()
            iconContainer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconContainer.widthAnchor.constraint(equalToConstant: 28),
                iconContainer.heightAnchor.constraint(equalToConstant: 28)
            ])

            let iconView = UIImageView()
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconContainer.addSubview(iconView)
            
           
            if i == 0 {
                // 1. School (Green Checkmark)
                iconContainer.layer.cornerRadius = 14
                iconContainer.backgroundColor = s.state == .pending ? .systemGray4 : .systemGreen
                iconView.image = UIImage(systemName: "checkmark")
                iconView.tintColor = .white
                iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(weight: .bold)
                
                NSLayoutConstraint.activate([
                    iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                    iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                    iconView.widthAnchor.constraint(equalToConstant: 14),
                    iconView.heightAnchor.constraint(equalToConstant: 14)
                ])
                
            } else if i == 1 {
                
                iconContainer.layer.cornerRadius = 14
                iconContainer.backgroundColor = .white
                
               
                iconView.image = UIImage(named: "Bus vehicle icon") ?? UIImage(systemName: "bus.fill")
                if iconView.image == UIImage(systemName: "bus.fill") { iconView.tintColor = .systemYellow }
                
                NSLayoutConstraint.activate([
                    iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                    iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                    iconView.widthAnchor.constraint(equalToConstant: 26),
                    iconView.heightAnchor.constraint(equalToConstant: 26)
                ])
                
            } else {
                // 3. Arjun's Stop (Target/Bullseye icon)
                iconContainer.backgroundColor = .white
                iconView.image = UIImage(systemName: "record.circle")
                iconView.tintColor = .systemGray3
                iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
                
                NSLayoutConstraint.activate([
                    iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                    iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                    iconView.widthAnchor.constraint(equalToConstant: 28),
                    iconView.heightAnchor.constraint(equalToConstant: 28)
                ])
            }

            
            let title = UILabel()
            title.font = .hankenBold(size: 12)
            title.textAlignment = .center
            title.text = s.title
            title.numberOfLines = 1
            title.adjustsFontSizeToFitWidth = true

            let sub = UILabel()
            sub.font = .hankenMedium(size: 10)
            sub.textAlignment = .center
            sub.text = s.subtitle

            
            switch s.state {
            case .done:
                title.textColor = .black
                sub.textColor = .systemGray
            case .current:
                title.textColor = blue
                sub.textColor = blue
            case .pending:
                title.textColor = .darkGray
                sub.textColor = .systemGray
            }

            col.addArrangedSubview(iconContainer)
            col.addArrangedSubview(title)
            col.addArrangedSubview(sub)
            stack.addArrangedSubview(col)
            circles.append(iconContainer)
        }

       
        guard let first = circles.first, let last = circles.last else { return }
        sendSubviewToBack(activeLine)
        sendSubviewToBack(line)

        let currentIndex = steps.firstIndex { $0.state == .current } ?? (steps.lastIndex { $0.state == .done } ?? 0)
        let target = circles[min(currentIndex, circles.count - 1)]

        NSLayoutConstraint.activate([
            line.centerYAnchor.constraint(equalTo: first.centerYAnchor),
            line.leadingAnchor.constraint(equalTo: first.centerXAnchor),
            line.trailingAnchor.constraint(equalTo: last.centerXAnchor),
            line.heightAnchor.constraint(equalToConstant: 3), // Figma లో లైన్ కొంచెం మందంగా ఉంది
            
            activeLine.centerYAnchor.constraint(equalTo: first.centerYAnchor),
            activeLine.leadingAnchor.constraint(equalTo: first.centerXAnchor),
            activeLine.trailingAnchor.constraint(equalTo: target.centerXAnchor),
            activeLine.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
}
class BuslivetrackingVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var Topview: UIView!
    @IBOutlet weak var LivetrackingLabel: UILabel!
    @IBOutlet weak var Mapview    : MKMapView!
    @IBOutlet weak var BackButton : UIButton!
    
    

    // MARK: - Input
    var busData: StudentBusData?
    private var isRouteDistanceAnimation = false
    private var routeAnimationStartDistance: CLLocationDistance = 0
    private var routeAnimationEndDistance: CLLocationDistance = 0
    
    private var panelHeightConstraint: NSLayoutConstraint!
    private var panelCollapsedHeight: CGFloat = 120
    private var panelExpandedHeight: CGFloat = 0
    private var panelDragStartHeight: CGFloat = 0
    private var isPanelExpanded = true
    private weak var panelGrabber: UIView?

    // MARK: - Private Properties
    private var busAnnotation  : BusAnnotation?
    private var lastRawCoordinate : CLLocationCoordinate2D?
    private var locationTimer  : Timer?
    private let refreshInterval: TimeInterval = 10.0
    private var hasFetchedBusDataOnce = false

    // MARK: - Smooth Movement Properties
    private var displayLink: CADisplayLink?
    private var animationStartRaw: CLLocationCoordinate2D?
    private var animationEndRaw: CLLocationCoordinate2D?
    private var animationStartTime: CFTimeInterval = 0
    private var animationDuration: CFTimeInterval = 4.0

    /// Current visual position on map (next leg starts here → no jump)
    private var visualCoordinate: CLLocationCoordinate2D?

    /// Speed settings — animation should finish just before next GPS update (5s)
    private let targetAnimationDuration: CFTimeInterval = 2.2
       private let minAnimationDuration: CFTimeInterval = 0.6
       private let maxAnimationDuration: CFTimeInterval = 2.8

    // MARK: - Route Properties
    private var routeStopCoordinates: [CLLocationCoordinate2D] = []
    private var routeStopNames: [String] = []
    private var fullRouteCoordinates: [CLLocationCoordinate2D] = []
    private var remainingRouteOverlay: MKPolyline?   // Ahead of bus (BLUE)
    private var traveledRouteOverlay: MKPolyline?    // Behind bus (GRAY - completed)
    private var isRouteDrawn = false
    private var hasFittedInitialRegion = false
    private var routeBuildToken = 0                  // cancels stale route builds
    private var lastTrimSegmentIndex: Int = -1
    private var lastTrimTime: CFTimeInterval = 0

    private let appBlue = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
    private let traveledColor = UIColor(red: 180/255, green: 190/255, blue: 205/255, alpha: 1)

    // MARK: - ETA Properties
    private var etaLastRoutedCoord: CLLocationCoordinate2D?
    private var etaIsRouting = false
    private var cachedETASeconds: TimeInterval?
    private var cachedDistanceMeters: CLLocationDistance?
    private var lastUpdateDate: Date?
    private var uiTimer: Timer?
    private var currentSpeed: Double = 0
    private var currentTripStatus: String = ""
    private var isStudentBoarded: Bool = false

    // MARK: - Header UI
    private let routeSubtitleLabel = UILabel()
    private let liveBadge = UIView()
    private let liveDot = UIView()

    // MARK: - Top Info Card UI
    private let infoCard = UIView()
    private let cardBusImage = UIImageView()
    private let cardBusNumber = UILabel()
    private let cardBusModel = UILabel()
    private let cardStatusTag = UILabel()
    private let cardETA = UILabel()
    private let cardDistance = UILabel()
    private let cardNextStopTitle = UILabel()
    private let cardNextStopName = UILabel()
    private let cardUpdated = UILabel()

    // MARK: - Bottom Panel UI
    private let panel = UIView()
    private let panelScroll = UIScrollView()
    private let panelStack = UIStackView()
    private let studentImage = UIImageView()
    private let studentName = UILabel()
    private let studentStatus = UILabel()
    private let studentExpected = UILabel()
    private var studentCardView: UIView!
    private let driverImage = UIImageView()
    private let driverName = UILabel()
    private let driverMeta = UILabel()
    private let statBusValue = UILabel()
    private let statBusSub = UILabel()
    private let statModelValue = UILabel()
    private let statModelSub = UILabel()
    private let statCapValue = UILabel()
    private let statCapSub = UILabel()
    private let progressCount = UILabel()
    private let progressView = RouteProgressView()
    private var panelHeight: CGFloat = 0
    
    private var tripCompletedOverlay: UIView!
    private let completedStartTimeLabel = UILabel()
    private let completedEndTimeLabel = UILabel()
    private let completedBusNumberLabel = UILabel()
    private let completedRouteNumberLabel = UILabel()
    
    // MARK: - Not Started dynamic labels
    private let notStartedPickupLabel = UILabel()
    private let notStartedBusNumberLabel = UILabel()
    private let notStartedRouteNumberLabel = UILabel()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var notStartedOverlay: UIView!

    // MARK: - Floating Map Controls UI
    private let mapControlsContainer = UIView()
    private let locateBusButton = UIButton(type: .system)
    private let zoomControlsView = UIView()
    private let zoomInButton = UIButton(type: .system)
    private let zoomOutButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
        setupMapView()
        setupHeaderUI()
        setupInfoCard()
        setupFloatingMapControls()
        setupBottomPanel()
        setupNotStartedOverlay()
        setupTripCompletedOverlay()
        setupFonts()
        setupTopViewShadow()

        populateStaticData()
        setupRouteOnMap()
        fetchInitialBusData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLiveLocationTracking()
        startUITimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLiveLocationTracking()
        uiTimer?.invalidate(); uiTimer = nil
        stopSmoothAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ✅ CHANGED: Calculate dynamic panel heights based on screen size
               let expanded = view.bounds.height * 0.46
               panelExpandedHeight = expanded
               panelCollapsedHeight = 130  // Shows only student card + grabber
               
               // First layout → start expanded
               if panelHeightConstraint.constant == 320 || panelHeightConstraint.constant <= 0 {
                   panelHeightConstraint.constant = expanded
                   isPanelExpanded = true
               }
               
               panelHeight = panelHeightConstraint.constant
               Mapview.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: panelHeight, right: 0)
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

    private func setupLoader() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - HEADER
    private func setupHeaderUI() {
        guard let top = Topview, let title = LivetrackingLabel else { return }

        routeSubtitleLabel.font = .hankenMedium(size: 11)
        routeSubtitleLabel.textColor = .systemGray
        routeSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        top.addSubview(routeSubtitleLabel)

        liveBadge.backgroundColor = UIColor(red: 220/255, green: 245/255, blue: 230/255, alpha: 1)
        liveBadge.layer.cornerRadius = 10
        liveBadge.translatesAutoresizingMaskIntoConstraints = false
        top.addSubview(liveBadge)

        liveDot.backgroundColor = .systemGreen
        liveDot.layer.cornerRadius = 3
        liveDot.translatesAutoresizingMaskIntoConstraints = false
        let liveText = UILabel()
        liveText.text = "LIVE"
        liveText.font = .hankenBold(size: 9)
        liveText.textColor = UIColor(red: 22/255, green: 140/255, blue: 70/255, alpha: 1)
        liveText.translatesAutoresizingMaskIntoConstraints = false
        liveBadge.addSubview(liveDot); liveBadge.addSubview(liveText)

        NSLayoutConstraint.activate([
            routeSubtitleLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            routeSubtitleLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 1),

            liveBadge.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            liveBadge.trailingAnchor.constraint(equalTo: top.trailingAnchor, constant: -16),
            liveBadge.heightAnchor.constraint(equalToConstant: 20),

            liveDot.leadingAnchor.constraint(equalTo: liveBadge.leadingAnchor, constant: 8),
            liveDot.centerYAnchor.constraint(equalTo: liveBadge.centerYAnchor),
            liveDot.widthAnchor.constraint(equalToConstant: 6),
            liveDot.heightAnchor.constraint(equalToConstant: 6),
            liveText.leadingAnchor.constraint(equalTo: liveDot.trailingAnchor, constant: 4),
            liveText.trailingAnchor.constraint(equalTo: liveBadge.trailingAnchor, constant: -8),
            liveText.centerYAnchor.constraint(equalTo: liveBadge.centerYAnchor)
        ])
        liveBadge.isHidden = true
        pulseLiveDot()
    }

    private func pulseLiveDot() {
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse]) {
            self.liveDot.alpha = 0.2
        }
    }

    // MARK: - TOP INFO CARD
    private func setupInfoCard() {

        infoCard.backgroundColor = .white
        infoCard.layer.cornerRadius = 14
        infoCard.layer.shadowColor = UIColor.black.cgColor
        infoCard.layer.shadowOpacity = 0.12
        infoCard.layer.shadowRadius = 8
        infoCard.layer.shadowOffset = CGSize(width: 0, height: 3)
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        infoCard.isHidden = true
        view.addSubview(infoCard)

        cardBusImage.contentMode = .scaleAspectFill
        cardBusImage.clipsToBounds = true
        cardBusImage.layer.cornerRadius = 8
        cardBusImage.backgroundColor = UIColor(white: 0.95, alpha: 1)
        cardBusImage.image = UIImage(systemName: "bus.fill")
        cardBusImage.tintColor = .systemOrange
        cardBusImage.translatesAutoresizingMaskIntoConstraints = false

        cardBusNumber.font = .hankenBold(size: 14)
        cardBusModel.font = .hankenBold(size: 10)
        cardBusModel.textColor = .systemGray
        cardStatusTag.font = .hankenBold(size: 10)
        cardStatusTag.textColor = .systemGreen
        cardStatusTag.text = "ON THE WAY"

        let busText = UIStackView(arrangedSubviews: [cardBusNumber, cardBusModel, cardStatusTag])
        busText.axis = .vertical
        busText.spacing = 1

        let col1 = UIStackView(arrangedSubviews: [cardBusImage, busText])
        col1.axis = .horizontal
        col1.spacing = 8
        col1.alignment = .center

        let clock = UIImageView(image: UIImage(named: "clock-3"))
        clock.tintColor = appBlue
        clock.contentMode = .scaleAspectFit
        clock.translatesAutoresizingMaskIntoConstraints = false

        cardETA.font = .hankenBold(size: 16)
        cardETA.textColor = appBlue
        cardETA.text = "-- min"

        let etaRow = UIStackView(arrangedSubviews: [clock, cardETA])
        etaRow.axis = .horizontal
        etaRow.spacing = 4
        etaRow.alignment = .center

        cardDistance.font = .hankenBold(size: 12)
        cardDistance.textColor = .darkGray
        cardDistance.text = "-- km away"

        let col2 = UIStackView(arrangedSubviews: [etaRow, cardDistance])
        col2.axis = .vertical
        col2.spacing = 2
        col2.alignment = .center

        cardNextStopTitle.font = .hankenBold(size: 10)
        cardNextStopTitle.textColor = .systemGray
        cardNextStopTitle.text = "Next stop"

        cardNextStopName.font = .hankenBold(size: 14)
        cardNextStopName.numberOfLines = 1

        cardUpdated.font = .hankenBold(size: 10)
        cardUpdated.textColor = .systemGray

        let col3 = UIStackView(arrangedSubviews: [cardNextStopTitle, cardNextStopName, cardUpdated])
        col3.axis = .vertical
        col3.spacing = 1

        let sep1 = UIView()
        sep1.backgroundColor = .systemGray5

        let sep2 = UIView()
        sep2.backgroundColor = .systemGray5

        let row = UIStackView(arrangedSubviews: [col1, sep1, col2, sep2, col3])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        infoCard.addSubview(row)

        NSLayoutConstraint.activate([

            infoCard.topAnchor.constraint(equalTo: Mapview.topAnchor, constant: 12),
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),

            // ONLY CHANGE: Info card height
            infoCard.heightAnchor.constraint(equalToConstant: 76),

            row.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 10),
            row.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -10),
            row.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -12),

            cardBusImage.widthAnchor.constraint(equalToConstant: 40),
            cardBusImage.heightAnchor.constraint(equalToConstant: 40),

            clock.widthAnchor.constraint(equalToConstant: 14),
            clock.heightAnchor.constraint(equalToConstant: 14),

            sep1.widthAnchor.constraint(equalToConstant: 1),
            sep1.heightAnchor.constraint(equalToConstant: 34),

            sep2.widthAnchor.constraint(equalToConstant: 1),
            sep2.heightAnchor.constraint(equalToConstant: 34),

            col1.widthAnchor.constraint(equalTo: col3.widthAnchor, multiplier: 1.15),
            col2.widthAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
    }
    // MARK: - FLOATING MAP CONTROLS
    private func setupFloatingMapControls() {
        mapControlsContainer.translatesAutoresizingMaskIntoConstraints = false
        mapControlsContainer.isHidden = false
        view.addSubview(mapControlsContainer)

        // 1. Locate / Recenter Button (Circle)
        locateBusButton.backgroundColor = .white
        locateBusButton.layer.cornerRadius = 20
        locateBusButton.layer.shadowColor = UIColor.black.cgColor
        locateBusButton.layer.shadowOpacity = 0.12
        locateBusButton.layer.shadowRadius = 6
        locateBusButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        locateBusButton.translatesAutoresizingMaskIntoConstraints = false
        
        let locateImg = (UIImage(named: "locate-fixed") ?? UIImage(systemName: "locate-fixed"))?
            .withRenderingMode(.alwaysTemplate)

        locateBusButton.setImage(locateImg, for: .normal)
        locateBusButton.tintColor = appBlue

        locateBusButton.imageView?.contentMode = .scaleAspectFit

        locateBusButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        locateBusButton.addTarget(self, action: #selector(locateBusTapped), for: .touchUpInside)
        mapControlsContainer.addSubview(locateBusButton)

        // 2. Zoom Controls Card (+ / -)
        zoomControlsView.backgroundColor = .white
        zoomControlsView.layer.cornerRadius = 10
        zoomControlsView.layer.shadowColor = UIColor.black.cgColor
        zoomControlsView.layer.shadowOpacity = 0.12
        zoomControlsView.layer.shadowRadius = 6
        zoomControlsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        zoomControlsView.translatesAutoresizingMaskIntoConstraints = false
        mapControlsContainer.addSubview(zoomControlsView)

        let plusConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let plusImg = UIImage(systemName: "plus", withConfiguration: plusConfig)?.withRenderingMode(.alwaysTemplate)
        zoomInButton.backgroundColor = .clear
        zoomInButton.setImage(plusImg, for: .normal)
        zoomInButton.tintColor = UIColor(red: 20/255, green: 30/255, blue: 50/255, alpha: 1)
        zoomInButton.imageView?.contentMode = .scaleAspectFit
        zoomInButton.imageEdgeInsets = .zero
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        zoomInButton.addTarget(self, action: #selector(zoomInTapped), for: .touchUpInside)

        let zoomDivider = UIView()
        zoomDivider.backgroundColor = UIColor(red: 235/255, green: 238/255, blue: 242/255, alpha: 1)
        zoomDivider.translatesAutoresizingMaskIntoConstraints = false

        let minusConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let minusImg = UIImage(systemName: "minus", withConfiguration: minusConfig)?.withRenderingMode(.alwaysTemplate)
        zoomOutButton.backgroundColor = .clear
        zoomOutButton.setImage(minusImg, for: .normal)
        zoomOutButton.tintColor = UIColor(red: 20/255, green: 30/255, blue: 50/255, alpha: 1)
        zoomOutButton.imageView?.contentMode = .scaleAspectFit
        zoomOutButton.imageEdgeInsets = .zero
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        zoomOutButton.addTarget(self, action: #selector(zoomOutTapped), for: .touchUpInside)

        zoomControlsView.addSubview(zoomInButton)
        zoomControlsView.addSubview(zoomDivider)
        zoomControlsView.addSubview(zoomOutButton)

        NSLayoutConstraint.activate([
            mapControlsContainer.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 14),
            mapControlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapControlsContainer.widthAnchor.constraint(equalToConstant: 40),

            locateBusButton.topAnchor.constraint(equalTo: mapControlsContainer.topAnchor),
            locateBusButton.centerXAnchor.constraint(equalTo: mapControlsContainer.centerXAnchor),
            locateBusButton.widthAnchor.constraint(equalToConstant: 40),
            locateBusButton.heightAnchor.constraint(equalToConstant: 40),

            zoomControlsView.topAnchor.constraint(equalTo: locateBusButton.bottomAnchor, constant: 12),
            zoomControlsView.centerXAnchor.constraint(equalTo: mapControlsContainer.centerXAnchor),
            zoomControlsView.widthAnchor.constraint(equalToConstant: 40),
            zoomControlsView.heightAnchor.constraint(equalToConstant: 80),
            zoomControlsView.bottomAnchor.constraint(equalTo: mapControlsContainer.bottomAnchor),

            zoomInButton.topAnchor.constraint(equalTo: zoomControlsView.topAnchor),
            zoomInButton.leadingAnchor.constraint(equalTo: zoomControlsView.leadingAnchor),
            zoomInButton.trailingAnchor.constraint(equalTo: zoomControlsView.trailingAnchor),
            zoomInButton.heightAnchor.constraint(equalToConstant: 39.5),

            zoomDivider.topAnchor.constraint(equalTo: zoomInButton.bottomAnchor),
            zoomDivider.leadingAnchor.constraint(equalTo: zoomControlsView.leadingAnchor, constant: 6),
            zoomDivider.trailingAnchor.constraint(equalTo: zoomControlsView.trailingAnchor, constant: -6),
            zoomDivider.heightAnchor.constraint(equalToConstant: 1),

            zoomOutButton.topAnchor.constraint(equalTo: zoomDivider.bottomAnchor),
            zoomOutButton.leadingAnchor.constraint(equalTo: zoomControlsView.leadingAnchor),
            zoomOutButton.trailingAnchor.constraint(equalTo: zoomControlsView.trailingAnchor),
            zoomOutButton.bottomAnchor.constraint(equalTo: zoomControlsView.bottomAnchor)
        ])
    }

    @objc private func zoomInTapped() {
        var region = Mapview.region
        region.span.latitudeDelta = max(0.001, region.span.latitudeDelta / 2.0)
        region.span.longitudeDelta = max(0.001, region.span.longitudeDelta / 2.0)
        Mapview.setRegion(region, animated: true)
    }

    @objc private func zoomOutTapped() {
        var region = Mapview.region
        region.span.latitudeDelta = min(120.0, region.span.latitudeDelta * 2.0)
        region.span.longitudeDelta = min(120.0, region.span.longitudeDelta * 2.0)
        Mapview.setRegion(region, animated: true)
    }

    @objc private func locateBusTapped() {
        if let busCoord = visualCoordinate ?? lastRawCoordinate ?? busAnnotation?.coordinate {
            let region = MKCoordinateRegion(center: busCoord, latitudinalMeters: 600, longitudinalMeters: 600)
            Mapview.setRegion(region, animated: true)
        } else {
            fitMapToRoute(includeBus: true)
        }
    }

    @objc private func handlePanelPan(_ gesture: UIPanGestureRecognizer) {
           let translation = gesture.translation(in: view)
           let velocity = gesture.velocity(in: view)

           switch gesture.state {
           case .began:
               // Store starting height when drag begins
               panelDragStartHeight = panelHeightConstraint.constant

           case .changed:
               // Dragging down decreases height (more map visible)
               // Dragging up increases height (more details visible)
               var newHeight = panelDragStartHeight - translation.y
               newHeight = max(panelCollapsedHeight, min(panelExpandedHeight, newHeight))
               panelHeightConstraint.constant = newHeight
               panelHeight = newHeight
               Mapview.layoutMargins.bottom = newHeight
               view.layoutIfNeeded()

           case .ended, .cancelled:
               // Snap to expanded or collapsed based on velocity and position
               let mid = (panelCollapsedHeight + panelExpandedHeight) / 2
               let shouldExpand: Bool
               if abs(velocity.y) > 600 {
                   shouldExpand = velocity.y < 0  // Flick up → expand
               } else {
                   shouldExpand = panelHeightConstraint.constant > mid
               }
               snapPanel(expanded: shouldExpand, animated: true)

           default:
               break
           }
       }

       private func snapPanel(expanded: Bool, animated: Bool) {
           isPanelExpanded = expanded
           let target = expanded ? panelExpandedHeight : panelCollapsedHeight

           let animations = {
               self.panelHeightConstraint.constant = target
               self.panelHeight = target
               self.Mapview.layoutMargins.bottom = target
               self.view.layoutIfNeeded()
           }

           if animated {
               UIView.animate(withDuration: 0.35,
                              delay: 0,
                              usingSpringWithDamping: 0.85,
                              initialSpringVelocity: 0.5,
                              options: [.curveEaseOut, .allowUserInteraction],
                              animations: animations)
           } else {
               animations()
           }

           // ✅ Inner scroll only enabled when panel is fully expanded
           panelScroll.isScrollEnabled = expanded
       }

       // ✅ Optional helper to programmatically expand/collapse panel
       func setPanelExpanded(_ expanded: Bool, animated: Bool = true) {
           snapPanel(expanded: expanded, animated: animated)
       }

    // MARK: - BOTTOM PANEL
    private func setupBottomPanel() {
               panel.backgroundColor = .white
               panel.layer.cornerRadius = 20
               panel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
               panel.layer.shadowColor = UIColor.black.cgColor
               panel.layer.shadowOpacity = 0.12
               panel.layer.shadowRadius = 10
               panel.layer.shadowOffset = CGSize(width: 0, height: -3)
               panel.translatesAutoresizingMaskIntoConstraints = false
               view.addSubview(panel)

               let grabber = UIView()
               grabber.backgroundColor = .systemGray4
               grabber.layer.cornerRadius = 2.5
               grabber.translatesAutoresizingMaskIntoConstraints = false
               panel.addSubview(grabber)
               panelGrabber = grabber  // ✅ CHANGED: Store grabber reference for gesture

               panelScroll.showsVerticalScrollIndicator = false
               panelScroll.isScrollEnabled = true
               panelScroll.alwaysBounceVertical = true
               panelScroll.translatesAutoresizingMaskIntoConstraints = false
               panel.addSubview(panelScroll)

               panelStack.axis = .vertical
               panelStack.spacing = 12
               panelStack.translatesAutoresizingMaskIntoConstraints = false
               panelScroll.addSubview(panelStack)

               // ✅ CHANGED: Use constant height constraint instead of multiplier (for drag)
               panelHeightConstraint = panel.heightAnchor.constraint(equalToConstant: 310)
               panelHeightConstraint.isActive = true

               NSLayoutConstraint.activate([
                   panel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   panel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   panel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                   // ✅ CHANGED: Height is now controlled by panelHeightConstraint above

                   grabber.topAnchor.constraint(equalTo: panel.topAnchor, constant: 8),
                   grabber.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
                   grabber.widthAnchor.constraint(equalToConstant: 40),
                   grabber.heightAnchor.constraint(equalToConstant: 5),

                   panelScroll.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 8),
                   panelScroll.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
                   panelScroll.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
                   panelScroll.bottomAnchor.constraint(equalTo: panel.safeAreaLayoutGuide.bottomAnchor, constant: -2),

                   panelStack.topAnchor.constraint(equalTo: panelScroll.contentLayoutGuide.topAnchor),
                   panelStack.bottomAnchor.constraint(equalTo: panelScroll.contentLayoutGuide.bottomAnchor, constant: -4),
                   panelStack.leadingAnchor.constraint(equalTo: panelScroll.contentLayoutGuide.leadingAnchor, constant: 16),
                   panelStack.trailingAnchor.constraint(equalTo: panelScroll.contentLayoutGuide.trailingAnchor, constant: -16),
                   panelStack.widthAnchor.constraint(equalTo: panelScroll.frameLayoutGuide.widthAnchor, constant: -32)
               ])

               // Student card is outside the bottom panel and displayed
               // at the bottom of the map, just above the bottom panel.
               studentCardView = buildStudentCard()
               studentCardView.translatesAutoresizingMaskIntoConstraints = false
               view.addSubview(studentCardView)

               NSLayoutConstraint.activate([
                   studentCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                   studentCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                   studentCardView.bottomAnchor.constraint(equalTo: panel.topAnchor, constant: -10)
               ])

               panelStack.addArrangedSubview(sectionTitle("Driver & Bus Details"))
               panelStack.addArrangedSubview(buildDriverRow())
               panelStack.addArrangedSubview(buildStatsRow())
               panelStack.addArrangedSubview(buildProgressHeader())
               progressView.translatesAutoresizingMaskIntoConstraints = false
               progressView.heightAnchor.constraint(equalToConstant: 66).isActive = true
               panelStack.addArrangedSubview(progressView)
               
               // ✅ CHANGED: Add drag gesture to panel for pull down/up functionality
               let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanelPan(_:)))
               pan.cancelsTouchesInView = false
               panel.addGestureRecognizer(pan)
    };    private func sectionTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .hankenBold(size: 15)
        l.textAlignment = .center
        l.textColor = .black
        return l
    }

    private func buildStudentCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 1)
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor

        studentImage.contentMode = .scaleAspectFill
        studentImage.clipsToBounds = true
        studentImage.layer.cornerRadius = 18
        studentImage.backgroundColor = .systemGray5
        studentImage.image = UIImage(systemName: "person.crop.circle.fill")
        studentImage.tintColor = .systemGray3
        studentImage.translatesAutoresizingMaskIntoConstraints = false

        studentName.font = .hankenBold(size: 15)
        studentStatus.font = .hankenSemiBold(size: 11); studentStatus.textColor = UIColor(red: 8/255, green: 120/255, blue: 249/255, alpha: 1.0)
        studentExpected.font = .hankenMedium(size: 10); studentExpected.textColor = .systemGray
        studentStatus.text = "Waiting for trip to start"
        studentExpected.text = "--"

        let text = UIStackView(arrangedSubviews: [studentName, studentStatus, studentExpected])
        text.axis = .vertical; text.spacing = 1
        text.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray2
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(studentImage); card.addSubview(text); card.addSubview(chevron)
        NSLayoutConstraint.activate([
            studentImage.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            studentImage.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            studentImage.widthAnchor.constraint(equalToConstant: 36),
            studentImage.heightAnchor.constraint(equalToConstant: 36),
            text.leadingAnchor.constraint(equalTo: studentImage.trailingAnchor, constant: 10),
            text.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            text.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            text.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(studentCardTapped))
        card.addGestureRecognizer(tap)
        return card
    }

    @objc private func studentCardTapped() {
        guard let bus = busAnnotation else { return }
        Mapview.setCenter(bus.coordinate, animated: true)
    }

    private func buildDriverRow() -> UIView {
            let container = UIView()

            driverImage.contentMode = .scaleAspectFill
            driverImage.clipsToBounds = true
            driverImage.layer.cornerRadius = 22
            driverImage.backgroundColor = .systemGray5
            driverImage.image = UIImage(systemName: "person.crop.circle.fill")
            driverImage.tintColor = .systemGray3
            driverImage.translatesAutoresizingMaskIntoConstraints = false

            driverName.font = .hankenBold(size: 15)
            driverMeta.font = .hankenBold(size: 12); driverMeta.textColor = .systemGray
            let text = UIStackView(arrangedSubviews: [driverName, driverMeta])
            text.axis = .vertical; text.spacing = 2
            text.translatesAutoresizingMaskIntoConstraints = false

            let msgBtn = UIButton(type: .system)
            if let image = UIImage(named: "message-square") {
                msgBtn.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            msgBtn.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 250/255, alpha: 1)
            msgBtn.layer.cornerRadius = 18
            msgBtn.clipsToBounds = true
            msgBtn.translatesAutoresizingMaskIntoConstraints = false
            msgBtn.addTarget(self, action: #selector(messageDriverTapped), for: .touchUpInside)

        let callBtn = UIButton(type: .system)

        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let phoneImage = UIImage(systemName: "phone", withConfiguration: config)

        callBtn.setTitle(" Call", for: .normal)
        callBtn.setImage(phoneImage, for: .normal)
            callBtn.tintColor = .white
            callBtn.titleLabel?.font = .hankenBold(size: 12)
            callBtn.backgroundColor = UIColor(red: 8/255, green: 120/255, blue: 249/255, alpha: 1.0)
            callBtn.layer.cornerRadius = 10
            callBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 14)
            callBtn.translatesAutoresizingMaskIntoConstraints = false
            callBtn.addTarget(self, action: #selector(callDriverTapped), for: .touchUpInside)

            // ✅ Ash colored separator line added here
            let separatorLine = UIView()
            separatorLine.backgroundColor = UIColor.systemGray5 // Ash/Light Gray color
            separatorLine.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(driverImage)
            container.addSubview(text)
            container.addSubview(msgBtn)
            container.addSubview(callBtn)
            container.addSubview(separatorLine)
            
            NSLayoutConstraint.activate([
                driverImage.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                driverImage.topAnchor.constraint(equalTo: container.topAnchor),
                driverImage.widthAnchor.constraint(equalToConstant: 44),
                driverImage.heightAnchor.constraint(equalToConstant: 44),
                
                text.leadingAnchor.constraint(equalTo: driverImage.trailingAnchor, constant: 10),
                text.centerYAnchor.constraint(equalTo: driverImage.centerYAnchor),
                text.trailingAnchor.constraint(lessThanOrEqualTo: msgBtn.leadingAnchor, constant: -8),
                
                callBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                callBtn.centerYAnchor.constraint(equalTo: driverImage.centerYAnchor),
                
                msgBtn.trailingAnchor.constraint(equalTo: callBtn.leadingAnchor, constant: -10),
                msgBtn.centerYAnchor.constraint(equalTo: driverImage.centerYAnchor),
                msgBtn.widthAnchor.constraint(equalToConstant: 36),
                msgBtn.heightAnchor.constraint(equalToConstant: 36),
                
                // ✅ Positioning the separator line at the bottom
                separatorLine.topAnchor.constraint(equalTo: driverImage.bottomAnchor, constant: 16),
                separatorLine.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                separatorLine.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                separatorLine.heightAnchor.constraint(equalToConstant: 1),
                separatorLine.bottomAnchor.constraint(equalTo: container.bottomAnchor) // Seals the container height
            ])
            
            return container
        }

        // ✅ Updated to accept `UIImage?` so it works with custom assets
        private func statColumn(iconImage: UIImage?, value: UILabel, sub: UILabel) -> UIView {
            // .alwaysTemplate allows the icon to take on the `appBlue` tint color like Figma
            let iv = UIImageView(image: iconImage?.withRenderingMode(.alwaysTemplate))
            iv.tintColor = appBlue
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                   iv.widthAnchor.constraint(equalToConstant: 24),
                   iv.heightAnchor.constraint(equalToConstant: 24)
               ])
            
            value.font = .hankenBold(size: 11); value.textAlignment = .center
            value.adjustsFontSizeToFitWidth = true; value.minimumScaleFactor = 0.7
            sub.font = .hankenBold(size: 10); sub.textColor = .systemGray; sub.textAlignment = .center
            sub.adjustsFontSizeToFitWidth = true; sub.minimumScaleFactor = 0.7
            
            let col = UIStackView(arrangedSubviews: [iv, value, sub])
            col.axis = .vertical; col.spacing = 4; col.alignment = .center
            return col
        }

        // ✅ Updated to pass the custom "busicon 1" asset
    private func buildStatsRow() -> UIView {
        // Asset bus icon fallback to SF Symbol
        let busIcon = UIImage(named: "busicon 1") ?? UIImage(systemName: "bus.fill")
        
        // ✅ Asset image use UIImage(named:)
        let capacityIcon = UIImage(named: "person 1") ?? UIImage(systemName: "person.fill")
        
        let row = UIStackView(arrangedSubviews: [
            statColumn(iconImage: busIcon, value: statBusValue, sub: statBusSub),
            statColumn(iconImage: busIcon, value: statModelValue, sub: statModelSub),
            statColumn(iconImage: capacityIcon, value: statCapValue, sub: statCapSub)
        ])
        
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.alignment = .top
        
        return row
    }
    private func buildProgressHeader() -> UIView {
        let title = UILabel()
        title.text = "Route Progress"
        title.font = .hankenBold(size: 12)
        progressCount.font = .hankenBold(size: 10)
        progressCount.textColor = .systemGray
        progressCount.textAlignment = .right
        let row = UIStackView(arrangedSubviews: [title, progressCount])
        row.axis = .horizontal
        return row
    }

    private func populateStaticData() {
        let data = busData
        self.currentTripStatus = data?.tripStatus?.lowercased() ?? ""

        // 1. Route Name & Shift setup (Top Header)
        let routeName = data?.route?.routeName ?? data?.route?.routeCode ?? "Route"
        let shiftRaw = (data?.tripShift ?? data?.route?.shift ?? data?.tripType ?? "").capitalized
        routeSubtitleLabel.text = shiftRaw.isEmpty ? routeName : "\(routeName) · \(shiftRaw)"

        // 2. Info Card setup (Top Floating Card)
        let vehicleNumber = data?.bus?.vehicleNumber ?? "School Bus"
        cardBusNumber.text = vehicleNumber
        cardBusModel.text = data?.bus?.model ?? data?.bus?.vehicleType ?? ""
        let busImageURL = data?.bus?.image ?? data?.bus?.busImage ?? data?.bus?.vehicleImage ?? data?.bus?.vehiclePhoto ?? data?.bus?.busPhoto ?? data?.bus?.photo
        if let u = busImageURL, !u.isEmpty { cardBusImage.loadImage(url: u) }

        // 3. Student Details Setup (Bottom Panel)
        let sName = UserManager.shared.resolvedStudentName
        studentName.text = sName.isEmpty ? (data?.student?.name ?? "Student") : sName
        let photo = UserManager.shared.resolvedStudentPhotoURL
        if !photo.isEmpty { studentImage.loadImage(url: photo) }

        // 4. Driver Details Setup (Bottom Panel)
        driverName.text = data?.driver?.name ?? "Driver"
        if let exp = data?.driver?.experience, exp > 0 {
            driverMeta.text = "\(String(format: "%.0f", exp))+ yrs experience"
        } else {
            driverMeta.text = data?.driver?.mobile ?? "Driver"
        }
        if let u = data?.driver?.profileImage, !u.isEmpty { driverImage.loadImage(url: u) }

        // ==========================================
        // ✅ 5. BUS STATS ROW — Figma mapping only
        // ==========================================

        // Column 1: Bus Number (top) + Registration Number (bottom)
        // Figma example: "Bus 09" / "TS-08-H-9905"
        statBusValue.text = vehicleNumber
        statBusSub.text = data?.bus?.registrationNumber ?? "N/A"

        // Column 2: Model (top) + Vehicle Type (bottom)
        statModelValue.text = data?.bus?.model ?? data?.bus?.vehicleType ?? "N/A"
        statModelSub.text = data?.bus?.vehicleType?.capitalized ?? "Vehicle"

        // Column 3: Capacity
        statCapValue.text = data?.bus?.capacity.map { "\($0)" } ?? "N/A"
        statCapSub.text = "Seating Capacity"

        // ==========================================
        let sortedStops = (data?.routeStops ?? []).sorted { ($0.stopOrder ?? 0) < ($1.stopOrder ?? 0) }
        let isPickupReached = sortedStops.first(where: { $0.id == data?.pickupStop?.id })?.status?.uppercased() == "REACHED"
        if isPickupReached {
            self.isStudentBoarded = true
        }

        updateProgress(currentStopIndex: nil)
    }
    private func studentFirstName() -> String {
        let n = UserManager.shared.resolvedStudentName
        return n.components(separatedBy: " ").first ?? "Student"
    }

    private func updateProgress(currentStopIndex: Int?) {
        let data = busData
        let stops = routeStopCoordinates.count
        let isActive = ["active", "started", "live", "running", "on_route"].contains(currentTripStatus)

        let done = currentStopIndex ?? 0
        progressCount.text = stops > 0 ? "\(min(done, stops)) of \(stops) stops completed" : ""

        // 1. Detect Shift Type (MORNING vs EVENING / AFTERNOON / DROP)
        let shiftRaw = (data?.tripShift ?? data?.route?.shift ?? "").uppercased()
        let tripTypeRaw = (data?.tripType ?? "").uppercased()
        let isEveningOrDrop = shiftRaw == "EVENING" || shiftRaw == "AFTERNOON" || tripTypeRaw == "DROP"

        // 2. Configure Start (Step 1) and Drop (Step 3) titles and times based on shift
        let startTitle: String
        let startTimeRaw: String
        let dropTitle: String
        let dropTimeRaw: String
        let targetIdx: Int?

        if isEveningOrDrop {
            // Evening / Drop Shift: Route Source -> Drop Stop
            startTitle = data?.route?.source ?? data?.routeStops?.first?.stopName ?? "School"
            startTimeRaw = data?.routeStops?.first?.pickupTime ?? data?.routeStops?.first?.dropTime ?? ""
            
            dropTitle = data?.dropStop?.stopName ?? data?.route?.destination ?? "Drop Stop"
            dropTimeRaw = data?.dropStop?.dropTime ?? data?.routeStops?.last?.dropTime ?? ""
            targetIdx = dropStopIndex()
        } else {
            // Morning / Pickup Shift: Pickup Stop -> Drop Location / School
            startTitle = data?.pickupStop?.stopName ?? data?.route?.source ?? "Pickup Stop"
            startTimeRaw = data?.pickupStop?.pickupTime ?? data?.routeStops?.first?.pickupTime ?? ""
            
            dropTitle = data?.dropStop?.stopName ?? data?.route?.destination ?? "Drop Location"
            dropTimeRaw = data?.dropStop?.dropTime ?? data?.routeStops?.last?.dropTime ?? ""
            targetIdx = dropStopIndex()
        }

        // 3. Check if Drop target has been reached
        let passedTarget = isActive && targetIdx != nil && done >= targetIdx!

        // 4. Format Drop Subtitle (Live ETA when active and approaching)
        var dropSubtitle = formatTime(dropTimeRaw)
        if isActive && !passedTarget {
            if let eta = cachedETASeconds, eta > 0 {
                dropSubtitle = "≈ \(formatETAText(eta))"
            }
        }

        // 5. Build 3-Step Progress
        let steps: [RouteProgressView.Step] = [
            // Step 1: Pickup Location (e.g. DMart Madhapur - 03:55 AM)
            .init(title: startTitle,
                  subtitle: formatTime(startTimeRaw),
                  state: isActive ? .done : .pending),
            
            // Step 2: On Route (Bus)
            .init(title: "On Route",
                  subtitle: isActive ? "Current" : "",
                  state: isActive && !passedTarget ? .current : (passedTarget ? .done : .pending)),
            
            // Step 3: Drop Location (e.g. Charging Station - 04:45 AM or ≈ 2 min)
            .init(title: dropTitle,
                  subtitle: dropSubtitle,
                  state: passedTarget ? .current : .pending)
        ]
        
        progressView.configure(steps: steps)
    }
    private func dropStopIndex() -> Int? {
        if let d = busData?.dropStop, let lat = d.latitude, let lng = d.longitude, !(lat == 0 && lng == 0) {
            if let idx = routeStopCoordinates.firstIndex(where: { abs($0.latitude - lat) < 0.0001 && abs($0.longitude - lng) < 0.0001 }) {
                return idx
            }
        }
        // Fallback to last route stop index
        return routeStopCoordinates.isEmpty ? nil : routeStopCoordinates.count - 1
    }

    private func dropCoordinate() -> CLLocationCoordinate2D? {
        if let d = busData?.dropStop, let lat = d.latitude, let lng = d.longitude, !(lat == 0 && lng == 0) {
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        return routeStopCoordinates.last
    }

    private func pickupStopIndex() -> Int? {
        guard let p = busData?.pickupStop, let lat = p.latitude, let lng = p.longitude else { return nil }
        return routeStopCoordinates.firstIndex { abs($0.latitude - lat) < 0.00001 && abs($0.longitude - lng) < 0.00001 }
    }

    private func pickupCoordinate() -> CLLocationCoordinate2D? {
        if let p = busData?.pickupStop, let lat = p.latitude, let lng = p.longitude, !(lat == 0 && lng == 0) {
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        return routeStopCoordinates.first
    }

    // MARK: - Distance & Time Formatting Helpers
    private func formatDistanceText(_ meters: CLLocationDistance) -> String {
        let kilometers = meters / 1000.0

        if kilometers < 0.01 {
            return "0 km"
        }

        if kilometers.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f km", kilometers)
        }

        return String(format: "%.1f km", kilometers)
    }

    private func formatETAText(_ seconds: TimeInterval?) -> String {
        guard let seconds = seconds, seconds > 0 else {
            return "--"
        }

        let totalMins = Int(ceil(seconds / 60.0))

        if totalMins >= 60 {
            let hrs = totalMins / 60
            let remMins = totalMins % 60
            return remMins > 0 ? "\(hrs) hr \(remMins) min" : "\(hrs) hr"
        } else {
            return "\(totalMins) min"
        }
    }
    private func calculateETASeconds(distance: CLLocationDistance, currentSpeed: Double) -> TimeInterval {
        let baseSpeedKmh: Double = 25.0
        let effectiveSpeedKmh: Double
        if currentSpeed >= 12.0 && currentSpeed <= 60.0 {
            effectiveSpeedKmh = (currentSpeed * 0.3) + (baseSpeedKmh * 0.7)
        } else {
            effectiveSpeedKmh = baseSpeedKmh
        }
        let speedMps = (effectiveSpeedKmh * 1000.0) / 3600.0
        return max(10, distance / speedMps)
    }

    private func findClosestRoutePointIndex(points: [CLLocationCoordinate2D], target: CLLocationCoordinate2D) -> Int {
        var minDistance = Double.greatestFiniteMagnitude
        var closestIdx = 0
        let targetLoc = CLLocation(latitude: target.latitude, longitude: target.longitude)
        for (i, pt) in points.enumerated() {
            let dist = targetLoc.distance(from: CLLocation(latitude: pt.latitude, longitude: pt.longitude))
            if dist < minDistance {
                minDistance = dist
                closestIdx = i
            }
        }
        return closestIdx
    }

    private func calculateRoadDistance(points: [CLLocationCoordinate2D], from busPosition: CLLocationCoordinate2D, to destPosition: CLLocationCoordinate2D) -> CLLocationDistance {
        guard points.count >= 2 else {
            return CLLocation(latitude: busPosition.latitude, longitude: busPosition.longitude)
                .distance(from: CLLocation(latitude: destPosition.latitude, longitude: destPosition.longitude))
        }
        let busIdx = findClosestRoutePointIndex(points: points, target: busPosition)
        let stopIdx = findClosestRoutePointIndex(points: points, target: destPosition)

        if points.count >= 2 && stopIdx > busIdx {
            var roadDistMeters: CLLocationDistance = 0.0
            var prev = busPosition
            for i in (busIdx + 1)...stopIdx {
                let pt = points[i]
                let d = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
                    .distance(from: CLLocation(latitude: pt.latitude, longitude: pt.longitude))
                roadDistMeters += d
                prev = pt
            }
            return roadDistMeters
        } else if stopIdx == busIdx {
            return CLLocation(latitude: busPosition.latitude, longitude: busPosition.longitude)
                .distance(from: CLLocation(latitude: destPosition.latitude, longitude: destPosition.longitude))
        } else {
            return 0.0
        }
    }

    @objc private func callDriverTapped() {
        guard let phone = busData?.driver?.mobile?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty else {
            showErrorAlert(message: "Driver phone number is not available."); return
        }
        let clean = phone.filter { "+0123456789".contains($0) }
        if let url = URL(string: "tel://\(clean)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    @objc private func messageDriverTapped() {
        guard let phone = busData?.driver?.mobile?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty else {
            showErrorAlert(message: "Driver phone number is not available."); return
        }
        let clean = phone.filter { "+0123456789".contains($0) }
        if let url = URL(string: "sms:\(clean)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - LIVE INFO
    private func updateLiveInfo(busCoord: CLLocationCoordinate2D, speed: Double, status: String) {
        currentSpeed = speed
        currentTripStatus = status
        lastUpdateDate = Date()
        infoCard.isHidden = false
        liveBadge.isHidden = false
        if status.lowercased() == "started" {
            cardStatusTag.text = "ON THE WAY"
            cardStatusTag.textColor = UIColor(red: 0.03, green: 0.53, blue: 0.98, alpha: 1.0)
        } else {
            cardStatusTag.text = status
                .replacingOccurrences(of: "_", with: " ")
                .uppercased()
        }

        let busLoc = CLLocation(latitude: busCoord.latitude, longitude: busCoord.longitude)
        let sortedStops = (busData?.routeStops ?? []).sorted { ($0.stopOrder ?? 0) < ($1.stopOrder ?? 0) }

        // Find school stop
        let schoolStop = sortedStops.last(where: {
            ($0.stopType?.uppercased() == "SCHOOL") || ($0.stopName?.localizedCaseInsensitiveContains("School") == true)
        }) ?? sortedStops.last

        let shiftRaw = (busData?.tripShift ?? busData?.route?.shift ?? "").uppercased()
        let tripTypeRaw = (busData?.tripType ?? "").uppercased()
        let isEveningOrDropTrip = shiftRaw == "EVENING" || shiftRaw == "AFTERNOON" || tripTypeRaw == "DROP"
        let isTripActive = ["active", "started", "live", "running", "on_route"].contains(currentTripStatus)

        // Target student stop
        let targetStudentStop = isEveningOrDropTrip ? busData?.dropStop : busData?.pickupStop

        // Next upcoming stop (first unpassed stop)
        let nextUpcomingStop: RouteStop?
        if !isTripActive {
            nextUpcomingStop = sortedStops.first
        } else {
            nextUpcomingStop = sortedStops.first(where: { ($0.status ?? "").uppercased() != "REACHED" }) ?? sortedStops.last
        }

        // Student boarded check for morning trip
        if !isEveningOrDropTrip {
            let isPickupMarkedReached = sortedStops.first(where: { $0.id == targetStudentStop?.id })?.status?.uppercased() == "REACHED"
            if isPickupMarkedReached {
                isStudentBoarded = true
            } else if let pId = targetStudentStop?.id,
                      let pIdx = sortedStops.firstIndex(where: { $0.id == pId }),
                      let nextId = nextUpcomingStop?.id,
                      let nextIdx = sortedStops.firstIndex(where: { $0.id == nextId }),
                      nextIdx > pIdx {
                isStudentBoarded = true
            } else if let sLat = targetStudentStop?.latitude, let sLng = targetStudentStop?.longitude, !(sLat == 0 && sLng == 0) {
                let distToPickup = busLoc.distance(from: CLLocation(latitude: sLat, longitude: sLng))
                if distToPickup < 70 {
                    isStudentBoarded = true
                }
            }
        }

        // Student Target coordinate: In morning: pickup stop before boarding; School stop after boarding
        let studentTargetLat = (isStudentBoarded && !isEveningOrDropTrip) ? (schoolStop?.latitude ?? busData?.dropStop?.latitude) : targetStudentStop?.latitude
        let studentTargetLng = (isStudentBoarded && !isEveningOrDropTrip) ? (schoolStop?.longitude ?? busData?.dropStop?.longitude) : targetStudentStop?.longitude

        let destCoord: CLLocationCoordinate2D
        if let sLat = studentTargetLat, let sLng = studentTargetLng, !(sLat == 0 && sLng == 0) {
            destCoord = CLLocationCoordinate2D(latitude: sLat, longitude: sLng)
        } else {
            destCoord = routeStopCoordinates.last ?? busCoord
        }

        // Update progress count & next stop title
        let nextStopIndex = nextUpcomingStop != nil ? (sortedStops.firstIndex(where: { $0.id == nextUpcomingStop?.id }) ?? 0) : 0
        cardNextStopName.text = nextUpcomingStop?.stopName ?? "--"
        updateProgress(currentStopIndex: nextStopIndex)

        // 1. Calculate for NEXT UPCOMING STOP (For Top InfoCard)
        var nextStopCoord: CLLocationCoordinate2D?
        if let nLat = nextUpcomingStop?.latitude, let nLng = nextUpcomingStop?.longitude, !(nLat == 0 && nLng == 0) {
            nextStopCoord = CLLocationCoordinate2D(latitude: nLat, longitude: nLng)
        } else if !routeStopCoordinates.isEmpty {
            nextStopCoord = routeStopCoordinates[min(nextStopIndex, routeStopCoordinates.count - 1)]
        }

        let nextStopDist: CLLocationDistance
        if let nCoord = nextStopCoord {
            if fullRouteCoordinates.count >= 2 {
                nextStopDist = calculateRoadDistance(points: fullRouteCoordinates, from: busCoord, to: nCoord)
            } else {
                nextStopDist = busLoc.distance(from: CLLocation(latitude: nCoord.latitude, longitude: nCoord.longitude)) * 1.35
            }
        } else {
            nextStopDist = 0
        }
        let nextStopETA = calculateETASeconds(distance: nextStopDist, currentSpeed: speed)

        // 2. Calculate for STUDENT TARGET STOP (For Student Card)
        let straightDistance = busLoc.distance(from: CLLocation(latitude: destCoord.latitude, longitude: destCoord.longitude))
        let studentDist: CLLocationDistance
        if fullRouteCoordinates.count >= 2 {
            studentDist = calculateRoadDistance(points: fullRouteCoordinates, from: busCoord, to: destCoord)
        } else {
            studentDist = straightDistance * 1.35
        }
        let studentETA = calculateETASeconds(distance: studentDist, currentSpeed: speed)

        self.cachedDistanceMeters = studentDist
        self.cachedETASeconds = studentETA

        if fullRouteCoordinates.count >= 2 {
            renderETA(nextStopDist: nextStopDist, nextStopETA: nextStopETA, studentDist: studentDist, studentETA: studentETA, isEveningOrDropTrip: isEveningOrDropTrip)
            return
        }

        var needRoute = etaLastRoutedCoord == nil
        if let last = etaLastRoutedCoord {
            let moved = busLoc.distance(from: CLLocation(latitude: last.latitude, longitude: last.longitude))
            needRoute = moved > 150
        }

        if needRoute && !etaIsRouting && straightDistance > 50 {
            etaIsRouting = true
            etaLastRoutedCoord = busCoord

            let req = MKDirections.Request()
            req.source = MKMapItem(placemark: MKPlacemark(coordinate: busCoord))
            req.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoord))
            req.transportType = .automobile

            MKDirections(request: req).calculate { [weak self] resp, _ in
                guard let self = self else { return }
                self.etaIsRouting = false
                if let r = resp?.routes.first {
                    self.cachedDistanceMeters = r.distance
                    self.cachedETASeconds = r.expectedTravelTime
                } else {
                    let roadEst = straightDistance * 1.35
                    self.cachedDistanceMeters = roadEst
                    self.cachedETASeconds = self.calculateETASeconds(distance: roadEst, currentSpeed: self.currentSpeed)
                }
                DispatchQueue.main.async {
                    self.renderETA(nextStopDist: nextStopDist, nextStopETA: nextStopETA, studentDist: self.cachedDistanceMeters, studentETA: self.cachedETASeconds, isEveningOrDropTrip: isEveningOrDropTrip)
                }
            }
        } else {
            renderETA(nextStopDist: nextStopDist, nextStopETA: nextStopETA, studentDist: studentDist, studentETA: studentETA, isEveningOrDropTrip: isEveningOrDropTrip)
        }
    }

    private func renderETA(nextStopDist: CLLocationDistance? = nil,
                           nextStopETA: TimeInterval? = nil,
                           studentDist: CLLocationDistance? = nil,
                           studentETA: TimeInterval? = nil,
                           isEveningOrDropTrip: Bool = false) {

        let nDist = nextStopDist ?? 0
        let nEta = nextStopETA
        let nDistText = formatDistanceText(nDist)
        let nTimeText = formatETAText(nEta)

        let sDist = studentDist ?? cachedDistanceMeters ?? 0
        let sEta = studentETA ?? cachedETASeconds
        let sDistText = formatDistanceText(sDist)
        let sTimeText = formatETAText(sEta)

        let sFirstName = studentFirstName()

        // your existing remaining code...
    
        
        // ✅ Dynamically get destination name (Morning -> "Charging Station", Evening -> "DMart Madhapur")
        let destinationName = getDestinationName(isEvening: isEveningOrDropTrip)

        // 1. TOP INFO CARD: Always shows Next Stop Distance and Time
        if nDist < 10 && nDist > 0 {
            cardETA.text = "Arrived"
            cardDistance.text = "At Stop"
        } else {
            cardETA.text = nTimeText
            cardDistance.text = "\(nDistText) away"
        }

        // 2. STUDENT CARD: Shows Boarded Status & Dynamic Destination
        if isEveningOrDropTrip {
            // 🌆 EVENING TRIP
            if isStudentBoarded {
                if sDist < 60 && sDist > 0 {
                    studentStatus.text = "\(sFirstName) • Reached \(destinationName)"
                    studentExpected.text = "Trip Completed"
                } else {
                    studentStatus.text = "\(sFirstName) Boarded • Heading to \(destinationName)"
                    studentExpected.text = "Expected in \(sTimeText) • \(sDistText) away"
                }
            } else {
                if sDist < 60 && sDist > 0 {
                    studentStatus.text = "\(sFirstName) • Reached Stop"
                    studentExpected.text = "Reached Stop"
                } else {
                    studentStatus.text = "Bus approaching your stop"
                    studentExpected.text = "Expected in \(sTimeText) • \(sDistText) away"
                }
            }
        } else {
           
            if isStudentBoarded {
                if sDist < 60 && sDist > 0 {
                    studentStatus.text = "\(sFirstName) • Reached \(destinationName)"
                    studentExpected.text = "Trip Completed"
                } else {
                    // ✅ Shows: "Kabir Boarded • Heading to Charging Station"
                    studentStatus.text = "\(sFirstName) Boarded • Heading to \(destinationName)"
                    studentExpected.text = "Expected in \(sTimeText) • \(sDistText) away"
                }
            } else {
                if sDist < 60 && sDist > 0 {
                    studentStatus.text = "Bus reached your stop"
                    studentExpected.text = "\(sFirstName) Boarding • Heading to \(destinationName)"
                } else {
                    studentStatus.text = "Bus approaching your stop"
                    studentExpected.text = "Expected in \(sTimeText) • \(sDistText) away"
                }
            }
        }
    }
    private func getDestinationName(isEvening: Bool) -> String {
        // ⚠️ Replace 'busData' with your actual property name (e.g. studentBusData, transportData, etc.)
        guard let data = busData else { return isEvening ? "Home" : "School" }
        
        if isEvening {
            // Evening trip → Destination is the drop/home stop (e.g. "DMart Madhapur")
            return data.dropStop?.stopName
                ?? data.pickupStop?.stopName
                ?? "Home"
        } else {
            // Morning trip → Destination is School / Charging Station
            let schoolStop = data.routeStops?.first(where: { $0.stopType?.uppercased() == "SCHOOL" })
            return data.dropStop?.stopName
                ?? schoolStop?.stopName
                ?? data.route?.destination
                ?? "School"
        }
    }
    private func startUITimer() {
        uiTimer?.invalidate()
        uiTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let d = self.lastUpdateDate else { return }
            let s = Int(Date().timeIntervalSince(d))
            self.cardUpdated.text = s < 3 ? "Updated just now" : (s < 60 ? "Updated \(s) sec ago" : "Updated \(s / 60) min ago")
        }
    }
    private func setScreenMode(isActive: Bool) {
        Mapview.isHidden = !isActive
        panel.isHidden = !isActive
        Topview.isHidden = !isActive
        mapControlsContainer.isHidden = !isActive

        if !isActive {
            infoCard.isHidden = true
            liveBadge.isHidden = true
            self.view.backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1)
        } else {
            self.view.backgroundColor = .white
        }
    }
    
    private func setupTripCompletedOverlay() {
        
        tripCompletedOverlay = UIView()
                
                tripCompletedOverlay.backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1)
                tripCompletedOverlay.translatesAutoresizingMaskIntoConstraints = false
                
        tripCompletedOverlay = UIView()
        tripCompletedOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        tripCompletedOverlay.translatesAutoresizingMaskIntoConstraints = false
        tripCompletedOverlay.isHidden = true
        tripCompletedOverlay.alpha = 0
        view.addSubview(tripCompletedOverlay)

        // White card
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowRadius = 20
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.translatesAutoresizingMaskIntoConstraints = false
        tripCompletedOverlay.addSubview(card)

        // Green check circle
        let checkCircle = UIView()
        checkCircle.backgroundColor = UIColor(red: 220/255, green: 245/255, blue: 230/255, alpha: 1)
        checkCircle.layer.cornerRadius = 36
        checkCircle.translatesAutoresizingMaskIntoConstraints = false

        let checkIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkIcon.tintColor = UIColor(red: 34/255, green: 170/255, blue: 100/255, alpha: 1)
        checkIcon.contentMode = .scaleAspectFit
        checkIcon.translatesAutoresizingMaskIntoConstraints = false
        checkCircle.addSubview(checkIcon)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Trip Completed"
        titleLabel.font = .hankenBold(size: 22)
        titleLabel.textColor = UIColor(red: 20/255, green: 30/255, blue: 50/255, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "The bus has successfully completed its journey."
        subtitleLabel.font = .hankenRegular(size: 14)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // COMPLETED badge
        let badge = UIView()
        badge.backgroundColor = UIColor(red: 220/255, green: 245/255, blue: 230/255, alpha: 1)
        badge.layer.cornerRadius = 14
        badge.translatesAutoresizingMaskIntoConstraints = false

        let badgeDot = UIView()
        badgeDot.backgroundColor = UIColor(red: 34/255, green: 170/255, blue: 100/255, alpha: 1)
        badgeDot.layer.cornerRadius = 4
        badgeDot.translatesAutoresizingMaskIntoConstraints = false

        let badgeText = UILabel()
        badgeText.text = "COMPLETED"
        badgeText.font = .hankenBold(size: 12)
        badgeText.textColor = UIColor(red: 22/255, green: 140/255, blue: 70/255, alpha: 1)
        badgeText.translatesAutoresizingMaskIntoConstraints = false

        badge.addSubview(badgeDot)
        badge.addSubview(badgeText)

        // Detail rows helper
        func makeRow(title: String, valueLabel: UILabel) -> UIView {
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false

            let t = UILabel()
            t.text = title
            t.font = .hankenMedium(size: 14)
            t.textColor = .darkGray
            t.translatesAutoresizingMaskIntoConstraints = false

            valueLabel.font = .hankenBold(size: 14)
            valueLabel.textColor = UIColor(red: 20/255, green: 30/255, blue: 50/255, alpha: 1)
            valueLabel.textAlignment = .right
            valueLabel.translatesAutoresizingMaskIntoConstraints = false

            let line = UIView()
            line.backgroundColor = UIColor.systemGray5
            line.translatesAutoresizingMaskIntoConstraints = false

            row.addSubview(t)
            row.addSubview(valueLabel)
            row.addSubview(line)

            NSLayoutConstraint.activate([
                t.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                t.centerYAnchor.constraint(equalTo: row.centerYAnchor),

                valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: t.trailingAnchor, constant: 12),

                line.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                line.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                line.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                line.heightAnchor.constraint(equalToConstant: 1),

                row.heightAnchor.constraint(equalToConstant: 44)
            ])
            return row
        }

        completedStartTimeLabel.text = "--"
        completedEndTimeLabel.text = "--"
        completedBusNumberLabel.text = "--"
        completedRouteNumberLabel.text = "--"

        let row1 = makeRow(title: "Start time", valueLabel: completedStartTimeLabel)
        let row2 = makeRow(title: "Completion time", valueLabel: completedEndTimeLabel)
        let row3 = makeRow(title: "Bus number", valueLabel: completedBusNumberLabel)
        let row4 = makeRow(title: "Route number", valueLabel: completedRouteNumberLabel)
        // Hide last divider
        row4.subviews.last?.isHidden = true

        let detailsStack = UIStackView(arrangedSubviews: [row1, row2, row3, row4])
        detailsStack.axis = .vertical
        detailsStack.spacing = 0
        detailsStack.translatesAutoresizingMaskIntoConstraints = false

        // Done / Go Back button
        let doneBtn = UIButton(type: .system)
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.titleLabel?.font = .hankenBold(size: 16)
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.backgroundColor = appBlue
        doneBtn.layer.cornerRadius = 12
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        doneBtn.addTarget(self, action: #selector(BackButtonTapped(_:)), for: .touchUpInside)

        card.addSubview(checkCircle)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(badge)
        card.addSubview(detailsStack)
        card.addSubview(doneBtn)

        NSLayoutConstraint.activate([
            tripCompletedOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            tripCompletedOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tripCompletedOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tripCompletedOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            card.centerXAnchor.constraint(equalTo: tripCompletedOverlay.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: tripCompletedOverlay.centerYAnchor),
            card.widthAnchor.constraint(equalTo: tripCompletedOverlay.widthAnchor, constant: -48),

            checkCircle.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            checkCircle.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            checkCircle.widthAnchor.constraint(equalToConstant: 72),
            checkCircle.heightAnchor.constraint(equalToConstant: 72),

            checkIcon.centerXAnchor.constraint(equalTo: checkCircle.centerXAnchor),
            checkIcon.centerYAnchor.constraint(equalTo: checkCircle.centerYAnchor),
            checkIcon.widthAnchor.constraint(equalToConstant: 40),
            checkIcon.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: checkCircle.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            badge.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            badge.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            badge.heightAnchor.constraint(equalToConstant: 28),

            badgeDot.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 12),
            badgeDot.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            badgeDot.widthAnchor.constraint(equalToConstant: 8),
            badgeDot.heightAnchor.constraint(equalToConstant: 8),

            badgeText.leadingAnchor.constraint(equalTo: badgeDot.trailingAnchor, constant: 6),
            badgeText.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -12),
            badgeText.centerYAnchor.constraint(equalTo: badge.centerYAnchor),

            detailsStack.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 20),
            detailsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            detailsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            doneBtn.topAnchor.constraint(equalTo: detailsStack.bottomAnchor, constant: 24),
            doneBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            doneBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            doneBtn.heightAnchor.constraint(equalToConstant: 48),
            doneBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
    }

    private func showTripCompletedPopup() {
            populateCompletedPopupData()
            hideNotStartedPopup()
            
            
            setScreenMode(isActive: false)
            
            stopLiveLocationTracking()
            stopSmoothAnimation()

            guard tripCompletedOverlay.isHidden else { return }
            tripCompletedOverlay.isHidden = false
            view.bringSubviewToFront(tripCompletedOverlay)
            UIView.animate(withDuration: 0.3) {
                self.tripCompletedOverlay.alpha = 1
            }
        }
    private func hideTripCompletedPopup() {
        guard !tripCompletedOverlay.isHidden else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.tripCompletedOverlay.alpha = 0
        }) { _ in
            self.tripCompletedOverlay.isHidden = true
        }
    }

    private func populateCompletedPopupData() {
        let data = busData

        // ✅ Start time
        let startRaw = data?.routeStops?.first?.pickupTime
            ?? data?.pickupStop?.pickupTime
            ?? ""
        let startFormatted = formatTime(startRaw)
        completedStartTimeLabel.text = startFormatted.isEmpty ? "--" : startFormatted

        // ✅ Completion time (Last REACHED stop -> Last Route Stop -> Current Time fallback)
        let reachedStop = data?.routeStops?
            .filter { ($0.status ?? "").uppercased() == "REACHED" }
            .last

        let endRaw = reachedStop?.reachedTime
            ?? data?.routeStops?.last?.reachedTime
            ?? data?.routeStops?.last?.dropTime
            ?? data?.dropStop?.dropTime
            ?? ""

        var endFormatted = formatTime(endRaw)
        
        
        if endFormatted.isEmpty || endFormatted.contains("-") || endFormatted.contains("T") {
            let df = DateFormatter()
            df.dateFormat = "h:mm a"
            df.locale = Locale(identifier: "en_US_POSIX")
            endFormatted = df.string(from: Date())
        }

        completedEndTimeLabel.text = endFormatted

        // ✅ Bus number
        completedBusNumberLabel.text = data?.bus?.vehicleNumber ?? "School Bus"

        // ✅ Route number
        completedRouteNumberLabel.text = data?.route?.routeCode
            ?? data?.route?.routeName
            ?? "--"
    }

    // MARK: - Not Started Popup
    private func setupNotStartedOverlay() {
        
        notStartedOverlay = UIView()
                
                notStartedOverlay.backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1)
                notStartedOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        
        notStartedOverlay = UIView()
        notStartedOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        notStartedOverlay.translatesAutoresizingMaskIntoConstraints = false
        notStartedOverlay.isHidden = true
        notStartedOverlay.alpha = 0
        view.addSubview(notStartedOverlay)

        // Tap outside → go back
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(notStartedOverlayTapped))
        notStartedOverlay.addGestureRecognizer(bgTap)

        // White card
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 20
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        notStartedOverlay.addSubview(cardView)

        // Prevent card tap from dismissing
        cardView.isUserInteractionEnabled = true
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))

        // Bus icon circle (Figma — soft yellow)
        let iconCircle = UIView()
        iconCircle.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 230/255, alpha: 1)
        iconCircle.layer.cornerRadius = 40
        iconCircle.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView()
        // Prefer asset if you have one, else SF Symbol bus
        iconView.image = UIImage(named: "bus_not_started")
            ?? UIImage(named: "Bus icon 1")
            ?? UIImage(systemName: "bus.fill")
        iconView.tintColor = UIColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 1)
        iconView.contentMode = .scaleAspectFill
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconView)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Trip Not Started"
        titleLabel.font = .hankenBold(size: 22)
        titleLabel.textColor = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Subtitle
        let messageLabel = UILabel()
        messageLabel.text = "The bus hasn't started its journey yet. Live tracking will be available once the driver starts the trip."
        messageLabel.font = .hankenRegular(size: 14)
        messageLabel.textColor = .systemGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        // "Waiting for Trip" badge (Figma pill)
        let badge = UIView()
        badge.backgroundColor = UIColor(red: 255/255, green: 243/255, blue: 224/255, alpha: 1)
        badge.layer.cornerRadius = 14
        badge.translatesAutoresizingMaskIntoConstraints = false

        let badgeDot = UIView()
        badgeDot.backgroundColor = UIColor(red: 217/255, green: 119/255, blue: 6/255, alpha: 1)
        badgeDot.layer.cornerRadius = 4
        badgeDot.translatesAutoresizingMaskIntoConstraints = false

        let badgeText = UILabel()
        badgeText.text = "Waiting for Trip"
        badgeText.font = .hankenBold(size: 12)
        badgeText.textColor = UIColor(red: 180/255, green: 83/255, blue: 9/255, alpha: 1)
        badgeText.translatesAutoresizingMaskIntoConstraints = false

        badge.addSubview(badgeDot)
        badge.addSubview(badgeText)

        // Detail row helper
        func makeRow(title: String, valueLabel: UILabel, showDivider: Bool) -> UIView {
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false

            let t = UILabel()
            t.text = title
            t.font = .hankenMedium(size: 14)
            t.textColor = UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1)
            t.translatesAutoresizingMaskIntoConstraints = false

            valueLabel.font = .hankenBold(size: 14)
            valueLabel.textColor = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1)
            valueLabel.textAlignment = .right
            valueLabel.text = "--"
            valueLabel.translatesAutoresizingMaskIntoConstraints = false

            row.addSubview(t)
            row.addSubview(valueLabel)

            NSLayoutConstraint.activate([
                t.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                t.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: t.trailingAnchor, constant: 12),
                row.heightAnchor.constraint(equalToConstant: 48)
            ])

            if showDivider {
                let line = UIView()
                line.backgroundColor = UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1)
                line.translatesAutoresizingMaskIntoConstraints = false
                row.addSubview(line)
                NSLayoutConstraint.activate([
                    line.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                    line.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                    line.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                    line.heightAnchor.constraint(equalToConstant: 1)
                ])
            }
            return row
        }

        let row1 = makeRow(title: "Scheduled pickup", valueLabel: notStartedPickupLabel,      showDivider: true)
        let row2 = makeRow(title: "Bus number",       valueLabel: notStartedBusNumberLabel,   showDivider: true)
        let row3 = makeRow(title: "Route number",     valueLabel: notStartedRouteNumberLabel, showDivider: false)

        let detailsStack = UIStackView(arrangedSubviews: [row1, row2, row3])
        detailsStack.axis = .vertical
        detailsStack.spacing = 0
        detailsStack.translatesAutoresizingMaskIntoConstraints = false

        // Go Back button (keep functionality)
        let backBtn = UIButton(type: .system)
        backBtn.setTitle("Go Back", for: .normal)
        backBtn.titleLabel?.font = .hankenBold(size: 16)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.backgroundColor = appBlue
        backBtn.layer.cornerRadius = 12
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.addTarget(self, action: #selector(BackButtonTapped(_:)), for: .touchUpInside)

        cardView.addSubview(iconCircle)
        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(badge)
        cardView.addSubview(detailsStack)
        cardView.addSubview(backBtn)

        NSLayoutConstraint.activate([
            notStartedOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            notStartedOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            notStartedOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notStartedOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: notStartedOverlay.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: notStartedOverlay.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: notStartedOverlay.widthAnchor, constant: -48),

            iconCircle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
            iconCircle.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 80),
            iconCircle.heightAnchor.constraint(equalToConstant: 80),

            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            badge.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            badge.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            badge.heightAnchor.constraint(equalToConstant: 28),

            badgeDot.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 12),
            badgeDot.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            badgeDot.widthAnchor.constraint(equalToConstant: 8),
            badgeDot.heightAnchor.constraint(equalToConstant: 8),

            badgeText.leadingAnchor.constraint(equalTo: badgeDot.trailingAnchor, constant: 6),
            badgeText.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -12),
            badgeText.centerYAnchor.constraint(equalTo: badge.centerYAnchor),

            detailsStack.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 20),
            detailsStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            detailsStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            backBtn.topAnchor.constraint(equalTo: detailsStack.bottomAnchor, constant: 20),
            backBtn.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            backBtn.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            backBtn.heightAnchor.constraint(equalToConstant: 48),
            backBtn.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24)
        ])
    }

    @objc private func notStartedOverlayTapped() {
        BackButtonTapped(BackButton)
    }

    private func showNotStartedPopup() {
           populateNotStartedPopupData()
           hideTripCompletedPopup()
           
           
           setScreenMode(isActive: false)

           guard notStartedOverlay.isHidden else { return }
           notStartedOverlay.isHidden = false
           view.bringSubviewToFront(notStartedOverlay)
           UIView.animate(withDuration: 0.3) {
               self.notStartedOverlay.alpha = 1
           }
       }
    private func populateNotStartedPopupData() {
        let data = busData

        
        let isDropTrip = (data?.tripType?.lowercased() == "drop")
        
        let rawPickupTime: String
        if isDropTrip {
            
            rawPickupTime = data?.dropStop?.dropTime
                ?? data?.pickupStop?.dropTime
                ?? data?.routeStops?.last?.dropTime
                ?? ""
        } else {
           
            rawPickupTime = data?.pickupStop?.pickupTime
                ?? data?.routeStops?.first?.pickupTime
                ?? ""
        }

        let pickupFormatted = formatTime(rawPickupTime)
        notStartedPickupLabel.text = pickupFormatted.isEmpty ? "--" : pickupFormatted

       
        notStartedBusNumberLabel.text = data?.bus?.vehicleNumber ?? "School Bus"

      
        notStartedRouteNumberLabel.text = data?.route?.routeCode
            ?? data?.route?.routeName
            ?? "--"
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

    // MARK: - ROUTE DRAWING
    private func setupRouteOnMap() {
        guard let data = busData else { return }

        // Cancel any in-flight route build
        routeBuildToken += 1
        let token = routeBuildToken

        let oldStops = Mapview.annotations.filter { $0 is StopAnnotation }
        Mapview.removeAnnotations(oldStops)

        clearAllRouteOverlays()

        fullRouteCoordinates.removeAll()
        routeStopCoordinates.removeAll()
        routeStopNames.removeAll()
        isRouteDrawn = false
        lastTrimSegmentIndex = -1
        isStudentBoarded = false

        var stops: [(coord: CLLocationCoordinate2D, name: String, time: String?,
                     kind: StopAnnotation.Kind, id: String?, reached: Bool)] = []

        let shiftRaw = (data.tripShift ?? data.route?.shift ?? "").uppercased()
        let tripTypeRaw = (data.tripType ?? "").uppercased()
        let isEveningOrDrop = shiftRaw == "EVENING" || shiftRaw == "AFTERNOON" || tripTypeRaw == "DROP"

        let pickupID = data.pickupStop?.id
        let dropID   = data.dropStop?.id

        if let routeStops = data.routeStops, !routeStops.isEmpty {
            let ordered = routeStops.sorted { ($0.stopOrder ?? 0) < ($1.stopOrder ?? 0) }
            for s in ordered {
                guard let lat = s.latitude, let lng = s.longitude else { continue }
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                guard CLLocationCoordinate2DIsValid(coord), !(lat == 0 && lng == 0) else { continue }

                // Skip exact duplicate consecutive coordinates (causes shortcut lines)
                if let lastCoord = stops.last?.coord,
                   abs(lastCoord.latitude - lat) < 0.000001,
                   abs(lastCoord.longitude - lng) < 0.000001 { continue }

                var kind: StopAnnotation.Kind = .normal
                let isSchool = (s.stopType?.uppercased() == "SCHOOL") || (s.stopName?.localizedCaseInsensitiveContains("School") == true)
                let isPickup = (pickupID != nil && pickupID == s.id)
                let isDrop = (dropID != nil && dropID == s.id)

                if isEveningOrDrop {
                    if isDrop {
                        kind = .student
                    } else if isPickup || isSchool {
                        kind = .school
                    }
                } else {
                    if isPickup {
                        kind = .student
                    } else if isDrop || isSchool {
                        kind = .school
                    }
                }

                var stopTitle = s.stopName ?? "Stop"
                if kind == .student {
                    let sFirstName = studentFirstName()
                    stopTitle = "\(sFirstName)'s Stop"
                }

                stops.append((
                    coord,
                    stopTitle,
                    s.pickupTime ?? s.dropTime,
                    kind,
                    s.id,
                    (s.status ?? "").uppercased() == "REACHED"
                ))
            }
        }

        if stops.count < 2 {
            stops.removeAll()
            let sFirstName = studentFirstName()
            if let p = data.pickupStop, let lat = p.latitude, let lng = p.longitude,
               !(lat == 0 && lng == 0) {
                let kind: StopAnnotation.Kind = isEveningOrDrop ? .school : .student
                let title = isEveningOrDrop ? (p.stopName ?? "School") : "\(sFirstName)'s Stop"
                stops.append((
                    CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    title, p.pickupTime, kind, p.id, false
                ))
            }
            if let d = data.dropStop, let lat = d.latitude, let lng = d.longitude,
               !(lat == 0 && lng == 0) {
                let kind: StopAnnotation.Kind = isEveningOrDrop ? .student : .school
                let title = isEveningOrDrop ? "\(sFirstName)'s Stop" : (d.stopName ?? "School")
                stops.append((
                    CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    title, d.dropTime, kind, d.id, false
                ))
            }
        }

        guard !stops.isEmpty else { return }

        if isEveningOrDrop {
            if !stops.contains(where: { $0.kind == .school }) { stops[0].kind = .school }
            if stops.count > 1, !stops.contains(where: { $0.kind == .student }) { stops[stops.count - 1].kind = .student }
        } else {
            if !stops.contains(where: { $0.kind == .student }) { stops[0].kind = .student }
            if stops.count > 1, !stops.contains(where: { $0.kind == .school }) { stops[stops.count - 1].kind = .school }
        }

        routeStopCoordinates = stops.map { $0.coord }
        routeStopNames = stops.map { $0.name }

        let annotations: [StopAnnotation] = stops.map { stop in
            StopAnnotation(coordinate: stop.coord,
                           title: stop.name,
                           subtitle: stop.time.map { formatTime($0) },
                           kind: stop.kind,
                           stopId: stop.id,
                           isReached: stop.reached)
        }
        Mapview.addAnnotations(annotations)

        fitMapToRoute(includeBus: false)

        guard routeStopCoordinates.count >= 2 else {
            isRouteDrawn = true
            return
        }

        // Build FULL route silently (no partial overlays → no duplicate / shortcut lines)
        buildFullRoute(segmentIndex: 0, accumulator: [], token: token)
    }

    /// Collect road coordinates segment-by-segment. Nothing is drawn until the
    /// whole route is ready → prevents duplicate / shortcut polylines.
    private func buildFullRoute(segmentIndex: Int,
                                accumulator: [CLLocationCoordinate2D],
                                token: Int) {

        guard token == routeBuildToken else { return }
        
        guard segmentIndex < routeStopCoordinates.count - 1 else {
            
            var uniqueCoords: [CLLocationCoordinate2D] = []
            for coord in accumulator {
                if let last = uniqueCoords.last {
                    let dist = CLLocation(latitude: last.latitude, longitude: last.longitude)
                        .distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
                    if dist > 2.0 {
                        uniqueCoords.append(coord)
                    }
                } else {
                    uniqueCoords.append(coord)
                }
            }
            
            self.fullRouteCoordinates = uniqueCoords
            self.isRouteDrawn = true
            self.drawInitialFullRoute()
            if let lastCoord = self.lastRawCoordinate {
                self.updateLiveInfo(busCoord: lastCoord, speed: self.currentSpeed, status: self.currentTripStatus)
            }
            return
        }

        let from = routeStopCoordinates[segmentIndex]
        let to   = routeStopCoordinates[segmentIndex + 1]

        let request = MKDirections.Request()
        request.source        = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination   = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self = self else { return }
            guard token == self.routeBuildToken else { return }

            var segmentCoords: [CLLocationCoordinate2D] = []

            if let route = response?.routes.first, error == nil {
                let polyline = route.polyline
                let count = polyline.pointCount
                var buffer = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: count)
                polyline.getCoordinates(&buffer, range: NSRange(location: 0, length: count))
                segmentCoords = buffer.filter { CLLocationCoordinate2DIsValid($0) }
            } else {
                segmentCoords = [from, to]
            }

            DispatchQueue.main.async {
                guard token == self.routeBuildToken else { return }

                var newAccumulator = accumulator
                if newAccumulator.isEmpty {
                    newAccumulator.append(contentsOf: segmentCoords)
                } else {
                    if let lastAccumulated = newAccumulator.last, let firstNew = segmentCoords.first {
                        
                        let latDelta = abs(lastAccumulated.latitude - firstNew.latitude)
                        let lngDelta = abs(lastAccumulated.longitude - firstNew.longitude)

                        if latDelta < 0.00015 && lngDelta < 0.00015 {
                            newAccumulator.append(contentsOf: segmentCoords.dropFirst())
                        } else {
                            newAccumulator.append(contentsOf: segmentCoords)
                        }
                    } else {
                        newAccumulator.append(contentsOf: segmentCoords)
                    }
                }

                
                self.buildFullRoute(segmentIndex: segmentIndex + 1,
                                    accumulator: newAccumulator,
                                    token: token)
            }
        }
    }

    /// Draw the complete route (BLUE). If bus already placed → split immediately.
    private func drawInitialFullRoute() {
        guard fullRouteCoordinates.count > 1 else { return }

        clearAllRouteOverlays()

        if let bus = busAnnotation {
            let snap = snapCoordinateToRoute(bus.coordinate, route: fullRouteCoordinates)
            bus.coordinate = snap.snapped
            visualCoordinate = snap.snapped
            if let v = Mapview.view(for: bus) as? BusAnnotationView {
                v.updateRotation(degrees: snap.segmentHeading)
            }
            trimTraveledPath(segmentIndex: snap.segmentIndex,
                             currentCoord: snap.snapped,
                             force: true)
        } else {
            let polyline = MKPolyline(coordinates: fullRouteCoordinates,
                                      count: fullRouteCoordinates.count)
            remainingRouteOverlay = polyline
            Mapview.addOverlay(polyline, level: .aboveRoads)
        }

        fitMapToRoute(includeBus: busAnnotation != nil)
    }

    private func clearAllRouteOverlays() {
        
        if let old = remainingRouteOverlay {
            Mapview.removeOverlay(old)
            remainingRouteOverlay = nil
        }
        if let old = traveledRouteOverlay {
            Mapview.removeOverlay(old)
            traveledRouteOverlay = nil
        }
        
       
        let strays = Mapview.overlays.compactMap { $0 as? MKPolyline }
        if !strays.isEmpty {
            Mapview.removeOverlays(strays)
        }
    }

    private func fitMapToRoute(includeBus: Bool) {
        var rect = MKMapRect.null

        if fullRouteCoordinates.count > 1 {
            for c in fullRouteCoordinates {
                let p = MKMapPoint(c)
                rect = rect.union(MKMapRect(x: p.x, y: p.y, width: 0.1, height: 0.1))
            }
        } else {
            for c in routeStopCoordinates {
                let p = MKMapPoint(c)
                rect = rect.union(MKMapRect(x: p.x, y: p.y, width: 0.1, height: 0.1))
            }
        }

        if includeBus, let bus = busAnnotation {
            let p = MKMapPoint(bus.coordinate)
            rect = rect.union(MKMapRect(x: p.x, y: p.y, width: 0.1, height: 0.1))
        }

        guard !rect.isNull else { return }
        let bottomPad = max(panelHeight, 260) + 30
        Mapview.setVisibleMapRect(rect,
                                  edgePadding: UIEdgeInsets(top: 110, left: 50,
                                                            bottom: bottomPad, right: 50),
                                  animated: true)
        hasFittedInitialRegion = true
    }

    private func formatTime(_ raw: String) -> String {
        var value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return "" }
        
        
        if let dot = value.firstIndex(of: ".") {
            value = String(value[..<dot])
        }
        
        value = value.replacingOccurrences(of: "Z", with: "")

        let out = DateFormatter()
        out.dateFormat = "h:mm a" // Output example: 9:10 AM
        out.locale = Locale(identifier: "en_US_POSIX")

        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd HH:mm",
            "HH:mm:ss",
            "HH:mm",
            "hh:mm a",
            "h:mm a"
        ]

        for f in formats {
            let p = DateFormatter()
            p.dateFormat = f
            p.locale = Locale(identifier: "en_US_POSIX")
            if let d = p.date(from: value) {
                return out.string(from: d)
            }
        }
        return raw
    }
    private func fetchStopsDataUpdate() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID
        guard !studentId.isEmpty, !schoolId.isEmpty else { return }

        NetworkManager.shared.request(
            urlString: API.TRANSPORT_BUS,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<StudentBusData>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if case .success(let response) = result, response.success, let data = response.data {
                    // Update local bus data array with new stop statuses
                    self.busData = data
                    self.refreshStopDots()
                }
            }
        }
    }

    // MARK: - Fetch Bus Data
    private func fetchInitialBusData() {
           guard !hasFetchedBusDataOnce else { return }
           hasFetchedBusDataOnce = true

           let studentId = UserManager.shared.resolvedStudentID
           let schoolId  = UserManager.shared.resolvedSchoolID
           guard !studentId.isEmpty, !schoolId.isEmpty else { return }

           NetworkManager.shared.request(
               urlString: API.TRANSPORT_BUS,
               method: .GET,
               requiresAuth: true,
               parameters: ["student_id": studentId],
               headers: ["X-School-Id": schoolId]
           ) { [weak self] (result: Result<APIResponse<StudentBusData>, NetworkError>) in
               DispatchQueue.main.async {
                   guard let self = self else { return }

                   if case .success(let response) = result, response.success, let data = response.data {
                       self.busData = data
                       self.currentTripStatus = data.tripStatus?.lowercased() ?? ""

                       self.populateStaticData()
                       self.setupRouteOnMap()
                       self.refreshStopDots()

                       let status = self.currentTripStatus
                       let isCompleted = ["completed", "complete", "finished", "ended", "done"].contains(status)
                       let isActive = ["active", "started", "live", "running", "on_route"].contains(status)

                      
                       if isCompleted {
                           self.showTripCompletedPopup()
                       } else if isActive {
                           self.setScreenMode(isActive: true)
                           self.hideNotStartedPopup()
                           self.hideTripCompletedPopup()
                       } else {
                           self.showNotStartedPopup()
                       }
                   }
               }
           }
       }

    private func fetchLiveLocation() {
           let studentId = UserManager.shared.resolvedStudentID
           let schoolId  = UserManager.shared.resolvedSchoolID

           guard !studentId.isEmpty, !schoolId.isEmpty else { return }

           if busAnnotation == nil && notStartedOverlay.isHidden && tripCompletedOverlay.isHidden {
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
                           let isCompleted = ["completed", "complete", "finished", "ended", "done"].contains(tripStatus)
                           let isActiveResponse = ["active", "started", "live", "running", "on_route"].contains(tripStatus)

                           self.currentTripStatus = tripStatus

                           // ✅ 1. TRIP COMPLETED
                           if isCompleted {
                               self.showTripCompletedPopup()
                               return
                           }

                           // ✅ 2. TRIP NOT STARTED
                           if !isActiveResponse {
                               self.stopLiveLocationTracking()
                               self.stopSmoothAnimation()
                               self.showNotStartedPopup()
                               return
                           }

                           // ✅ 3. TRIP IS ACTIVE -> Show Map, Topview & Bottom Panel!
                           self.setScreenMode(isActive: true)
                           self.hideNotStartedPopup()
                           self.hideTripCompletedPopup()

                           if data.isAvailable == false {
                               self.showErrorAlert(message: "Bus live location is not available at this moment.")
                               return
                           }

                           guard let location = data.location,
                                 let latitude = location.latitude,
                                 let longitude = location.longitude else {
                               return
                           }

                           let rawCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                           let vehicleNumber = data.vehicle?.vehicleNumber ?? self.busData?.bus?.vehicleNumber ?? "School Bus"
                           let speed = location.speed ?? 0.0

                           // బస్ స్మూత్ మూవ్‌మెంట్ అండ్ ఎటా అప్‌డేట్ ఎప్పటిలాగే జరుగుతాయి
                           self.updateBusLocation(
                               rawCoordinate: rawCoordinate,
                               vehicleNumber: vehicleNumber,
                               tripStatus: tripStatus,
                               speed: speed
                           )
                           self.updateLiveInfo(busCoord: rawCoordinate, speed: speed, status: tripStatus)
                       }

                   case .failure(_):
                       break
                   }
               }
           }
       }
    // MARK: - SMOOTH ROAD-SNAPPING BUS MOVEMENT
    private func updateBusLocation(rawCoordinate: CLLocationCoordinate2D,
                                   vehicleNumber: String,
                                   tripStatus: String,
                                   speed: Double) {

        // FIRST TIME → place bus
        if busAnnotation == nil {
            let snap: (snapped: CLLocationCoordinate2D, segmentIndex: Int, segmentHeading: Double)

            if fullRouteCoordinates.count >= 2 {
                snap = snapCoordinateToRoute(rawCoordinate, route: fullRouteCoordinates)
            } else {
                snap = (rawCoordinate, 0, 0)
            }

            let annotation = BusAnnotation(coordinate: snap.snapped)
            annotation.title = "🚌 \(vehicleNumber)"
            annotation.subtitle = "Trip: \(tripStatus.capitalized)"

            busAnnotation = annotation
            Mapview.addAnnotation(annotation)

            lastRawCoordinate = rawCoordinate
            visualCoordinate = snap.snapped

            if !routeStopCoordinates.isEmpty {
                fitMapToRoute(includeBus: true)
            } else {
                let region = MKCoordinateRegion(center: snap.snapped,
                                                latitudinalMeters: 1000,
                                                longitudinalMeters: 1000)
                Mapview.setRegion(region, animated: true)
            }

            if let annotationView = Mapview.view(for: annotation) as? BusAnnotationView {
                annotationView.updateRotation(degrees: snap.segmentHeading)
            }

            if fullRouteCoordinates.count >= 2 {
                trimTraveledPath(segmentIndex: snap.segmentIndex,
                                 currentCoord: snap.snapped,
                                 force: true)
            }

            return
        }

        guard let annotation = busAnnotation else { return }

        annotation.title = "🚌 \(vehicleNumber)"
        annotation.subtitle = "Trip: \(tripStatus.capitalized)"

        lastRawCoordinate = rawCoordinate

        // =====================================================
        // ✅ BEST SMOOTH MODE: Animate along route distance
        // =====================================================
        if fullRouteCoordinates.count >= 2 {

            // Current visual bus position snap
            let currentCoord = visualCoordinate ?? annotation.coordinate
            let fromSnap = snapCoordinateToRoute(currentCoord, route: fullRouteCoordinates)

            // New GPS target snap
            let toSnap = snapCoordinateToRoute(rawCoordinate, route: fullRouteCoordinates)

            let fromDistance = distanceAlongRoute(
                segmentIndex: fromSnap.segmentIndex,
                coordinate: fromSnap.snapped
            )

            let toDistance = distanceAlongRoute(
                segmentIndex: toSnap.segmentIndex,
                coordinate: toSnap.snapped
            )

            let moveDistance = toDistance - fromDistance

            // ✅ Prevent backward jump due to GPS snap on nearby road/segment
            if moveDistance < -10 {
                return
            }

            // Ignore small GPS jitter
            if abs(moveDistance) < 2 {
                return
            }

            // Huge GPS jump / wrong location
            if abs(moveDistance) > 1500 {
                stopSmoothAnimation()

                annotation.coordinate = toSnap.snapped
                visualCoordinate = toSnap.snapped

                if let v = Mapview.view(for: annotation) as? BusAnnotationView {
                    v.updateRotation(degrees: toSnap.segmentHeading)
                }

                trimTraveledPath(segmentIndex: toSnap.segmentIndex,
                                 currentCoord: toSnap.snapped,
                                 force: true)

                return
            }

            let duration = animationDurationForDistance(abs(moveDistance))

            // ✅ Smoothly move bus on route line for almost full API interval
            startRouteSmoothAnimation(fromDistance: fromDistance,
                                      toDistance: toDistance,
                                      duration: duration)

            return
        }

        // =====================================================
        // Fallback if route not ready
        // =====================================================
        let fromCoord = visualCoordinate ?? annotation.coordinate
        let startLoc = CLLocation(latitude: fromCoord.latitude, longitude: fromCoord.longitude)
        let endLoc = CLLocation(latitude: rawCoordinate.latitude, longitude: rawCoordinate.longitude)
        let distance = startLoc.distance(from: endLoc)

        if distance < 2 {
            return
        }

        if distance > 1500 {
            stopSmoothAnimation()
            annotation.coordinate = rawCoordinate
            visualCoordinate = rawCoordinate
            return
        }

        let duration = animationDurationForDistance(distance)
        startSmoothAnimation(from: fromCoord, to: rawCoordinate, duration: duration)
    }
    /// Finish the move just before next GPS update → bus never looks slow/stuck
    private func animationDurationForDistance(_ meters: CLLocationDistance) -> CFTimeInterval {
           
           if meters < 5 {
               
               return 1.0
           } else if meters < 20 {
              
               return 2.5
           } else if meters < 60 {
               
               return 4.0
           } else {
              
               return 5.0
           }
       }
    private func distanceAlongRoute(segmentIndex: Int,
                                    coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        guard fullRouteCoordinates.count >= 2 else { return 0 }

        let safeIndex = max(0, min(segmentIndex, fullRouteCoordinates.count - 2))

        var total: CLLocationDistance = 0

        if safeIndex > 0 {
            for i in 0..<safeIndex {
                let a = CLLocation(latitude: fullRouteCoordinates[i].latitude,
                                   longitude: fullRouteCoordinates[i].longitude)
                let b = CLLocation(latitude: fullRouteCoordinates[i + 1].latitude,
                                   longitude: fullRouteCoordinates[i + 1].longitude)
                total += a.distance(from: b)
            }
        }

        let segmentStart = CLLocation(latitude: fullRouteCoordinates[safeIndex].latitude,
                                      longitude: fullRouteCoordinates[safeIndex].longitude)
        let current = CLLocation(latitude: coordinate.latitude,
                                 longitude: coordinate.longitude)

        total += segmentStart.distance(from: current)

        return total
    }
    private func startRouteSmoothAnimation(fromDistance: CLLocationDistance,
                                           toDistance: CLLocationDistance,
                                           duration: TimeInterval) {
        stopSmoothAnimation()

        isRouteDistanceAnimation = true
        routeAnimationStartDistance = fromDistance
        routeAnimationEndDistance = toDistance

        animationStartTime = CACurrentMediaTime()
        animationDuration = max(duration, 0.5)

        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    // MARK: - CADisplayLink Smooth Interpolation
    private func startSmoothAnimation(from startRaw: CLLocationCoordinate2D,
                                      to endRaw: CLLocationCoordinate2D,
                                      duration: TimeInterval) {
        stopSmoothAnimation()

        isRouteDistanceAnimation = false

        animationStartRaw = startRaw
        animationEndRaw = endRaw
        animationStartTime = CACurrentMediaTime()
        animationDuration = max(duration, 0.5)

        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    private func stopSmoothAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        isRouteDistanceAnimation = false
    }

    @objc private func updateAnimation() {
        guard let annotation = busAnnotation else {
            stopSmoothAnimation()
            return
        }

        let elapsed = CACurrentMediaTime() - animationStartTime
        var progress = elapsed / animationDuration
        var finished = false

        if progress >= 1.0 {
            progress = 1.0
            finished = true
        }

        // =====================================================
        // ✅ Smooth route-distance animation
        // =====================================================
        if isRouteDistanceAnimation, fullRouteCoordinates.count >= 2 {

            let currentDistance = routeAnimationStartDistance +
                (routeAnimationEndDistance - routeAnimationStartDistance) * progress

            let point = coordinateOnRoute(at: currentDistance)

            annotation.coordinate = point.coordinate
            visualCoordinate = point.coordinate

            if let annotationView = Mapview.view(for: annotation) as? BusAnnotationView {
                annotationView.updateRotation(degrees: point.heading)
            }

            trimTraveledPath(segmentIndex: point.segmentIndex,
                             currentCoord: point.coordinate,
                             force: finished)

            if finished {
                stopSmoothAnimation()
            }

            return
        }

        // =====================================================
        // Fallback raw coordinate animation
        // =====================================================
        guard let startRaw = animationStartRaw,
              let endRaw = animationEndRaw else {
            stopSmoothAnimation()
            return
        }

        let lat = startRaw.latitude + (endRaw.latitude - startRaw.latitude) * progress
        let lng = startRaw.longitude + (endRaw.longitude - startRaw.longitude) * progress
        let interpolatedRaw = CLLocationCoordinate2D(latitude: lat, longitude: lng)

        annotation.coordinate = interpolatedRaw
        visualCoordinate = interpolatedRaw

        if finished {
            stopSmoothAnimation()
        }
    }
    private func coordinateOnRoute(at distance: CLLocationDistance)
    -> (coordinate: CLLocationCoordinate2D, segmentIndex: Int, heading: Double) {

        guard fullRouteCoordinates.count >= 2 else {
            return (visualCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0), 0, 0)
        }

        if distance <= 0 {
            let heading = calculateHeading(from: fullRouteCoordinates[0],
                                           to: fullRouteCoordinates[1])
            return (fullRouteCoordinates[0], 0, heading)
        }

        var remaining = distance

        for i in 0..<(fullRouteCoordinates.count - 1) {
            let start = fullRouteCoordinates[i]
            let end = fullRouteCoordinates[i + 1]

            let startLoc = CLLocation(latitude: start.latitude, longitude: start.longitude)
            let endLoc = CLLocation(latitude: end.latitude, longitude: end.longitude)
            let segmentDistance = startLoc.distance(from: endLoc)

            if segmentDistance <= 0 {
                continue
            }

            if remaining <= segmentDistance {
                let ratio = remaining / segmentDistance

                let lat = start.latitude + (end.latitude - start.latitude) * ratio
                let lng = start.longitude + (end.longitude - start.longitude) * ratio

                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                let heading = calculateHeading(from: start, to: end)

                return (coord, i, heading)
            }

            remaining -= segmentDistance
        }

        let lastIndex = fullRouteCoordinates.count - 1
        let heading = calculateHeading(from: fullRouteCoordinates[lastIndex - 1],
                                       to: fullRouteCoordinates[lastIndex])

        return (fullRouteCoordinates[lastIndex], lastIndex - 1, heading)
    }
    // MARK: - CARTESIAN MAP SNAPPING
    private func snapCoordinateToRoute(_ coord: CLLocationCoordinate2D,
                                       route: [CLLocationCoordinate2D])
    -> (snapped: CLLocationCoordinate2D, segmentIndex: Int, segmentHeading: Double) {

        guard route.count >= 2 else { return (coord, 0, 0) }

        let p = MKMapPoint(coord)
        var closestPoint = MKMapPoint(route[0])
        var minDistance = Double.greatestFiniteMagnitude
        var closestSegmentIndex = 0
        var segmentHeading: Double = 0

        for i in 0..<(route.count - 1) {
            let a = MKMapPoint(route[i])
            let b = MKMapPoint(route[i + 1])

            let dx = b.x - a.x
            let dy = b.y - a.y
            let lengthSq = dx * dx + dy * dy

            var t = 0.0
            if lengthSq != 0 {
                t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / lengthSq
                t = max(0, min(1, t))
            }

            let projX = a.x + t * dx
            let projY = a.y + t * dy

            let distSq = pow(p.x - projX, 2) + pow(p.y - projY, 2)

            if distSq < minDistance {
                minDistance = distSq
                closestPoint = MKMapPoint(x: projX, y: projY)
                closestSegmentIndex = i
                segmentHeading = calculateHeading(from: route[i], to: route[i + 1])
            }
        }

        return (closestPoint.coordinate, closestSegmentIndex, segmentHeading)
    }

    // MARK: - SPLIT PATH: Traveled (gray) BEHIND + Remaining (blue) AHEAD
    private func trimTraveledPath(segmentIndex: Int,
                                  currentCoord: CLLocationCoordinate2D,
                                  force: Bool = false) {

        guard fullRouteCoordinates.count > 1 else { return }

        // Throttle overlay rebuild (~12 fps) for performance, but always allow forced
        let now = CACurrentMediaTime()
        if !force {
            if segmentIndex == lastTrimSegmentIndex && (now - lastTrimTime) < 0.08 { return }
        }
        lastTrimTime = now
        lastTrimSegmentIndex = segmentIndex

        // Remove previous split overlays
        if let old = remainingRouteOverlay {
            Mapview.removeOverlay(old)
            remainingRouteOverlay = nil
        }
        if let old = traveledRouteOverlay {
            Mapview.removeOverlay(old)
            traveledRouteOverlay = nil
        }

        let lastIdx = fullRouteCoordinates.count - 1
        let safeIndex = max(0, min(segmentIndex, lastIdx))

        // ✅ TRAVELED PATH (behind the bus → LIGHT GRAY)
        var traveledCoords = Array(fullRouteCoordinates[0...safeIndex])
        traveledCoords.append(currentCoord)
        if traveledCoords.count > 1 {
            let traveled = MKPolyline(coordinates: traveledCoords, count: traveledCoords.count)
            traveledRouteOverlay = traveled
            Mapview.addOverlay(traveled, level: .aboveRoads)
        }

        // ✅ REMAINING PATH (ahead of the bus → BLUE)
        var remainingCoords: [CLLocationCoordinate2D] = [currentCoord]
        if safeIndex + 1 <= lastIdx {
            remainingCoords.append(contentsOf: fullRouteCoordinates[(safeIndex + 1)...])
        }
        if remainingCoords.count > 1 {
            let remaining = MKPolyline(coordinates: remainingCoords, count: remainingCoords.count)
            remainingRouteOverlay = remaining
            Mapview.addOverlay(remaining, level: .aboveRoads)
        }
    }

    private func calculateHeading(from: CLLocationCoordinate2D,
                                  to: CLLocationCoordinate2D) -> Double {
        let fromLat = from.latitude * .pi / 180
        let fromLon = from.longitude * .pi / 180
        let toLat = to.latitude * .pi / 180
        let toLon = to.longitude * .pi / 180

        let deltaLon = toLon - fromLon
        let y = sin(deltaLon) * cos(toLat)
        let x = cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(deltaLon)

        let radians = atan2(y, x)
        var degrees = radians * 180.0 / .pi
        degrees = (degrees + 360).truncatingRemainder(dividingBy: 360)
        return degrees
    }

    private func startLiveLocationTracking() {
        locationTimer?.invalidate()
        locationTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval,
                                             repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.fetchLiveLocation()       // Fetch smooth bus coordinate updates
            self.fetchStopsDataUpdate()    // Fetch dynamic driver stop status updates
        }
        // Immediate first hit on view load
        fetchLiveLocation()
        fetchStopsDataUpdate()
    }
    private func stopLiveLocationTracking() {
        locationTimer?.invalidate()
        locationTimer = nil
    }

    private func refreshStopDots() {
        let reachedIds = Set(
            (busData?.routeStops ?? [])
                .filter { ($0.status ?? "").uppercased() == "REACHED" }
                .compactMap { $0.id }
        )

        for ann in Mapview.annotations.compactMap({ $0 as? StopAnnotation }) {
            let reached = ann.stopId.map { reachedIds.contains($0) } ?? false
            if ann.isReached != reached {
                ann.isReached = reached
                
                // Force immediate MapKit redraw on the Main Thread
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if let view = self.Mapview.view(for: ann) {
                        view.image = self.stopDotImage(reached: reached)
                    }
                }
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Live Bus Tracking",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        stopLiveLocationTracking()
        stopSmoothAnimation()
        uiTimer?.invalidate(); uiTimer = nil
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension BuslivetrackingVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is BusAnnotation {
            let reuseID = "BusAnnotationView"
            if let existing = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? BusAnnotationView {
                existing.annotation = annotation
                return existing
            }
            let v = BusAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            v.displayPriority = .required
            v.zPriority = .max
            return v
        }

        if let stop = annotation as? StopAnnotation {
            let reuseId = "StopAnnotationView_\(stop.kind)"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)

            view.annotation = annotation
            view.canShowCallout = true
            view.displayPriority = (stop.kind == .normal) ? .defaultHigh : .required
            view.collisionMode = .none

            // Setup custom callout card matching Figma
            let callout = UIView()
            callout.translatesAutoresizingMaskIntoConstraints = false

            let titleLabel = UILabel()
            titleLabel.text = stop.title ?? "Stop"
            titleLabel.font = .hankenBold(size: 13)
            titleLabel.textColor = UIColor(red: 20/255, green: 30/255, blue: 50/255, alpha: 1)

            let subtitleLabel = UILabel()
            subtitleLabel.text = stop.subtitle
            subtitleLabel.font = .hankenBold(size: 10)
            subtitleLabel.textColor = .systemGray

            let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stack.axis = .vertical
            stack.spacing = 2
            stack.translatesAutoresizingMaskIntoConstraints = false

            callout.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: callout.topAnchor, constant: 4),
                stack.bottomAnchor.constraint(equalTo: callout.bottomAnchor, constant: 4),
                stack.leadingAnchor.constraint(equalTo: callout.leadingAnchor, constant: 4),
                stack.trailingAnchor.constraint(equalTo: callout.trailingAnchor, constant: 4)
            ])
            view.detailCalloutAccessoryView = callout

            switch stop.kind {
            case .school, .drop:
                view.image = createSchoolAnnotationImage()
                view.centerOffset = .zero

            case .student, .pickup:
                view.image = createStudentAnnotationImage(from: nil)
                view.centerOffset = .zero
                loadStudentAnnotationImage { [weak view] styledImg in
                    DispatchQueue.main.async {
                        view?.image = styledImg
                    }
                }

            case .normal:
                view.image = stopDotImage(reached: stop.isReached)
                view.centerOffset = .zero
            }

            return view
        }

        return nil
    }

    // MARK: - Stop Annotation Images
    private func createSchoolAnnotationImage() -> UIImage {
        let size = CGSize(width: 36, height: 36)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let c = ctx.cgContext
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)

            // Blue circle background
            c.setFillColor(appBlue.cgColor)
            c.fillEllipse(in: rect)

            // White border
            c.setStrokeColor(UIColor.white.cgColor)
            c.setLineWidth(2)
            c.strokeEllipse(in: rect)

            // White School Building / Stop icon from Assets or SF Symbol
            let iconImage = (UIImage(named: "home 2") ?? UIImage(named: "school_building") ?? UIImage(systemName: "building.2.fill"))?
                .withRenderingMode(.alwaysTemplate)
            if let icon = iconImage {
                let targetSize = CGSize(width: 18, height: 18)
                let iconRect = CGRect(x: (size.width - targetSize.width) / 2,
                                      y: (size.height - targetSize.height) / 2,
                                      width: targetSize.width,
                                      height: targetSize.height)
                UIColor.white.set()
                icon.draw(in: iconRect)
            }
        }
    }

    private func createStudentAnnotationImage(from image: UIImage?) -> UIImage {
        let size = CGSize(width: 38, height: 38)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let c = ctx.cgContext
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)

            // Circular clip for student image
            c.saveGState()
            c.addEllipse(in: rect)
            c.clip()

            if let img = image {
                img.draw(in: rect)
            } else if let assetImg = UIImage(named: "student 2") ?? UIImage(named: "student") {
                assetImg.draw(in: rect)
            } else {
                c.setFillColor(UIColor(red: 235/255, green: 242/255, blue: 255/255, alpha: 1).cgColor)
                c.fill(rect)
                if let placeholder = UIImage(systemName: "person.fill")?.withTintColor(appBlue, renderingMode: .alwaysOriginal) {
                    let pRect = CGRect(x: (size.width - placeholder.size.width) / 2,
                                       y: (size.height - placeholder.size.height) / 2 + 2,
                                       width: placeholder.size.width,
                                       height: placeholder.size.height)
                    placeholder.draw(in: pRect)
                }
            }
            c.restoreGState()

            // White border
            c.setStrokeColor(UIColor.white.cgColor)
            c.setLineWidth(2.5)
            c.strokeEllipse(in: rect)
        }
    }

    private func loadStudentAnnotationImage(completion: @escaping (UIImage) -> Void) {
        let photoURL = UserManager.shared.resolvedStudentPhotoURL
        if !photoURL.isEmpty, let url = URL(string: photoURL) {
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    let styled = self.createStudentAnnotationImage(from: imageResult.image)
                    completion(styled)
                case .failure:
                    let styled = self.createStudentAnnotationImage(from: nil)
                    completion(styled)
                }
            }
        } else {
            let styled = createStudentAnnotationImage(from: nil)
            completion(styled)
        }
    }
    
    
    

    // ✅ Renderer picks correct color for traveled vs remaining path
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }

       
        guard polyline === traveledRouteOverlay || polyline === remainingRouteOverlay else {
            let emptyRenderer = MKPolylineRenderer(polyline: polyline)
            emptyRenderer.strokeColor = .clear
            return emptyRenderer
        }

        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineCap  = .round
        renderer.lineJoin = .round

        if polyline === traveledRouteOverlay {
            
            renderer.strokeColor = traveledColor
            renderer.lineWidth   = 3
        } else {
           
            renderer.strokeColor = appBlue
            renderer.lineWidth   = 3
        }
        return renderer
    }
    fileprivate func stopDotImage(reached: Bool = false) -> UIImage {
        let size = CGSize(width: 20, height: 20)
        
        
        let reachedGreen = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1)
        
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let c = ctx.cgContext
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 1.5, dy: 1.5)

            if reached {
              
                c.setFillColor(reachedGreen.cgColor)
                c.fillEllipse(in: rect)
                c.setStrokeColor(UIColor.white.cgColor)
                c.setLineWidth(1.5)
                c.strokeEllipse(in: rect)

                
                c.setStrokeColor(UIColor.white.cgColor)
                c.setLineWidth(2)
                c.setLineCap(.round)
                c.setLineJoin(.round)
                c.move(to: CGPoint(x: 6, y: 10.5))
                c.addLine(to: CGPoint(x: 9, y: 13.5))
                c.addLine(to: CGPoint(x: 14, y: 7))
                c.strokePath()
            } else {
                
                c.setFillColor(UIColor.white.cgColor)
                c.fillEllipse(in: rect)
                c.setStrokeColor(appBlue.cgColor)
                c.setLineWidth(3)
                c.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))
            }
        }
    }
}
extension UIImage {
    func rotated(by degrees: CGFloat) -> UIImage? {
        let radians = degrees * .pi / 180
        var newSize = CGRect(origin: .zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: radians)).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2,
                             width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

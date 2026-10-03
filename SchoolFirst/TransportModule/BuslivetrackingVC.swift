//
//  BuslivetrackingVC.swift
//  SchoolFirst
//

import UIKit
import MapKit

// MARK: - Stop Annotation (Pickup / Drop / Intermediate)
final class StopAnnotation: NSObject, MKAnnotation {
    enum Kind { case pickup, drop, normal }

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
            
            // ✅ Figma డిజైన్ ప్రకారం 3 వేరు వేరు స్టైల్స్
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

            // టెక్స్ట్ లేబుల్స్
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

            // కలర్ అప్లై చేయడం
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

        // లైన్ డ్రా చేయడం
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

    // MARK: - Private Properties
    private var busAnnotation  : BusAnnotation?
    private var lastRawCoordinate : CLLocationCoordinate2D?
    private var locationTimer  : Timer?
    private let refreshInterval: TimeInterval = 5.0
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

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var notStartedOverlay: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
        setupMapView()
        setupHeaderUI()
        setupInfoCard()
        setupBottomPanel()
        setupNotStartedOverlay()

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
        panelHeight = panel.bounds.height
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

        cardBusNumber.font = .hankenBold(size: 12)
        cardBusModel.font = .hankenMedium(size: 9); cardBusModel.textColor = .systemGray
        cardStatusTag.font = .hankenBold(size: 8)
        cardStatusTag.textColor = .systemGreen
        cardStatusTag.text = "ON THE WAY"

        let busText = UIStackView(arrangedSubviews: [cardBusNumber, cardBusModel, cardStatusTag])
        busText.axis = .vertical; busText.spacing = 1
        let col1 = UIStackView(arrangedSubviews: [cardBusImage, busText])
        col1.axis = .horizontal; col1.spacing = 8; col1.alignment = .center

        let clock = UIImageView(image: UIImage(systemName: "clock"))
        clock.tintColor = appBlue; clock.contentMode = .scaleAspectFit
        clock.translatesAutoresizingMaskIntoConstraints = false
        cardETA.font = .hankenBold(size: 14); cardETA.textColor = appBlue; cardETA.text = "-- min"
        let etaRow = UIStackView(arrangedSubviews: [clock, cardETA])
        etaRow.axis = .horizontal; etaRow.spacing = 4; etaRow.alignment = .center
        cardDistance.font = .hankenMedium(size: 9); cardDistance.textColor = .darkGray; cardDistance.text = "-- km away"
        let col2 = UIStackView(arrangedSubviews: [etaRow, cardDistance])
        col2.axis = .vertical; col2.spacing = 2; col2.alignment = .center

        cardNextStopTitle.font = .hankenMedium(size: 8); cardNextStopTitle.textColor = .systemGray; cardNextStopTitle.text = "Next stop"
        cardNextStopName.font = .hankenBold(size: 10); cardNextStopName.numberOfLines = 2
        cardUpdated.font = .hankenMedium(size: 8); cardUpdated.textColor = .systemGray
        let col3 = UIStackView(arrangedSubviews: [cardNextStopTitle, cardNextStopName, cardUpdated])
        col3.axis = .vertical; col3.spacing = 1

        let sep1 = UIView(); sep1.backgroundColor = .systemGray5
        let sep2 = UIView(); sep2.backgroundColor = .systemGray5

        let row = UIStackView(arrangedSubviews: [col1, sep1, col2, sep2, col3])
        row.axis = .horizontal; row.spacing = 10; row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        infoCard.addSubview(row)

        NSLayoutConstraint.activate([
            infoCard.topAnchor.constraint(equalTo: Mapview.topAnchor, constant: 12),
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),

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

        panelScroll.showsVerticalScrollIndicator = false
        panelScroll.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(panelScroll)

        panelStack.axis = .vertical
        panelStack.spacing = 12
        panelStack.translatesAutoresizingMaskIntoConstraints = false
        panelScroll.addSubview(panelStack)

        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            panel.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.46),

            grabber.topAnchor.constraint(equalTo: panel.topAnchor, constant: 8),
            grabber.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 40),
            grabber.heightAnchor.constraint(equalToConstant: 5),

            panelScroll.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 8),
            panelScroll.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            panelScroll.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            panelScroll.bottomAnchor.constraint(equalTo: panel.safeAreaLayoutGuide.bottomAnchor, constant: -8),

            panelStack.topAnchor.constraint(equalTo: panelScroll.contentLayoutGuide.topAnchor),
            panelStack.bottomAnchor.constraint(equalTo: panelScroll.contentLayoutGuide.bottomAnchor),
            panelStack.leadingAnchor.constraint(equalTo: panelScroll.contentLayoutGuide.leadingAnchor, constant: 16),
            panelStack.trailingAnchor.constraint(equalTo: panelScroll.contentLayoutGuide.trailingAnchor, constant: -16),
            panelStack.widthAnchor.constraint(equalTo: panelScroll.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        let h = panelScroll.heightAnchor.constraint(equalTo: panelStack.heightAnchor)
        h.priority = .defaultHigh
        h.isActive = true

        panelStack.addArrangedSubview(buildStudentCard())
        panelStack.addArrangedSubview(sectionTitle("Driver & Bus Details"))
        panelStack.addArrangedSubview(buildDriverRow())
        panelStack.addArrangedSubview(buildStatsRow())
        panelStack.addArrangedSubview(buildProgressHeader())
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.heightAnchor.constraint(equalToConstant: 62).isActive = true
        panelStack.addArrangedSubview(progressView)
    }

    private func sectionTitle(_ text: String) -> UILabel {
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
            driverMeta.font = .hankenMedium(size: 12); driverMeta.textColor = .systemGray
            let text = UIStackView(arrangedSubviews: [driverName, driverMeta])
            text.axis = .vertical; text.spacing = 2
            text.translatesAutoresizingMaskIntoConstraints = false

            let msgBtn = UIButton(type: .system)
            if let image = UIImage(named: "icon 33") {
                msgBtn.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            msgBtn.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 250/255, alpha: 1)
            msgBtn.layer.cornerRadius = 18
            msgBtn.clipsToBounds = true
            msgBtn.translatesAutoresizingMaskIntoConstraints = false
            msgBtn.addTarget(self, action: #selector(messageDriverTapped), for: .touchUpInside)

            let callBtn = UIButton(type: .system)
            callBtn.setTitle(" Call", for: .normal)
            callBtn.setImage(UIImage(systemName: "phone.fill"), for: .normal)
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
            sub.font = .hankenMedium(size: 9); sub.textColor = .systemGray; sub.textAlignment = .center
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
        title.font = .hankenBold(size: 11)
        progressCount.font = .hankenMedium(size: 9)
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

           let pickupIdx = pickupStopIndex()
           let passedPickup = isActive && pickupIdx != nil && done > pickupIdx!

          
           var studentStopSubtitle = formatTime(data?.pickupStop?.pickupTime ?? "")
           
           
           if isActive && !passedPickup {
               if let eta = cachedETASeconds, eta > 0 {
                   let mins = max(1, Int(ceil(eta / 60)))
                   studentStopSubtitle = "≈ \(mins) min"
               }
           }

         
           let steps: [RouteProgressView.Step] = [
               // 1. School (Source)
               .init(title: data?.route?.source ?? "School",
                     subtitle: formatTime(data?.routeStops?.first?.pickupTime ?? data?.pickupStop?.pickupTime ?? ""),
                     state: isActive ? .done : .pending),
               
               // 2. On Route (Bus)
               .init(title: "On Route",
                     subtitle: isActive ? "Current" : "",
                     state: isActive && !passedPickup ? .current : (passedPickup ? .done : .pending)),
               
               // 3. Student's Stop
               .init(title: "\(studentFirstName())'s Stop",
                     subtitle: studentStopSubtitle,
                     state: passedPickup ? .current : .pending)
           ]
           
           progressView.configure(steps: steps)
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
        cardStatusTag.text = status.replacingOccurrences(of: "_", with: " ").uppercased()

        let busLoc = CLLocation(latitude: busCoord.latitude, longitude: busCoord.longitude)
        var nearestIdx: Int?
        var nearestDist = CLLocationDistance.greatestFiniteMagnitude
        for (i, c) in routeStopCoordinates.enumerated() {
            let d = busLoc.distance(from: CLLocation(latitude: c.latitude, longitude: c.longitude))
            if d < nearestDist { nearestDist = d; nearestIdx = i }
        }
        if let i = nearestIdx {
            let nextIdx = (nearestDist < 120 && i + 1 < routeStopNames.count) ? i + 1 : i
            cardNextStopName.text = routeStopNames[nextIdx]
            updateProgress(currentStopIndex: nearestDist < 120 ? i + 1 : i)
        } else {
            cardNextStopName.text = busData?.pickupStop?.stopName ?? "--"
            updateProgress(currentStopIndex: nil)
        }

        guard let dest = pickupCoordinate() else { return }
        let straight = busLoc.distance(from: CLLocation(latitude: dest.latitude, longitude: dest.longitude))

        var needRoute = etaLastRoutedCoord == nil
        if let last = etaLastRoutedCoord {
            let moved = busLoc.distance(from: CLLocation(latitude: last.latitude, longitude: last.longitude))
            needRoute = moved > 150
        }

        if needRoute && !etaIsRouting {
            etaIsRouting = true
            etaLastRoutedCoord = busCoord
            let req = MKDirections.Request()
            req.source = MKMapItem(placemark: MKPlacemark(coordinate: busCoord))
            req.destination = MKMapItem(placemark: MKPlacemark(coordinate: dest))
            req.transportType = .automobile
            MKDirections(request: req).calculate { [weak self] resp, _ in
                guard let self = self else { return }
                self.etaIsRouting = false
                if let r = resp?.routes.first {
                    self.cachedETASeconds = r.expectedTravelTime
                    self.cachedDistanceMeters = r.distance
                } else {
                    self.cachedDistanceMeters = straight * 1.3
                    let kmh = self.currentSpeed > 3 ? self.currentSpeed : 25
                    self.cachedETASeconds = (straight * 1.3) / (kmh * 1000 / 3600)
                }
                DispatchQueue.main.async { self.renderETA() }
            }
        } else if cachedDistanceMeters == nil {
            cachedDistanceMeters = straight * 1.3
            let kmh = speed > 3 ? speed : 25
            cachedETASeconds = (straight * 1.3) / (kmh * 1000 / 3600)
        }
        renderETA()
    }

    private func renderETA() {
        let dist = cachedDistanceMeters ?? 0
        let eta = cachedETASeconds ?? 0
        let mins = max(1, Int(ceil(eta / 60)))
        let distText = dist >= 1000 ? String(format: "%.1f km", dist / 1000) : "\(Int(dist)) m"

        cardETA.text = "\(mins) min"
        cardDistance.text = "\(distText) away"

        if dist < 150 {
            studentStatus.text = "Bus has reached your stop"
            studentExpected.text = "Arrived now"
        } else if mins <= 5 {
            studentStatus.text = "Bus approaching your stop"
            studentExpected.text = "Expected in \(mins) min • \(distText) away"
        } else {
            studentStatus.text = "Bus is on the way"
            studentExpected.text = "Expected in \(mins) min • \(distText) away"
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

    // MARK: - Not Started Popup
    private func setupNotStartedOverlay() {
        notStartedOverlay = UIView()
        notStartedOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        notStartedOverlay.translatesAutoresizingMaskIntoConstraints = false
        notStartedOverlay.isHidden = true
        notStartedOverlay.alpha = 0
        view.addSubview(notStartedOverlay)

        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 15
        cardView.translatesAutoresizingMaskIntoConstraints = false
        notStartedOverlay.addSubview(cardView)

        let iconView = UIImageView(image: UIImage(systemName: "clock.badge.exclamationmark"))
        iconView.tintColor = .systemOrange
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Trip Not Started Yet"
        titleLabel.font = .hankenBold(size: 20)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let messageLabel = UILabel()
        messageLabel.text = "The driver hasn't initiated the trip yet.\nStay on this screen, we are actively checking. Tracking will begin automatically once started."
        messageLabel.font = .hankenRegular(size: 14)
        messageLabel.textColor = .darkGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        let backBtn = UIButton(type: .system)
        backBtn.setTitle("Go Back", for: .normal)
        backBtn.titleLabel?.font = .hankenBold(size: 16)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.backgroundColor = appBlue
        backBtn.layer.cornerRadius = 12
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.addTarget(self, action: #selector(BackButtonTapped(_:)), for: .touchUpInside)

        cardView.addSubview(iconView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(backBtn)

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
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),

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

        var stops: [(coord: CLLocationCoordinate2D, name: String, time: String?,
                     kind: StopAnnotation.Kind, id: String?, reached: Bool)] = []

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
                if let pid = pickupID, pid == s.id { kind = .pickup }
                else if let did = dropID, did == s.id { kind = .drop }

                stops.append((
                    coord,
                    s.stopName ?? "Stop",
                    s.pickupTime ?? s.dropTime,
                    kind,
                    s.id,
                    (s.status ?? "").uppercased() == "REACHED"
                ))
            }
        }

        if stops.count < 2 {
            stops.removeAll()
            if let p = data.pickupStop, let lat = p.latitude, let lng = p.longitude,
               !(lat == 0 && lng == 0) {
                stops.append((
                    CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    p.stopName ?? "Pickup", p.pickupTime, .pickup, p.id, false
                ))
            }
            if let d = data.dropStop, let lat = d.latitude, let lng = d.longitude,
               !(lat == 0 && lng == 0) {
                stops.append((
                    CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    d.stopName ?? "Drop", d.dropTime, .drop, d.id, false
                ))
            }
        }

        guard !stops.isEmpty else { return }

        if !stops.contains(where: { $0.kind == .pickup }) { stops[0].kind = .pickup }
        if stops.count > 1, !stops.contains(where: { $0.kind == .drop }) { stops[stops.count - 1].kind = .drop }

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
        if let dot = value.firstIndex(of: ".") { value = String(value[..<dot]) }
        let out = DateFormatter(); out.dateFormat = "hh:mm a"; out.locale = Locale(identifier: "en_US_POSIX")
        for f in ["HH:mm:ss", "HH:mm", "hh:mm a", "h:mm a"] {
            let p = DateFormatter(); p.dateFormat = f; p.locale = Locale(identifier: "en_US_POSIX")
            if let d = p.date(from: value) { return out.string(from: d) }
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

                    let isActive = ["active", "started", "live", "running", "on_route"].contains(self.currentTripStatus)
                    if isActive {
                        self.hideNotStartedPopup()
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
                        let isActiveResponse = ["active", "started", "live", "running", "on_route"].contains(tripStatus)

                        self.currentTripStatus = tripStatus

                       
                        if !isActiveResponse {
                            self.liveBadge.isHidden = true
                            
                           
                            self.stopLiveLocationTracking()
                            self.stopSmoothAnimation()
                            
                            
                            self.view.bringSubviewToFront(self.notStartedOverlay)
                            self.showNotStartedPopup()
                            return
                        }

                        self.hideNotStartedPopup()

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
        // API interval is 5 sec. Animation should run almost until next response.
        let maxSmoothDuration = max(1.0, refreshInterval - 0.35) // around 4.65 sec

        if meters < 5 {
            return 1.0
        } else if meters < 15 {
            return 2.5
        } else {
            return maxSmoothDuration
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
            switch stop.kind {
            case .pickup, .drop:
                let id = "StopMarker"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
                view.annotation = annotation
                view.canShowCallout = true
                view.displayPriority = .required
                if stop.kind == .pickup {
                    view.markerTintColor = .systemGreen
                    view.glyphImage = UIImage(systemName: "figure.wave")
                } else {
                    view.markerTintColor = .systemRed
                    view.glyphImage = UIImage(systemName: "graduationcap.fill")
                }
                return view

            case .normal:
                let id = "StopDot"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                    ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                view.annotation = annotation
                view.canShowCallout = true
                view.image = stopDotImage(reached: stop.isReached)
                view.displayPriority = .defaultHigh
                view.collisionMode = .none
                return view
            }
        }

        return nil
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

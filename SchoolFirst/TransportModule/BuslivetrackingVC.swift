//
//  BuslivetrackingVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 31/07/26.
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

    // Callout lo time + status chupistundi
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

// MARK: - Route Progress View (School → On Route → Stop → Home)
final class RouteProgressView: UIView {

    enum State { case done, current, pending }
    struct Step { let title: String; let subtitle: String; let state: State }

    private let line = UIView()
    private let activeLine = UIView()
    private let stack = UIStackView()
    private var circles: [UIView] = []
    private let blue = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
    private var activeWidth: NSLayoutConstraint?

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        line.backgroundColor = UIColor.systemGray4
        activeLine.backgroundColor = blue
        line.translatesAutoresizingMaskIntoConstraints = false
        activeLine.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(line); addSubview(activeLine); addSubview(stack)
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

        let icons = ["building.2.fill", "bus.fill", "figure.wave", "house.fill"]
        for (i, s) in steps.enumerated() {
            let col = UIStackView()
            col.axis = .vertical; col.alignment = .center; col.spacing = 4

            let circle = UIView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.layer.cornerRadius = 12
            let icon = UIImageView(image: UIImage(systemName: i < icons.count ? icons[i] : "circle.fill"))
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            circle.addSubview(icon)
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: 24),
                circle.heightAnchor.constraint(equalToConstant: 24),
                icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 13),
                icon.heightAnchor.constraint(equalToConstant: 13)
            ])

            let title = UILabel()
            title.font = .hankenSemiBold(size: 10)
            title.textAlignment = .center
            title.text = s.title
            title.numberOfLines = 1
            title.adjustsFontSizeToFitWidth = true
            title.minimumScaleFactor = 0.7

            let sub = UILabel()
            sub.font = .hankenMedium(size: 9)
            sub.textAlignment = .center
            sub.text = s.subtitle
            sub.textColor = .systemGray

            switch s.state {
            case .done:
                circle.backgroundColor = .systemGreen; icon.tintColor = .white
                title.textColor = .darkGray
            case .current:
                circle.backgroundColor = blue; icon.tintColor = .white
                title.textColor = blue; sub.textColor = blue
            case .pending:
                circle.backgroundColor = .systemGray5; icon.tintColor = .systemGray
                title.textColor = .darkGray
            }

            col.addArrangedSubview(circle)
            col.addArrangedSubview(title)
            col.addArrangedSubview(sub)
            stack.addArrangedSubview(col)
            circles.append(circle)
        }

        guard let first = circles.first, let last = circles.last else { return }
        sendSubviewToBack(activeLine); sendSubviewToBack(line)

        let currentIndex = steps.firstIndex { $0.state == .current } ?? (steps.lastIndex { $0.state == .done } ?? 0)
        let target = circles[min(currentIndex, circles.count - 1)]

        NSLayoutConstraint.activate([
            line.centerYAnchor.constraint(equalTo: first.centerYAnchor),
            line.leadingAnchor.constraint(equalTo: first.centerXAnchor),
            line.trailingAnchor.constraint(equalTo: last.centerXAnchor),
            line.heightAnchor.constraint(equalToConstant: 2),
            activeLine.centerYAnchor.constraint(equalTo: first.centerYAnchor),
            activeLine.leadingAnchor.constraint(equalTo: first.centerXAnchor),
            activeLine.trailingAnchor.constraint(equalTo: target.centerXAnchor),
            activeLine.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
}

class BuslivetrackingVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var Topview: UIView!
    @IBOutlet weak var LivetrackingLabel: UILabel!
    @IBOutlet weak var Mapview    : MKMapView!
    @IBOutlet weak var BackButton : UIButton!

    // MARK: - Input (set from dashboard)
    var busData: StudentBusData?

    // MARK: - Private Properties
    private var busAnnotation  : BusAnnotation?
    private var lastCoordinate : CLLocationCoordinate2D?
    private var locationTimer  : Timer?
    private let refreshInterval: TimeInterval = 5.0

    // ✅ NEW: Flag to ensure TRANSPORT_BUS API is called only once
    private var hasFetchedBusDataOnce = false

    // MARK: - Route Properties
    private var routeStopCoordinates: [CLLocationCoordinate2D] = []
    private var routeStopNames: [String] = []
    private var routeOverlays: [MKPolyline] = []
    private var isRouteDrawn = false
    private var hasFittedInitialRegion = false
    private let appBlue = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)

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
        setupHeaderUI()
        setupInfoCard()
        setupBottomPanel()
        setupNotStartedOverlay()
        
        // Setup initial static data if provided
        setupRouteOnMap()
        populateStaticData()
        
        // ✅ Call Stops API (TRANSPORT_BUS) strictly ONCE when entering the screen
        fetchInitialBusData()
        
        setupFonts()
        setupTopViewShadow()
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

    // MARK: - Setup Loader
    private func setupLoader() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - ================= HEADER =================
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

    // MARK: - ================= TOP INFO CARD =================
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

    // MARK: - ================= BOTTOM PANEL =================
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
        l.font = .hankenBold(size: 12)
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

        studentName.font = .hankenBold(size: 13)
        studentStatus.font = .hankenSemiBold(size: 11); studentStatus.textColor = appBlue
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
        let row = UIView()

        driverImage.contentMode = .scaleAspectFill
        driverImage.clipsToBounds = true
        driverImage.layer.cornerRadius = 22
        driverImage.backgroundColor = .systemGray5
        driverImage.image = UIImage(systemName: "person.crop.circle.fill")
        driverImage.tintColor = .systemGray3
        driverImage.translatesAutoresizingMaskIntoConstraints = false

        driverName.font = .hankenBold(size: 13)
        driverMeta.font = .hankenMedium(size: 10); driverMeta.textColor = .systemGray
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
        callBtn.backgroundColor = appBlue
        callBtn.layer.cornerRadius = 10
        callBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 14)
        callBtn.translatesAutoresizingMaskIntoConstraints = false
        callBtn.addTarget(self, action: #selector(callDriverTapped), for: .touchUpInside)

        row.addSubview(driverImage); row.addSubview(text); row.addSubview(msgBtn); row.addSubview(callBtn)
        NSLayoutConstraint.activate([
            driverImage.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            driverImage.topAnchor.constraint(equalTo: row.topAnchor),
            driverImage.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            driverImage.widthAnchor.constraint(equalToConstant: 44),
            driverImage.heightAnchor.constraint(equalToConstant: 44),
            text.leadingAnchor.constraint(equalTo: driverImage.trailingAnchor, constant: 10),
            text.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            text.trailingAnchor.constraint(lessThanOrEqualTo: msgBtn.leadingAnchor, constant: -8),
            callBtn.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            callBtn.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            msgBtn.trailingAnchor.constraint(equalTo: callBtn.leadingAnchor, constant: -10),
            msgBtn.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            msgBtn.widthAnchor.constraint(equalToConstant: 36),
            msgBtn.heightAnchor.constraint(equalToConstant: 36)
        ])
        return row
    }

    private func statColumn(icon: String, value: UILabel, sub: UILabel) -> UIView {
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = appBlue; iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.heightAnchor.constraint(equalToConstant: 18).isActive = true
        value.font = .hankenBold(size: 11); value.textAlignment = .center
        value.adjustsFontSizeToFitWidth = true; value.minimumScaleFactor = 0.7
        sub.font = .hankenMedium(size: 9); sub.textColor = .systemGray; sub.textAlignment = .center
        sub.adjustsFontSizeToFitWidth = true; sub.minimumScaleFactor = 0.7
        let col = UIStackView(arrangedSubviews: [iv, value, sub])
        col.axis = .vertical; col.spacing = 3; col.alignment = .center
        return col
    }

    private func buildStatsRow() -> UIView {
        let row = UIStackView(arrangedSubviews: [
            statColumn(icon: "bus", value: statBusValue, sub: statBusSub),
            statColumn(icon: "bus", value: statModelValue, sub: statModelSub),
            statColumn(icon: "person.2", value: statCapValue, sub: statCapSub)
        ])
        row.axis = .horizontal; row.distribution = .fillEqually; row.alignment = .top
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

    // MARK: - Populate static data from busData
    private func populateStaticData() {
        let data = busData

        // Set Initial Trip Status
        self.currentTripStatus = data?.tripStatus?.lowercased() ?? ""

        // Header subtitle
        let routeName = data?.route?.routeName ?? data?.route?.routeCode ?? "Route"
        let shiftRaw = (data?.route?.shift ?? data?.tripType ?? "").capitalized
        routeSubtitleLabel.text = shiftRaw.isEmpty ? routeName : "\(routeName) · \(shiftRaw)"

        // Bus card
        let vehicle = data?.bus?.vehicleNumber ?? "School Bus"
        cardBusNumber.text = vehicle
        cardBusModel.text = data?.bus?.vehicleType ?? ""
        let busImageURL = data?.bus?.image ?? data?.bus?.busImage ?? data?.bus?.vehicleImage ?? data?.bus?.vehiclePhoto ?? data?.bus?.busPhoto ?? data?.bus?.photo
        if let u = busImageURL, !u.isEmpty { cardBusImage.loadImage(url: u) }

        // Student
        let sName = UserManager.shared.resolvedStudentName
        studentName.text = sName.isEmpty ? (data?.student?.name ?? "Student") : sName
        let photo = UserManager.shared.resolvedStudentPhotoURL
        if !photo.isEmpty { studentImage.loadImage(url: photo) }

        // Driver
        driverName.text = data?.driver?.name ?? "Driver"
        if let exp = data?.driver?.experience, exp > 0 {
            driverMeta.text = "⭐ \(String(format: "%.0f", exp))+ yrs experience"
        } else {
            driverMeta.text = data?.driver?.mobile ?? "Driver"
        }
        if let u = data?.driver?.profileImage, !u.isEmpty { driverImage.loadImage(url: u) }

        // Stats
        statBusValue.text = data?.route?.routeCode.map { "Bus \($0)" } ?? "Bus"
        statBusSub.text = vehicle
        statModelValue.text = data?.bus?.vehicleType ?? "N/A"
        statModelSub.text = data?.bus?.status?.capitalized ?? "Vehicle"
        statCapValue.text = data?.bus?.capacity.map { "\($0)" } ?? "N/A"
        statCapSub.text = "Seating Capacity"

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

        // Has the bus passed the student's pickup stop?
        let pickupIdx = pickupStopIndex()
        let passedPickup = isActive && pickupIdx != nil && done > pickupIdx!

        let steps: [RouteProgressView.Step] = [
            .init(title: data?.route?.source ?? "School",
                  subtitle: formatTime(data?.routeStops?.first?.pickupTime ?? data?.pickupStop?.pickupTime ?? ""),
                  state: isActive ? .done : .pending),
            .init(title: "On Route",
                  subtitle: isActive ? "Current" : "",
                  state: isActive && !passedPickup ? .current : (passedPickup ? .done : .pending)),
            .init(title: "\(studentFirstName())'s Stop",
                  subtitle: formatTime(data?.pickupStop?.pickupTime ?? ""),
                  state: passedPickup ? .current : .pending),
            .init(title: data?.route?.destination ?? "Home",
                  subtitle: formatTime(data?.dropStop?.dropTime ?? ""),
                  state: .pending)
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

    // MARK: - Driver actions
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

    // MARK: - ================= LIVE INFO =================
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

    // MARK: - Setup Attractive Not Started Popup
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

    // MARK: - ================= ROUTE DRAWING =================
    private func setupRouteOnMap() {
        guard let data = busData else { return }

        var stops: [(coord: CLLocationCoordinate2D, name: String, time: String?,
                     kind: StopAnnotation.Kind, id: String?, reached: Bool)] = []

        let pickupID = data.pickupStop?.id
        let dropID   = data.dropStop?.id

        if let routeStops = data.routeStops, !routeStops.isEmpty {
            let ordered = routeStops.sorted { ($0.stopOrder ?? 0) < ($1.stopOrder ?? 0) }
            for s in ordered {
                guard let lat = s.latitude, let lng = s.longitude,
                      CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: lat, longitude: lng)),
                      !(lat == 0 && lng == 0) else { continue }

                var kind: StopAnnotation.Kind = .normal
                if let pid = pickupID, pid == s.id { kind = .pickup }
                else if let did = dropID, did == s.id { kind = .drop }

                stops.append((CLLocationCoordinate2D(latitude: lat, longitude: lng),
                              s.stopName ?? "Stop",
                              s.pickupTime ?? s.dropTime,
                              kind,
                              s.id,
                              (s.status ?? "").uppercased() == "REACHED"))
            }
        }

        if stops.count < 2 {
            stops.removeAll()
            if let p = data.pickupStop, let lat = p.latitude, let lng = p.longitude {
                stops.append((CLLocationCoordinate2D(latitude: lat, longitude: lng),
                              p.stopName ?? "Pickup", p.pickupTime, .pickup, p.id, false))
            }
            if let d = data.dropStop, let lat = d.latitude, let lng = d.longitude {
                stops.append((CLLocationCoordinate2D(latitude: lat, longitude: lng),
                              d.stopName ?? "Drop", d.dropTime, .drop, d.id, false))
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
        guard routeStopCoordinates.count >= 2 else { return }
        drawRoadRoute(segmentIndex: 0)
    }

    private func drawRoadRoute(segmentIndex: Int) {
        guard segmentIndex < routeStopCoordinates.count - 1 else {
            isRouteDrawn = true
            fitMapToRoute(includeBus: true)
            return
        }

        let from = routeStopCoordinates[segmentIndex]
        let to   = routeStopCoordinates[segmentIndex + 1]

        let request = MKDirections.Request()
        request.source        = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination   = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .automobile

        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self = self else { return }

            let polyline: MKPolyline
            if let route = response?.routes.first, error == nil {
                polyline = route.polyline
            } else {
                var pair = [from, to]
                polyline = MKPolyline(coordinates: &pair, count: 2)
            }

            DispatchQueue.main.async {
                self.routeOverlays.append(polyline)
                self.Mapview.addOverlay(polyline, level: .aboveRoads)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.drawRoadRoute(segmentIndex: segmentIndex + 1)
                }
            }
        }
    }

    private func fitMapToRoute(includeBus: Bool) {
        var rect = MKMapRect.null
        for overlay in routeOverlays { rect = rect.union(overlay.boundingMapRect) }
        if rect.isNull {
            for c in routeStopCoordinates {
                let p = MKMapPoint(c)
                rect = rect.union(MKMapRect(x: p.x, y: p.y, width: 1, height: 1))
            }
        }
        if includeBus, let bus = busAnnotation {
            let p = MKMapPoint(bus.coordinate)
            rect = rect.union(MKMapRect(x: p.x, y: p.y, width: 1, height: 1))
        }

        guard !rect.isNull else { return }
        let bottomPad = max(panelHeight, 260) + 30
        Mapview.setVisibleMapRect(rect,
                                  edgePadding: UIEdgeInsets(top: 110, left: 50, bottom: bottomPad, right: 50),
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

    // MARK: - ✅ Fetch Stops Data ONLY ONCE
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
                    
                    self.setupRouteOnMap()
                    self.populateStaticData()
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
    
    // MARK: - Fetch Live Location API
    // ✅ NO EARLY RETURNS: Always fetch live location to check if trip started
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
                        
                        // Check if trip is active from the lightweight API
                        if !isActiveResponse {
                            self.liveBadge.isHidden = true
                            self.showNotStartedPopup()
                            return
                        }

                        // Trip is active! Hide popup and update location
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

                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let vehicleNumber = data.vehicle?.vehicleNumber ?? self.busData?.bus?.vehicleNumber ?? "School Bus"
                        let speed = location.speed ?? 0.0
                        let heading = location.heading

                        self.updateBusLocation(
                            coordinate: coordinate,
                            vehicleNumber: vehicleNumber,
                            tripStatus: tripStatus,
                            speed: speed,
                            heading: heading
                        )
                        self.updateLiveInfo(busCoord: coordinate, speed: speed, status: tripStatus)
                    }

                case .failure(_):
                    break
                }
            }
        }
    }

    private func updateBusLocation(coordinate: CLLocationCoordinate2D,
                                   vehicleNumber: String,
                                   tripStatus: String,
                                   speed: Double,
                                   heading: Double?) {

        let busHeading = heading ?? 0.0

        if busAnnotation == nil {
            let annotation = BusAnnotation(coordinate: coordinate)
            annotation.title = "🚌 \(vehicleNumber)"
            annotation.subtitle = "Trip: \(tripStatus.capitalized)"

            busAnnotation = annotation
            Mapview.addAnnotation(annotation)
            lastCoordinate = coordinate

            if !routeStopCoordinates.isEmpty {
                fitMapToRoute(includeBus: true)
            } else {
                let region = MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                )
                Mapview.setRegion(region, animated: true)
            }
            return
        }

        guard let annotation = busAnnotation else { return }
        let previousCoordinate = lastCoordinate ?? annotation.coordinate
        
        var directionDegrees = busHeading
        if heading == nil {
            directionDegrees = calculateHeading(from: previousCoordinate, to: coordinate)
        }

        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut]) {
            annotation.coordinate = coordinate
        }

        annotation.title = "🚌 \(vehicleNumber)"
        annotation.subtitle = "Trip: \(tripStatus.capitalized)"

        if let annotationView = Mapview.view(for: annotation) as? BusAnnotationView {
            annotationView.rotate(degrees: directionDegrees)
        }

        Mapview.setCenter(coordinate, animated: true)
        lastCoordinate = coordinate
    }

    private func calculateHeading(from: CLLocationCoordinate2D,
                                  to: CLLocationCoordinate2D) -> Double {
        let deltaLon = to.longitude - from.longitude
        let y = sin(deltaLon) * cos(to.latitude)
        let x = cos(from.latitude) * sin(to.latitude) -
        sin(from.latitude) * cos(to.latitude) * cos(deltaLon)

        let radians = atan2(y, x)
        var degrees = radians * 180.0 / .pi
        degrees = (degrees + 360).truncatingRemainder(dividingBy: 360)
        return degrees
    }

    // MARK: - Start/Stop Location Tracking (Auto Refresh)
    private func startLiveLocationTracking() {
        locationTimer?.invalidate()
        locationTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval,
                                             repeats: true) { [weak self] _ in
            self?.fetchLiveLocation()
        }
    }

    private func stopLiveLocationTracking() {
        locationTimer?.invalidate()
        locationTimer = nil
    }

    // ✅ Refresh dots based on initial load data
    private func refreshStopDots() {
        let reachedIds = Set(
            (busData?.routeStops ?? [])
                .filter { ($0.status ?? "").uppercased() == "REACHED" }
                .compactMap { $0.id }
        )

        for ann in Mapview.annotations.compactMap({ $0 as? StopAnnotation }) {
            let reached = ann.stopId.map { reachedIds.contains($0) } ?? false
            guard ann.isReached != reached else { continue }
            ann.isReached = reached
            if ann.kind == .normal, let v = Mapview.view(for: ann) {
                v.image = stopDotImage(reached: reached)
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Live Bus Tracking",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        stopLiveLocationTracking()
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
            return BusAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
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

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = appBlue
        renderer.lineWidth   = 6
        renderer.lineCap     = .round
        renderer.lineJoin    = .round
        return renderer
    }

    fileprivate func stopDotImage(reached: Bool = false) -> UIImage {
        let size = CGSize(width: 20, height: 20)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let c = ctx.cgContext
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 1.5, dy: 1.5)

            if reached {
                c.setFillColor(appBlue.cgColor)
                c.fillEllipse(in: rect)
                c.setStrokeColor(UIColor.white.cgColor)
                c.setLineWidth(1.5)
                c.strokeEllipse(in: rect)

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

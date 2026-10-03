//
//  TRSPRpickupUITableviewcell2.swift
//  SchoolFirst
//

import UIKit

class TRSPRpickupUITableviewcell2: UITableViewCell {

    @IBOutlet weak var Ckeckmarkimageview: UIImageView!
    @IBOutlet weak var imagebackgroundview: UIView!
    @IBOutlet weak var PickupandDroptimelabel: UILabel!
    @IBOutlet weak var StopnameLabel: UILabel!

    @IBOutlet weak var statusBadgeLabel: UILabel?
    @IBOutlet weak var timelineTopLine: UIView?
    @IBOutlet weak var timelineBottomLine: UIView?

    // MARK: - Figma "Your Stop" Highlight
    private let highlightCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1.2
        view.layer.borderColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1).cgColor
        view.backgroundColor = .white
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let mapIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "map")
        iv.tintColor = UIColor(red: 68/255.0, green: 70/255.0, blue: 86/255.0, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // MARK: - Figma ETA UI (Info Icon + ETA Text)
    private let etaStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()

    private let etaIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "info.circle")
        iv.tintColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1) // Primary Blue
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let etaLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1) // Primary Blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Programmatic status badge fallback
    private let fallbackStatusBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 9, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var activeBadgeLabel: UILabel? {
        return statusBadgeLabel ?? fallbackStatusBadge
    }

    // MARK: - Programmatic timeline lines (fallback if XIB nil)
    private let fallbackTopLine: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private let fallbackBottomLine: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private var activeTopLine: UIView? {
        return timelineTopLine ?? fallbackTopLine
    }

    private var activeBottomLine: UIView? {
        return timelineBottomLine ?? fallbackBottomLine
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupFonts()
        setupHighlightCard()
        setupFallbackBadgeIfNeeded()
        setupFallbackTimelineIfNeeded()

        imagebackgroundview?.layer.cornerRadius = (imagebackgroundview?.frame.height ?? 28) / 2
        imagebackgroundview?.clipsToBounds = true

        statusBadgeLabel?.layer.cornerRadius = 4
        statusBadgeLabel?.clipsToBounds = true
        statusBadgeLabel?.textAlignment = .center
    }

    private func setupHighlightCard() {
        contentView.insertSubview(highlightCardView, at: 0)
        contentView.addSubview(mapIconImageView)
        
        etaStackView.addArrangedSubview(etaIconImageView)
        etaStackView.addArrangedSubview(etaLabel)
        contentView.addSubview(etaStackView)

        guard let circleView = imagebackgroundview,
              let stopName = StopnameLabel,
              let timeLabel = PickupandDroptimelabel else { return }

        // Dynamic constraint wrapping the labels and ETA seamlessly
        NSLayoutConstraint.activate([
            highlightCardView.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 12),
            highlightCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            highlightCardView.topAnchor.constraint(equalTo: stopName.topAnchor, constant: -12),
            highlightCardView.bottomAnchor.constraint(greaterThanOrEqualTo: timeLabel.bottomAnchor, constant: 12),

            // Map icon to Top Right of the card
            mapIconImageView.trailingAnchor.constraint(equalTo: highlightCardView.trailingAnchor, constant: -12),
            mapIconImageView.topAnchor.constraint(equalTo: highlightCardView.topAnchor, constant: 12),
            mapIconImageView.widthAnchor.constraint(equalToConstant: 20),
            mapIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // ETA Stack view immediately below the Time label
            etaStackView.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            etaStackView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 6),
            
            // Ensure card expands downwards to include ETA when visible
            highlightCardView.bottomAnchor.constraint(greaterThanOrEqualTo: etaStackView.bottomAnchor, constant: 12),
            
            // ETA Icon dimensions
            etaIconImageView.widthAnchor.constraint(equalToConstant: 14),
            etaIconImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        // Push the cell boundaries down if the card expands
        let cellBottom = contentView.bottomAnchor.constraint(greaterThanOrEqualTo: highlightCardView.bottomAnchor, constant: 8)
        cellBottom.priority = .defaultHigh // Prevents layout crashes with strict XIB constraints
        cellBottom.isActive = true
    }

    private func setupFallbackBadgeIfNeeded() {
        guard statusBadgeLabel == nil else { return }
        contentView.addSubview(fallbackStatusBadge)

        NSLayoutConstraint.activate([
            fallbackStatusBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            fallbackStatusBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            fallbackStatusBadge.heightAnchor.constraint(equalToConstant: 22),
            fallbackStatusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])
    }

    private func setupFallbackTimelineIfNeeded() {
        let needTop = (timelineTopLine == nil)
        let needBottom = (timelineBottomLine == nil)
        guard needTop || needBottom else { return }
        guard let circle = imagebackgroundview else { return }

        let lineWidth: CGFloat = 2.0

        if needTop {
            contentView.insertSubview(fallbackTopLine, at: 0)
            NSLayoutConstraint.activate([
                fallbackTopLine.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                fallbackTopLine.topAnchor.constraint(equalTo: contentView.topAnchor),
                fallbackTopLine.bottomAnchor.constraint(equalTo: circle.topAnchor),
                fallbackTopLine.widthAnchor.constraint(equalToConstant: lineWidth)
            ])
        }

        if needBottom {
            contentView.insertSubview(fallbackBottomLine, at: 0)
            NSLayoutConstraint.activate([
                fallbackBottomLine.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                fallbackBottomLine.topAnchor.constraint(equalTo: circle.bottomAnchor),
                fallbackBottomLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                fallbackBottomLine.widthAnchor.constraint(equalToConstant: lineWidth)
            ])
        }
    }

    private func setupFonts() {
        StopnameLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        PickupandDroptimelabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        statusBadgeLabel?.font = UIFont.systemFont(ofSize: 9, weight: .bold)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        StopnameLabel.text = nil
        PickupandDroptimelabel.text = nil

        statusBadgeLabel?.text = nil
        statusBadgeLabel?.isHidden = true
        fallbackStatusBadge.text = nil
        fallbackStatusBadge.isHidden = true

        Ckeckmarkimageview?.image = nil
        Ckeckmarkimageview?.tintColor = nil
        contentView.backgroundColor = .clear

        imagebackgroundview?.backgroundColor = .clear
        imagebackgroundview?.layer.borderWidth = 0
        imagebackgroundview?.layer.borderColor = nil

        highlightCardView.isHidden = true
        mapIconImageView.isHidden = true
        
        etaStackView.isHidden = true
        etaLabel.text = nil

        activeTopLine?.isHidden = true
        activeBottomLine?.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let iv = imagebackgroundview, iv.bounds.height > 0 {
            iv.layer.cornerRadius = iv.bounds.height / 2
        }
    }

    // MARK: - Configure Cell State
    func configure(
        stopName: String?,
        time: String?,
        isYourStop: Bool = false,
        isFirst: Bool = false,
        isLast: Bool = false,
        stopOrder: Int? = nil,
        isDrop: Bool = false,
        isPassed: Bool = false,
        isLive: Bool = false,
        estimatedTravelTime: Int? = nil
    ) {
        let name = stopName?.trimmingCharacters(in: .whitespacesAndNewlines)
        StopnameLabel.text = (name?.isEmpty == false) ? name : "N/A"
        PickupandDroptimelabel.text = Self.formatTime(time, isDrop: isDrop)

        let primaryBlue = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
        let grayColor   = UIColor(red: 196/255, green: 197/255, blue: 216/255, alpha: 1) // #C4C5D8 Figma
        let lightGray   = UIColor.systemGray3

        let topLine = activeTopLine
        let bottomLine = activeBottomLine

        topLine?.isHidden = isFirst
        bottomLine?.isHidden = isLast

        topLine?.backgroundColor = (isPassed || isLive) ? primaryBlue : grayColor
        bottomLine?.backgroundColor = isPassed ? primaryBlue : grayColor

        if let top = topLine { contentView.insertSubview(top, at: 0) }
        if let bottom = bottomLine { contentView.insertSubview(bottom, at: 0) }
        if let circle = imagebackgroundview { contentView.bringSubviewToFront(circle) }
        if let icon = Ckeckmarkimageview { contentView.bringSubviewToFront(icon) }

        imagebackgroundview?.layer.borderWidth = 0
        imagebackgroundview?.layer.borderColor = nil
        imagebackgroundview?.backgroundColor = .clear
        StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        StopnameLabel.textColor = .black
        PickupandDroptimelabel.textColor = .darkGray

        statusBadgeLabel?.isHidden = true
        fallbackStatusBadge.isHidden = true
        highlightCardView.isHidden = true
        mapIconImageView.isHidden = true
        etaStackView.isHidden = true
        Ckeckmarkimageview?.contentMode = .scaleAspectFit

        let badge = activeBadgeLabel

        if isLive {
            // 🚌 LIVE STATE
            imagebackgroundview?.backgroundColor = primaryBlue
            imagebackgroundview?.layer.borderWidth = 0

            let busImg = UIImage(named: "Icon 30") ?? UIImage(named: "school_bus")
            if let bImg = busImg {
                Ckeckmarkimageview?.image = bImg.withRenderingMode(.alwaysTemplate)
                Ckeckmarkimageview?.tintColor = .white
            } else {
                Ckeckmarkimageview?.image = UIImage(systemName: "bus.fill")
                Ckeckmarkimageview?.tintColor = .white
            }

            StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            StopnameLabel.textColor = primaryBlue

            badge?.isHidden = false
            badge?.text = "  LIVE  "
            badge?.backgroundColor = primaryBlue
            badge?.textColor = .white

        } else if isYourStop {
            // 📍 YOUR STOP STATE
            imagebackgroundview?.backgroundColor = .white
            imagebackgroundview?.layer.borderWidth = 2.0
            imagebackgroundview?.layer.borderColor = UIColor(red: 196/255, green: 197/255, blue: 216/255, alpha: 1).cgColor

            let pinColor = UIColor(red: 75/255, green: 85/255, blue: 99/255, alpha: 1)
            let locImg = UIImage(named: "locationicon") ?? UIImage(named: "locationiconblue")

            if let lImg = locImg {
                Ckeckmarkimageview?.image = lImg.withRenderingMode(.alwaysOriginal)
                Ckeckmarkimageview?.tintColor = nil
            } else {
                Ckeckmarkimageview?.image = UIImage(systemName: "mappin") ?? UIImage(systemName: "mappin.and.ellipse")
                Ckeckmarkimageview?.tintColor = pinColor
            }

            highlightCardView.isHidden = false
            mapIconImageView.isHidden = false

            // ETA Render
            if let eta = estimatedTravelTime, eta > 0 {
                etaStackView.isHidden = false
                etaLabel.text = "ETA: \(eta) mins away"
            }

            StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            StopnameLabel.textColor = .black
            PickupandDroptimelabel.textColor = .darkGray

            badge?.isHidden = false
            badge?.text = "  YOUR STOP  "
            badge?.backgroundColor = primaryBlue
            badge?.textColor = .white

        } else if isPassed {
            // ✅ PASSED STATE (Green ticks inside the blue round circle)
            imagebackgroundview?.backgroundColor = .white
            imagebackgroundview?.layer.borderWidth = 1.0
            imagebackgroundview?.layer.borderColor = lightGray.cgColor

            if isDrop {
                Ckeckmarkimageview?.image = nil
            } else {
                let checkImg = UIImage(named: "Circle_checkbox") ?? UIImage(named: "GreenTick")
                if let cImg = checkImg {
                    Ckeckmarkimageview?.image = cImg.withRenderingMode(.alwaysOriginal)
                    Ckeckmarkimageview?.tintColor = nil
                } else {
                    Ckeckmarkimageview?.image = UIImage(systemName: "checkmark.circle.fill")
                    Ckeckmarkimageview?.tintColor = primaryBlue
                }
            }

            StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            StopnameLabel.textColor = .black

            badge?.isHidden = false
            badge?.text = "  PASSED  "
            badge?.backgroundColor = primaryBlue.withAlphaComponent(0.12)
            badge?.textColor = primaryBlue

        } else {
            // ⚪ UPCOMING STATE
            imagebackgroundview?.backgroundColor = .white
            imagebackgroundview?.layer.borderWidth = 1.0
            imagebackgroundview?.layer.borderColor = lightGray.cgColor
            Ckeckmarkimageview?.image = nil

            StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            StopnameLabel.textColor = .darkGray
            PickupandDroptimelabel.textColor = .lightGray
        }

        if let activeBadge = badge { contentView.bringSubviewToFront(activeBadge) }
        if !highlightCardView.isHidden {
            contentView.insertSubview(highlightCardView, at: 0)
            if let top = topLine { contentView.insertSubview(top, at: 0) }
            if let bottom = bottomLine { contentView.insertSubview(bottom, at: 0) }
            contentView.bringSubviewToFront(mapIconImageView)
            if !etaStackView.isHidden { contentView.bringSubviewToFront(etaStackView) }
            if let activeBadge = badge { contentView.bringSubviewToFront(activeBadge) }
            if let circle = imagebackgroundview { contentView.bringSubviewToFront(circle) }
            if let icon = Ckeckmarkimageview { contentView.bringSubviewToFront(icon) }
        }
    }

    // MARK: - Time Formatter
    static func formatTime(_ raw: String?, isDrop: Bool = false) -> String {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return "--:--" }
        let upper = value.uppercased()
        if upper.contains("AM") || upper.contains("PM") {
            let ampmFormats = ["hh:mm a","h:mm a","hh:mm:ss a","h:mm:ss a","hh:mma","h:mma"]
            for format in ampmFormats {
                let parser = DateFormatter()
                parser.locale = Locale(identifier: "en_US_POSIX")
                parser.dateFormat = format
                if let date = parser.date(from: value) { return displayFormatter.string(from: date) }
            }
            return upper
                .replacingOccurrences(of: "AM", with: " AM")
                .replacingOccurrences(of: "PM", with: " PM")
                .replacingOccurrences(of: "  ", with: " ")
                .trimmingCharacters(in: .whitespaces)
        }
        if let dotIndex = value.firstIndex(of: ".") { value = String(value[..<dotIndex]) }
        let inputFormats = ["HH:mm:ss","H:mm:ss","HH:mm","H:mm",
                            "yyyy-MM-dd'T'HH:mm:ss","yyyy-MM-dd'T'HH:mm:ssZ","yyyy-MM-dd HH:mm:ss"]
        var parsedDate: Date?
        for format in inputFormats {
            let parser = DateFormatter()
            parser.locale = Locale(identifier: "en_US_POSIX")
            parser.dateFormat = format
            if let date = parser.date(from: value) { parsedDate = date; break }
        }
        guard let date = parsedDate else { return value }
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        if isDrop && hour >= 1 && hour <= 11 {
            hour += 12
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            if let updatedDate = calendar.date(from: components) {
                return displayFormatter.string(from: updatedDate)
            }
        }
        return displayFormatter.string(from: date)
    }

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "hh:mm a"
        return f
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

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

    // MARK: - Figma "Your Stop" Highlight UI Elements
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
        iv.tintColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupFonts()
        setupHighlightCard()
        
        imagebackgroundview?.layer.cornerRadius = (imagebackgroundview?.frame.height ?? 28) / 2
        imagebackgroundview?.clipsToBounds = true
        
        statusBadgeLabel?.layer.cornerRadius = 4
        statusBadgeLabel?.clipsToBounds = true
        statusBadgeLabel?.textAlignment = .center
    }

    private func setupHighlightCard() {
        contentView.insertSubview(highlightCardView, at: 0)
        contentView.addSubview(mapIconImageView)
        
        // Keep clear gap from the circle so blue card never touches it
        guard let circleView = imagebackgroundview else { return }
        
        NSLayoutConstraint.activate([
            highlightCardView.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 12),
            highlightCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            highlightCardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            highlightCardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            mapIconImageView.trailingAnchor.constraint(equalTo: highlightCardView.trailingAnchor, constant: -12),
            mapIconImageView.centerYAnchor.constraint(equalTo: highlightCardView.centerYAnchor),
            mapIconImageView.widthAnchor.constraint(equalToConstant: 20),
            mapIconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func setupFonts() {
        StopnameLabel?.font = .hankenBold(size: 16)
        PickupandDroptimelabel?.font = .hankenRegular(size: 13)
        statusBadgeLabel?.font = .hankenBold(size: 9)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        StopnameLabel.text = nil
        PickupandDroptimelabel.text = nil
        statusBadgeLabel?.text = nil
        statusBadgeLabel?.isHidden = true
        Ckeckmarkimageview?.image = nil
        Ckeckmarkimageview?.tintColor = nil
        contentView.backgroundColor = .clear
        
        imagebackgroundview?.backgroundColor = .clear
        imagebackgroundview?.layer.borderWidth = 0
        imagebackgroundview?.layer.borderColor = nil
        
        highlightCardView.isHidden = true
        mapIconImageView.isHidden = true
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
        isLive: Bool = false
    ) {
        let name = stopName?.trimmingCharacters(in: .whitespacesAndNewlines)
        StopnameLabel.text = (name?.isEmpty == false) ? name : "N/A"
        PickupandDroptimelabel.text = Self.formatTime(time, isDrop: isDrop)

        // Base Colors
        let primaryBlue = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
        let grayColor   = UIColor.systemGray4
        let lightGray   = UIColor.systemGray3
        
        // 1. TIMELINE LOGIC (Match Figma exactly)
        timelineTopLine?.backgroundColor = (isLive || isPassed) ? primaryBlue : grayColor
        timelineBottomLine?.backgroundColor = isPassed ? primaryBlue : grayColor
        timelineTopLine?.isHidden = isFirst
        timelineBottomLine?.isHidden = isLast

        // Keep circle + lines above the highlight card
        if let top = timelineTopLine { contentView.bringSubviewToFront(top) }
        if let bottom = timelineBottomLine { contentView.bringSubviewToFront(bottom) }
        if let circle = imagebackgroundview { contentView.bringSubviewToFront(circle) }
        if let icon = Ckeckmarkimageview { contentView.bringSubviewToFront(icon) }

        // Reset base states
        imagebackgroundview?.layer.borderWidth = 0
        imagebackgroundview?.layer.borderColor = nil
        imagebackgroundview?.backgroundColor = .clear
        StopnameLabel.font = .hankenRegular(size: 15)
        StopnameLabel.textColor = .black
        PickupandDroptimelabel.textColor = .darkGray
        statusBadgeLabel?.isHidden = true
        highlightCardView.isHidden = true
        mapIconImageView.isHidden = true
        Ckeckmarkimageview?.contentMode = .scaleAspectFit

        // --- STATE VISUALS ---
        if isLive {
            // 🚌 BUS IN A STOP (Evening Drop live / current)
            imagebackgroundview?.backgroundColor = primaryBlue
            imagebackgroundview?.layer.borderWidth = 0
            
            var busImg: UIImage? = UIImage(named: "Icon 30")
            if busImg == nil { busImg = UIImage(named: "Icon30") }
            if busImg == nil { busImg = UIImage(named: "icon 30") }
            if busImg == nil { busImg = UIImage(named: "icon30") }
            if busImg == nil { busImg = UIImage(named: "busicon") }
            if busImg == nil { busImg = UIImage(named: "school_bus") }
            
            if let bImg = busImg {
                // ✅ FORCE WHITE bus icon on blue background
                Ckeckmarkimageview?.image = bImg.withRenderingMode(.alwaysTemplate)
                Ckeckmarkimageview?.tintColor = .white
            } else {
                Ckeckmarkimageview?.image = UIImage(systemName: "bus.fill")
                Ckeckmarkimageview?.tintColor = .white
            }

            StopnameLabel.font = .hankenBold(size: 15)
            StopnameLabel.textColor = primaryBlue
            statusBadgeLabel?.isHidden = false
            statusBadgeLabel?.text = "  LIVE  "
            statusBadgeLabel?.backgroundColor = primaryBlue
            statusBadgeLabel?.textColor = .white

        } else if isPassed {
            // ✅ BUS PASSED STOP
            // ✅ FIX: Add 1pt gray border (especially needed for pickup index 0)
            imagebackgroundview?.backgroundColor = .white
            imagebackgroundview?.layer.borderWidth = 1.0
            imagebackgroundview?.layer.borderColor = lightGray.cgColor
            
            var checkImg: UIImage? = UIImage(named: "Circle_checkbox")
            if checkImg == nil { checkImg = UIImage(named: "check-mark") }
            if checkImg == nil { checkImg = UIImage(named: "GreenTick") }
            if checkImg == nil { checkImg = UIImage(named: "tickmark") }
            if checkImg == nil { checkImg = UIImage(named: "done_check") }
            
            if let cImg = checkImg {
                Ckeckmarkimageview?.image = cImg.withRenderingMode(.alwaysOriginal)
                Ckeckmarkimageview?.tintColor = nil
            } else {
                Ckeckmarkimageview?.image = UIImage(systemName: "checkmark.circle.fill")
                Ckeckmarkimageview?.tintColor = primaryBlue
            }
            
            StopnameLabel.font = .hankenRegular(size: 15)
            StopnameLabel.textColor = .black
            statusBadgeLabel?.isHidden = false
            statusBadgeLabel?.text = "  PASSED  "
            statusBadgeLabel?.backgroundColor = primaryBlue.withAlphaComponent(0.12)
            statusBadgeLabel?.textColor = primaryBlue

        } else {
            // 📍 UPCOMING STOPS: Empty circle + light grey border
            imagebackgroundview?.backgroundColor = .white
            imagebackgroundview?.layer.borderWidth = 1.0
            imagebackgroundview?.layer.borderColor = lightGray.cgColor
            
            if isYourStop {
                var locImg: UIImage? = UIImage(named: "locationicon")
                if locImg == nil { locImg = UIImage(named: "Location") }
                if locImg == nil { locImg = UIImage(named: "locatio") }
                if locImg == nil { locImg = UIImage(named: "locationiconblue") }
                
                if let lImg = locImg {
                    Ckeckmarkimageview?.image = lImg.withRenderingMode(.alwaysOriginal)
                    Ckeckmarkimageview?.tintColor = nil
                } else {
                    Ckeckmarkimageview?.image = UIImage(systemName: "mappin.and.ellipse") ?? UIImage(systemName: "mappin")
                    Ckeckmarkimageview?.tintColor = primaryBlue
                }
            } else {
                Ckeckmarkimageview?.image = nil
            }
            
            StopnameLabel.font = .hankenRegular(size: 15)
            StopnameLabel.textColor = .darkGray
            PickupandDroptimelabel.textColor = .lightGray
        }

        // --- "YOUR STOP" HIGHLIGHT OVERRIDE ---
        if isYourStop {
            highlightCardView.isHidden = false
            mapIconImageView.isHidden = false
            
            StopnameLabel.font = .hankenBold(size: 15)
            StopnameLabel.textColor = .black
            PickupandDroptimelabel.textColor = .darkGray
            
            // If it's not live or passed, show the YOUR STOP badge
            if !isLive && !isPassed {
                statusBadgeLabel?.isHidden = false
                statusBadgeLabel?.text = "  YOUR STOP  "
                statusBadgeLabel?.backgroundColor = primaryBlue
                statusBadgeLabel?.textColor = .white
            }
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
            return upper.replacingOccurrences(of: "AM", with: " AM").replacingOccurrences(of: "PM", with: " PM").replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
        }
        if let dotIndex = value.firstIndex(of: ".") { value = String(value[..<dotIndex]) }
        let inputFormats = ["HH:mm:ss","H:mm:ss","HH:mm","H:mm","yyyy-MM-dd'T'HH:mm:ss","yyyy-MM-dd'T'HH:mm:ssZ","yyyy-MM-dd HH:mm:ss"]
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
            if let updatedDate = calendar.date(from: components) { return displayFormatter.string(from: updatedDate) }
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

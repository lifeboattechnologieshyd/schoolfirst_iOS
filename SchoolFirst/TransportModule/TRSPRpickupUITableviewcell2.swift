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

    override func awakeFromNib() {
        super.awakeFromNib()
        imagebackgroundview?.layer.cornerRadius = (imagebackgroundview?.frame.height ?? 28) / 2
        imagebackgroundview?.clipsToBounds = true
        statusBadgeLabel?.layer.cornerRadius = 4
        statusBadgeLabel?.clipsToBounds = true
        statusBadgeLabel?.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        statusBadgeLabel?.textAlignment = .center
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
    }

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

        // Reset
        imagebackgroundview?.layer.borderWidth = 0
        StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        StopnameLabel.textColor = .black
        PickupandDroptimelabel.textColor = .darkGray
        statusBadgeLabel?.isHidden = true
        contentView.backgroundColor = .clear
        Ckeckmarkimageview?.contentMode = .scaleAspectFit

        // --- STATE VISUALS ---
        if isLive {
            // 🚌 LIVE: Icon 30 asset
            imagebackgroundview?.backgroundColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
            imagebackgroundview?.layer.borderWidth = 0
            
            var busImg: UIImage? = UIImage(named: "Icon 30")
            if busImg == nil { busImg = UIImage(named: "Icon30") }
            if busImg == nil { busImg = UIImage(named: "icon 30") }
            if busImg == nil { busImg = UIImage(named: "icon30") }
            
            if let bImg = busImg {
                Ckeckmarkimageview?.image = bImg.withRenderingMode(.alwaysOriginal)
                Ckeckmarkimageview?.tintColor = nil
            } else {
                Ckeckmarkimageview?.image = UIImage(systemName: "bus.fill")
                Ckeckmarkimageview?.tintColor = .white
            }

            StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            StopnameLabel.textColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
            statusBadgeLabel?.isHidden = false
            statusBadgeLabel?.text = "  LIVE  "
            statusBadgeLabel?.backgroundColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
            statusBadgeLabel?.textColor = .white

        } else if isPassed {
            // ✅ PASSED: Circle_checkbox asset
            imagebackgroundview?.backgroundColor = .clear
            imagebackgroundview?.layer.borderWidth = 0
            
            if let checkImg = UIImage(named: "Circle_checkbox") {
                Ckeckmarkimageview?.image = checkImg.withRenderingMode(.alwaysOriginal)
                Ckeckmarkimageview?.tintColor = nil
            } else {
                // Fallback if asset missing
                Ckeckmarkimageview?.image = UIImage(systemName: "checkmark.circle.fill")
                Ckeckmarkimageview?.tintColor = UIColor.systemBlue
            }
            statusBadgeLabel?.isHidden = false
            statusBadgeLabel?.text = "  PASSED  "
            statusBadgeLabel?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
            statusBadgeLabel?.textColor = .systemBlue

        } else {
            // 📍 UPCOMING: location symbol
            imagebackgroundview?.backgroundColor = .white
            imagebackgroundview?.layer.borderWidth = 1.2
            imagebackgroundview?.layer.borderColor = UIColor.systemGray3.cgColor
            
            Ckeckmarkimageview?.image = UIImage(systemName: "mappin")
            Ckeckmarkimageview?.tintColor = .systemGray
        }

        // YOUR STOP highlight (keeps icon state but adds background)
        if isYourStop {
            StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            contentView.backgroundColor = UIColor(red: 235/255, green: 244/255, blue: 255/255, alpha: 1)
            // Keep live/passed badge priority, else show YOUR STOP
            if !isLive && !isPassed {
                statusBadgeLabel?.isHidden = false
                statusBadgeLabel?.text = "  YOUR STOP  "
                statusBadgeLabel?.backgroundColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
                statusBadgeLabel?.textColor = .white
            }
        }

        timelineTopLine?.isHidden = isFirst
        timelineBottomLine?.isHidden = isLast
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

    override func setSelected(_ selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated) }
}

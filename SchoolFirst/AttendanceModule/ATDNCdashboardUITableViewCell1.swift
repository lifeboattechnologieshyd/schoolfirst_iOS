//
//  ATDNCdashboardUITableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/08/26.
//

import UIKit
import FSCalendar

class ATDNCdashboardUITableViewCell1: UITableViewCell {

    @IBOutlet weak var Collectionview3: UICollectionView!
    @IBOutlet weak var Collectionview2: UICollectionView!
    // MARK: - Outlets
    @IBOutlet weak var Collectionview: UICollectionView!

    // MARK: - Layout Constants
    private let cardSpacing: CGFloat    = 8    // gap between cards
    private let sideInset: CGFloat      = 16   // leading & trailing — equal
    private let cardHeight: CGFloat     = 60
    private let calendarHeight: CGFloat = 426  // ✅ Figma: 358 × 426
    private let calendarTopSpace: CGFloat = 16 // ✅ top space from collectionview

    // ✅ Quick Navigation constants
    private let quickNavCellWidth: CGFloat  = 80
    private let quickNavCellHeight: CGFloat = 92
    private let quickNavSpacing: CGFloat    = 12
    private let quickNavSectionHeight: CGFloat = 92
    private let quickNavTopSpace: CGFloat   = 16
    private let quickNavTitleHeight: CGFloat = 24
    private let quickNavTitleTopSpace: CGFloat = 16

    // ✅ Recent Attendance constants
    private let recentAttendanceRowHeight: CGFloat = 52   // each row height inside container
    private let recentAttendanceTitleTopSpace: CGFloat = 16
    private let recentAttendanceTitleHeight: CGFloat = 24
    private let recentAttendanceTopSpace: CGFloat = 12

    // MARK: - Attendance Status
    enum AttendanceStatus {
        case present, absent, leave, late

        var fillColor: UIColor {
            switch self {
            case .present: return UIColor(red: 220/255, green: 245/255, blue: 230/255, alpha: 1.0) // light green
            case .absent:  return UIColor(red: 252/255, green: 226/255, blue: 228/255, alpha: 1.0) // light red
            case .leave:   return UIColor(red: 222/255, green: 235/255, blue: 253/255, alpha: 1.0) // light blue
            case .late:    return UIColor(red: 253/255, green: 235/255, blue: 214/255, alpha: 1.0) // light orange
            }
        }

        var dotColor: UIColor {
            switch self {
            case .present: return UIColor(red:  34/255, green: 160/255, blue:  82/255, alpha: 1.0) // green
            case .absent:  return UIColor(red: 225/255, green:  70/255, blue:  80/255, alpha: 1.0) // red
            case .leave:   return UIColor(red:  50/255, green: 120/255, blue: 220/255, alpha: 1.0) // blue
            case .late:    return UIColor(red: 235/255, green: 150/255, blue:  40/255, alpha: 1.0) // orange
            }
        }

        var displayText: String {
            switch self {
            case .present: return "Present"
            case .absent:  return "Absent"
            case .leave:   return "Leave"
            case .late:    return "Late"
            }
        }
    }

    // ✅ Demo attendance data ("yyyy-MM-dd" → status) — replace with API later
    private var attendanceData: [String: AttendanceStatus] = [
        "2026-05-05": .present,
        "2026-05-07": .present,
        "2026-05-12": .present,
        "2026-05-13": .absent,
        "2026-05-15": .present,
        "2026-05-19": .present,
        "2026-05-20": .late,
        "2026-05-21": .leave,
        "2026-05-26": .present,
        "2026-05-27": .late
    ]

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Recent Attendance Model
    struct RecentAttendance {
        let dateText: String     // e.g. "20 May 2026"
        let status: AttendanceStatus
    }

    // ✅ Demo Recent Attendance data — replace with API later
    private var recentAttendance: [RecentAttendance] = [
        RecentAttendance(dateText: "20 May 2026", status: .present),
        RecentAttendance(dateText: "19 May 2026", status: .present),
        RecentAttendance(dateText: "18 May 2026", status: .absent)
    ]

    // MARK: - Calendar Views (programmatic)
    private var calendarContainer: UIView!
    private var calendar: FSCalendar!

    // MARK: - Quick Navigation (programmatic)
    private var quickNavTitleLabel: UILabel!

    // MARK: - Recent Attendance (programmatic)
    private var recentAttendanceTitleLabel: UILabel!
    //private var viewAllButton: UIButton!
    private var recentAttendanceContainer: UIView!
    private var recentAttendanceHeightConstraint: NSLayoutConstraint!

    // MARK: - Attendance Stat Model
    private struct AttendanceStat {
        let title: String
        var value: String
        let backgroundColor: UIColor
        let borderColor: UIColor
        let textColor: UIColor
    }

    // ✅ Quick Navigation Item Model
    private struct QuickNavItem {
        let title: String
        let imageName: String
        let backgroundColor: UIColor
    }

    // ✅ Colors match Figma design: Present(green), Absent(red), Leave(blue), Att.%(orange)
    private var stats: [AttendanceStat] = [
        AttendanceStat(
            title: "Present",
            value: "18",
            backgroundColor: UIColor(red: 232/255, green: 247/255, blue: 237/255, alpha: 1.0),
            borderColor:     UIColor(red: 167/255, green: 220/255, blue: 184/255, alpha: 1.0),
            textColor:       UIColor(red:  34/255, green: 160/255, blue:  82/255, alpha: 1.0)
        ),
        AttendanceStat(
            title: "Absent",
            value: "5",
            backgroundColor: UIColor(red: 253/255, green: 235/255, blue: 236/255, alpha: 1.0),
            borderColor:     UIColor(red: 244/255, green: 184/255, blue: 188/255, alpha: 1.0),
            textColor:       UIColor(red: 225/255, green:  70/255, blue:  80/255, alpha: 1.0)
        ),
        AttendanceStat(
            title: "Leave",
            value: "2",
            backgroundColor: UIColor(red: 232/255, green: 241/255, blue: 253/255, alpha: 1.0),
            borderColor:     UIColor(red: 170/255, green: 205/255, blue: 245/255, alpha: 1.0),
            textColor:       UIColor(red:  50/255, green: 120/255, blue: 220/255, alpha: 1.0)
        ),
        AttendanceStat(
            title: "Att. %",
            value: "72%",
            backgroundColor: UIColor(red: 254/255, green: 242/255, blue: 230/255, alpha: 1.0),
            borderColor:     UIColor(red: 248/255, green: 200/255, blue: 160/255, alpha: 1.0),
            textColor:       UIColor(red: 235/255, green: 120/255, blue:  35/255, alpha: 1.0)
        )
    ]

    // ✅ Quick Navigation Items (matches Figma design)
    private var quickNavItems: [QuickNavItem] = [
        QuickNavItem(
            title: "My Child\nAttendance",
            imageName: "Icon 51",
            backgroundColor: UIColor(red: 254/255, green: 236/255, blue: 220/255, alpha: 1.0)
        ),
        QuickNavItem(
            title: "Attendance\nReport",
            imageName: "reporticon",
            backgroundColor: UIColor(red: 226/255, green: 236/255, blue: 253/255, alpha: 1.0)
        ),
        QuickNavItem(
            title: "Leave\nStatus",
            imageName: "icon 52",
            backgroundColor: UIColor(red: 226/255, green: 236/255, blue: 253/255, alpha: 1.0)
        ),
        QuickNavItem(
            title: "Request\nCorrection",
            imageName: "editicon",
            backgroundColor: UIColor(red: 220/255, green: 245/255, blue: 230/255, alpha: 1.0)
        )
    ]

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCollectionView()
        setupCalendar()
        setupQuickNavigation()
        setupRecentAttendance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // ✅ Frame is final here — recalc card widths so leading/trailing match
        Collectionview?.collectionViewLayout.invalidateLayout()
        Collectionview2?.collectionViewLayout.invalidateLayout()
        Collectionview3?.collectionViewLayout.invalidateLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - CollectionView Setup (Top Stats)
    private func setupCollectionView() {
        guard let cv = Collectionview else { return }

        cv.delegate   = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.bounces         = false

        cv.register(
            UINib(nibName: "ATDNCattendanceCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ATDNCattendanceCollectionViewCell"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .horizontal
        layout.minimumLineSpacing      = cardSpacing
        layout.minimumInteritemSpacing = cardSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        cv.collectionViewLayout = layout

        cv.reloadData()
    }

    // MARK: - ✅ FSCalendar Setup (programmatic)
    private func setupCalendar() {

        calendarContainer = UIView()
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        calendarContainer.backgroundColor    = .white
        calendarContainer.layer.cornerRadius = 12
        calendarContainer.layer.borderWidth  = 1
        calendarContainer.layer.borderColor  = UIColor(red: 229/255, green: 231/255, blue: 235/255, alpha: 1.0).cgColor
        calendarContainer.layer.masksToBounds = true
        contentView.addSubview(calendarContainer)

        calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.delegate   = self
        calendar.dataSource = self
        calendar.backgroundColor = .white
        calendar.scrollDirection = .horizontal
        calendar.scope           = .month

        calendar.appearance.headerTitleColor        = .black
        calendar.appearance.headerTitleFont         = UIFont.systemFont(ofSize: 17, weight: .semibold)
        calendar.appearance.headerDateFormat        = "MMMM yyyy"
        calendar.appearance.headerMinimumDissolvedAlpha = 0

        calendar.appearance.weekdayTextColor = UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1.0)
        calendar.appearance.weekdayFont      = UIFont.systemFont(ofSize: 14, weight: .medium)

        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleFont         = UIFont.systemFont(ofSize: 16, weight: .medium)
        calendar.appearance.todayColor        = .clear
        calendar.appearance.titleTodayColor   = .black
        calendar.appearance.selectionColor    = .clear
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.borderRadius      = 1.0

        calendar.appearance.eventOffset = CGPoint(x: 0, y: 3)

        calendar.placeholderType = .none

        calendarContainer.addSubview(calendar)

        NSLayoutConstraint.activate([
            calendarContainer.topAnchor.constraint(equalTo: Collectionview.bottomAnchor, constant: calendarTopSpace),
            calendarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sideInset),
            calendarContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sideInset),
            calendarContainer.heightAnchor.constraint(equalToConstant: calendarHeight),

            calendar.topAnchor.constraint(equalTo: calendarContainer.topAnchor, constant: 8),
            calendar.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor, constant: 8),
            calendar.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor, constant: -8),
            calendar.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - ✅ Quick Navigation Setup
    private func setupQuickNavigation() {
        guard let cv2 = Collectionview2 else { return }

        quickNavTitleLabel = UILabel()
        quickNavTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        quickNavTitleLabel.text = "Quick Navigation"
        quickNavTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        quickNavTitleLabel.textColor = .black
        contentView.addSubview(quickNavTitleLabel)

        cv2.delegate   = self
        cv2.dataSource = self
        cv2.backgroundColor = .clear
        cv2.showsHorizontalScrollIndicator = false
        cv2.isScrollEnabled = false
        cv2.bounces         = false
        cv2.translatesAutoresizingMaskIntoConstraints = false

        cv2.register(
            UINib(nibName: "ATDNCmultitypeattendanceCLVCLL", bundle: nil),
            forCellWithReuseIdentifier: "ATDNCmultitypeattendanceCLVCLL"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .horizontal
        layout.minimumLineSpacing      = quickNavSpacing
        layout.minimumInteritemSpacing = quickNavSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        cv2.collectionViewLayout = layout

        if cv2.superview == nil {
            contentView.addSubview(cv2)
        }

        NSLayoutConstraint.activate([
            quickNavTitleLabel.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: quickNavTitleTopSpace),
            quickNavTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sideInset),
            quickNavTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sideInset),
            quickNavTitleLabel.heightAnchor.constraint(equalToConstant: quickNavTitleHeight),

            cv2.topAnchor.constraint(equalTo: quickNavTitleLabel.bottomAnchor, constant: quickNavTopSpace),
            cv2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cv2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cv2.heightAnchor.constraint(equalToConstant: quickNavSectionHeight)
        ])

        cv2.reloadData()
    }

    // MARK: - ✅ NEW: Recent Attendance Setup
    private func setupRecentAttendance() {
        guard let cv3 = Collectionview3 else { return }

        // ── Title "Recent Attendance" ─────────────────────────────────────
        recentAttendanceTitleLabel = UILabel()
        recentAttendanceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recentAttendanceTitleLabel.text = "Recent Attendance"
        recentAttendanceTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        recentAttendanceTitleLabel.textColor = .black
        contentView.addSubview(recentAttendanceTitleLabel)

      
        // ── Container (rounded, bordered card) ────────────────────────────
        recentAttendanceContainer = UIView()
        recentAttendanceContainer.translatesAutoresizingMaskIntoConstraints = false
        recentAttendanceContainer.backgroundColor = .white
        recentAttendanceContainer.layer.cornerRadius = 12
        recentAttendanceContainer.layer.borderWidth = 1
        recentAttendanceContainer.layer.borderColor = UIColor(red: 229/255, green: 231/255, blue: 235/255, alpha: 1.0).cgColor
        recentAttendanceContainer.layer.masksToBounds = true
        contentView.addSubview(recentAttendanceContainer)

        // ── CollectionView3 Setup ─────────────────────────────────────────
        cv3.delegate   = self
        cv3.dataSource = self
        cv3.backgroundColor = .clear
        cv3.showsVerticalScrollIndicator = false
        cv3.isScrollEnabled = false
        cv3.bounces        = false
        cv3.translatesAutoresizingMaskIntoConstraints = false

        // ✅ Register the Recent Attendance cell
        cv3.register(
            UINib(nibName: "ATDNCattendanceCLVCLL", bundle: nil),
            forCellWithReuseIdentifier: "ATDNCattendanceCLVCLL"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .vertical
        layout.minimumLineSpacing      = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset            = .zero
        cv3.collectionViewLayout       = layout

        // Add cv3 into container
        recentAttendanceContainer.addSubview(cv3)

        // ── Constraints ────────────────────────────────────────────────────
        recentAttendanceHeightConstraint = recentAttendanceContainer.heightAnchor.constraint(
            equalToConstant: CGFloat(recentAttendance.count) * recentAttendanceRowHeight
        )

        NSLayoutConstraint.activate([
            // Title
            recentAttendanceTitleLabel.topAnchor.constraint(equalTo: Collectionview2.bottomAnchor, constant: recentAttendanceTitleTopSpace),
            recentAttendanceTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sideInset),
            recentAttendanceTitleLabel.heightAnchor.constraint(equalToConstant: recentAttendanceTitleHeight),

         
            // Container (rounded card)
            recentAttendanceContainer.topAnchor.constraint(equalTo: recentAttendanceTitleLabel.bottomAnchor, constant: recentAttendanceTopSpace),
            recentAttendanceContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sideInset),
            recentAttendanceContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sideInset),
            recentAttendanceHeightConstraint,

            // CollectionView3 fills container
            cv3.topAnchor.constraint(equalTo: recentAttendanceContainer.topAnchor),
            cv3.leadingAnchor.constraint(equalTo: recentAttendanceContainer.leadingAnchor),
            cv3.trailingAnchor.constraint(equalTo: recentAttendanceContainer.trailingAnchor),
            cv3.bottomAnchor.constraint(equalTo: recentAttendanceContainer.bottomAnchor)
        ])

        cv3.reloadData()
    }

    // MARK: - ✅ Dynamic height update for Recent Attendance
    private func updateRecentAttendanceHeight() {
        let height = CGFloat(recentAttendance.count) * recentAttendanceRowHeight
        recentAttendanceHeightConstraint.constant = height
        contentView.layoutIfNeeded()
    }

    // MARK: - Helper: status for a date
    private func status(for date: Date) -> AttendanceStatus? {
        let key = dateFormatter.string(from: date)
        return attendanceData[key]
    }

    // MARK: - Update with API data (call from VC later)
    func configure(present: Int, absent: Int, leave: Int, attendancePercent: Int) {
        stats[0].value = "\(present)"
        stats[1].value = "\(absent)"
        stats[2].value = "\(leave)"
        stats[3].value = "\(attendancePercent)%"
        Collectionview?.reloadData()
    }

    // MARK: - ✅ Update calendar with API attendance data (call from VC later)
    func configureCalendar(with data: [String: AttendanceStatus]) {
        attendanceData = data
        calendar?.reloadData()
    }

    // MARK: - ✅ NEW: Update Recent Attendance from API (call from VC later)
    /// Call this to refresh recent attendance rows with API data
    func configureRecentAttendance(with items: [RecentAttendance]) {
        recentAttendance = items
        Collectionview3?.reloadData()
        updateRecentAttendanceHeight()

        // ✅ Notify tableview so it can recalculate row height
        if let tv = self.superview as? UITableView {
            tv.beginUpdates()
            tv.endUpdates()
        }
    }

    // MARK: - ✅ Total content height (helps parent VC set row height dynamically)
    func totalContentHeight() -> CGFloat {
        // top collectionview area (60) + calendarTopSpace(16) + calendar(426)
        // + quickNav title top(16) + title(24) + quickNav top(16) + quickNav section(92)
        // + recentAtt title top(16) + recentAtt title(24) + recentAtt top(12)
        // + recentAtt container(dynamic) + bottom breathing (16)
        let recentHeight = CGFloat(recentAttendance.count) * recentAttendanceRowHeight
        let total: CGFloat = 60 + calendarTopSpace + calendarHeight
                             + quickNavTitleTopSpace + quickNavTitleHeight + quickNavTopSpace + quickNavSectionHeight
                             + recentAttendanceTitleTopSpace + recentAttendanceTitleHeight + recentAttendanceTopSpace
                             + recentHeight + 16
        return total
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ATDNCdashboardUITableViewCell1: UICollectionViewDataSource,
                                          UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == Collectionview2 {
            return quickNavItems.count
        }
        if collectionView == Collectionview3 {
            return recentAttendance.count
        }
        return stats.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // ✅ Quick Navigation cell
        if collectionView == Collectionview2 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ATDNCmultitypeattendanceCLVCLL",
                for: indexPath
            ) as! ATDNCmultitypeattendanceCLVCLL

            let item = quickNavItems[indexPath.item]

            cell.Backgroundview.backgroundColor = item.backgroundColor
            cell.Backgroundview.layer.cornerRadius = 16
            cell.Backgroundview.layer.masksToBounds = true

            cell.Imageview.image = UIImage(named: item.imageName)
            cell.Imageview.contentMode = .scaleAspectFit

            cell.TitleLbl.text = item.title
            cell.TitleLbl.numberOfLines = 2
            cell.TitleLbl.textAlignment = .center
            cell.TitleLbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            cell.TitleLbl.textColor = .black

            return cell
        }

        // ✅ Recent Attendance cell (Collectionview3)
        if collectionView == Collectionview3 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ATDNCattendanceCLVCLL",
                for: indexPath
            ) as! ATDNCattendanceCLVCLL

            let item = recentAttendance[indexPath.item]

            // Date label
            cell.DateLbl.text = item.dateText
            cell.DateLbl.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            cell.DateLbl.textColor = .black

            // Status label with colored dot (using attributed text)
            let statusColor = item.status.dotColor
            let statusText  = item.status.displayText

            let attrText = NSMutableAttributedString(
                string: "\(statusText)  ",
                attributes: [
                    .foregroundColor: statusColor,
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium)
                ]
            )
            // colored dot
            let dotAttachment = NSTextAttachment()
            let dotSize: CGFloat = 8
            let dotImage = UIGraphicsImageRenderer(size: CGSize(width: dotSize, height: dotSize)).image { ctx in
                statusColor.setFill()
                UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: dotSize, height: dotSize)).fill()
            }
            dotAttachment.image = dotImage
            dotAttachment.bounds = CGRect(x: 0, y: -1, width: dotSize, height: dotSize)
            attrText.append(NSAttributedString(attachment: dotAttachment))
            cell.AttendancestatusLbl.attributedText = attrText
            cell.AttendancestatusLbl.textAlignment = .right

            // Backgroundview (row bottom separator except last row)
            cell.Backgroundview.backgroundColor = .white
            // Remove existing sublayers to avoid stacking on reuse
            cell.Backgroundview.layer.sublayers?.removeAll(where: { $0.name == "bottomSeparator" })

            if indexPath.item < recentAttendance.count - 1 {
                let separator = CALayer()
                separator.name = "bottomSeparator"
                separator.backgroundColor = UIColor(red: 229/255, green: 231/255, blue: 235/255, alpha: 1.0).cgColor
                separator.frame = CGRect(
                    x: 16,
                    y: recentAttendanceRowHeight - 1,
                    width: collectionView.bounds.width - 32,
                    height: 1
                )
                cell.Backgroundview.layer.addSublayer(separator)
            }

            return cell
        }

        // ✅ Top stat cards
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ATDNCattendanceCollectionViewCell",
            for: indexPath
        ) as! ATDNCattendanceCollectionViewCell

        let stat = stats[indexPath.item]
        cell.configure(
            title:           stat.title,
            value:           stat.value,
            backgroundColor: stat.backgroundColor,
            borderColor:     stat.borderColor,
            textColor:       stat.textColor
        )
        return cell
    }

    // MARK: - Dynamic width per collection view
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        // ✅ Quick Navigation: fixed 80 × 92
        if collectionView == Collectionview2 {
            return CGSize(width: quickNavCellWidth, height: quickNavCellHeight)
        }

        // ✅ Recent Attendance: full width × 52
        if collectionView == Collectionview3 {
            return CGSize(width: collectionView.bounds.width, height: recentAttendanceRowHeight)
        }

        // ✅ Top stat cards: dynamic width fills row
        let cardCount: CGFloat    = CGFloat(stats.count)
        let totalSpacing: CGFloat = cardSpacing * (cardCount - 1)
        let totalInsets: CGFloat  = sideInset * 2

        let availableWidth = collectionView.bounds.width - totalSpacing - totalInsets
        let cardWidth = floor(availableWidth / cardCount)

        return CGSize(width: cardWidth, height: cardHeight)
    }
}

// MARK: - ✅ FSCalendar Delegate, DataSource & Appearance
extension ATDNCdashboardUITableViewCell1: FSCalendarDelegate,
                                          FSCalendarDataSource,
                                          FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  fillDefaultColorFor date: Date) -> UIColor? {
        return status(for: date)?.fillColor
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  titleDefaultColorFor date: Date) -> UIColor? {
        return status(for: date)?.dotColor ?? .black
    }

    func calendar(_ calendar: FSCalendar,
                  numberOfEventsFor date: Date) -> Int {
        return status(for: date) != nil ? 1 : 0
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  eventDefaultColorsFor date: Date) -> [UIColor]? {
        guard let s = status(for: date) else { return nil }
        return [s.dotColor]
    }

    func calendar(_ calendar: FSCalendar,
                  shouldSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) -> Bool {
        return false
    }
}

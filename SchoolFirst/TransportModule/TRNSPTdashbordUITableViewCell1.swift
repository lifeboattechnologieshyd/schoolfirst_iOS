//
//  TRNSPTdashbordUITableViewCell1.swift
//  SchoolFirst
//

import UIKit

// MARK: - Delegate Protocol for Navigation
protocol TRNSPTdashbordCell1Delegate: AnyObject {
    func didTapLiveTracking()
    func didTapDriverContact()
    func didTapFeeModule()
    func didTapPickupandDrop()
}

class TRNSPTdashbordUITableViewCell1: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var StudentgradeLbl: UILabel!
    @IBOutlet weak var StudentnameLbl: UILabel!
    @IBOutlet weak var CollectionView2: UICollectionView!   // Today's Journey list
    @IBOutlet weak var CollectionView: UICollectionView!    // Top module cards

    // MARK: - Delegate
    weak var delegate: TRNSPTdashbordCell1Delegate?

    // MARK: - Layout Constants (Top cards)
    private let cardSpacing: CGFloat   = 12   // gap between cards
    private let sideInset: CGFloat     = 16   // leading & trailing — MUST be equal
    private let cardHeight: CGFloat    = 120

    // MARK: - Transport Item Model (Top cards)
    private struct TransportItem {
        let title: String
        let description: String
        let imageName: String
        let backgroundColor: UIColor
        let iconTintColor: UIColor
    }

    private let items: [TransportItem] = [
        TransportItem(
            title: "Live\nTracking",
            description: "Track bus live",
            imageName: "icon 42",
            backgroundColor: UIColor(red: 210/255, green: 232/255, blue: 220/255, alpha: 1.0),
            iconTintColor:   UIColor(red:  46/255, green: 139/255, blue:  87/255, alpha: 1.0)
        ),
        TransportItem(
            title: "Driver\nContact",
            description: "Call or message",
            imageName: "icon 43",
            backgroundColor: UIColor(red: 230/255, green: 230/255, blue: 235/255, alpha: 1.0),
            iconTintColor:   UIColor(red: 230/255, green: 120/255, blue:  40/255, alpha: 1.0)
        ),
        TransportItem(
            title: "Fee\nModule",
            description: "Manage Payments",
            imageName: "icon 44",
            backgroundColor: UIColor(red: 225/255, green: 220/255, blue: 245/255, alpha: 1.0),
            iconTintColor:   UIColor(red: 170/255, green: 110/255, blue: 200/255, alpha: 1.0)
        ),
        TransportItem(
            title: "Pickup&Drop\nDetails",
            description: "View timings",
            imageName: "icon 45",
            backgroundColor: UIColor(red: 232/255, green: 225/255, blue: 245/255, alpha: 1.0),
            iconTintColor:   UIColor(red: 220/255, green:  80/255, blue: 150/255, alpha: 1.0)
        )
    ]

    // MARK: - Today's Journey Model
    private struct JourneyItem {
        let title: String
        let time: String
        let location: String
        let imageName: String
        let iconTintColor: UIColor
        let iconBackgroundColor: UIColor
    }

    private let journeyItems: [JourneyItem] = [
        JourneyItem(
            title: "Pickup",
            time: "07:30 AM",
            location: "Green Park Layout",
            imageName: "icon 47",
            iconTintColor:       UIColor(red:  22/255, green: 163/255, blue:  74/255, alpha: 1.0),
            iconBackgroundColor: UIColor(red: 220/255, green: 252/255, blue: 231/255, alpha: 1.0)
        ),
        JourneyItem(
            title: "On Route",
            time: "07:50 AM",
            location: "Towards Springdale School",
            imageName: "icon 48",
            iconTintColor:       UIColor(red:  22/255, green: 163/255, blue:  74/255, alpha: 1.0),
            iconBackgroundColor: UIColor(red: 220/255, green: 252/255, blue: 231/255, alpha: 1.0)
        ),
        JourneyItem(
            title: "School",
            time: "08:20 AM",
            location: "Springdale International School",
            imageName: "icon 49",
            iconTintColor:       UIColor(red:  37/255, green:  99/255, blue: 235/255, alpha: 1.0),
            iconBackgroundColor: UIColor(red: 219/255, green: 234/255, blue: 254/255, alpha: 1.0)
        )
    ]

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        StudentnameLbl.text = UserManager.shared.resolvedStudentName
        StudentgradeLbl.text   = UserManager.shared.resolvedGradeSection
        
        selectionStyle = .none

        // ── DEBUG ─────────────────────────────────────────────────────────
        print("🔍 CollectionView  :", CollectionView  == nil ? "❌ NIL" : "✅ connected")
        print("🔍 CollectionView2 :", CollectionView2 == nil ? "❌ NIL" : "✅ connected")

        setupTopCollectionView()
        setupJourneyCollectionView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // ✅ Frame is final here — recalc card sizes so leading/trailing match
        CollectionView?.collectionViewLayout.invalidateLayout()
        CollectionView2?.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Top CollectionView Setup
    private func setupTopCollectionView() {
        guard let cv = CollectionView else { return }

        cv.delegate   = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false   // ✅ no scroll — all 4 fit
        cv.bounces         = false
        cv.tag = 1

        cv.register(
            UINib(nibName: "TRNSPTdashbordCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TRNSPTdashbordCollectionViewCell"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .horizontal
        layout.minimumLineSpacing      = cardSpacing
        layout.minimumInteritemSpacing = cardSpacing
        // ✅ Equal insets — itemSize handled in sizeForItemAt (dynamic)
        layout.sectionInset = UIEdgeInsets(top: 8, left: sideInset, bottom: 8, right: sideInset)
        cv.collectionViewLayout = layout

        cv.reloadData()
    }

    // MARK: - Journey CollectionView Setup
    private func setupJourneyCollectionView() {
        guard let cv = CollectionView2 else { return }

        cv.delegate   = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.bounces         = false
        cv.tag = 2

        cv.register(
            UINib(nibName: "TRNSPTTodayJourneyCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TRNSPTTodayJourneyCollectionViewCell"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .vertical
        layout.minimumLineSpacing      = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset            = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        cv.collectionViewLayout        = layout

        cv.reloadData()
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension TRNSPTdashbordUITableViewCell1: UICollectionViewDataSource,
                                          UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 2 {
            return journeyItems.count
        }
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // ── Journey Cell (CollectionView2) ────────────────────────────────
        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TRNSPTTodayJourneyCollectionViewCell",
                for: indexPath
            ) as! TRNSPTTodayJourneyCollectionViewCell

            let item = journeyItems[indexPath.item]
            cell.configure(
                title:            item.title,
                time:             item.time,
                location:         item.location,
                imageName:        item.imageName,
                iconTint:         item.iconTintColor,
                iconBackground:   item.iconBackgroundColor
            )
            return cell
        }

        // ── Top Module Cell (CollectionView) ──────────────────────────────
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TRNSPTdashbordCollectionViewCell",
            for: indexPath
        ) as! TRNSPTdashbordCollectionViewCell

        let item = items[indexPath.item]
        cell.configure(
            title:           item.title,
            description:     item.description,
            imageName:       item.imageName,
            backgroundColor: item.backgroundColor,
            iconTint:        item.iconTintColor
        )
        return cell
    }

    // MARK: - ✅ Dynamic Size (fixes unequal leading/trailing)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView.tag == 2 {
            return CGSize(width: collectionView.bounds.width, height: 48)
        }

        // ✅ 4 cards exactly fill width:
        // total = (cardWidth × 4) + (spacing × 3) + leftInset + rightInset
        let cardCount: CGFloat    = CGFloat(items.count)          // 4
        let totalSpacing: CGFloat = cardSpacing * (cardCount - 1) // 12 × 3 = 36
        let totalInsets: CGFloat  = sideInset * 2                 // 16 + 16 = 32

        let availableWidth = collectionView.bounds.width - totalSpacing - totalInsets
        let cardWidth = floor(availableWidth / cardCount)

        return CGSize(width: cardWidth, height: cardHeight)
    }

    // MARK: - didSelectItemAt (Navigation via Delegate)
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        // ── Journey CollectionView taps ───────────────────────────────────
        if collectionView.tag == 2 {
            print("🛣️ Journey selected: \(journeyItems[indexPath.item].title)")
            return
        }

        // ── Top Module CollectionView taps ────────────────────────────────
        let selectedTitle = items[indexPath.item].title
        print("🚌 Module selected: \(selectedTitle)")

        switch selectedTitle {
        case "Live\nTracking":
            print("📍 Navigating to BuslivetrackingVC")
            delegate?.didTapLiveTracking()

        case "Fee\nModule":
            print("📍 Navigating to TRSPRTfeepaymentVC")
            delegate?.didTapFeeModule()

        case "Driver\nContact":
            print("📞 Navigating to TRSPRTcantactdriverVC")
            delegate?.didTapDriverContact()

        case "Pickup&Drop\nDetails":
            print("Navigating to TRSPRTpickupanddropVC")
            delegate?.didTapPickupandDrop()

        default:
            break
        }
    }
}

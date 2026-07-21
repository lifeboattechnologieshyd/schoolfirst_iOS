//
//  PTMhomeTableViewCell1TableViewCell2.swift
//  SchoolFirst
//

import UIKit

class PTMhomeTableViewCell1TableViewCell2: UITableViewCell {

    @IBOutlet weak var collectionview: UICollectionView!

    // ── NEW: Height constraint outlet (connect from Storyboard/XIB) ──
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    // ── Holds real completed meetings ──
    var meetingsData: [PTMCompletedMeeting] = []

    // ── Constants for height calculation ──
    private let itemHeight: CGFloat = 81       // must match sizeForItemAt
    private let itemSpacing: CGFloat = 1       // must match minimumLineSpacing
    private let emptyStateHeight: CGFloat = 81 // when no data → show 1 empty cell

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        applyFigmaStyling()
    }

    private func setupCollectionView() {
        let nib = UINib(
            nibName: "PTMcompletedmeetingsCollectionViewCell",
            bundle: nil
        )

        collectionview.register(
            nib,
            forCellWithReuseIdentifier: "PTMcompletedmeetingsCollectionViewCell"
        )

        collectionview.delegate = self
        collectionview.dataSource = self

        if let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = itemSpacing
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        collectionview.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        collectionview.showsVerticalScrollIndicator = false

        // ── Disable scrolling — table cell height will grow instead ──
        collectionview.isScrollEnabled = false
    }

    private func applyFigmaStyling() {
        collectionview.layer.cornerRadius = 12
        collectionview.layer.borderWidth = 1.0
        collectionview.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        collectionview.clipsToBounds = true

        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
    }

    // ── Configure ──
    func configure(with data: [PTMCompletedMeeting]) {
        meetingsData = data
        collectionview.reloadData()

        // ── Update dynamic height ──
        updateCollectionViewHeight()

        print("📋 PTMhomeTableViewCell1TableViewCell2 configure() → \(data.count) completed meetings")
        print("   → New CV height:", collectionViewHeightConstraint?.constant ?? 0)
    }

    // MARK: - Dynamic Height Calculation
    private func updateCollectionViewHeight() {

        let itemCount   = max(meetingsData.count, 1) // at least 1 empty cell
        let totalHeight = (CGFloat(itemCount) * itemHeight) + (CGFloat(itemCount - 1) * itemSpacing)

        // Update constraint (if connected)
        collectionViewHeightConstraint?.constant = totalHeight

        // Also invalidate layout so cells re-render properly
        collectionview.collectionViewLayout.invalidateLayout()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    /// Public helper — call from parent VC to know total cell height
    func requiredHeight() -> CGFloat {
        let itemCount   = max(meetingsData.count, 1)
        let totalHeight = (CGFloat(itemCount) * itemHeight) + (CGFloat(itemCount - 1) * itemSpacing)

        // Add padding for top/bottom breathing space in the tableview cell
        let verticalPadding: CGFloat = 40
        return totalHeight + verticalPadding
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - CollectionView Extension

extension PTMhomeTableViewCell1TableViewCell2: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(meetingsData.count, 1)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PTMcompletedmeetingsCollectionViewCell",
            for: indexPath
        ) as! PTMcompletedmeetingsCollectionViewCell

        cell.backgroundColor = .white

        if meetingsData.isEmpty {
            cell.configureEmpty()
        } else if indexPath.item < meetingsData.count {
            let meeting = meetingsData[indexPath.item]
            cell.configure(with: meeting)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: itemHeight)
    }
}

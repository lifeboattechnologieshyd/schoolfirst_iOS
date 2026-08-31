//
//  PTMhomeTableViewCell1TableViewCell2.swift
//  SchoolFirst
//

import UIKit

class PTMhomeTableViewCell1TableViewCell2: UITableViewCell {

    @IBOutlet weak var collectionview: UICollectionView!

    // ── Height constraint outlet (connected from Storyboard/XIB) ──
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    // ── Holds real completed meetings ──
    var meetingsData: [PTMCompletedMeeting] = []

    // ── Constants for height calculation ──
    private let itemHeight: CGFloat = 81       // must match sizeForItemAt
    private let itemSpacing: CGFloat = 1       // must match minimumLineSpacing

    // ── Programmatic Placeholder Label for Empty State ──
    private let noMeetingsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No completed meetings"
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        setupPlaceholderLabel()
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

    private func setupPlaceholderLabel() {
        contentView.addSubview(noMeetingsLabel)
        NSLayoutConstraint.activate([
            noMeetingsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            // Pushes the label down by 55 points so it sits beautifully below the "Completed Meetings" title
            noMeetingsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 55),
            noMeetingsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            noMeetingsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
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

        if data.isEmpty {
            collectionview.isHidden = true
            noMeetingsLabel.isHidden = false
            
            // Disable background card borders & shadows when empty for a clean layout
            collectionview.layer.borderWidth = 0
            self.layer.shadowOpacity = 0
            
            collectionViewHeightConstraint?.constant = 40
        } else {
            collectionview.isHidden = false
            noMeetingsLabel.isHidden = true
            
            // Restore original borders & shadows
            collectionview.layer.borderWidth = 1.0
            self.layer.shadowOpacity = 0.2
            
            collectionview.reloadData()
            updateCollectionViewHeight()
        }

        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        print("📋 PTMhomeTableViewCell1TableViewCell2 configure() → \(data.count) completed meetings")
        print("   → New CV height: \(collectionViewHeightConstraint?.constant ?? 0)")
    }

    // MARK: - Dynamic Height Calculation
    private func updateCollectionViewHeight() {
        let itemCount = meetingsData.count
        guard itemCount > 0 else {
            collectionViewHeightConstraint?.constant = 0
            return
        }
        
        let totalHeight = (CGFloat(itemCount) * itemHeight) + (CGFloat(itemCount - 1) * itemSpacing)

        // Update constraint
        collectionViewHeightConstraint?.constant = totalHeight

        // Invalidate layout so cells re-render correctly
        collectionview.collectionViewLayout.invalidateLayout()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    /// Public helper — call from parent VC to determine total cell height
    func requiredHeight() -> CGFloat {
        let itemCount = meetingsData.count
        if itemCount == 0 {
            return 100 // Increased from 80 to 100 to make room for the offset label
        }
        
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
        return meetingsData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PTMcompletedmeetingsCollectionViewCell",
            for: indexPath
        ) as! PTMcompletedmeetingsCollectionViewCell

        cell.backgroundColor = .white

        if indexPath.item < meetingsData.count {
            let meeting = meetingsData[indexPath.item]
            cell.configure(with: meeting)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: itemHeight)
    }
}

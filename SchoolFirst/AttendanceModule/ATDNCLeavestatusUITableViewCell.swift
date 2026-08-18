//
//  ATDNCLeavestatusUITableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 13/08/26.
//

import UIKit

class ATDNCLeavestatusUITableViewCell: UITableViewCell {

    @IBOutlet weak var Collectionview: UICollectionView!

    // MARK: - Data
    private let leaveData: [(title: String, days: String, color: UIColor)] = [
        ("Total Leaves", "12", UIColor(red: 234/255, green: 88/255, blue: 12/255, alpha: 1.0)),   // Orange
        ("Approved",     "08", UIColor(red: 22/255,  green: 128/255, blue: 61/255, alpha: 1.0)),  // Green
        ("Pending",      "02", UIColor(red: 234/255, green: 88/255, blue: 12/255, alpha: 1.0))    // Orange
    ]

    // Spacing between items
    private let itemSpacing: CGFloat = 4
    private let sectionInsetLeft: CGFloat = 0
    private let sectionInsetRight: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    // MARK: - CollectionView Setup
    private func setupCollectionView() {

        Collectionview.delegate = self
        Collectionview.dataSource = self

        Collectionview.register(
            UINib(nibName: "ATDNCLeavestatusCLVCLL", bundle: nil),
            forCellWithReuseIdentifier: "ATDNCLeavestatusCLVCLL"
        )

        if let layout = Collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = itemSpacing
            layout.minimumLineSpacing = itemSpacing
            layout.sectionInset = UIEdgeInsets(top: 0,
                                               left: sectionInsetLeft,
                                               bottom: 0,
                                               right: sectionInsetRight)
        }

        Collectionview.showsHorizontalScrollIndicator = false
        Collectionview.showsVerticalScrollIndicator = false
        Collectionview.backgroundColor = .clear
        Collectionview.isScrollEnabled = false   // No scrolling
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Force refresh layout so cells always fill correctly
        Collectionview.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - UICollectionViewDelegate
extension ATDNCLeavestatusUITableViewCell: UICollectionViewDelegate { }

// MARK: - UICollectionViewDataSource
extension ATDNCLeavestatusUITableViewCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return leaveData.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ATDNCLeavestatusCLVCLL",
            for: indexPath
        ) as! ATDNCLeavestatusCLVCLL

        let item = leaveData[indexPath.item]

        cell.leavestatustitle.text = item.title
        cell.NumberofdaysLbl.text = item.days
        cell.NumberofdaysLbl.textColor = item.color

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ATDNCLeavestatusUITableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalItems = CGFloat(leaveData.count)
        let totalSpacing = (itemSpacing * (totalItems - 1)) + sectionInsetLeft + sectionInsetRight
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / totalItems)

        let itemHeight = collectionView.bounds.height > 0 ? collectionView.bounds.height : 90

        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: sectionInsetLeft,
                            bottom: 0,
                            right: sectionInsetRight)
    }
}

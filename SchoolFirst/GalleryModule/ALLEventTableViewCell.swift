//
//  ALLEventTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/09/26.
//

import UIKit

class ALLEventTableViewCell: UITableViewCell {

    @IBOutlet weak var Allimagesgridcollectionview: UICollectionView!

    // Callback to GalleryhomeVC
    var onAlbumTapped: ((Int) -> Void)?

    private var albums: [(title: String, type: String, meta: String, imageName: String)] = [
        ("Science Exhibition 2026", "Academic", "62 photos • 08 Mar", "placeholder"),
        ("Annual Day 2025", "Events", "94 photos • 10 Dec", "placeholder"),
        ("Science Exhibition 2026", "Academic", "62 photos • 08 Mar", "placeholder"),
        ("Annual Day 2025", "Events", "94 photos • 10 Dec", "placeholder"),
        ("Sports Day 2026", "Sports", "48 photos • 15 Feb", "placeholder"),
        ("Campus Tour", "Campus", "30 photos • 01 Jan", "placeholder")
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCollectionView()
    }

    private func setupCollectionView() {
        Allimagesgridcollectionview.delegate = self
        Allimagesgridcollectionview.dataSource = self
        Allimagesgridcollectionview.backgroundColor = .clear
        Allimagesgridcollectionview.isScrollEnabled = false
        Allimagesgridcollectionview.showsVerticalScrollIndicator = false

        Allimagesgridcollectionview.register(
            UINib(nibName: "AllimagesCLVCell", bundle: nil),
            forCellWithReuseIdentifier: "AllimagesCLVCell"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        Allimagesgridcollectionview.collectionViewLayout = layout
    }

    func configure(with data: [(title: String, type: String, meta: String, imageName: String)]) {
        self.albums = data
        Allimagesgridcollectionview.reloadData()
    }
}

// MARK: - UICollectionView
extension ALLEventTableViewCell: UICollectionViewDelegate,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AllimagesCLVCell",
            for: indexPath
        ) as! AllimagesCLVCell

        let item = albums[indexPath.item]
        cell.configure(
            title: item.title,
            eventType: item.type,
            dateText: item.meta,
            imageName: item.imageName
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInset: CGFloat = 16
        let interItemSpacing: CGFloat = 12
        let availableWidth = collectionView.bounds.width - (sectionInset * 2) - interItemSpacing
        let cellWidth = floor(availableWidth / 2)
        return CGSize(width: cellWidth, height: 172)
    }

    // ✅ TAP → Navigate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onAlbumTapped?(indexPath.item)
    }
}

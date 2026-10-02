//
//  SingleeventTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/09/26.
//

import UIKit

class SingleeventTableViewCell: UITableViewCell {

    @IBOutlet weak var NumberofAlbumsLabel: UILabel!
    @IBOutlet weak var YearLabel: UILabel!
    @IBOutlet weak var TypeofEventLabel: UILabel!
    @IBOutlet weak var Imagegridcollectionview: UICollectionView!

    // Callback to GalleryhomeVC
    var onAlbumTapped: ((Int) -> Void)?

    private var albums: [(title: String, subtitle: String, meta: String, badge: String)] = [
        ("Republic Day Celebration",
         "Flag hoisting, cultural programme and student parade.",
         "35 photos • 26 Jan 2026", "Events"),
        ("Annual Day 2025",
         "Performances, awards and a joyful finale from our annual celebration.",
         "84 photos • 10 videos • 10 Dec 2025", "Events"),
        ("Sports Day 2026",
         "Track, field and trophy ceremony highlights.",
         "48 photos • 4 videos • 15 Feb 2026", "Events"),
        ("Cultural Fest 2025",
         "Dance, music and art performances by students.",
         "62 photos • 8 videos • 05 Nov 2025", "Events")
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupCollectionView()
    }

    private func setupCollectionView() {
        Imagegridcollectionview.delegate = self
        Imagegridcollectionview.dataSource = self
        Imagegridcollectionview.backgroundColor = .clear
        Imagegridcollectionview.isScrollEnabled = false
        Imagegridcollectionview.showsVerticalScrollIndicator = false

        Imagegridcollectionview.register(
            UINib(nibName: "SingleeventCLVcell", bundle: nil),
            forCellWithReuseIdentifier: "SingleeventCLVcell"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        Imagegridcollectionview.collectionViewLayout = layout
    }

    func configure(category: String) {
        TypeofEventLabel.text = category
        NumberofAlbumsLabel.text = "\(albums.count) albums • 129 moments"
        YearLabel.text = "2025-26"
        Imagegridcollectionview.reloadData()
    }
}

// MARK: - UICollectionView
extension SingleeventTableViewCell: UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SingleeventCLVcell",
            for: indexPath
        ) as! SingleeventCLVcell

        let item = albums[indexPath.item]
        cell.configure(
            title: item.title,
            subtitle: item.subtitle,
            meta: item.meta,
            badge: item.badge
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 236)
    }

    // ✅ TAP → Navigate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onAlbumTapped?(indexPath.item)
    }
}

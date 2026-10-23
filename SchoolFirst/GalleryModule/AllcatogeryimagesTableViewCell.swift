//
//  AllcatogeryimagesTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/10/26.
//

import UIKit

class AllcatogeryimagesTableViewCell: UITableViewCell {

    @IBOutlet weak var Collectionview: UICollectionView!
    
    private var albums: [GalleryAlbum] = []
    var onAlbumTapped: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    private func setupCollectionView() {
        Collectionview.delegate = self
        Collectionview.dataSource = self
        Collectionview.register(UINib(nibName: "AllimagesCLVCell", bundle: nil), forCellWithReuseIdentifier: "AllimagesCLVCell")
        
        if let layout = Collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        }
    }
    
    func configure(with data: [GalleryAlbum]) {
        self.albums = data
        Collectionview.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension AllcatogeryimagesTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllimagesCLVCell", for: indexPath) as! AllimagesCLVCell
        let item = albums[indexPath.item]
        cell.configure(
            title: item.title,
            eventType: item.category?.name ?? "",
            dateText: item.metaText,
            imageURL: item.coverImageURL
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onAlbumTapped?(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalSpacing: CGFloat = 16 + 12 + 16
        let width = floor((collectionView.bounds.width - totalHorizontalSpacing) / 2)
        return CGSize(width: width, height: 175) // ✅ reduced from 220
    }
}

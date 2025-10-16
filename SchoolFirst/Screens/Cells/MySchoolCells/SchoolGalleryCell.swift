//
//  SchoolGalleryCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 13/09/25.

import UIKit

class SchoolGalleryCell: UITableViewCell {

    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var btnViewAll: UIButton!
    var gallery = [EventGallery]()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.colVw.register(UINib(nibName: "GalleryCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCollectionCell")
        colVw.delegate = self
        colVw.dataSource = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    @IBAction func onClickViewAll(_ sender: UIButton) {
        
    }
}

extension SchoolGalleryCell :  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionCell", for: indexPath) as! GalleryCollectionCell
        cell.config(gallery: self.gallery[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: colVw.frame.size.width * 0.6, height: 207)
    }
    
}

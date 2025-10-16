//
//  HomeCollectionViewCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 10/10/25.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    
    var names = [String]()
    var images = [String]()
    var onSelectModule: ((Int) -> Void)!

    
    @IBOutlet weak var colVw: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.colVw.register(UINib(nibName: "HomeViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeViewCell")
    }
    
    func config(name: [String], imageName: [String]) {
        self.names = name
        self.images = imageName
        
        self.colVw.delegate = self
        self.colVw.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeViewCell", for: indexPath) as! HomeViewCell
        cell.config(name: self.names[indexPath.row], imageName: self.images[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (colVw.frame.size.width-16)/3, height: (colVw.frame.size.width-16)/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onSelectModule(indexPath.row)
    }
}

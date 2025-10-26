//
//  AnnualDayViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 25/10/25.
//

import UIKit

class AnnualDayViewController: UIViewController {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var annualLbl: UILabel!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    var gallery : EventGallery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLbl.text = gallery.eventDate.convertTo()
        annualLbl.text = gallery.eventName
        
        topVw.addBottomShadow()
        
        colVw.delegate = self
        colVw.dataSource = self
        
        self.colVw.register(UINib(nibName: "AnnualCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AnnualCollectionViewCell")
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AnnualDayViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnualCollectionViewCell", for: indexPath) as! AnnualCollectionViewCell
        cell.imgVw.loadImage(url: self.gallery.images[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width-10)/2
        return CGSize(width: width, height: width*0.575)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

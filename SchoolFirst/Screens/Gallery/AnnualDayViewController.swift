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
    
    let numberOfItems = 10
    let imageName = "Annaual Day Celebrations"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.layer.shadowColor = UIColor.black.cgColor
        topVw.layer.shadowOpacity = 0.3
        topVw.layer.shadowOffset = CGSize(width: 0, height: 3)
        topVw.layer.shadowRadius = 4
        topVw.layer.masksToBounds = false
       
        
        colVw.delegate = self
        colVw.dataSource = self
        
         colVw.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "AnnualCollectionViewCell")
        
         backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AnnualDayViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colVw.dequeueReusableCell(withReuseIdentifier: "AnnualCollectionViewCell", for: indexPath)
        
        
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        cell.contentView.addSubview(imageView)
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 92)
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

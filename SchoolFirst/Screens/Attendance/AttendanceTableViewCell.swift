//
//  AttendanceTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 28/10/25.
//

import UIKit

class AttendanceTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var colVw: UICollectionView!

    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    override func awakeFromNib() {
        super.awakeFromNib()

        colVw.delegate = self
        colVw.dataSource = self

        colVw.register(UINib(nibName: "MonthCollectionCell", bundle: nil), forCellWithReuseIdentifier: "MonthCollectionCell")

         if let layout = colVw.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCollectionCell", for: indexPath) as! MonthCollectionCell
        cell.monthLbl.text = months[indexPath.item]
        cell.bgVw.layer.cornerRadius = 8
        cell.bgVw.backgroundColor = .systemGray5
        return cell
    }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 72
        let height: CGFloat = 32
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected month: \(months[indexPath.item])")
     }
}


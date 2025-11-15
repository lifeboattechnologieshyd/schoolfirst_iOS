//
//  FeePartPaymentVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit

class FeePartPaymentVC: UIViewController {
    
    @IBOutlet weak var bachButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var feesummaryButton: UIButton!
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var paynowButton: UIButton!
    
    let amountList = [
        "₹15,000 (75%)",
        "₹10,000 (50%)",
        "₹5,000 (25%)",
        "₹2,500 (12.5%)",
        "₹1,000 (5%)",
        "₹500 (2.5%)",
        "₹250 (1.25%)",
        "₹100 (0.5%)",
        "₹50 (0.25%)",
        "₹25 (0.12%)"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        
        bgVw.layer.shadowColor = UIColor.black.cgColor
        bgVw.layer.shadowOpacity = 0.15
        bgVw.layer.shadowOffset = CGSize(width: 0, height: 4)
        bgVw.layer.masksToBounds = false
        
        colVw.register(
            UINib(nibName: "AmountCell", bundle: nil),
            forCellWithReuseIdentifier: "AmountCell"
        )
        
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickFeeSummary(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "FeeSummaryVC"
        ) as! FeeSummaryVC
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension FeePartPaymentVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return amountList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AmountCell",
            for: indexPath
        ) as! AmountCell
        
        cell.amountLbl.text = amountList[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.width - 40) / 3
        return CGSize(width: width, height: 34)
    }
}

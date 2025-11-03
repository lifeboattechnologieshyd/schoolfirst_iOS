//
//  LeaveHistoryViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 01/11/25.
//

import UIKit

class LeaveHistoryViewController: UIViewController {
    
    @IBOutlet weak var monthsCollectionView: UICollectionView!
    @IBOutlet weak var shravVw: UIView!
    @IBOutlet weak var mainOneVw: UIView!
    @IBOutlet weak var mainFourView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var approveVw: UIView!
    @IBOutlet weak var pendingVw: UIView!
    @IBOutlet weak var mainThreeView: UIView!
    @IBOutlet weak var buttontwoVw: UIView!
    @IBOutlet weak var rejectedVw: UIView!
    @IBOutlet weak var buttonOneView: UIView!
    @IBOutlet weak var resubmitButton: UIButton!
    @IBOutlet weak var submitleaveButton: UIButton!
    @IBOutlet weak var maintwoView: UIView!
    @IBOutlet weak var abhiVw: UIView!
    @IBOutlet weak var topVw: UIView!
    
    let months = ["ALL", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                  "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow(shadowOpacity: 0.15, shadowRadius: 3, shadowHeight: 4)
         
        setupCollectionView()
        setupViews()
    }
    
    private func setupCollectionView() {
        monthsCollectionView.delegate = self
        monthsCollectionView.dataSource = self
        
        let nib = UINib(nibName: "MonthCell", bundle: nil)
        monthsCollectionView.register(nib, forCellWithReuseIdentifier: "MonthCell")
        
        if let layout = monthsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
        
        monthsCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupViews() {
        let mainViews = [mainOneVw, maintwoView, mainThreeView, mainFourView]
        for view in mainViews {
            view?.layer.cornerRadius = 10
            view?.layer.shadowColor = UIColor.black.cgColor
            view?.layer.shadowOpacity = 0.15
            view?.layer.shadowOffset = CGSize(width: 0, height: 2)
            view?.layer.shadowRadius = 4
            view?.layer.masksToBounds = false
        }
        
        let statusViews = [approveVw, pendingVw, rejectedVw]
        for view in statusViews {
            view?.layer.cornerRadius = 12
            view?.layer.masksToBounds = true
        }
        
        let buttonViews = [buttonOneView, buttontwoVw]
        for view in buttonViews {
            view?.layer.cornerRadius = 16
            view?.layer.masksToBounds = true
        }
        
        abhiVw.layer.cornerRadius = 25
        abhiVw.layer.borderWidth = 1
        abhiVw.layer.borderColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1).cgColor // #0B569A
        abhiVw.layer.masksToBounds = true
        
        shravVw.layer.cornerRadius = 25
        shravVw.layer.borderWidth = 1
        shravVw.layer.borderColor = UIColor(red: 203/255, green: 229/255, blue: 253/255, alpha: 1).cgColor // #CBE5FD
        shravVw.layer.masksToBounds = true
    }
    
 
    @IBAction func resubmitButtonTapped(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ReSubmitViewController") as? ReSubmitViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func submitLeaveButtonTapped(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SubmitLeaveViewController") as? SubmitLeaveViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension LeaveHistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath) as! MonthCell
        let isSelected = indexPath.item == selectedIndex
        cell.configure(with: months[indexPath.item], isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 72, height: 32)
    }
}

 

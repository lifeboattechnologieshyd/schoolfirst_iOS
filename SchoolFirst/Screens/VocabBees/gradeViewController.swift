//
//  gradeViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//
import UIKit
 
class gradeViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, GradeCellDelegate {
    
    
    @IBOutlet weak var topbarView: UIView!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    
    let cls = ["Nursery", "PP1", "PP2","Grade 1", "Grade 2", "Grade 3", "Grade 4", "Grade 5",
               "Grade 6", "Grade 7", "Grade 8", "Grade 9", "Grade 10"]
    
    let cellWidth: CGFloat = 156
    let cellHeight: CGFloat = 40
    let cellSpacing: CGFloat = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topbarView.layer.masksToBounds = false
        topbarView.layer.shadowColor = UIColor.black.cgColor
        topbarView.layer.shadowOpacity = 0.15
        topbarView.layer.shadowOffset = CGSize(width: 0, height: 3)
        topbarView.layer.shadowRadius = 4
        
        //  setup
        colVw.register(UINib(nibName: "gradeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "gradeCollectionViewCell")
        colVw.delegate = self
        colVw.dataSource = self
        
        
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gradeCollectionViewCell", for: indexPath) as! gradeCollectionViewCell
        cell.clsLabel.text = cls[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    // MARK: - FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalWidth = (cellWidth * 2) + cellSpacing
        let sideInset = max((collectionView.frame.width - totalWidth) / 2, cellSpacing)
        return UIEdgeInsets(top: 12, left: sideInset, bottom: 12, right: sideInset)
    }
    
    // MARK: - GradeCellDelegate
    func didTapNextButton(cell: gradeCollectionViewCell) {
        if let indexPath = colVw.indexPath(for: cell), indexPath.row == 4 {
            let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
            if let nextVC = storyboard.instantiateViewController(withIdentifier: "DateViewController") as? DateViewController {
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
     @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

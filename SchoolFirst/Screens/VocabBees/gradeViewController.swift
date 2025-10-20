//
//  gradeViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit

class gradeViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    
    @IBOutlet weak var colVw: UICollectionView!
     
     
         let cls = ["Nursery", "PP1", "PP2","Grade 1", "Grade 2", "Grade 3", "Grade 4", "Grade 5",
                      "Grade 6", "Grade 7", "Grade 8", "Grade 9", "Grade 10",
                       ]

    override func viewDidLoad() {
            super.viewDidLoad()
            
            colVw.register(UINib(nibName: "gradeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "gradeCollectionViewCell")
            colVw.delegate = self
            colVw.dataSource = self
            
            if let layout = colVw.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
                layout.minimumInteritemSpacing = 12 // horizontal gap
                layout.minimumLineSpacing = 12      // vertical gap
                layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            }
        }
        
        // MARK: DataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return cls.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gradeCollectionViewCell", for: indexPath) as! gradeCollectionViewCell
            cell.clsLabel.text = cls[indexPath.row]
            return cell
        }
        
        // MARK: Delegate
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("Selected grade: \(cls[indexPath.row])")
        }
        
        // MARK: FlowLayout
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // Calculate width for 2 cells per row with 12pt gap
            let totalSpacing: CGFloat = 12 + 12 + 12 // left + right + interitem
            let cellWidth = (collectionView.frame.width - totalSpacing) / 2
            let cellHeight: CGFloat = 40
            return CGSize(width: cellWidth, height: cellHeight)
        }
    }


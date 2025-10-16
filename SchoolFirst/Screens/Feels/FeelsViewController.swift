//
//  FeelsViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

class FeelsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var colVw: UICollectionView!
    
     var images: [UIImage] = [
        UIImage(named: "Feelsone")!,
        UIImage(named: "Feelstwo")!,
        UIImage(named: "Feelsthree")!,
        UIImage(named: "Feelsfour")!,
        UIImage(named: "Feelsone")!,
        UIImage(named: "Feelstwo")!,
        UIImage(named: "Feelsthree")!,
        UIImage(named: "Feelsfour")!
    ]
    
    var labels: [String] = [
        "Family First Calendar Day 1",
        "Family First Calendar Day 2",
        "Family First Calendar Day 3",
        "Family First Calendar Day 4",
        "Family First Calendar Day 5",
        "Family First Calendar Day 6",
        "Family First Calendar Day 7",
        "Family First Calendar Day 8"
    ]
    
    var likes: [Int] = [10, 5, 8, 2, 7, 3, 12, 9]
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            colVw.delegate = self
            colVw.dataSource = self
            
            colVw.register(UINib(nibName: "FeelsFirst", bundle: nil), forCellWithReuseIdentifier: "FeelsFirst")
            
            if let layout = colVw.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 10
                layout.minimumInteritemSpacing = 10
            }
        }
        
 
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return images.count / 2
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = colVw.dequeueReusableCell(withReuseIdentifier: "FeelsFirst", for: indexPath) as! FeelsFirst
            
            let firstIndex = indexPath.row * 2
            let secondIndex = firstIndex + 1
            
            cell.configureCell(
                imageOne: images[firstIndex],
                imageTwo: images[secondIndex],
                textOne: labels[firstIndex],
                textTwo: labels[secondIndex],
                likesOne: likes[firstIndex],
                likesTwo: likes[secondIndex]
            )
            
             cell.likeButtonOne.tag = firstIndex
            cell.likeButtonTwo.tag = secondIndex
            cell.playButton.tag = firstIndex
            cell.play1Button.tag = secondIndex
            
             cell.likeButtonOne.addTarget(self, action: #selector(likeTapped(_:)), for: .touchUpInside)
            cell.likeButtonTwo.addTarget(self, action: #selector(likeTapped(_:)), for: .touchUpInside)
            cell.playButton.addTarget(self, action: #selector(playTapped(_:)), for: .touchUpInside)
            cell.play1Button.addTarget(self, action: #selector(playTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        
 
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width
            let height = width / 2
            return CGSize(width: width, height: height)
        }
        
 
        @objc func likeTapped(_ sender: UIButton) {
            let index = sender.tag
            likes[index] += 1
            colVw.reloadData()
            print("Like tapped on image at index \(index)")
        }
        
        @objc func playTapped(_ sender: UIButton) {
            let index = sender.tag
            print("Play tapped on image at index \(index)")
         }
    }

//
//  AlphabetKeyboardView.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 30/10/25.
//

import Foundation
import UIKit

protocol AlphabetKeyboardDelegate: AnyObject {
    func didTapLetter(_ letter: String)
    func didTapDelete()
    func didTapSubmit()
}


@IBDesignable
class AlphabetKeyboardView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: AlphabetKeyboardDelegate?

//    private let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let allKeys = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }
    let extraKeys = ["Y", "Z", "⌫"]
    
    var rows: [[String]] {
        var result: [[String]] = []
        var index = 0
        
        // First 4 rows = 24 letters (6 each)
        for _ in 0..<4 {
            let row = Array(allKeys[index..<index+6])
            result.append(row)
            index += 6
        }
        // Last row = Y, Z, Delete
        result.append(extraKeys)
        return result
    }
    
    private let cellIdentifier = "KeyboardCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AlphabetKeyboardView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .clear
        addSubview(view)
        
        guard collectionView != nil else {
            print("collectionView outlet is nil — check XIB connection ⚠️")
            return
        }
        self.collectionView.register(UINib(nibName: "KeyboardCell", bundle: nil), forCellWithReuseIdentifier: "KeyboardCell")

        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // flow layout tweak
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    // helper to reload layout when bounds change (for rotations)
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
}

extension AlphabetKeyboardView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return letters.count + 2 // A-Z + delete + submit
        return rows[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? KeyboardCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: rows[indexPath.section][indexPath.item])

//        if indexPath.item < letters.count {
//            let letter = String(letters[indexPath.item])
//            cell.configure(text: letter,
//                           bgColor: UIColor(red: 175/255, green: 239/255, blue: 230/255, alpha: 1),
//                           textColor: .black)
//        } else if indexPath.item == letters.count {
//            cell.configure(text: "⌫",
//                           bgColor: UIColor(red: 50/255, green: 90/255, blue: 180/255, alpha: 1),
//                           textColor: .white)
//        } else {
//            cell.configure(text: "⏎",
//                           bgColor: UIColor(red: 50/255, green: 90/255, blue: 180/255, alpha: 1),
//                           textColor: .white)
//        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? KeyboardCell else { return }

        cell.animatePress()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let key = rows[indexPath.section][indexPath.item]
        if key == "⌫" {
            delegate?.didTapDelete()
        } else {
            delegate?.didTapLetter(String(key))
        }
    }


//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let columns: CGFloat = 6
//        let layout = collectionViewLayout as! UICollectionViewFlowLayout
//        let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + (columns - 1) * layout.minimumInteritemSpacing
//        let width = floor((collectionView.bounds.width - totalSpacing) / columns)
//        return CGSize(width: width, height: 55)
//    }
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {

          let totalWidth = collectionView.bounds.width
          let spacing: CGFloat = 6
          let keysInRow = CGFloat(6) // we want equal size keys always
          let availableWidth = totalWidth - (spacing * (keysInRow - 1))
          let width = floor(availableWidth / keysInRow)
          return CGSize(width: width, height: 44)
      }

      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets {

          let totalWidth = collectionView.bounds.width
          let spacing: CGFloat = 6
          let keysInRow = CGFloat(rows[section].count)
          let maxKeys = CGFloat(6)
          let keyWidth = floor((totalWidth - (spacing * (maxKeys - 1))) / maxKeys)
          let rowWidth = keyWidth * keysInRow + spacing * (keysInRow - 1)
          let inset = max((totalWidth - rowWidth) / 2, 0)

          return UIEdgeInsets(top: 6, left: inset, bottom: 6, right: inset)
      }

      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 8
      }

      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
          return 6
      }
}


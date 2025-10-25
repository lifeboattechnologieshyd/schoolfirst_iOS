//
//  FeelsFirst.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

class FeelsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    var playClicked: ((Int) -> Void)?

     
    
    @IBAction func onClickPlay(_ sender: UIButton) {
        self.playClicked!(sender.tag)
    }
    
}


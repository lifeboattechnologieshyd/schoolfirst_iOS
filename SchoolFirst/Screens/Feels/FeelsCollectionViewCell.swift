//
//  FeelsFirst.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

class FeelsCollectionViewCell: UICollectionViewCell {

     @IBOutlet weak var imgVwOne: UIImageView!
    @IBOutlet weak var imgVwTwo: UIImageView!
     @IBOutlet weak var lblOne: UILabel!
    @IBOutlet weak var numberButtonOne: UIButton!
    @IBOutlet weak var likeButtonTwo: UIButton!
    @IBOutlet weak var numberButtonTwo: UIButton!
    @IBOutlet weak var likeButtonOne: UIButton!
    @IBOutlet weak var lblTwo: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playButtonOne: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         imgVwOne.layer.cornerRadius = 8
        imgVwOne.clipsToBounds = true
        imgVwTwo.layer.cornerRadius = 8
        imgVwTwo.clipsToBounds = true
    }
    
     func configureCell(
        imageOne: UIImage?,
        imageTwo: UIImage?,
        textOne: String,
        textTwo: String,
        likesOne: Int,
        likesTwo: Int
    ) {
        imgVwOne.image = imageOne
        imgVwTwo.image = imageTwo
        
        lblOne.text = textOne
        lblTwo.text = textTwo
        
        numberButtonOne.setTitle("\(likesOne)", for: .normal)
        numberButtonTwo.setTitle("\(likesTwo)", for: .normal)
    }
}


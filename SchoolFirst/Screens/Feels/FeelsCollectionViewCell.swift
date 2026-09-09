//
//  FeelsCollectionViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

class FeelsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var NumberoflikeLbl: UILabel!
    @IBOutlet weak var LikeButton: UIButton!
    @IBOutlet weak var ShareButton: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    
    var playClicked: ((Int) -> Void)?
    var likeClicked: ((Int) -> Void)?
    var shareClicked: ((Int) -> Void)?   // ✅ NEW

    @IBAction func onClickPlay(_ sender: UIButton) {
        playClicked?(sender.tag)
    }

    @IBAction func onClickLike(_ sender: UIButton) {
        likeClicked?(sender.tag)
    }

    @IBAction func onClickShare(_ sender: UIButton) {
        shareClicked?(sender.tag)
    }
}

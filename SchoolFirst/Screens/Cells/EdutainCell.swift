//
//  EdutainCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 19/08/25.
//

import UIKit

class EdutainCell: UITableViewCell {
    
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    var likeClicked: ((Int) -> Void)?

    
    var arr = ["That’s awesome!", "This is Very useful!",
               "This is exactly what I needed!", "I learned something new!", "I already knew this!"]
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.colVw.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        colVw.collectionViewLayout = layout

        self.colVw.delegate = self
        self.colVw.dataSource = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setup(feed: Feed) {
        lblDescription.font = UIFont.lexend(.regular, size: 14)
        lblDescription.text = feed.description
        var time = "\(feed.approvedTime!.getTimeAgo()) | "

        if feed.duration > 0 {
            time += "\(feed.duration) | "
        }

        time += "\(feed.language)"
        lblTime.text = time
        lblTitle.text = feed.heading
        imgVw.loadImage(url: feed.image ?? "", placeHolderImage: "login_img")
        
        lblLikeCount.text = "\(feed.likesCount)"
    }
    
    
    @IBAction func onClickLogin(_ sender: UIButton) {
        likeClicked!(sender.tag)
    }
    
    
    
    
    
}

extension EdutainCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.lblText.text = arr[indexPath.row]
        return cell
    }
}

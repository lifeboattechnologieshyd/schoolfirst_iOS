//
//  EdutainCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 19/08/25.
//

import UIKit

extension UILabel {
    func padding(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        self.drawText(in: bounds.insetBy(dx: left, dy: top))
    }
}

class EdutainCell: UITableViewCell {
    
    @IBOutlet weak var subjectConceptStackView: UIStackView!
    @IBOutlet weak var lblSkillTested: UILabel!
    @IBOutlet weak var lblDescription2: UILabel!
    @IBOutlet weak var lblTopic: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
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
//        lblSubject.backgroundColor = UIColor(hex: "#DDD0FE")
//        lblTopic.backgroundColor = UIColor(hex: "#F7E0A8")
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
        
        // SUBJECT
          if let subject = feed.subject, !subject.isEmpty {
              lblSubject.isHidden = false
              lblSubject.text = subject
              lblSubject.backgroundColor = UIColor(hex: "#DDD0FE")
          } else {
              lblSubject.isHidden = true
          }

          // CONCEPT
          if let concept = feed.lesson, !concept.isEmpty {
              lblTopic.isHidden = false
              lblTopic.text = concept
              lblTopic.backgroundColor = UIColor(hex: "#F7E0A8")
          } else {
              lblTopic.isHidden = true
          }

        [lblSubject, lblTopic].forEach { label in
            label?.layer.cornerRadius = 8
            label?.layer.masksToBounds = true
            label?.setContentHuggingPriority(.required, for: .horizontal)
            label?.setContentCompressionResistancePriority(.required, for: .horizontal)
            label?.numberOfLines = 1
            label?.padding(left: 8, right: 8, top: 4, bottom: 4)
        }
          // Hide entire HStack if both are hidden
          subjectConceptStackView.isHidden =
        lblTopic.isHidden && lblTopic.isHidden
        
        if let sk = feed.skill_tested {
            self.lblSkillTested.text = sk
        }
        else {
            self.lblSkillTested.text = ""
        }
        lblDescription2.attributedText = NSAttributedString.fromHTML(feed.description_2 ?? "",
                                                                     regularFont: .lexend(.regular, size: 14),
                                                                     boldFont: .lexend(.semiBold, size: 14),
                                                                     italicFont: .lexend(.regular, size: 14),
                                                                     textColor: .black)
        
        lblDescription.font = UIFont.lexend(.regular, size: 14)
        lblDescription.attributedText = NSAttributedString.fromHTML(feed.description,
                                                                    regularFont: .lexend(.regular, size: 14),
                                                                    boldFont: .lexend(.semiBold, size: 14),
                                                                    italicFont: .lexend(.regular, size: 14),
                                                                    textColor: .black)
        lblTitle.attributedText = NSAttributedString.fromHTML(feed.heading,
                                                                    regularFont: .lexend(.semiBold, size: 14),
                                                                    boldFont: .lexend(.semiBold, size: 14),
                                                                    italicFont: .lexend(.regular, size: 14),
                                                                    textColor: .black)
        var time = "\(feed.approvedTime?.getTimeAgo() ?? "Just now") | "
        if feed.duration > 0 {
            time += "\(feed.duration) | "
        }
        time += "\(feed.language)"
        lblTime.text = time
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

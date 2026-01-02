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
    @IBOutlet weak var likeVw: UIView!
    @IBOutlet weak var whatsappBtn: UIButton!
    @IBOutlet weak var whatsappLbl: UILabel!
    @IBOutlet weak var shareLbl: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    
    // Callbacks
    var likeClicked: ((Int) -> Void)?
    var whatsappClicked: ((Int, Feed) -> Void)?
    var shareClicked: ((Int, Feed) -> Void)?
    
    // Track states
    var isLiked: Bool = false
    var currentLikeCount: Int = 0
    var currentWhatsappCount: Int = 0
    var currentShareCount: Int = 0
    var currentFeed: Feed?
    
    var arr = ["That's awesome!", "This is Very useful!",
               "This is exactly what I needed!", "I learned something new!", "I already knew this!"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        colVw.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        colVw.collectionViewLayout = layout
        colVw.showsHorizontalScrollIndicator = false
        
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isLiked = false
        currentLikeCount = 0
        currentWhatsappCount = 0
        currentShareCount = 0
        currentFeed = nil
        imgVw.image = nil
        lblLikeCount.text = "0"
        whatsappLbl.text = "0"
        shareLbl.text = "0"
    }
    
    func setup(feed: Feed) {
        // Store current feed
        currentFeed = feed
        
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
        
        subjectConceptStackView.isHidden = lblTopic.isHidden && lblSubject.isHidden
        
        // Skill Tested
        lblSkillTested.text = feed.skill_tested ?? ""
        
        // Description 2
        lblDescription2.attributedText = NSAttributedString.fromHTML(
            feed.description_2 ?? "",
            regularFont: .lexend(.regular, size: 14),
            boldFont: .lexend(.semiBold, size: 14),
            italicFont: .lexend(.regular, size: 14),
            textColor: .black
        )
        
        // Description
        lblDescription.font = UIFont.lexend(.regular, size: 14)
        lblDescription.attributedText = NSAttributedString.fromHTML(
            feed.description,
            regularFont: .lexend(.regular, size: 14),
            boldFont: .lexend(.semiBold, size: 14),
            italicFont: .lexend(.regular, size: 14),
            textColor: .black
        )
        
        // Title
        lblTitle.attributedText = NSAttributedString.fromHTML(
            feed.heading,
            regularFont: .lexend(.semiBold, size: 14),
            boldFont: .lexend(.semiBold, size: 14),
            italicFont: .lexend(.regular, size: 14),
            textColor: .black
        )
        
        // Time
        var time = "\(feed.approvedTime?.getTimeAgo() ?? "Just now") | "
        if feed.duration > 0 {
            time += "\(feed.duration) | "
        }
        time += "\(feed.language)"
        lblTime.text = time
        
        // Image
        imgVw.loadImage(url: feed.image ?? "", placeHolderImage: "login_img")
        
        // Like Count & State
        currentLikeCount = feed.likesCount
        isLiked = feed.isLiked
        lblLikeCount.text = "\(currentLikeCount)"
        updateLikeUI(isLiked: isLiked)
        
        // WhatsApp Share Count
        currentWhatsappCount = feed.whatsappShareCount
        whatsappLbl.text = "\(currentWhatsappCount)"
        
        // Share Count (if available in Feed model)
        currentShareCount = feed.shareCount ?? 0
        shareLbl.text = "\(currentShareCount)"
        
        // Reload collection view
        colVw.reloadData()
    }
    
    func updateLikeUI(isLiked: Bool) {
        if isLiked {
            imgLike.image = UIImage(named: "likefill")
            likeVw.backgroundColor = UIColor(hex: "#CDE9FA")
        } else {
            imgLike.image = UIImage(named: "like")
            likeVw.backgroundColor = UIColor(hex: "#F5F5F5")
        }
    }
    
    func toggleLike() {
        isLiked.toggle()
        
        if isLiked {
            currentLikeCount += 1
        } else {
            currentLikeCount = max(0, currentLikeCount - 1)
        }
        
        lblLikeCount.text = "\(currentLikeCount)"
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.imgLike.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.imgLike.transform = .identity
            }
        }
        
        updateLikeUI(isLiked: isLiked)
    }
    
    func updateWhatsappCount() {
        currentWhatsappCount += 1
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.whatsappLbl.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.whatsappLbl.transform = .identity
                self.whatsappLbl.text = "\(self.currentWhatsappCount)"
            }
        }
    }
    
    func updateShareCount() {
        currentShareCount += 1
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.shareLbl.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.shareLbl.transform = .identity
                self.shareLbl.text = "\(self.currentShareCount)"
            }
        }
    }
    
    func revertLike() {
        isLiked.toggle()
        
        if isLiked {
            currentLikeCount += 1
        } else {
            currentLikeCount = max(0, currentLikeCount - 1)
        }
        
        lblLikeCount.text = "\(currentLikeCount)"
        updateLikeUI(isLiked: isLiked)
    }
    
    // MARK: - Actions
    @IBAction func onClickLike(_ sender: UIButton) {
        toggleLike()
        likeClicked?(sender.tag)
    }
    
    @IBAction func onClickWhatsapp(_ sender: UIButton) {
        guard let feed = currentFeed else { return }
        whatsappClicked?(sender.tag, feed)
    }
    
    @IBAction func onClickShare(_ sender: UIButton) {
        guard let feed = currentFeed else { return }
        shareClicked?(sender.tag, feed)
    }
}

extension EdutainCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.lblText.text = arr[indexPath.row]
        return cell
    }
}

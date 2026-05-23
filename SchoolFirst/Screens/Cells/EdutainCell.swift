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
    @IBOutlet weak var commentBtn: UIButton!

    // Callbacks
    var likeClicked: ((Int) -> Void)?
    var whatsappClicked: ((Int, Feed) -> Void)?
    var shareClicked: ((Int, Feed) -> Void)?
    var commentClicked: ((Int, Feed) -> Void)?
    var tagClicked: ((Int, Feed, String) -> Void)?

    // Track states
    var isLiked: Bool = false
    var currentLikeCount: Int = 0
    var currentWhatsappCount: Int = 0
    var currentShareCount: Int = 0
    var currentFeed: Feed?
    var cellIndex: Int = 0
    var selectedTagIndex: Int? = nil
    var currentCommentCount: Int = 0

    var arr = ["That's awesome!", "This is Very useful!",
               "This is exactly what I needed!", "I learned something new!", "I already knew this!"]

    let tagFont = UIFont.systemFont(ofSize: 14)
   
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCollectionView()
    }

    private func setupCollectionView() {
        colVw.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        
        let layout = UICollectionViewFlowLayout()
          
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
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
        currentCommentCount = 0
        currentFeed = nil
        cellIndex = 0
        selectedTagIndex = nil
        imgVw.image = nil
        lblLikeCount.text = "0"
        whatsappLbl.text = "0"
        shareLbl.text = "0"
    }

    func setup(feed: Feed, index: Int = 0) {
        currentFeed = feed
        cellIndex = index
        selectedTagIndex = nil
        
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
        
        // Share Count
        currentShareCount = feed.shareCount ?? 0
        shareLbl.text = "\(currentShareCount)"
        
        // Comment Button Title
        currentCommentCount = feed.commentsCount
        setupCommentButton(count: currentCommentCount)
        
        // Reload collection view
        colVw.reloadData()
    }

    private func setupCommentButton(count: Int) {
        if count == 0 {
            commentBtn.setTitle("0 Comments", for: .normal)
        } else if count == 1 {
            commentBtn.setTitle("1 Comment", for: .normal)
        } else {
            commentBtn.setTitle("\(count) Comments", for: .normal)
        }
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
    
    func incrementCommentCount() {
        currentCommentCount += 1
        setupCommentButton(count: currentCommentCount)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.commentBtn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.commentBtn.transform = .identity
            }
        }
    }
    
    func resetTagSelection() {
        selectedTagIndex = nil
        colVw.reloadData()
    }

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

    @IBAction func onClickComment(_ sender: UIButton) {
        guard let feed = currentFeed else { return }
        commentClicked?(sender.tag, feed)
    }
}

// MARK: - CollectionView Delegate, DataSource & FlowLayout
extension EdutainCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.lblText.text = arr[indexPath.row]
        
        if selectedTagIndex == indexPath.row {
            cell.setSelected(true)
        } else {
            cell.setSelected(false)
        }
        
        return cell
    }
    
    // MARK: - DYNAMIC SIZE CALCULATION (THE FIX)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 1. Get the text for THIS specific cell
        let text = arr[indexPath.row]
        
        // 2. Calculate the width of THIS text using the font
        let fontAttributes = [NSAttributedString.Key.font: tagFont]
        let textSize = (text as NSString).size(withAttributes: fontAttributes)
        
        // 3. Add horizontal padding (Left 16 + Right 16 = 32) + small buffer
        let horizontalPadding: CGFloat = 32
        let buffer: CGFloat = 4 // Extra safety buffer
        let totalWidth = ceil(textSize.width) + horizontalPadding + buffer
        
        // 4. Fixed height for all cells (adjust as needed: 36, 40, 44)
        let height: CGFloat = 36
        
        // 5. Return the calculated size
        return CGSize(width: totalWidth, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let feed = currentFeed else { return }
        
        let selectedText = arr[indexPath.row]
        
        selectedTagIndex = indexPath.row
        collectionView.reloadData()
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCell {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                }
            }
        }
        
        tagClicked?(cellIndex, feed, selectedText)
    }
}

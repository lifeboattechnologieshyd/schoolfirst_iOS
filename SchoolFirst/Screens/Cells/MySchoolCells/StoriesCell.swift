////  StoriesCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 02/01/26.
//

import UIKit
import YouTubeiOSPlayerHelper

class StoriesCell: UITableViewCell {

    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var serialNo: UILabel!
    @IBOutlet weak var likeVw: UIView!
    @IBOutlet weak var shareBTn: UIButton!
    @IBOutlet weak var whatsappBtn: UIButton!
    @IBOutlet weak var whatsappLbl: UILabel!
    @IBOutlet weak var shareLbl: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var btnLike: UIButton!

    var playerView: YTPlayerView?
    var activityIndicator: UIActivityIndicatorView?
    var btnPlay: UIButton?
    var youtubeURL: String?

    var likeClicked: ((Int) -> Void)?
    var commentClicked: ((Int, Feed) -> Void)?
    var whatsappClicked: ((Int, Feed) -> Void)?
    var shareClicked: ((Int, Feed) -> Void)?
    var tagClicked: ((Int, Feed, String) -> Void)?
    var isLiked: Bool = false
    var currentLikeCount: Int = 0
    var currentWhatsappCount: Int = 0
    var currentShareCount: Int = 0
    var currentFeed: Feed?
    var cellIndex: Int = 0
    var selectedTagIndex: Int? = nil
    var currentCommentCount: Int = 0

    var arr = ["That's awesome!", "This is Very useful!", "This is exactly what I needed!", "I learned something new!", "I already knew this!"]

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        imgVw.isUserInteractionEnabled = true
        setupCollectionView()
        setupPlayButton()
    }

    func setupPlayButton() {
        btnPlay = UIButton(type: .custom)
        btnPlay?.translatesAutoresizingMaskIntoConstraints = false
        btnPlay?.setImage(UIImage(systemName: "play.circle.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 60)), for: .normal)
        btnPlay?.tintColor = .white
        btnPlay?.addTarget(self, action: #selector(onPlayTapped), for: .touchUpInside)
        
        guard let btnPlay = btnPlay else { return }
        imgVw.addSubview(btnPlay)
        NSLayoutConstraint.activate([
            btnPlay.centerXAnchor.constraint(equalTo: imgVw.centerXAnchor),
            btnPlay.centerYAnchor.constraint(equalTo: imgVw.centerYAnchor),
            btnPlay.widthAnchor.constraint(equalToConstant: 70),
            btnPlay.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    func setupCollectionView() {
        colVw.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        colVw.collectionViewLayout = layout
        colVw.delegate = self
        colVw.dataSource = self
        colVw.showsHorizontalScrollIndicator = false
    }

    func setup(feed: Feed, index: Int = 0) {
        currentFeed = feed
        cellIndex = index
        selectedTagIndex = nil
        
        lblTitle.text = feed.heading
        serialNo.text = "\(feed.serial_number)"
        lblSubject.text = feed.language
        
        currentLikeCount = feed.likesCount
        isLiked = feed.isLiked
        lblLikeCount.text = "\(currentLikeCount)"
        updateLikeUI(isLiked: isLiked)
        
        currentWhatsappCount = feed.whatsappShareCount
        whatsappLbl.text = "\(currentWhatsappCount)"
        
        currentShareCount = feed.shareCount ?? 0
        shareLbl.text = "\(currentShareCount)"
        
        lblTime.text = "\(feed.postingDate.formatDate()) |"
        
        currentCommentCount = feed.commentsCount
        setupCommentButton(count: currentCommentCount)
        
        youtubeURL = feed.youtubeVideo
        removePlayerView()
        imgVw.loadImage(url: feed.image ?? "", placeHolderImage: "login_img")
        btnPlay?.isHidden = (feed.youtubeVideo ?? "").isEmpty
        
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

    private func setupCommentButton(count: Int) {
        if count == 0 {
            commentBtn.setTitle("0 Comments", for: .normal)
        } else if count == 1 {
            commentBtn.setTitle("1 Comment", for: .normal)
        } else {
            commentBtn.setTitle("\(count) Comments", for: .normal)
        }
    }
    
    // Update comment count after posting
    func incrementCommentCount() {
        currentCommentCount += 1
        setupCommentButton(count: currentCommentCount)
        
        // Animate the comment button
        UIView.animate(withDuration: 0.1, animations: {
            self.commentBtn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.commentBtn.transform = .identity
            }
        }
    }
    
    // Reset tag selection
    func resetTagSelection() {
        selectedTagIndex = nil
        colVw.reloadData()
    }

    @objc func onPlayTapped() {
        guard let url = youtubeURL, !url.isEmpty, let videoID = url.extractYoutubeId() else { return }
        btnPlay?.isHidden = true
        playYouTubeVideo(videoID: videoID)
    }

    func playYouTubeVideo(videoID: String) {
        removePlayerView()
        
        playerView = YTPlayerView()
        playerView?.delegate = self
        playerView?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let playerView = playerView else { return }
        imgVw.addSubview(playerView)
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: imgVw.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: imgVw.bottomAnchor),
            playerView.leadingAnchor.constraint(equalTo: imgVw.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: imgVw.trailingAnchor)
        ])
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.color = .white
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        
        if let indicator = activityIndicator {
            playerView.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: playerView.centerYAnchor)
            ])
            indicator.startAnimating()
        }
        
        playerView.load(withVideoId: videoID, playerVars: [
            "playsinline": 1, "autoplay": 1, "mute": 0, "controls": 1, "modestbranding": 1
        ])
    }

    func removePlayerView() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
        playerView?.stopVideo()
        playerView?.removeFromSuperview()
        playerView = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        removePlayerView()
        imgVw.image = nil
        youtubeURL = nil
        btnPlay?.isHidden = false
        isLiked = false
        currentLikeCount = 0
        currentWhatsappCount = 0
        currentShareCount = 0
        currentCommentCount = 0
        currentFeed = nil
        cellIndex = 0
        selectedTagIndex = nil
        lblLikeCount.text = "0"
        whatsappLbl.text = "0"
        shareLbl.text = "0"
    }

    @IBAction func onClickLike(_ sender: UIButton) {
        toggleLike()
        likeClicked?(sender.tag)
    }

    @IBAction func onClickComment(_ sender: UIButton) {
        guard let feed = currentFeed else { return }
        commentClicked?(sender.tag, feed)
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

extension StoriesCell: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        activityIndicator?.stopAnimating()
        playerView.playVideo()
    }

    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        activityIndicator?.stopAnimating()
        btnPlay?.isHidden = false
        removePlayerView()
    }
}

extension StoriesCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.lblText.text = arr[indexPath.row]
        
        // Update UI based on selection
        if selectedTagIndex == indexPath.row {
            cell.setSelected(true)
        } else {
            cell.setSelected(false)
        }
        
        return cell
    }
    
    // Handle tag selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let feed = currentFeed else { return }
        
        let selectedText = arr[indexPath.row]
        
        // Update selected state
        selectedTagIndex = indexPath.row
        collectionView.reloadData()
        
        // Animate the selected cell
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCell {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                }
            }
        }
        
        // Call the callback with selected tag text
        tagClicked?(cellIndex, feed, selectedText)
    }
}

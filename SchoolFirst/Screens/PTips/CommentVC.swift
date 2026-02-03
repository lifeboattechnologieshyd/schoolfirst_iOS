//
//  CommentVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 03/01/26.
//

import UIKit

class CommentVC: UIViewController {

    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var bottomVw: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var feed: Feed?
    
    var comments: [Comment] = []
    
    // Quick reactions array
    var quickReactions = ["That's awesome!", "This is Very useful!",
                          "This is exactly what I needed!", "I learned something new!",
                          "I already knew this!"]
    
    var isPostingComment = false
    
    let tagFont = UIFont.systemFont(ofSize: 14)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupCollectionView()
        fetchComments()
    }
    
    func setupUI() {
        topVw.addBottomShadow()
        bottomVw.addTopShadow()
        
        // Set title if available
        if let lblTitle = lblTitle {
            lblTitle.text = "Comments"
        }
    }
    
    func setupTableView() {
        // Register cells
        tblVw.register(UINib(nibName: "EdutainCell", bundle: nil), forCellReuseIdentifier: "EdutainCell")
        tblVw.register(UINib(nibName: "CommentsCell", bundle: nil), forCellReuseIdentifier: "CommentsCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.keyboardDismissMode = .onDrag
        tblVw.estimatedRowHeight = 100
        tblVw.rowHeight = UITableView.automaticDimension
    }
    
    func setupCollectionView() {
        colVw.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        
        let layout = UICollectionViewFlowLayout()
        
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        colVw.collectionViewLayout = layout
        colVw.delegate = self
        colVw.dataSource = self
        colVw.showsHorizontalScrollIndicator = false
    }
    
    func fetchComments() {
        guard let feedId = feed?.id else { return }
        
        showLoader()
        let url = API.GET_COMMENTS + "?feed_id=\(feedId)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<CommentsResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.comments = data.comments
                        self.tblVw.reloadData()
                    } else {
                        self.showAlert(msg: info.description)
                    }
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    func postComment(text: String, completion: @escaping (Bool) -> Void) {
        guard let feedId = feed?.id, !text.isEmpty else {
            completion(false)
            return
        }
        
        showLoader()
        let url = API.POST_COMMENT
        let parameters: [String: Any] = [
            "feed_id": feedId,
            "comment": text
        ]
        
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { [weak self] (result: Result<APIResponse<PostCommentResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
                switch result {
                case .success(let info):
                    if info.success {
                        // Update comment count in feed
                        self.feed?.commentsCount += 1
                        
                        // Refresh comments from API
                        self.fetchComments()
                        
                        // Reload feed cell to show updated count
                        if self.feed != nil {
                            self.tblVw.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                        }
                        
                        // Show success toast
                        self.showSuccessToast(message: "Comment posted!")
                        
                        completion(true)
                        
                    } else {
                        self.showAlert(msg: info.description)
                        completion(false)
                    }
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
    
    func likeFeed(feedId: String, completion: @escaping (Bool, Int, Bool) -> Void) {
        let url = API.LIKE_FEED + feedId + "/like"
        
        NetworkManager.shared.request(urlString: url, method: .POST) { [weak self] (result: Result<APIResponse<LikeResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        completion(true, data.likes_count, data.is_liked)
                    } else {
                        self.showAlert(msg: info.description)
                        completion(false, 0, false)
                    }
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                    completion(false, 0, false)
                }
            }
        }
    }
    
    func handleWhatsAppShare(feed: Feed, updateCountClosure: @escaping () -> Void) {
        let shareText = "test"
        guard let encodedText = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let testURL = URL(string: "whatsapp://send?text=\(encodedText)"),
              UIApplication.shared.canOpenURL(testURL) else {
            showWhatsAppNotInstalledAlert()
            return
        }
        
        let url = API.WHATSAPP_SHARE
        let parameters: [String: Any] = ["feed_id": feed.id]
        
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { [weak self] (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success {
                        updateCountClosure()
                        _ = self.openWhatsApp(with: feed)
                    } else {
                        self.showAlert(msg: info.description)
                    }
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    func openWhatsApp(with feed: Feed) -> Bool {
        let shareText = """
        📚 *\(feed.heading)*
        
        \(feed.description.stripHTML())
        
        🔗 \(feed.youtubeVideo ?? "")
        
        📲 Download SchoolFirst App for more!
        """
        
        guard let encodedText = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "whatsapp://send?text=\(encodedText)") else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }
        return false
    }
    
    func showWhatsAppNotInstalledAlert() {
        let alert = UIAlertController(
            title: "WhatsApp Not Installed",
            message: "WhatsApp is not installed on your device. Would you like to download it?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Download", style: .default) { _ in
            if let appStoreURL = URL(string: "https://apps.apple.com/app/whatsapp-messenger/id310633997") {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func shareContent(feed: Feed, sourceView: UIView, completion: @escaping (Bool) -> Void) {
        let shareText = """
        📚 \(feed.heading)
        
        \(feed.description.stripHTML())
        
        🔗 \(feed.youtubeVideo ?? "")
        
        📲 Download SchoolFirst App for more!
        """
        
        var itemsToShare: [Any] = [shareText]
        
        if let imageUrlString = feed.image, let imageUrl = URL(string: imageUrlString) {
            itemsToShare.append(imageUrl)
        }
        
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            completion(success)
        }
        
        present(activityVC, animated: true)
    }
    
    func showSuccessToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastLabel.text = "  ✓ \(message)  "
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 20
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            toastLabel.heightAnchor.constraint(equalToConstant: 40),
            toastLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension CommentVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Section 0: Feed Cell, Section 1: Comments
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return feed != nil ? 1 : 0
        } else {
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return configureFeedCell(for: indexPath)
        } else {
            return configureCommentCell(for: indexPath)
        }
    }
    
    private func configureFeedCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let feed = feed else {
            return UITableViewCell()
        }
        
        let cell = tblVw.dequeueReusableCell(withIdentifier: "EdutainCell", for: indexPath) as! EdutainCell
        cell.setup(feed: feed)
        
        // Hide comment button since we're already in comments
        cell.commentBtn.isHidden = true
        
        // Hide collection view in feed cell (we have it at bottom)
        cell.colVw.isHidden = true
        
        // Like Action
        cell.likeClicked = { [weak self] index in
            guard let self = self else { return }
            
            // Toggle UI immediately
            cell.toggleLike()
            
            self.likeFeed(feedId: feed.id) { success, likesCount, isLiked in
                if success {
                    self.feed?.likesCount = likesCount
                    self.feed?.isLiked = isLiked
                    
                    // Update cell with server response
                    DispatchQueue.main.async {
                        cell.lblLikeCount.text = "\(likesCount)"
                        cell.updateLikeUI(isLiked: isLiked)
                    }
                } else {
                    // Revert on failure
                    cell.revertLike()
                }
            }
        }
        
        // WhatsApp Share Action
        cell.whatsappClicked = { [weak self] index, feed in
            guard let self = self else { return }
            self.handleWhatsAppShare(feed: feed) {
                self.feed?.whatsappShareCount += 1
                cell.updateWhatsappCount()
            }
        }
        
        // Native Share Action
        cell.shareClicked = { [weak self] index, feed in
            guard let self = self else { return }
            self.shareContent(feed: feed, sourceView: cell.shareBtn) { success in
                if success {
                    self.feed?.shareCount = (self.feed?.shareCount ?? 0) + 1
                    cell.updateShareCount()
                }
            }
        }
        
        return cell
    }
    
    private func configureCommentCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVw.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        let comment = comments[indexPath.row]
        
        let isFirstComment = indexPath.row == 0
        cell.configure(with: comment, showTopLabel: isFirstComment)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CommentVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quickReactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.lblText.text = quickReactions[indexPath.row]
        
        // Reset to default state
        cell.setSelected(false)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 1. Get the text for THIS specific cell
        let text = quickReactions[indexPath.row]
        
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
        // Prevent multiple taps while posting
        guard !isPostingComment else { return }
        
        let reaction = quickReactions[indexPath.row]
        
        // Show loading state on the selected cell
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCell {
            isPostingComment = true
            
            // Visual feedback - show selected state
            cell.setSelected(true)
            
            // Animate the cell
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                }
            }
            
            // Post the comment
            postComment(text: reaction) { [weak self] success in
                guard let self = self else { return }
                
                self.isPostingComment = false
                
                // Reset cell appearance
                cell.setSelected(false)
                
                if success {
                    // Scroll to show the new comment
                    if !self.comments.isEmpty {
                        let commentIndexPath = IndexPath(row: 0, section: 1)
                        self.tblVw.scrollToRow(at: commentIndexPath, at: .top, animated: true)
                    }
                }
            }
        }
    }
}

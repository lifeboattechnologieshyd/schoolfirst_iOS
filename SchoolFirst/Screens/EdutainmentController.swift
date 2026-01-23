//
//  EdutainmentController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 01/07/25.
//
import UIKit

class EdutainmentController: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var videonoTf: UITextField!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    
    var diyFeed = [Feed]()
    var storiesFeed = [Feed]()
    var currentFeed = [Feed]()
    
    var searchResults = [Feed]()
    var isSearchActive = false
    var searchDebounceTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchTF()
        setupUI()
        setupSegmentControl()
        setupTextFields()
        setupTableView()
        segmentController.selectedSegmentIndex = 0
        getDiyFeed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applySegmentCornerRadius()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applySegmentCornerRadius()
    }
    
    
    func setupUI() {
        topVw.addBottomShadow()
    }
    
    func setupSegmentControl() {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.lexend(.regular, size: 16),
            .foregroundColor: UIColor.gray
        ]
        segmentController.setTitleTextAttributes(normalAttributes, for: .normal)

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.lexend(.semiBold, size: 16),
            .foregroundColor: UIColor.white
        ]
        segmentController.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        segmentController.backgroundColor = UIColor.white
        
        DispatchQueue.main.async {
            self.applySegmentCornerRadius()
        }
    }
    func setupSearchTF() {
        searchTf.delegate = self
        searchTf.addTarget(
            self,
            action: #selector(searchTextChanged(_:)),
            for: .editingChanged
        )
    }
    @objc func searchTextChanged(_ textField: UITextField) {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Hide button when user starts typing
        searchBtn.isHidden = !text.isEmpty
    }

    func applySegmentCornerRadius() {
        guard segmentController.frame.height > 0 else { return }
        
        let cornerRadius = segmentController.frame.height / 2
        segmentController.layer.cornerRadius = cornerRadius
        segmentController.layer.masksToBounds = true
        segmentController.clipsToBounds = true
    }
    
    func setupTextFields() {
        searchTf.delegate = self
        searchTf.returnKeyType = .search
        searchTf.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
        
        videonoTf.delegate = self
        videonoTf.keyboardType = .numberPad
        videonoTf.addTarget(self, action: #selector(videoNumberTextFieldDidChange(_:)), for: .editingChanged)
        
        addDoneButtonToKeyboard()
    }
    
    func addDoneButtonToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        videonoTf.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupTableView() {
        tblVw.register(UINib(nibName: "EdutainCell", bundle: nil), forCellReuseIdentifier: "EdutainCell")
        tblVw.register(UINib(nibName: "StoriesCell", bundle: nil), forCellReuseIdentifier: "StoriesCell")
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.keyboardDismissMode = .onDrag
    }
    
    
    func navigateToComments(feed: Feed, cellType: FeedCellType) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC else { return }
        vc.feed = feed
        vc.cellType = cellType
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func onChangeSegment(_ sender: UISegmentedControl) {
        clearSearch()
        
        if sender.selectedSegmentIndex == 0 {
            diyFeed.isEmpty ? getDiyFeed() : { currentFeed = diyFeed; tblVw.reloadData() }()
        } else {
            storiesFeed.isEmpty ? getStoriesFeed() : { currentFeed = storiesFeed; tblVw.reloadData() }()
        }
    }
    
    @IBAction func onClickGo(_ sender: UIButton) {
        dismissKeyboard()
        
        guard let serialText = videonoTf.text?.trimmingCharacters(in: .whitespaces), !serialText.isEmpty else {
            showAlert(msg: "Please enter a video number")
            return
        }
        
        guard let serialNumber = Int(serialText) else {
            showAlert(msg: "Please enter a valid number")
            return
        }
        
        searchTf.text = ""
        searchDebounceTimer?.invalidate()
        
        searchBySerialNumber(serialNumber: serialNumber)
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func clearSearch() {
        searchDebounceTimer?.invalidate()
        searchTf.text = ""
        videonoTf.text = ""
        isSearchActive = false
        searchResults.removeAll()
    }
    
    func getCurrentCategory() -> String {
        return segmentController.selectedSegmentIndex == 0 ? "Diy" : "Stories"
    }
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        searchDebounceTimer?.invalidate()
        videonoTf.text = ""
        
        let keyword = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if keyword.isEmpty {
            isSearchActive = false
            currentFeed = segmentController.selectedSegmentIndex == 0 ? diyFeed : storiesFeed
            tblVw.reloadData()
            return
        }
        
        guard keyword.count >= 1 else { return }
        
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.searchByKeyword(keyword: keyword)
        }
    }
    
    @objc func videoNumberTextFieldDidChange(_ textField: UITextField) {
        searchTf.text = ""
        searchDebounceTimer?.invalidate()
    }
    
    func searchByKeyword(keyword: String) {
        guard !keyword.isEmpty else { return }
        
        let category = getCurrentCategory()
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let url = API.EDUTAIN_SEARCH + "?keyword=\(encodedKeyword)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let currentKeyword = self.searchTf.text?.trimmingCharacters(in: .whitespaces) ?? ""
                guard currentKeyword == keyword else { return }
                
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.searchResults = data.filter { feed in
                            feed.f_category?.lowercased() == category.lowercased()
                        }
                        self.isSearchActive = true
                        self.currentFeed = self.searchResults
                        self.tblVw.reloadData()
                        
                        if !self.currentFeed.isEmpty {
                            self.tblVw.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                        }
                    } else {
                        self.showAlert(msg: info.description)
                    }
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    func searchBySerialNumber(serialNumber: Int) {
        let category = getCurrentCategory()
        let sourceData = segmentController.selectedSegmentIndex == 0 ? diyFeed : storiesFeed
        
        if let foundFeed = sourceData.first(where: { $0.serial_number == serialNumber }) {
            isSearchActive = true
            searchResults = [foundFeed]
            currentFeed = searchResults
            tblVw.reloadData()
            
            if !currentFeed.isEmpty {
                tblVw.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        } else {
            searchSerialNumberFromAPI(serialNumber: serialNumber, category: category)
        }
    }
    
    func searchSerialNumberFromAPI(serialNumber: Int, category: String) {
        let url = API.EDUTAIN_SEARCH + "?keyword=\(serialNumber)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.searchResults = data.filter { feed in
                            feed.f_category?.lowercased() == category.lowercased() &&
                            feed.serial_number == serialNumber
                        }
                        
                        if self.searchResults.isEmpty {
                            self.searchResults = data.filter { feed in
                                feed.f_category?.lowercased() == category.lowercased()
                            }
                        }
                        
                        self.isSearchActive = true
                        self.currentFeed = self.searchResults
                        self.tblVw.reloadData()
                        
                        if self.searchResults.isEmpty {
                            self.showNoResultsMessage(for: "Video #\(serialNumber)")
                        } else {
                            self.tblVw.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                    } else {
                        self.showAlert(msg: info.description)
                    }
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    func showNoResultsMessage(for searchTerm: String) {
        let category = getCurrentCategory()
        showAlert(msg: "No results found for \(searchTerm) in \(category)")
    }
    
    
    func getDiyFeed() {
        let url = API.EDUTAIN_FEED + "?f_category=Diy"
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            switch result {
            case .success(let info):
                if info.success, let data = info.data {
                    self.diyFeed = data
                    if !self.isSearchActive {
                        self.currentFeed = data
                    }
                    DispatchQueue.main.async { self.tblVw.reloadData() }
                } else {
                    DispatchQueue.main.async { self.showAlert(msg: info.description) }
                }
            case .failure(let error):
                DispatchQueue.main.async { self.showAlert(msg: error.localizedDescription) }
            }
        }
    }
    
    func getStoriesFeed() {
        let url = API.EDUTAIN_FEED + "?f_category=Stories"
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            switch result {
            case .success(let info):
                if info.success, let data = info.data {
                    self.storiesFeed = data
                    if !self.isSearchActive {
                        self.currentFeed = data
                    }
                    DispatchQueue.main.async { self.tblVw.reloadData() }
                } else {
                    DispatchQueue.main.async { self.showAlert(msg: info.description) }
                }
            case .failure(let error):
                DispatchQueue.main.async { self.showAlert(msg: error.localizedDescription) }
            }
        }
    }
    
    func likeFeed(at index: Int) {
        guard index < currentFeed.count else { return }
        let feed = currentFeed[index]
        let feedId = feed.id
        let url = API.LIKE_FEED + feedId + "/like"
        
        NetworkManager.shared.request(urlString: url, method: .POST) { [weak self] (result: Result<APIResponse<LikeResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.currentFeed[index].likesCount = data.likes_count
                        self.currentFeed[index].isLiked = data.is_liked
                        
                        if self.isSearchActive {
                            if let searchIndex = self.searchResults.firstIndex(where: { $0.id == feedId }) {
                                self.searchResults[searchIndex].likesCount = data.likes_count
                                self.searchResults[searchIndex].isLiked = data.is_liked
                            }
                        }
                        
                        if self.segmentController.selectedSegmentIndex == 0 {
                            if let diyIndex = self.diyFeed.firstIndex(where: { $0.id == feedId }) {
                                self.diyFeed[diyIndex].likesCount = data.likes_count
                                self.diyFeed[diyIndex].isLiked = data.is_liked
                            }
                        } else {
                            if let storiesIndex = self.storiesFeed.firstIndex(where: { $0.id == feedId }) {
                                self.storiesFeed[storiesIndex].likesCount = data.likes_count
                                self.storiesFeed[storiesIndex].isLiked = data.is_liked
                            }
                        }
                    } else {
                        self.showAlert(msg: info.description)
                    }
                    
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tblVw.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    
    func postQuickComment(feedId: String, comment: String, at index: Int, completion: @escaping (Bool) -> Void) {
        let url = API.POST_COMMENT  // Replace with your actual comment API endpoint
        
        let parameters: [String: Any] = [
            "feed_id": feedId,
            "comment": comment
        ]
        
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { [weak self] (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success {
                        print("✅ Quick comment posted successfully: \(comment)")
                        
                        // Update comment count in current feed
                        self.currentFeed[index].commentsCount += 1
                        
                        // Update search results if active
                        if self.isSearchActive {
                            if let searchIndex = self.searchResults.firstIndex(where: { $0.id == feedId }) {
                                self.searchResults[searchIndex].commentsCount += 1
                            }
                        }
                        
                        // Update source array
                        if self.segmentController.selectedSegmentIndex == 0 {
                            if let diyIndex = self.diyFeed.firstIndex(where: { $0.id == feedId }) {
                                self.diyFeed[diyIndex].commentsCount += 1
                            }
                        } else {
                            if let storiesIndex = self.storiesFeed.firstIndex(where: { $0.id == feedId }) {
                                self.storiesFeed[storiesIndex].commentsCount += 1
                            }
                        }
                        
                        completion(true)
                        
                        // Show success feedback
                        self.showSuccessToast(message: "Comment posted!")
                        
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
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
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
    
    
    func callWhatsAppShareAPI(feedId: String, completion: @escaping (Bool) -> Void) {
        let url = API.WHATSAPP_SHARE
        let parameters: [String: Any] = ["feed_id": feedId]
        
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { [weak self] (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success {
                        print("✅ WhatsApp share logged successfully")
                        completion(true)
                    } else {
                        print("❌ WhatsApp share API failed: \(info.description)")
                        self.showAlert(msg: info.description)
                        completion(false)
                    }
                case .failure(let error):
                    print("❌ WhatsApp share API error: \(error.localizedDescription)")
                    self.showAlert(msg: error.localizedDescription)
                    completion(false)
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
        } else {
            showWhatsAppNotInstalledAlert()
            return false
        }
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
    
    func handleWhatsAppShare(at index: Int, feed: Feed, updateCountClosure: @escaping () -> Void) {
        let shareText = "test"
        guard let encodedText = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let testURL = URL(string: "whatsapp://send?text=\(encodedText)"),
              UIApplication.shared.canOpenURL(testURL) else {
            showWhatsAppNotInstalledAlert()
            return
        }
        
        callWhatsAppShareAPI(feedId: feed.id) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.currentFeed[index].whatsappShareCount += 1
                
                if self.isSearchActive {
                    if let searchIndex = self.searchResults.firstIndex(where: { $0.id == feed.id }) {
                        self.searchResults[searchIndex].whatsappShareCount += 1
                    }
                }
                
                if self.segmentController.selectedSegmentIndex == 0 {
                    if let diyIndex = self.diyFeed.firstIndex(where: { $0.id == feed.id }) {
                        self.diyFeed[diyIndex].whatsappShareCount += 1
                    }
                } else {
                    if let storiesIndex = self.storiesFeed.firstIndex(where: { $0.id == feed.id }) {
                        self.storiesFeed[storiesIndex].whatsappShareCount += 1
                    }
                }
                
                updateCountClosure()
                _ = self.openWhatsApp(with: feed)
            }
        }
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
        
        if let youtubeUrl = feed.youtubeVideo, let url = URL(string: youtubeUrl) {
            itemsToShare.append(url)
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
}


extension EdutainmentController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = currentFeed[indexPath.row]
        
        if segmentController.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EdutainCell") as! EdutainCell
            cell.setup(feed: feed, index: indexPath.row)
            cell.btnLike.tag = indexPath.row
            cell.whatsappBtn.tag = indexPath.row
            cell.shareBtn.tag = indexPath.row
            cell.commentBtn.tag = indexPath.row
            
            // Like Action
            cell.likeClicked = { [weak self] index in
                self?.likeFeed(at: index)
            }
            
            // WhatsApp Share Action
            cell.whatsappClicked = { [weak self] index, feed in
                guard let self = self else { return }
                self.handleWhatsAppShare(at: index, feed: feed) {
                    cell.updateWhatsappCount()
                }
            }
            
            // Native Share Action
            cell.shareClicked = { [weak self] index, feed in
                guard let self = self else { return }
                self.shareContent(feed: feed, sourceView: cell.shareBtn) { success in
                    if success {
                        cell.updateShareCount()
                    }
                }
            }
            
            // Comment Action
            cell.commentClicked = { [weak self] index, feed in
                guard let self = self else { return }
                self.navigateToComments(feed: feed, cellType: .diy)
            }
            
            // NEW: Tag Click Action - Post quick comment
            cell.tagClicked = { [weak self] index, feed, commentText in
                guard let self = self else { return }
                
                self.postQuickComment(feedId: feed.id, comment: commentText, at: index) { success in
                    if success {
                        // Update the cell's comment count
                        cell.incrementCommentCount()
                        
                        // Reset the tag selection after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            cell.resetTagSelection()
                        }
                    } else {
                        // Reset selection on failure
                        cell.resetTagSelection()
                    }
                }
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesCell") as! StoriesCell
            cell.setup(feed: feed, index: indexPath.row)
            cell.btnLike.tag = indexPath.row
            cell.whatsappBtn.tag = indexPath.row
            cell.shareBTn.tag = indexPath.row
            cell.commentBtn.tag = indexPath.row
            
            // Like Action
            cell.likeClicked = { [weak self] index in
                self?.likeFeed(at: index)
            }
            
            // WhatsApp Share Action
            cell.whatsappClicked = { [weak self] index, feed in
                guard let self = self else { return }
                self.handleWhatsAppShare(at: index, feed: feed) {
                    cell.updateWhatsappCount()
                }
            }
            
            // Native Share Action
            cell.shareClicked = { [weak self] index, feed in
                guard let self = self else { return }
                self.shareContent(feed: feed, sourceView: cell.shareBTn) { success in
                    if success {
                        cell.updateShareCount()
                    }
                }
            }
            
            // Comment Action
            cell.commentClicked = { [weak self] index, feed in
                guard let self = self else { return }
                self.navigateToComments(feed: feed, cellType: .stories)
            }
            
            // NEW: Tag Click Action - Post quick comment
            cell.tagClicked = { [weak self] index, feed, commentText in
                guard let self = self else { return }
                
                self.postQuickComment(feedId: feed.id, comment: commentText, at: index) { success in
                    if success {
                        // Update the cell's comment count
                        cell.incrementCommentCount()
                        
                        // Reset the tag selection after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            cell.resetTagSelection()
                        }
                    } else {
                        // Reset selection on failure
                        cell.resetTagSelection()
                    }
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return segmentController.selectedSegmentIndex == 0 ? UITableView.automaticDimension : 420
    }
}


extension EdutainmentController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == searchTf {
            searchDebounceTimer?.invalidate()
            let keyword = searchTf.text?.trimmingCharacters(in: .whitespaces) ?? ""
            if !keyword.isEmpty {
                searchByKeyword(keyword: keyword)
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchTf {
            videonoTf.text = ""
            searchBtn.isHidden = !(searchTf.text?.isEmpty ?? true)
        }
        else if textField == videonoTf {
            searchTf.text = ""
            searchBtn.isHidden = false   // show button back

            searchDebounceTimer?.invalidate()
            if isSearchActive {
                isSearchActive = false
                currentFeed = segmentController.selectedSegmentIndex == 0 ? diyFeed : storiesFeed
                tblVw.reloadData()
            }
        }
    }

    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == searchTf {
            searchDebounceTimer?.invalidate()
            searchBtn.isHidden = false   // SHOW button

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.isSearchActive = false
                self.currentFeed = self.segmentController.selectedSegmentIndex == 0
                    ? self.diyFeed
                    : self.storiesFeed
                self.tblVw.reloadData()
            }
        }
        return true
    }

}

//
//  PTipsViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

class PTipsViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var postTf: UITextField!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    
    var feed = [Feed]()
    var ptipsFeed = [Feed]()
    var ftipsFeed = [Feed]()
    var currentFeed = [Feed]()
    
    var searchResults = [Feed]()
    var isSearchActive = false
    var searchDebounceTimer: Timer?
    
    var isEdutain = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTextFields()
        setupTableView()
        
        if isEdutain {
            self.getEdutainment(text: "Diy")
            segmentControl.removeFromSuperview()
            lblTitle.text = "Edutainment"
        } else {
            self.getEdutainment(text: "Ptips")
            lblTitle.text = "Ptips"
            segmentControl.selectedSegmentIndex = 0
        }
    }
    
    func setupUI() {
        topView.addBottomShadow()
        segmentControl.applyCustomStyle()
    }
    
    func setupTextFields() {
        searchTf.delegate = self
        searchTf.returnKeyType = .search
        searchTf.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
        
        postTf.delegate = self
        postTf.keyboardType = .numberPad
        postTf.addTarget(self, action: #selector(postNumberTextFieldDidChange(_:)), for: .editingChanged)
        
        addDoneButtonToKeyboard()
    }
    
    func addDoneButtonToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        postTf.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupTableView() {
        tblView.register(UINib(nibName: "EdutainCell", bundle: nil), forCellReuseIdentifier: "EdutainCell")
        tblView.delegate = self
        tblView.dataSource = self
        tblView.keyboardDismissMode = .onDrag
    }
    
    @IBAction func onChangeSegment(_ sender: UISegmentedControl) {
        clearSearch()
        
        if sender.selectedSegmentIndex == 0 {
            ptipsFeed.isEmpty ? getEdutainment(text: "Ptips") : { currentFeed = ptipsFeed; tblView.reloadData() }()
        } else {
            ftipsFeed.isEmpty ? getEdutainment(text: "Ftips") : { currentFeed = ftipsFeed; tblView.reloadData() }()
        }
    }
    
    @IBAction func onClickGo(_ sender: UIButton) {
        dismissKeyboard()
        
        guard let serialText = postTf.text?.trimmingCharacters(in: .whitespaces), !serialText.isEmpty else {
            showAlert(msg: "Please enter a post number")
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
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func clearSearch() {
        searchDebounceTimer?.invalidate()
        searchTf.text = ""
        postTf.text = ""
        isSearchActive = false
        searchResults.removeAll()
    }
    
    func getCurrentCategory() -> String {
        if isEdutain {
            return "Diy"
        }
        return segmentControl.selectedSegmentIndex == 0 ? "Ptips" : "Ftips"
    }
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        searchDebounceTimer?.invalidate()
        postTf.text = ""
        
        let keyword = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        // Update search button visibility
        if let searchBtn = searchBtn {
            searchBtn.isHidden = !keyword.isEmpty
        }
        
        if keyword.isEmpty {
            isSearchActive = false
            if isEdutain {
                currentFeed = feed
            } else {
                currentFeed = segmentControl.selectedSegmentIndex == 0 ? ptipsFeed : ftipsFeed
            }
            tblView.reloadData()
            return
        }
        
        guard keyword.count >= 1 else { return }
        
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.searchByKeyword(keyword: keyword)
        }
    }
    
    @objc func postNumberTextFieldDidChange(_ textField: UITextField) {
        searchTf.text = ""
        searchDebounceTimer?.invalidate()
        
        // Show search button back
        if let searchBtn = searchBtn {
            searchBtn.isHidden = false
        }
    }
    
    func searchByKeyword(keyword: String) {
        showLoader()
        guard !keyword.isEmpty else { return }
        
        let category = getCurrentCategory()
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let url = API.EDUTAIN_SEARCH + "?keyword=\(encodedKeyword)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
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
                        self.tblView.reloadData()
                        
                        if !self.currentFeed.isEmpty {
                            self.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
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
        showLoader()
        let category = getCurrentCategory()
        var sourceData: [Feed]
        
        if isEdutain {
            sourceData = feed
        } else {
            sourceData = segmentControl.selectedSegmentIndex == 0 ? ptipsFeed : ftipsFeed
        }
        
        if let foundFeed = sourceData.first(where: { $0.serial_number == serialNumber }) {
            hideLoader()
            isSearchActive = true
            searchResults = [foundFeed]
            currentFeed = searchResults
            tblView.reloadData()
            
            if !currentFeed.isEmpty {
                tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
                self.hideLoader()
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
                        self.tblView.reloadData()
                        
                        if self.searchResults.isEmpty {
                            self.showNoResultsMessage(for: "Post #\(serialNumber)")
                        } else {
                            self.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
    
    func getEdutainment(text: String = "Ptips") {
        showLoader()
        let url = API.EDUTAIN_FEED + "?f_category=\(text)"
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    print("data fetching for table \(info.data)")
                    if let data = info.data {
                        // Store in appropriate array based on category
                        if text == "Ptips" {
                            self.ptipsFeed = data
                        } else if text == "Ftips" {
                            self.ftipsFeed = data
                        } else if text == "Diy" {
                            self.feed = data
                        }
                        
                        if !self.isSearchActive {
                            self.currentFeed = data
                        }
                    }
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    func navigateToComments(feed: Feed) {
        let storyboard = UIStoryboard(name: "PTips", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CommentVC") as? CommentVC else {
            return
        }
        vc.feed = feed
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeFeed(at index: Int) {
        guard index < currentFeed.count else { return }
        let feedItem = currentFeed[index]
        let feedId = feedItem.id
        let url = API.LIKE_FEED + feedId + "/like"
        
        NetworkManager.shared.request(urlString: url, method: .POST) { [weak self] (result: Result<APIResponse<LikeResponse>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.currentFeed[index].likesCount = data.likes_count
                        self.currentFeed[index].isLiked = data.is_liked
                        
                        // Update search results if active
                        if self.isSearchActive {
                            if let searchIndex = self.searchResults.firstIndex(where: { $0.id == feedId }) {
                                self.searchResults[searchIndex].likesCount = data.likes_count
                                self.searchResults[searchIndex].isLiked = data.is_liked
                            }
                        }
                        
                        // Update source arrays
                        if self.isEdutain {
                            if let feedIndex = self.feed.firstIndex(where: { $0.id == feedId }) {
                                self.feed[feedIndex].likesCount = data.likes_count
                                self.feed[feedIndex].isLiked = data.is_liked
                            }
                        } else {
                            if self.segmentControl.selectedSegmentIndex == 0 {
                                if let ptipsIndex = self.ptipsFeed.firstIndex(where: { $0.id == feedId }) {
                                    self.ptipsFeed[ptipsIndex].likesCount = data.likes_count
                                    self.ptipsFeed[ptipsIndex].isLiked = data.is_liked
                                }
                            } else {
                                if let ftipsIndex = self.ftipsFeed.firstIndex(where: { $0.id == feedId }) {
                                    self.ftipsFeed[ftipsIndex].likesCount = data.likes_count
                                    self.ftipsFeed[ftipsIndex].isLiked = data.is_liked
                                }
                            }
                        }
                    } else {
                        self.showAlert(msg: info.description)
                    }
                    
                case .failure(let error):
                    self.showAlert(msg: error.localizedDescription)
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tblView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    func postQuickComment(feedId: String, comment: String, at index: Int, completion: @escaping (Bool) -> Void) {
        let url = API.POST_COMMENT
        
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
                        
                        // Update source arrays
                        if self.isEdutain {
                            if let feedIndex = self.feed.firstIndex(where: { $0.id == feedId }) {
                                self.feed[feedIndex].commentsCount += 1
                            }
                        } else {
                            if self.segmentControl.selectedSegmentIndex == 0 {
                                if let ptipsIndex = self.ptipsFeed.firstIndex(where: { $0.id == feedId }) {
                                    self.ptipsFeed[ptipsIndex].commentsCount += 1
                                }
                            } else {
                                if let ftipsIndex = self.ftipsFeed.firstIndex(where: { $0.id == feedId }) {
                                    self.ftipsFeed[ftipsIndex].commentsCount += 1
                                }
                            }
                        }
                        
                        completion(true)
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
                
                // Update search results if active
                if self.isSearchActive {
                    if let searchIndex = self.searchResults.firstIndex(where: { $0.id == feed.id }) {
                        self.searchResults[searchIndex].whatsappShareCount += 1
                    }
                }
                
                // Update source arrays
                if self.isEdutain {
                    if let feedIndex = self.feed.firstIndex(where: { $0.id == feed.id }) {
                        self.feed[feedIndex].whatsappShareCount += 1
                    }
                } else {
                    if self.segmentControl.selectedSegmentIndex == 0 {
                        if let ptipsIndex = self.ptipsFeed.firstIndex(where: { $0.id == feed.id }) {
                            self.ptipsFeed[ptipsIndex].whatsappShareCount += 1
                        }
                    } else {
                        if let ftipsIndex = self.ftipsFeed.firstIndex(where: { $0.id == feed.id }) {
                            self.ftipsFeed[ftipsIndex].whatsappShareCount += 1
                        }
                    }
                }
                
                updateCountClosure()
                _ = self.openWhatsApp(with: feed)
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
}

extension PTipsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("reloading table \(currentFeed.count)")
        return currentFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EdutainCell") as! EdutainCell
        let feedItem = currentFeed[indexPath.row]
        
        cell.setup(feed: feedItem, index: indexPath.row)
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
                    self.currentFeed[index].shareCount = (self.currentFeed[index].shareCount ?? 0) + 1
                    cell.updateShareCount()
                }
            }
        }
        
        // Comment Action - Navigate to PTipsCommentVC
        cell.commentClicked = { [weak self] index, feed in
            guard let self = self else { return }
            self.navigateToComments(feed: feed)
        }
        
        // Tag Click Action - Post quick comment
        cell.tagClicked = { [weak self] index, feed, commentText in
            guard let self = self else { return }
            
            self.postQuickComment(feedId: feed.id, comment: commentText, at: index) { success in
                if success {
                    cell.incrementCommentCount()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        cell.resetTagSelection()
                    }
                } else {
                    cell.resetTagSelection()
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PTipsViewController: UITextFieldDelegate {
    
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
            postTf.text = ""
            if let searchBtn = searchBtn {
                searchBtn.isHidden = !(searchTf.text?.isEmpty ?? true)
            }
        } else if textField == postTf {
            searchTf.text = ""
            if let searchBtn = searchBtn {
                searchBtn.isHidden = false
            }
            searchDebounceTimer?.invalidate()
            if isSearchActive {
                isSearchActive = false
                if isEdutain {
                    currentFeed = feed
                } else {
                    currentFeed = segmentControl.selectedSegmentIndex == 0 ? ptipsFeed : ftipsFeed
                }
                tblView.reloadData()
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == searchTf {
            searchDebounceTimer?.invalidate()
            if let searchBtn = searchBtn {
                searchBtn.isHidden = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.isSearchActive = false
                if self.isEdutain {
                    self.currentFeed = self.feed
                } else {
                    self.currentFeed = self.segmentControl.selectedSegmentIndex == 0 ? self.ptipsFeed : self.ftipsFeed
                }
                self.tblView.reloadData()
            }
        }
        return true
    }
}

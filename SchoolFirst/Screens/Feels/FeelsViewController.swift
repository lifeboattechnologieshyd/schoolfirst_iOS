//
//  FeelsViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

class FeelsViewController: UIViewController,
                            UICollectionViewDelegate,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout,
                            UITextFieldDelegate {
    
    var page = 1
    var pageSize = 20
    var isLoading = false
    var canLoadMore = true
    var searchText = ""
    var serialNumber = ""
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var feelsLbl: UILabel!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var videonoTf: UITextField!
    
    var items = [FeelItem]()
    
    // ✅ Local overrides for like state/count
    var likeStates: [String: Bool] = [:]   // id -> isLiked
    var likeCounts: [String: Int] = [:]    // id -> likesCount
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        colVw.delegate = self
        colVw.dataSource = self
        
        searchTf.delegate = self
        videonoTf.delegate = self
        
        searchTf.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        videonoTf.addTarget(self, action: #selector(videoNoTextChanged), for: .editingChanged)
        
        colVw.register(UINib(nibName: "FeelsCollectionViewCell", bundle: nil),
                       forCellWithReuseIdentifier: "FeelsCollectionViewCell")
        
        getEdutainment()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func searchTextChanged() {
        let query = searchTf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        searchText = query
        serialNumber = ""
        videonoTf.text = ""
        
        page = 1
        canLoadMore = true
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.5)
    }
    
    @objc func performSearch() {
        getEdutainment()
    }
    
    @objc func videoNoTextChanged() {
        let text = videonoTf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if text.isEmpty {
            serialNumber = ""
            searchText = ""
            page = 1
            canLoadMore = true
            getEdutainment()
        }
    }
    
    @IBAction func onClickGo(_ sender: UIButton) {
        let serial = videonoTf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if serial.isEmpty {
            showAlert(msg: "Please enter a video number")
            return
        }
        
        view.endEditing(true)
        
        searchTf.text = ""
        searchText = ""
        serialNumber = serial
        page = 1
        canLoadMore = false
        
        getEdutainment()
    }
    
    // MARK: - Collection View DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = colVw.dequeueReusableCell(withReuseIdentifier: "FeelsCollectionViewCell",
                                             for: indexPath) as! FeelsCollectionViewCell
        
        cell.imgVw.layer.cornerRadius = 8
        cell.btnPlay.tag = indexPath.row
        cell.LikeButton.tag = indexPath.row
        cell.ShareButton.tag = indexPath.row
        
        let item = items[indexPath.row]
        
        // Load image
        if let url = item.thumbnailImage {
            cell.imgVw.loadImage(url: url)
        } else if let videoURL = item.youtubeVideo {
            let videoString = videoURL.absoluteString
            if let youtubeID = videoString.extractYoutubeId() {
                cell.imgVw.loadImage(url: youtubeID.youtubeThumbnailURL())
            }
        }
        
        cell.lblName.text = item.title
        
        // ✅ Like handling – yellow fill when liked
        let feelID = item.id
        let isLiked = likeStates[feelID] ?? item.isLiked
        let likeCount = likeCounts[feelID] ?? item.likesCount
        
        cell.NumberoflikeLbl.text = "\(likeCount)"
        cell.LikeButton.tintColor = isLiked ? .systemYellow : .systemGray2
        
        // ✅ Closures
        cell.playClicked = { index in
            self.navigateToPlayer(index: index)
        }
        
        cell.likeClicked = { [weak self] index in
            self?.handleLikeTapped(at: index)
        }
        
        cell.shareClicked = { [weak self] index in
            self?.handleShareTapped(at: index)
        }
        
        return cell
    }
    
    // MARK: - Collection View Layout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 8) / 2
        return CGSize(width: width, height: 284)
    }
    
    // MARK: - Navigation
    
    func navigateToPlayer(index: Int) {
        let stbd = UIStoryboard(name: "Feels", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "FeelPlayerController") as! FeelPlayerController
        vc.selected_feel_item = items[index]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToPlayer(index: indexPath.row)
    }
    
    // MARK: - Pagination
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if offsetY > contentHeight - frameHeight - 200 {
            if !isLoading && canLoadMore {
                page += 1
                getEdutainment()
            }
        }
    }
    
    // ✅ Handle Like/Unlike Tap
    private func handleLikeTapped(at index: Int) {
        guard index < items.count else { return }
        
        let item = items[index]
        let feelID = item.id
        
        guard !feelID.isEmpty else {
            showAlert(msg: "Unable to like this item.")
            return
        }
        
        let isLiked = likeStates[feelID] ?? item.isLiked
        let currentCount = likeCounts[feelID] ?? item.likesCount
        
        // Optimistic update
        let newLiked = !isLiked
        let newCount = isLiked ? (currentCount - 1) : (currentCount + 1)
        
        likeStates[feelID] = newLiked
        likeCounts[feelID] = newCount
        
        colVw.reloadItems(at: [IndexPath(row: index, section: 0)])
        
        let url = isLiked ? API.FEEL_UNLIKE : API.FEEL_LIKE
        
        NetworkManager.shared.request(
            urlString: url,
            method: .POST,
            parameters: ["feel_id": feelID]
        ) { [weak self] (result: Result<APIResponse<EmptyData>, NetworkError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success {
                    print("✅ Like/Unlike success")
                } else {
                    self.likeStates[feelID] = isLiked
                    self.likeCounts[feelID] = currentCount
                    DispatchQueue.main.async {
                        self.colVw.reloadItems(at: [IndexPath(row: index, section: 0)])
                        self.showAlert(msg: response.description ?? "Failed to update like")
                    }
                }
                
            case .failure(let error):
                self.likeStates[feelID] = isLiked
                self.likeCounts[feelID] = currentCount
                DispatchQueue.main.async {
                    self.colVw.reloadItems(at: [IndexPath(row: index, section: 0)])
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    // ✅ Handle Share Tap – opens native share sheet and updates count
    private func handleShareTapped(at index: Int) {
        guard index < items.count else { return }
        
        let item = items[index]
        let feelID = item.id
        
        // Build share text
        var shareText = item.title
        if let youtubeURL = item.youtubeVideo {
            shareText = "\(item.title)\n\(youtubeURL.absoluteString)"
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // Required for iPad popover
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                        y: self.view.bounds.midY,
                                        width: 0,
                                        height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true, completion: nil)
        
        // Update share count via API (if feelID exists)
        guard !feelID.isEmpty else { return }
        
        NetworkManager.shared.request(
            urlString: API.FEEL_SHARE,
            method: .POST,
            parameters: ["feel_id": feelID]
        ) { [weak self] (result: Result<APIResponse<EmptyData>, NetworkError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success {
                    print("✅ Share count updated")
                } else {
                    print("⚠️ Share count failed: \(response.description)")
                }
                
            case .failure(let error):
                print("❌ Share error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - API
    
    func getEdutainment() {
        guard !isLoading else { return }
        isLoading = true
        
        if page == 1 {
            showLoader()
        }
        
        var url = ""
        
        if !serialNumber.isEmpty {
            url = API.EDUTAIN_FEEL + "?serial_number=\(serialNumber)"
        } else if !searchText.isEmpty {
            url = API.EDUTAIN_FEEL + "?page_size=\(pageSize)&page=\(page)"
            if let encoded = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                url += "&title=\(encoded)"
            }
        } else {
            url = API.EDUTAIN_FEEL + "?page_size=\(pageSize)&page=\(page)"
        }
        
        NetworkManager.shared.request(urlString: url, method: .GET)
        { [weak self] (result: Result<APIResponse<[FeelItem]>, NetworkError>) in
            
            guard let self = self else { return }
            self.isLoading = false
            self.hideLoader()
            
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        if data.count < self.pageSize {
                            self.canLoadMore = false
                        }
                        
                        if self.page == 1 {
                            self.items = data
                        } else {
                            self.items.append(contentsOf: data)
                        }
                        
                        for item in data {
                            let id = item.id
                            if self.likeStates[id] == nil {
                                self.likeStates[id] = item.isLiked
                                self.likeCounts[id] = item.likesCount
                            }
                        }
                    } else {
                        if self.page == 1 {
                            self.items = []
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.colVw.reloadData()
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
}

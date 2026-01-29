//
//  FeelsViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

class FeelsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
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
        
        // If cleared, show all videos
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
        
        // Clear title search
        searchTf.text = ""
        searchText = ""
        
        // Set serial number
        serialNumber = serial
        page = 1
        canLoadMore = false
        
        // Call API - will show in same collection view
        getEdutainment()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = colVw.dequeueReusableCell(withReuseIdentifier: "FeelsCollectionViewCell",
                                             for: indexPath) as! FeelsCollectionViewCell
        
        cell.imgVw.layer.cornerRadius = 8
        cell.btnPlay.tag = indexPath.row
        
        if let url = self.items[indexPath.row].thumbnailImage {
            cell.imgVw.loadImage(url: url)
        } else {
            if let urlstring = "\(self.items[indexPath.row].youtubeVideo!)".extractYoutubeId() {
                cell.imgVw.loadImage(url: urlstring.youtubeThumbnailURL())
            }
        }
        
        cell.playClicked = { index in
            self.navigateToPlayer(index: index)
        }
        
        cell.lblName.text = self.items[indexPath.row].title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 8) / 2
        return CGSize(width: width, height: 284)
    }
    
    func navigateToPlayer(index: Int) {
        let stbd = UIStoryboard(name: "Feels", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "FeelPlayerController") as! FeelPlayerController
        vc.selected_feel_item = items[index]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToPlayer(index: indexPath.row)
    }
    
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
    
    func getEdutainment() {
        
        
        guard !isLoading else { return }
        isLoading = true
        
        if page == 1 {
                showLoader()
            }
        var url = ""
        
        // Serial number search
        if !serialNumber.isEmpty {
            url = API.EDUTAIN_FEEL + "?serial_number=\(serialNumber)"
        }
        // Title search
        else if !searchText.isEmpty {
            url = API.EDUTAIN_FEEL + "?page_size=\(pageSize)&page=\(page)"
            if let encoded = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                url += "&title=\(encoded)"
            }
        }
        // Normal - show all
        else {
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

import UIKit

class GalleryhomeVC: UIViewController {

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var EventtypeCollectionview: UICollectionView!
    @IBOutlet weak var eventsTableView: UITableView!

    // MARK: - API Data
    private var categories: [GalleryCategory] = []
    private var allAlbums: [GalleryAlbum] = []
    private var filteredAlbums: [GalleryAlbum] = []
    
    private var selectedIndex: Int = 0
    private var hasAlbums: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCategoryCollectionView()
        setupEventsTableView()
        
        fetchCategories()
        fetchGalleries()
    }

    @IBAction func backBtnTapped(_ sender: UIButton) { popBack() }
    @objc private func backButtonTapped() { popBack() }
    private func popBack() {
        if navigationController?.popViewController(animated: true) == nil {
            dismiss(animated: true)
        }
    }

    // MARK: - API Fetching
    private func fetchCategories() {
        let schoolId = UserManager.shared.resolvedSchoolID
        guard !schoolId.isEmpty else { return }

        NetworkManager.shared.request(urlString: API.GALLERY_CATEGORIES, method: .GET, requiresAuth: true, headers: ["X-School-Id": schoolId]) { [weak self] (result: Result<APIResponse<[GalleryCategory]>, NetworkError>) in
            DispatchQueue.main.async {
                if case .success(let response) = result, response.success, let list = response.data {
                    let all = GalleryCategory(id: "ALL", name: "All", description: nil)
                    self?.categories = [all] + list
                    self?.EventtypeCollectionview.reloadData()
                }
            }
        }
    }

    private func fetchGalleries() {
        let schoolId = UserManager.shared.resolvedSchoolID
        guard !schoolId.isEmpty else { return }

        NetworkManager.shared.request(urlString: API.GALLERY_LIST, method: .GET, requiresAuth: true, headers: ["X-School-Id": schoolId]) { [weak self] (result: Result<APIResponse<[GalleryAlbum]>, NetworkError>) in
            DispatchQueue.main.async {
                if case .success(let response) = result, response.success, let list = response.data {
                    self?.allAlbums = list
                    self?.filterAlbums()
                } else {
                    self?.allAlbums = []
                    self?.filterAlbums()
                }
            }
        }
    }

    private func filterAlbums() {
        guard selectedIndex < categories.count else { return }
        let catId = categories[selectedIndex].id
        
        if catId == "ALL" {
            filteredAlbums = allAlbums
        } else {
            filteredAlbums = allAlbums.filter { $0.category?.id == catId }
        }
        
        hasAlbums = !filteredAlbums.isEmpty
        eventsTableView.reloadData()
    }

    // MARK: - Setup Views
    private func setupCategoryCollectionView() {
        EventtypeCollectionview.delegate = self
        EventtypeCollectionview.dataSource = self
        EventtypeCollectionview.register(UINib(nibName: "EventnameCLVcell", bundle: nil), forCellWithReuseIdentifier: "EventnameCLVcell")
        
        if let layout = EventtypeCollectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            layout.estimatedItemSize = .zero
        }
        
        EventtypeCollectionview.showsHorizontalScrollIndicator = false
        EventtypeCollectionview.contentInsetAdjustmentBehavior = .never
    }

    private func setupEventsTableView() {
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.register(UINib(nibName: "ALLEventTableViewCell", bundle: nil), forCellReuseIdentifier: "ALLEventTableViewCell")
        eventsTableView.register(UINib(nibName: "SingleeventTableViewCell", bundle: nil), forCellReuseIdentifier: "SingleeventTableViewCell")
        eventsTableView.register(EmtyalbumsTableViewCell.self, forCellReuseIdentifier: "EmtyalbumsTableViewCell")
    }

    // MARK: - Navigation
    private func navigateToSingleEventGallery(albumIndex: Int) {
        guard albumIndex < filteredAlbums.count else { return }
        let album = filteredAlbums[albumIndex]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SingleeventsGalleryVC") as? SingleeventsGalleryVC {
            vc.album = album // PASS DATA
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = SingleeventsGalleryVC()
        vc.album = album
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionView (Categories)
extension GalleryhomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return categories.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventnameCLVcell", for: indexPath) as! EventnameCLVcell
        cell.configure(title: categories[indexPath.item].name, isSelected: indexPath.item == selectedIndex)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
        filterAlbums()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = categories[indexPath.item].name as NSString
        let textWidth = title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 13, weight: .medium)]).width
        return CGSize(width: max(textWidth + 28, 54), height: 36)
    }
}

// MARK: - UITableView (Albums)
extension GalleryhomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !hasAlbums {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmtyalbumsTableViewCell", for: indexPath) as! EmtyalbumsTableViewCell
            cell.configure(category: categories[safe: selectedIndex]?.name ?? "All")
            cell.onBrowseAllTapped = { [weak self] in
                self?.selectedIndex = 0
                self?.EventtypeCollectionview.reloadData()
                self?.filterAlbums()
            }
            return cell
        }

        if selectedIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ALLEventTableViewCell", for: indexPath) as! ALLEventTableViewCell
            cell.configure(with: filteredAlbums)
            cell.onAlbumTapped = { [weak self] idx in self?.navigateToSingleEventGallery(albumIndex: idx) }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleeventTableViewCell", for: indexPath) as! SingleeventTableViewCell
        cell.configure(category: categories[selectedIndex].name, albums: filteredAlbums)
        cell.onAlbumTapped = { [weak self] idx in self?.navigateToSingleEventGallery(albumIndex: idx) }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return hasAlbums ? 1000 : 480 }
}

extension Collection { subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil } }

//
//  GalleryhomeVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/09/26.
//

import UIKit

class GalleryhomeVC: UIViewController {

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var EventtypeCollectionview: UICollectionView!
    @IBOutlet weak var eventsTableView: UITableView!

    private let categories = ["All", "Events", "Sports", "Academic", "Campus"]
    private var selectedIndex: Int = 0
    private var hasAlbums: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCategoryCollectionView()
        setupEventsTableView()
    }
    @IBAction func backBtnTapped(_ sender: UIButton) {
        popBack()
    }

    @objc private func backButtonTapped() {
        popBack()
    }

    private func popBack() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Category chips
    private func setupCategoryCollectionView() {
        EventtypeCollectionview.delegate = self
        EventtypeCollectionview.dataSource = self
        EventtypeCollectionview.backgroundColor = .clear
        EventtypeCollectionview.showsHorizontalScrollIndicator = false

        EventtypeCollectionview.register(
            UINib(nibName: "EventnameCLVcell", bundle: nil),
            forCellWithReuseIdentifier: "EventnameCLVcell"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        EventtypeCollectionview.collectionViewLayout = layout
    }

    // MARK: - TableView
    private func setupEventsTableView() {
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.backgroundColor = .clear
        eventsTableView.separatorStyle = .none
        eventsTableView.showsVerticalScrollIndicator = false

        eventsTableView.register(
            UINib(nibName: "ALLEventTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ALLEventTableViewCell"
        )

        eventsTableView.register(
            UINib(nibName: "SingleeventTableViewCell", bundle: nil),
            forCellReuseIdentifier: "SingleeventTableViewCell"
        )

        eventsTableView.register(
            EmtyalbumsTableViewCell.self,
            forCellReuseIdentifier: "EmtyalbumsTableViewCell"
        )
    }

    // MARK: - Navigation
    private func navigateToSingleEventGallery(albumIndex: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)   // change name if needed
        
        // Option A: Storyboard ID
        if let vc = storyboard.instantiateViewController(
            withIdentifier: "SingleeventsGalleryVC"
        ) as? SingleeventsGalleryVC {
            // Pass data if you want
            // vc.albumId = ...
            // vc.albumTitle = ...
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        // Option B: Pure code (if no storyboard)
        let vc = SingleeventsGalleryVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionView (Categories)
extension GalleryhomeVC: UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EventnameCLVcell",
            for: indexPath
        ) as! EventnameCLVcell

        cell.configure(title: categories[indexPath.item],
                       isSelected: indexPath.item == selectedIndex)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previous = selectedIndex
        selectedIndex = indexPath.item

        var reload = [indexPath]
        if previous != selectedIndex {
            reload.append(IndexPath(item: previous, section: 0))
        }
        collectionView.reloadItems(at: reload)
        eventsTableView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = categories[indexPath.item] as NSString
        let font = UIFont.systemFont(ofSize: 13, weight: .medium)
        let textWidth = title.size(withAttributes: [.font: font]).width
        return CGSize(width: max(textWidth + 28, 54), height: 36)
    }
}

// MARK: - UITableView
extension GalleryhomeVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // EMPTY STATE
        if !hasAlbums {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "EmtyalbumsTableViewCell",
                for: indexPath
            ) as! EmtyalbumsTableViewCell

            cell.configure(category: categories[selectedIndex])
            cell.onBrowseAllTapped = { [weak self] in
                guard let self = self else { return }
                self.selectedIndex = 0
                self.hasAlbums = true
                self.EventtypeCollectionview.reloadData()
                self.eventsTableView.reloadData()
                self.EventtypeCollectionview.scrollToItem(
                    at: IndexPath(item: 0, section: 0),
                    at: .left,
                    animated: true
                )
            }
            return cell
        }

        // ALL tab
        if selectedIndex == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ALLEventTableViewCell",
                for: indexPath
            ) as! ALLEventTableViewCell

            // ✅ Tap on any grid cell
            cell.onAlbumTapped = { [weak self] albumIndex in
                self?.navigateToSingleEventGallery(albumIndex: albumIndex)
            }
            return cell
        }

        // Other categories
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SingleeventTableViewCell",
            for: indexPath
        ) as! SingleeventTableViewCell

        cell.configure(category: categories[selectedIndex])

        // ✅ Tap on any album card
        cell.onAlbumTapped = { [weak self] albumIndex in
            self?.navigateToSingleEventGallery(albumIndex: albumIndex)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !hasAlbums { return 480 }
        return 1000
    }
}

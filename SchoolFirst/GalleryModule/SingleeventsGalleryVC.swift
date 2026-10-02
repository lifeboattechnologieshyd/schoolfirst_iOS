//
//  SingleeventsGalleryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/09/26.
//

import UIKit

// MARK: - Simple model (replace with API model later)
enum MediaType {
    case image
    case video
}

struct GalleryItem {
    let id: Int
    let imageName: String
    let type: MediaType
}

class SingleeventsGalleryVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var Collectionview: UICollectionView!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Data (pass from previous screen)
    var albumTitle: String = "Annual Sports Day 2026"
    var albumIndex: Int = 0
    var categoryBadge: String = "SPORTS"

    // Dummy data using your Assets image "Media"
    private var items: [GalleryItem] = [
        GalleryItem(id: 1,  imageName: "Media", type: .image),
        GalleryItem(id: 2,  imageName: "Media", type: .image),
        GalleryItem(id: 3,  imageName: "Media", type: .image),
        GalleryItem(id: 4,  imageName: "Media", type: .video),
        GalleryItem(id: 5,  imageName: "Media", type: .image),
        GalleryItem(id: 6,  imageName: "Media", type: .image),
        GalleryItem(id: 7,  imageName: "Media", type: .video),
        GalleryItem(id: 8,  imageName: "Media", type: .image),
        GalleryItem(id: 9,  imageName: "Media", type: .image),
        GalleryItem(id: 10, imageName: "Media", type: .image),
        GalleryItem(id: 11, imageName: "Media", type: .image),
        GalleryItem(id: 12, imageName: "Media", type: .video)
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
    }

    // MARK: - CollectionView Setup
    private func setupCollectionView() {
        Collectionview.delegate = self
        Collectionview.dataSource = self
        Collectionview.backgroundColor = .white
        Collectionview.showsVerticalScrollIndicator = false
        Collectionview.alwaysBounceVertical = true

        // Register your XIB cell
        Collectionview.register(
            UINib(nibName: "ImageCLVcell", bundle: nil),
            forCellWithReuseIdentifier: "ImageCLVcell"
        )

        // 3-column grid layout (Figma style)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        Collectionview.collectionViewLayout = layout
    }

    // MARK: - Back Button
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

    // MARK: - Navigation to Full Image
    private func openFullImage(item: GalleryItem, index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Prefer Storyboard ID if you set it
        if let vc = storyboard.instantiateViewController(withIdentifier: "FullimageVC") as? FullimageVC {
            vc.imageName = item.imageName
            vc.albumTitle = albumTitle
            vc.selectedIndex = index
            navigationController?.pushViewController(vc, animated: true)
            return
        }

        // Fallback pure code
        let vc = FullimageVC()
        vc.imageName = item.imageName
        vc.albumTitle = albumTitle
        vc.selectedIndex = index
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionView
extension SingleeventsGalleryVC: UICollectionViewDelegate,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ImageCLVcell",
            for: indexPath
        ) as! ImageCLVcell

        let item = items[indexPath.item]
        cell.configure(imageName: item.imageName, isVideo: item.type == .video)
        return cell
    }

    // 3 equal columns (like Figma)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset: CGFloat = 16
        let spacing: CGFloat = 8
        let totalSpacing = (inset * 2) + (spacing * 2)   // left + right + 2 gaps
        let width = (collectionView.bounds.width - totalSpacing) / 3
        return CGSize(width: floor(width), height: floor(width)) // square cells
    }

    // TAP → FullimageVC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]

        if item.type == .video {
            // Later: navigate to VideoPlayerVC
            // For now also open FullimageVC or your video screen
            openFullImage(item: item, index: indexPath.item)
        } else {
            openFullImage(item: item, index: indexPath.item)
        }
    }
}

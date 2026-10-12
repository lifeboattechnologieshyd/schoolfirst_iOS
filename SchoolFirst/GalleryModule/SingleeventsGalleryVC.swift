import UIKit

enum MediaType { case image, video }
struct GalleryItem {
    let id: String
    let url: String
    let type: MediaType
    let order: Int
    let caption: String?
}

class SingleeventsGalleryVC: UIViewController {

    @IBOutlet weak var CatogeryLabel: UILabel!
    @IBOutlet weak var EventcatoryandacadamicyearLabel: UILabel!
    @IBOutlet weak var NumberofimagesLabel: UILabel!
    @IBOutlet weak var ImagetitleLabel: UILabel!
    @IBOutlet weak var Collectionview: UICollectionView!
    @IBOutlet weak var ImagedateandnumberofimagesandphotosLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Incoming Data from API
    var album: GalleryAlbum?
    private var items: [GalleryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        parseAlbumMedia()
    }

    private func parseAlbumMedia() {
        guard let album = album else { return }
        var temp: [GalleryItem] = []
        
        album.images.forEach {
            temp.append(GalleryItem(id: $0.id, url: $0.image, type: .image, order: $0.displayOrder, caption: $0.caption))
        }
        album.videos.forEach {
            temp.append(GalleryItem(id: $0.id, url: $0.video, type: .video, order: $0.displayOrder, caption: $0.caption))
        }
        
        items = temp.sorted { $0.order < $1.order }
        
        ImagetitleLabel.text = album.title
        ImagedateandnumberofimagesandphotosLabel.text = album.metaText
        
        // MARK: - API Data Configuration
        CatogeryLabel.text = album.category?.name
        
        if let categoryName = album.category?.name, !categoryName.isEmpty {
            EventcatoryandacadamicyearLabel.text = "\(categoryName) album"
        } else {
            EventcatoryandacadamicyearLabel.text = album.academicYear?.name ?? ""
        }
        
        // Configure moments count label (Figma style: "52 moments")
        NumberofimagesLabel.text = "\(items.count) moments"
        
        Collectionview.reloadData()
    }

    private func setupCollectionView() {
        Collectionview.delegate = self
        Collectionview.dataSource = self
        Collectionview.register(UINib(nibName: "ImageCLVcell", bundle: nil), forCellWithReuseIdentifier: "ImageCLVcell")
        
        if let layout = Collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            // Figma: 3 columns, tighter spacing
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
            layout.estimatedItemSize = .zero
        }
        
        Collectionview.showsVerticalScrollIndicator = false
        Collectionview.contentInsetAdjustmentBehavior = .always
    }

    @IBAction func backBtnTapped(_ sender: UIButton) { navigationController?.popViewController(animated: true) }

    private func openFullImage(index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "FullimageVC") as? FullimageVC {
            vc.items = items
            vc.currentIndex = index
            vc.album = album
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = FullimageVC()
        vc.items = items
        vc.currentIndex = index
        vc.album = album
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SingleeventsGalleryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCLVcell", for: indexPath) as! ImageCLVcell
        let item = items[indexPath.item]
        cell.configure(imageURL: item.url, isVideo: item.type == .video)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        if item.type == .video {
            openVideoPlayer(index: indexPath.item)
        } else {
            openFullImage(index: indexPath.item)
        }
    }

    private func openVideoPlayer(index: Int) {
        let vc = VedioplayerviewVC()
        vc.items = items
        vc.currentIndex = index
        vc.album = album
        vc.videoURLString = items[index].url
        vc.videoTitle = items[index].caption ?? album?.title ?? "Video"
        vc.videoDescription = album?.description ?? ""
        vc.albumTitle = album?.title ?? ""
        
        let videoItems = items.filter { $0.type == .video }
        let videoIndex = videoItems.firstIndex(where: { $0.id == items[index].id }) ?? 0
        vc.subtitleText = "\(videoIndex + 1) of \(videoItems.count) videos"
        
        vc.videoDate = album?.formattedEventDate ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 3 columns grid (Figma) + dynamic square height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16          // left/right inset
        let spacing: CGFloat = 8           // space between cells
        let numberOfColumns: CGFloat = 3   // Figma: 3 per row
        
        let totalSpacing = (padding * 2) + (spacing * (numberOfColumns - 1))
        let width = floor((collectionView.bounds.width - totalSpacing) / numberOfColumns)
        
        // Dynamic square height based on width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

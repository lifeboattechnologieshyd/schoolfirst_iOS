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
        
        Collectionview.reloadData()
    }

    private func setupCollectionView() {
        Collectionview.delegate = self
        Collectionview.dataSource = self
        Collectionview.register(UINib(nibName: "ImageCLVcell", bundle: nil), forCellWithReuseIdentifier: "ImageCLVcell")
        
        if let layout = Collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return items.count }
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
        vc.subtitleText = "\(index + 1) of \(items.filter { $0.type == .video }.count) videos"
        vc.videoDate = album?.formattedEventDate ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let spacing: CGFloat = 12
        let numberOfColumns: CGFloat = 2
        let totalSpacing = (padding * 2) + (spacing * (numberOfColumns - 1))
        let width = floor((collectionView.bounds.width - totalSpacing) / numberOfColumns)
        return CGSize(width: width, height: width)
    }
}

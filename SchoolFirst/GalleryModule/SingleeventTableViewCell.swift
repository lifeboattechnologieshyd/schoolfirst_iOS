import UIKit

class SingleeventTableViewCell: UITableViewCell {
    @IBOutlet weak var NumberofAlbumsLabel: UILabel!
    @IBOutlet weak var YearLabel: UILabel!
    @IBOutlet weak var TypeofEventLabel: UILabel!
    @IBOutlet weak var Imagegridcollectionview: UICollectionView!

    @IBOutlet weak var AcadamicyearLabel: UILabel!
    @IBOutlet weak var CategorytypeLabel: UILabel!
    @IBOutlet weak var NumberofalbumsandmomentsLabel: UILabel!
    var onAlbumTapped: ((Int) -> Void)?
    private var albums: [GalleryAlbum] = [] // API Model

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        Imagegridcollectionview.delegate = self
        Imagegridcollectionview.dataSource = self
        Imagegridcollectionview.register(UINib(nibName: "SingleeventCLVcell", bundle: nil), forCellWithReuseIdentifier: "SingleeventCLVcell")
    }

    func configure(category: String, albums: [GalleryAlbum]) {
        self.albums = albums
        
        // Category
        TypeofEventLabel.text = category
        CategorytypeLabel.text = category
        
        // Academic year
        let yearText = albums.first?.academicYear?.name ?? ""
        YearLabel.text = yearText
        AcadamicyearLabel.text = yearText
        
        // Albums + moments count
        let totalMedia = albums.reduce(0) { $0 + $1.imageCount + $1.videoCount }
        let albumsMomentsText = "\(albums.count) albums • \(totalMedia) moments"
        NumberofAlbumsLabel.text = albumsMomentsText
        NumberofalbumsandmomentsLabel.text = albumsMomentsText
        
        Imagegridcollectionview.reloadData()
    }
}

extension SingleeventTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return albums.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleeventCLVcell", for: indexPath) as! SingleeventCLVcell
        let item = albums[indexPath.item]
        cell.configure(title: item.title, subtitle: item.description ?? "", meta: item.metaText, badge: item.category?.name ?? "", imageURL: item.coverImageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { onAlbumTapped?(indexPath.item) }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 236)
    }
}

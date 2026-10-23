import UIKit

class ALLEventTableViewCell: UITableViewCell {
    @IBOutlet weak var Allimagesgridcollectionview: UICollectionView!
    var onAlbumTapped: ((Int) -> Void)?
    @IBOutlet weak var Viewallbutton: UIButton!
    
    // ✅ NEW: tell GalleryhomeVC to expand
    var onViewAllTapped: (() -> Void)?
    
    @IBOutlet weak var ImagecountLabel: UILabel!
    @IBOutlet weak var ImagedescriptionLabel: UILabel!
    @IBOutlet weak var ImagetitleLabel: UILabel!
    @IBOutlet weak var Latestimageview: UIImageView!
    
    private var albums: [GalleryAlbum] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCollectionView()
        Latestimageview.contentMode = .scaleAspectFill
        Latestimageview.clipsToBounds = true
        
        // ✅ NEW
        Viewallbutton.addTarget(self, action: #selector(viewAllTapped), for: .touchUpInside)
    }
    
    @objc private func viewAllTapped() {
        onViewAllTapped?()
    }
    
    private func setupCollectionView() {
        Allimagesgridcollectionview.delegate = self
        Allimagesgridcollectionview.dataSource = self
        Allimagesgridcollectionview.register(UINib(nibName: "AllimagesCLVCell", bundle: nil), forCellWithReuseIdentifier: "AllimagesCLVCell")
        
        if let layout = Allimagesgridcollectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        }
    }
    
    func configure(with data: [GalleryAlbum]) {
        self.albums = data
        Allimagesgridcollectionview.reloadData()
        
        guard let firstAlbum = data.first else {
            ImagetitleLabel.text = ""
            ImagedescriptionLabel.text = ""
            ImagecountLabel.text = ""
            Latestimageview.image = nil
            return
        }
        
        ImagetitleLabel.text = firstAlbum.title
        ImagedescriptionLabel.text = firstAlbum.description ?? ""
        ImagecountLabel.text = firstAlbum.metaText
       
        if let coverURLString = firstAlbum.coverImageURL,
           let url = URL(string: coverURLString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        self?.Latestimageview.image = UIImage(data: imageData)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.Latestimageview.image = nil
                    }
                }
            }
        } else {
            Latestimageview.image = nil
        }
    }
}

extension ALLEventTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return albums.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllimagesCLVCell", for: indexPath) as! AllimagesCLVCell
        let item = albums[indexPath.item]
        cell.configure(title: item.title, eventType: item.category?.name ?? "", dateText: item.metaText, imageURL: item.coverImageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { onAlbumTapped?(indexPath.item) }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sidePadding: CGFloat = 32
        let interItemSpacing: CGFloat = 12
        let width = floor((collectionView.bounds.width - sidePadding - interItemSpacing) / 2)
        return CGSize(width: width, height: 172)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

import UIKit

class ImageCLVcell: UICollectionViewCell {
    @IBOutlet weak var imageview: UIImageView!
    private let playIcon = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // ... (Keep your UI setup code here)
        playIcon.image = UIImage(systemName: "play.circle.fill")
        playIcon.tintColor = .white
        playIcon.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        playIcon.layer.cornerRadius = 14
        playIcon.isHidden = true
        playIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playIcon)
        NSLayoutConstraint.activate([
            playIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            playIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            playIcon.widthAnchor.constraint(equalToConstant: 28),
            playIcon.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(imageURL: String, isVideo: Bool = false) {
        // If it's a video, the url is a .mp4. We need a thumbnail generator eventually,
        // but for now, just fallback to placeholder or image.
        if isVideo {
            imageview.image = UIImage(systemName: "video") // Placeholder for video
        } else {
            imageview.loadAsync(from: imageURL)
        }
        playIcon.isHidden = !isVideo
    }
}

//
//  ImageCLVcell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/09/26.
//

import UIKit

class ImageCLVcell: UICollectionViewCell {

    @IBOutlet weak var imageview: UIImageView!
    
    private let playIcon = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // Image
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        imageview.layer.cornerRadius = 8
        imageview.backgroundColor = UIColor(white: 0.93, alpha: 1)

        // Play icon (for videos)
        playIcon.image = UIImage(systemName: "play.circle.fill")
        playIcon.tintColor = .white
        playIcon.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        playIcon.layer.cornerRadius = 14
        playIcon.clipsToBounds = true
        playIcon.translatesAutoresizingMaskIntoConstraints = false
        playIcon.isHidden = true
        contentView.addSubview(playIcon)

        NSLayoutConstraint.activate([
            playIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            playIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            playIcon.widthAnchor.constraint(equalToConstant: 28),
            playIcon.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(imageName: String, isVideo: Bool = false) {
        imageview.image = UIImage(named: imageName) ?? UIImage(named: "Media")
        playIcon.isHidden = !isVideo
    }
}

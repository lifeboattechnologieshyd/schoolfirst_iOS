//
//  PTMhomeTableViewCell1TableViewCell2.swift
//  SchoolFirst
//

import UIKit

class PTMhomeTableViewCell1TableViewCell2: UITableViewCell {

    @IBOutlet weak var collectionview: UICollectionView!

    var meetingsData: [Any] = [1, 2, 3]

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        applyFigmaStyling()
    }

    private func setupCollectionView() {
        let nib = UINib(
            nibName: "PTMcompletedmeetingsCollectionViewCell",
            bundle: nil
        )

        collectionview.register(
            nib,
            forCellWithReuseIdentifier: "PTMcompletedmeetingsCollectionViewCell"
        )

        collectionview.delegate = self
        collectionview.dataSource = self

        if let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            // Figma look: 1px separator line between cells
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        // Background color acts as the separator line color
        collectionview.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        collectionview.showsVerticalScrollIndicator = false
    }
    
    private func applyFigmaStyling() {
        // 1. Border and Corner Radius
        collectionview.layer.cornerRadius = 12 // Matches Figma card rounding
        collectionview.layer.borderWidth = 1.0
        collectionview.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        collectionview.clipsToBounds = true
        
        // 2. Shadow (Applied to the Cell's content view or a wrapper if necessary)
        // Note: For a true Figma shadow, the TableViewCell background should be clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        // Shadow configuration on the collection view's layer parent or the container
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
    }

    func configure(with data: [Any]) {
        meetingsData = data
        collectionview.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - CollectionView Extension

extension PTMhomeTableViewCell1TableViewCell2: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meetingsData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PTMcompletedmeetingsCollectionViewCell",
            for: indexPath
        ) as! PTMcompletedmeetingsCollectionViewCell

        // Ensure cell background is white to hide the collectionview background color
        cell.backgroundColor = .white
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use full width of collection view
        return CGSize(width: collectionView.frame.width, height: 81)
    }
}

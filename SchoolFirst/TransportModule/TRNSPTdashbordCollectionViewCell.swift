//
//  TRNSPTdashbordCollectionViewCell.swift
//  SchoolFirst
//

import UIKit

class TRNSPTdashbordCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var CardBackgroundView: UIView!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var ImageView: UIImageView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        // ── DEBUG: verify outlets ─────────────────────────────────────────
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 TRNSPTdashbordCollectionViewCell outlets:")
        print("   CardBackgroundView :", CardBackgroundView == nil ? "❌ NIL" : "✅ connected")
        print("   TitleLbl           :", TitleLbl           == nil ? "❌ NIL" : "✅ connected")
        print("   DescriptionLbl     :", DescriptionLbl     == nil ? "❌ NIL" : "✅ connected")
        print("   ImageView          :", ImageView          == nil ? "❌ NIL" : "✅ connected")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        setupDefaultUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        TitleLbl?.text                     = nil
        DescriptionLbl?.text               = nil
        ImageView?.image                   = nil
        CardBackgroundView?.backgroundColor = .clear
    }

    // MARK: - Default UI
    private func setupDefaultUI() {
        CardBackgroundView?.layer.cornerRadius = 12
        CardBackgroundView?.clipsToBounds      = true

        contentView.backgroundColor = .clear
        backgroundColor             = .clear

     //   TitleLbl?.textColor       = .black
        //TitleLbl?.font            = UIFont.systemFont(ofSize: 12, weight: .semibold)
       // TitleLbl?.numberOfLines   = 2
       // TitleLbl?.textAlignment   = .center

       // DescriptionLbl?.textColor     = .darkGray
       // DescriptionLbl?.font          = UIFont.systemFont(ofSize: 9, weight: .regular)
       // DescriptionLbl?.numberOfLines = 2
      //  DescriptionLbl?.textAlignment = .center

       // ImageView?.contentMode   = .scaleAspectFit
       // ImageView?.clipsToBounds = true
    }

    // MARK: - Configure
    func configure(title: String,
                   description: String,
                   imageName: String,
                   backgroundColor: UIColor,
                   iconTint: UIColor) {

        TitleLbl?.text       = title
        DescriptionLbl?.text = description
        CardBackgroundView?.backgroundColor = backgroundColor

        if let assetImage = UIImage(named: imageName) {
            ImageView?.image = assetImage.withRenderingMode(.alwaysTemplate)
        } else {
            ImageView?.image = UIImage(systemName: imageName)
        }
        ImageView?.tintColor = iconTint

        print("🎨 Cell configured: \(title) | bg: \(backgroundColor) | icon: \(imageName)")
    }
}

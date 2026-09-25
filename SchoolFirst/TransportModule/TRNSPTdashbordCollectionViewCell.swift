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
        TitleLbl?.text                      = nil
        DescriptionLbl?.text                = nil
        ImageView?.image                    = nil
        CardBackgroundView?.backgroundColor = .clear
        CardBackgroundView?.layer.borderColor = nil
    }

    // MARK: - Default UI
    private func setupDefaultUI() {
        CardBackgroundView?.layer.cornerRadius = 14
        CardBackgroundView?.clipsToBounds      = true
        CardBackgroundView?.layer.borderWidth  = 1.0 // Subtle border to match Figma

        contentView.backgroundColor = .clear
        backgroundColor             = .clear

        // MARK: - Title Label Setup (Thick/Bold)
        TitleLbl?.font                      = .hankenBold(size: 11)
        TitleLbl?.textAlignment            = .center
        TitleLbl?.numberOfLines            = 2
        TitleLbl?.lineBreakMode            = .byWordWrapping
        TitleLbl?.adjustsFontSizeToFitWidth = true
        TitleLbl?.minimumScaleFactor       = 0.75

        // MARK: - Description Label Setup
        DescriptionLbl?.font                      = .hankenRegular(size: 9)
        DescriptionLbl?.textAlignment            = .center
        DescriptionLbl?.numberOfLines            = 2
        DescriptionLbl?.lineBreakMode            = .byWordWrapping
        DescriptionLbl?.adjustsFontSizeToFitWidth = true
        DescriptionLbl?.minimumScaleFactor       = 0.75
    }

    // MARK: - Configure
    func configure(title: String,
                   description: String,
                   imageName: String,
                   backgroundColor: UIColor,
                   iconTint: UIColor,
                   borderColor: UIColor) {

        TitleLbl?.text       = title
        DescriptionLbl?.text = description
        
        // Fill and Border
        CardBackgroundView?.backgroundColor = backgroundColor
        CardBackgroundView?.layer.borderColor = borderColor.cgColor

        if let assetImage = UIImage(named: imageName) {
            ImageView?.image = assetImage.withRenderingMode(.alwaysTemplate)
        } else {
            ImageView?.image = UIImage(systemName: imageName)
        }
        ImageView?.tintColor = iconTint

        print("🎨 Cell configured: \(title)")
    }
}

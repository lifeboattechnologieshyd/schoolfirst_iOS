//
//  TRNSPTTodayJourneyCollectionViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/07/26.
//

import UIKit

class TRNSPTTodayJourneyCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var LocationLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var Backgroundview: UIView!
    @IBOutlet weak var ImageView: UIImageView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        // ── DEBUG ─────────────────────────────────────────────────────────
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 TRNSPTTodayJourneyCollectionViewCell outlets:")
        print("   Backgroundview :", Backgroundview == nil ? "❌ NIL" : "✅")
        print("   ImageView      :", ImageView      == nil ? "❌ NIL" : "✅")
        print("   TitleLbl       :", TitleLbl       == nil ? "❌ NIL" : "✅")
        print("   TimeLbl        :", TimeLbl        == nil ? "❌ NIL" : "✅")
        print("   LocationLbl    :", LocationLbl    == nil ? "❌ NIL" : "✅")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        setupDefaultUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        TitleLbl?.text      = nil
        TimeLbl?.text       = nil
        LocationLbl?.text   = nil
        ImageView?.image    = nil
        Backgroundview?.backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Make Backgroundview a perfect circle
        Backgroundview?.layer.cornerRadius = (Backgroundview?.frame.height ?? 0) / 2
        Backgroundview?.clipsToBounds      = true
    }

    // MARK: - Default UI
    private func setupDefaultUI() {
        contentView.backgroundColor = .clear
        backgroundColor             = .clear

        // ── Icon background (circle) ──────────────────────────────────────
        Backgroundview?.clipsToBounds = true

        // ── ImageView ────────────────────────────────────────────────────
        ImageView?.contentMode   = .scaleAspectFit
        ImageView?.clipsToBounds = true

        // ── Title label ──────────────────────────────────────────────────
        TitleLbl?.textColor       = .black
        TitleLbl?.font            = UIFont.systemFont(ofSize: 15, weight: .semibold)
        TitleLbl?.numberOfLines   = 1

        // ── Time label ───────────────────────────────────────────────────
        TimeLbl?.textColor        = .gray
        TimeLbl?.font             = UIFont.systemFont(ofSize: 12, weight: .regular)
        TimeLbl?.numberOfLines    = 1

        // ── Location label ───────────────────────────────────────────────
        LocationLbl?.textColor      = .darkGray
        LocationLbl?.font           = UIFont.systemFont(ofSize: 13, weight: .regular)
        LocationLbl?.numberOfLines  = 2
        LocationLbl?.textAlignment  = .right
        LocationLbl?.lineBreakMode  = .byWordWrapping
    }

    // MARK: - Configure
    func configure(title: String,
                   time: String,
                   location: String,
                   imageName: String,
                   iconTint: UIColor,
                   iconBackground: UIColor) {

        TitleLbl?.text    = title
        TimeLbl?.text     = time
        LocationLbl?.text = location

        Backgroundview?.backgroundColor = iconBackground

        // Icon (SF Symbol fallback if asset not found)
        if let assetImage = UIImage(named: imageName) {
            ImageView?.image = assetImage.withRenderingMode(.alwaysTemplate)
        } else {
            ImageView?.image = UIImage(systemName: imageName)
        }
        ImageView?.tintColor = iconTint

        // Ensure circle is applied immediately
        Backgroundview?.setNeedsLayout()
        Backgroundview?.layoutIfNeeded()
        Backgroundview?.layer.cornerRadius = (Backgroundview?.frame.height ?? 0) / 2

        print("✅ Journey cell configured → \(title) | \(time) | \(location)")
    }
}

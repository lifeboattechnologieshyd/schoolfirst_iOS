//
//  NotificationTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 10/06/26.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var Timebadge: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var Notificationtitle: UILabel!
    @IBOutlet weak var NotificationImage: UIImageView!
    @IBOutlet weak var ImageBackgroundView: UIView!
    @IBOutlet weak var ContainerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // MARK: - Container View Styling (Figma Style)

        ContainerView.backgroundColor = .white
        ContainerView.layer.cornerRadius = 12

        ContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        ContainerView.layer.shadowOpacity = 0.12
        ContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        ContainerView.layer.shadowRadius = 6
        ContainerView.layer.masksToBounds = false

        // MARK: - Image Background View

        ImageBackgroundView.layer.cornerRadius = 10
        ImageBackgroundView.clipsToBounds = true

        // MARK: - Notification Image

        NotificationImage.contentMode = .scaleAspectFit

        // MARK: - Labels

        Notificationtitle.numberOfLines = 2
        Description.numberOfLines = 2
        Description.lineBreakMode = .byTruncatingTail

        Timebadge.textColor = .gray
        Timebadge.font = UIFont.systemFont(ofSize: 11)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Better shadow performance
        ContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: ContainerView.bounds,
            cornerRadius: 12
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        NotificationImage.image = nil
        Notificationtitle.text = nil
        Description.text = nil
        Timebadge.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

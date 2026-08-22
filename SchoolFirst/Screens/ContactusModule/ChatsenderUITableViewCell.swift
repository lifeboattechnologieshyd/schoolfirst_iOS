//
//  ChatsenderUITableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/08/26.
//

import UIKit

class ChatsenderUITableViewCell: UITableViewCell {

    // MARK: - UI Elements

    private let messageBubbleView: UIView = {

        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = UIColor(
            red: 31 / 255,
            green: 71 / 255,
            blue: 127 / 255,
            alpha: 1
        )

        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true

        return view
    }()

    private let messageLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .white

        label.font = UIFont.systemFont(
            ofSize: 15,
            weight: .regular
        )

        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        return label
    }()

    private let timeLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .systemGray

        label.font = UIFont.systemFont(
            ofSize: 11,
            weight: .regular
        )

        label.textAlignment = .right
        label.numberOfLines = 1

        return label
    }()

    private let deliveryImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.image = UIImage(
            systemName: "checkmark"
        )

        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupMessageBubble()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        messageLabel.text = nil
        timeLabel.text = nil
    }

    // MARK: - Setup

    private func setupMessageBubble() {

        contentView.addSubview(
            messageBubbleView
        )

        messageBubbleView.addSubview(
            messageLabel
        )

        contentView.addSubview(
            timeLabel
        )

        contentView.addSubview(
            deliveryImageView
        )

        NSLayoutConstraint.activate([

            // MARK: Message Bubble

            messageBubbleView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 8
            ),

            messageBubbleView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),

            messageBubbleView.leadingAnchor.constraint(
                greaterThanOrEqualTo:
                    contentView.leadingAnchor,
                constant: 60
            ),

            messageBubbleView.widthAnchor.constraint(
                lessThanOrEqualTo:
                    contentView.widthAnchor,
                multiplier: 0.75
            ),

            // MARK: Message Label

            messageLabel.topAnchor.constraint(
                equalTo: messageBubbleView.topAnchor,
                constant: 10
            ),

            messageLabel.leadingAnchor.constraint(
                equalTo: messageBubbleView.leadingAnchor,
                constant: 12
            ),

            messageLabel.trailingAnchor.constraint(
                equalTo: messageBubbleView.trailingAnchor,
                constant: -12
            ),

            messageLabel.bottomAnchor.constraint(
                equalTo: messageBubbleView.bottomAnchor,
                constant: -10
            ),

            // MARK: Delivery Image

            deliveryImageView.topAnchor.constraint(
                equalTo: messageBubbleView.bottomAnchor,
                constant: 4
            ),

            deliveryImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),

            deliveryImageView.widthAnchor.constraint(
                equalToConstant: 14
            ),

            deliveryImageView.heightAnchor.constraint(
                equalToConstant: 14
            ),

            // MARK: Time Label

            timeLabel.centerYAnchor.constraint(
                equalTo: deliveryImageView.centerYAnchor
            ),

            timeLabel.trailingAnchor.constraint(
                equalTo: deliveryImageView.leadingAnchor,
                constant: -4
            ),

            timeLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo:
                    contentView.leadingAnchor,
                constant: 16
            ),

            // This bottom constraint completes the dynamic-height chain.
            timeLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -8
            )
        ])
    }

    // MARK: - Configure

    func configure(
        message: String,
        time: String
    ) {

        messageLabel.text = message
        timeLabel.text = time
    }
}

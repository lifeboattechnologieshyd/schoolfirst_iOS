//
//  ChatsenderUITableViewCell.swift
//  SchoolFirst
//

import UIKit

class ChatsenderUITableViewCell: UITableViewCell {

    static let reuseId = "ChatsenderUITableViewCell"

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    private func setupUI() {

        // MARK: Cell

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // MARK: Bubble

        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        bubbleView.backgroundColor = UIColor(
            red: 0.93,
            green: 0.93,
            blue: 0.93,
            alpha: 1.0
        )

        bubbleView.layer.cornerRadius = 16
        bubbleView.clipsToBounds = true

        // MARK: Message

        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping

        messageLabel.font = UIFont.systemFont(
            ofSize: 13,
            weight: .regular
        )

        messageLabel.textColor = .black

        // MARK: Time

        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(
            ofSize: 10,
            weight: .medium
        )

        timeLabel.textColor = .gray

        timeLabel.textAlignment = .left

        timeLabel.numberOfLines = 1

        // MARK: Add Views

        contentView.addSubview(bubbleView)

        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)

        // MARK: Constraints

        NSLayoutConstraint.activate([

            // ==========================================
            // SENDER BUBBLE → LEFT SIDE
            // ==========================================

            bubbleView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),

            bubbleView.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -60
            ),

            bubbleView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 5
            ),

            bubbleView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -5
            ),

            // ==========================================
            // MESSAGE
            // ==========================================

            messageLabel.topAnchor.constraint(
                equalTo: bubbleView.topAnchor,
                constant: 10
            ),

            messageLabel.leadingAnchor.constraint(
                equalTo: bubbleView.leadingAnchor,
                constant: 12
            ),

            messageLabel.trailingAnchor.constraint(
                equalTo: bubbleView.trailingAnchor,
                constant: -12
            ),

            // ==========================================
            // TIME
            // ==========================================

            timeLabel.topAnchor.constraint(
                equalTo: messageLabel.bottomAnchor,
                constant: 5
            ),

            timeLabel.leadingAnchor.constraint(
                equalTo: bubbleView.leadingAnchor,
                constant: 12
            ),

            timeLabel.trailingAnchor.constraint(
                equalTo: bubbleView.trailingAnchor,
                constant: -12
            ),

            timeLabel.bottomAnchor.constraint(
                equalTo: bubbleView.bottomAnchor,
                constant: -9
            )
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        messageLabel.text = nil
        timeLabel.text = nil
    }

    func configure(
        message: String,
        time: String
    ) {

        messageLabel.text = message
        timeLabel.text = time

        setNeedsLayout()
    }
}

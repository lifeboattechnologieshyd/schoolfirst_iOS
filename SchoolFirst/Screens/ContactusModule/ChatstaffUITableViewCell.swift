//
//  ChatUserTableViewCell.swift
//  SchoolFirst
//

import UIKit

class ChatUserTableViewCell: UITableViewCell {

    static let reuseId = "ChatUserTableViewCell"

    // MARK: - UI Elements

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let checkImageView = UIImageView()

    // MARK: - Init

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

    // MARK: - Setup UI

    private func setupUI() {

        // MARK: Cell

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear


        // MARK: Blue Bubble

        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        bubbleView.backgroundColor = UIColor(
            red: 31.0 / 255.0,
            green: 71.0 / 255.0,
            blue: 127.0 / 255.0,
            alpha: 1.0
        )

        bubbleView.layer.cornerRadius = 16
        bubbleView.clipsToBounds = true


        // MARK: Message Label

        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping

        messageLabel.font = UIFont.systemFont(
            ofSize: 13,
            weight: .regular
        )

        messageLabel.textColor = .white


        // MARK: Time Label

        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(
            ofSize: 10,
            weight: .medium
        )

        timeLabel.textColor = UIColor.white.withAlphaComponent(0.85)

        timeLabel.textAlignment = .right

        timeLabel.numberOfLines = 1


        // MARK: Double Checkmark

        checkImageView.translatesAutoresizingMaskIntoConstraints = false

        // WhatsApp-style double check
        checkImageView.image = UIImage(
            systemName: "checkmark.double"
        )

        checkImageView.tintColor = .white

        checkImageView.contentMode = .scaleAspectFit

        checkImageView.isHidden = false


        // MARK: Add Views

        contentView.addSubview(bubbleView)

        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
        bubbleView.addSubview(checkImageView)


        // MARK: Constraints

        NSLayoutConstraint.activate([

            // ==========================================
            // USER BUBBLE - RIGHT SIDE
            // ==========================================

            bubbleView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),

            bubbleView.leadingAnchor.constraint(
                greaterThanOrEqualTo: contentView.leadingAnchor,
                constant: 60
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
                equalTo: checkImageView.leadingAnchor,
                constant: -5
            ),

            timeLabel.bottomAnchor.constraint(
                equalTo: bubbleView.bottomAnchor,
                constant: -9
            ),


            // ==========================================
            // DOUBLE CHECKMARK
            // ==========================================

            checkImageView.trailingAnchor.constraint(
                equalTo: bubbleView.trailingAnchor,
                constant: -10
            ),

            checkImageView.bottomAnchor.constraint(
                equalTo: bubbleView.bottomAnchor,
                constant: -8
            ),

            checkImageView.widthAnchor.constraint(
                equalToConstant: 16
            ),

            checkImageView.heightAnchor.constraint(
                equalToConstant: 14
            )
        ])
    }


    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        messageLabel.text = nil
        timeLabel.text = nil

        // Always show checkmark for user messages
        checkImageView.isHidden = false
    }


    // MARK: - Configure

    func configure(
        text: String,
        time: String
    ) {

        messageLabel.text = text
        timeLabel.text = time

        // Show double check
        checkImageView.isHidden = false

        setNeedsLayout()
        layoutIfNeeded()
    }
}

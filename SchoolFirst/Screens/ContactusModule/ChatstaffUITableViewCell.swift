//
//  ChatUserTableViewCell.swift
//  SchoolFirst
//

import UIKit

// MARK: - WhatsApp Tick Status Enum

enum MessageTickStatus {
    case sent       // Single check ✓
    case delivered  // Double check ✓✓ White
    case read       // Double check ✓✓ Light Blue
}

// MARK: - Chat User Cell

class ChatUserTableViewCell: UITableViewCell {

    static let reuseId = "ChatUserTableViewCell"

    // MARK: - UI Elements

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let checkImageView = UIImageView()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup UI

    private func setupUI() {

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

        messageLabel.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )

        // MARK: Time Label

        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(
            ofSize: 10,
            weight: .medium
        )

        timeLabel.textColor = UIColor.white.withAlphaComponent(0.85)

        timeLabel.textAlignment = .right
        timeLabel.numberOfLines = 1

        timeLabel.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )

        timeLabel.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        // MARK: Checkmark ImageView

        checkImageView.translatesAutoresizingMaskIntoConstraints = false

        checkImageView.contentMode = .scaleAspectFit
        checkImageView.clipsToBounds = false

        checkImageView.isHidden = false

        checkImageView.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )

        checkImageView.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        // MARK: Add Subviews

        contentView.addSubview(bubbleView)

        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
        bubbleView.addSubview(checkImageView)

        // MARK: Constraints

        NSLayoutConstraint.activate([

            // ------------------------------------------------
            // Bubble - Right Side
            // ------------------------------------------------

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
                constant: 4
            ),

            bubbleView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -4
            ),

            // ------------------------------------------------
            // Message Label
            // ------------------------------------------------

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

            // ------------------------------------------------
            // Time
            // ------------------------------------------------

            timeLabel.trailingAnchor.constraint(
                equalTo: checkImageView.leadingAnchor,
                constant: -4
            ),

            timeLabel.topAnchor.constraint(
                equalTo: messageLabel.bottomAnchor,
                constant: 5
            ),

            timeLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: bubbleView.leadingAnchor,
                constant: 12
            ),

            timeLabel.bottomAnchor.constraint(
                equalTo: bubbleView.bottomAnchor,
                constant: -8
            ),

            // ------------------------------------------------
            // Tick
            // ------------------------------------------------

            checkImageView.trailingAnchor.constraint(
                equalTo: bubbleView.trailingAnchor,
                constant: -10
            ),

            checkImageView.centerYAnchor.constraint(
                equalTo: timeLabel.centerYAnchor
            ),

            checkImageView.widthAnchor.constraint(
                equalToConstant: 20
            ),

            checkImageView.heightAnchor.constraint(
                equalToConstant: 14
            )
        ])

        // Default status
        applyTickStatus(.delivered)
    }

    // MARK: - Tick Icon

    private func applyTickStatus(_ status: MessageTickStatus) {

        checkImageView.isHidden = false

        switch status {

        case .sent:

            checkImageView.image = createTickImage(
                doubleTick: false,
                color: UIColor.white.withAlphaComponent(0.85)
            )

        case .delivered:

            checkImageView.image = createTickImage(
                doubleTick: true,
                color: .white
            )

        case .read:

            checkImageView.image = createTickImage(
                doubleTick: true,
                color: UIColor(
                    red: 0.41,
                    green: 0.82,
                    blue: 1.0,
                    alpha: 1.0
                )
            )
        }

        checkImageView.setNeedsDisplay()
        checkImageView.setNeedsLayout()
    }

    // MARK: - Create WhatsApp Style Tick Image

    private func createTickImage(
        doubleTick: Bool,
        color: UIColor
    ) -> UIImage {

        let width: CGFloat = doubleTick ? 20 : 12
        let height: CGFloat = 12

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(
                width: width,
                height: height
            )
        )

        return renderer.image { context in

            let cgContext = context.cgContext

            cgContext.setStrokeColor(color.cgColor)
            cgContext.setLineWidth(1.8)
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)

            if doubleTick {

                // First tick

                let firstPath = UIBezierPath()

                firstPath.move(
                    to: CGPoint(x: 1.0, y: 6.0)
                )

                firstPath.addLine(
                    to: CGPoint(x: 4.0, y: 9.0)
                )

                firstPath.addLine(
                    to: CGPoint(x: 10.0, y: 2.5)
                )

                cgContext.addPath(firstPath.cgPath)
                cgContext.strokePath()

                // Second tick

                let secondPath = UIBezierPath()

                secondPath.move(
                    to: CGPoint(x: 7.0, y: 6.0)
                )

                secondPath.addLine(
                    to: CGPoint(x: 10.0, y: 9.0)
                )

                secondPath.addLine(
                    to: CGPoint(x: 16.5, y: 2.5)
                )

                cgContext.addPath(secondPath.cgPath)
                cgContext.strokePath()

            } else {

                // Single tick

                let path = UIBezierPath()

                path.move(
                    to: CGPoint(x: 1.5, y: 6.0)
                )

                path.addLine(
                    to: CGPoint(x: 4.5, y: 9.0)
                )

                path.addLine(
                    to: CGPoint(x: 10.5, y: 2.5)
                )

                cgContext.addPath(path.cgPath)
                cgContext.strokePath()
            }
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {

        super.prepareForReuse()

        messageLabel.text = nil
        timeLabel.text = nil

        checkImageView.image = nil
        checkImageView.isHidden = false

        applyTickStatus(.delivered)
    }

    // MARK: - Configure

    func configure(
        text: String,
        time: String
    ) {

        configure(
            text: text,
            time: time,
            tickStatus: .delivered
        )
    }

    func configure(
        text: String,
        time: String,
        tickStatus: MessageTickStatus
    ) {

        messageLabel.text = text
        timeLabel.text = time

        applyTickStatus(tickStatus)

        checkImageView.isHidden = false

        setNeedsLayout()
        layoutIfNeeded()
    }
}

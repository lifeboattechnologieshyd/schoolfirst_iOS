//
//  ChatUserTableViewCell.swift
//  SchoolFirst
//

import UIKit

// MARK: - WhatsApp Tick Status Enum

enum MessageTickStatus {
    case sent        // Single check ✓
    case delivered   // Double check ✓✓ White
    case read        // Double check ✓✓ Light Blue
}

// MARK: - Chat User Cell

class ChatUserTableViewCell: UITableViewCell {

    static let reuseId = "ChatUserTableViewCell"

    // MARK: - UI Elements

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let checkImageView = UIImageView()
    private let attachmentImageView = UIImageView()

    private let mainStack = UIStackView()       // image + text + timeRow
    private let timeRowStack = UIStackView()    // spacer + time + ticks

    private var imageHeightConstraint: NSLayoutConstraint?
    private var imageWidthConstraint: NSLayoutConstraint?
    private var bubbleMaxWidthConstraint: NSLayoutConstraint?
    private var currentImageURL: String?

    // Max bubble width (~75% of screen)
    private var maxBubbleWidth: CGFloat {
        UIScreen.main.bounds.width * 0.72
    }

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

        // Bubble
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.backgroundColor = UIColor(
            red: 31.0 / 255.0,
            green: 71.0 / 255.0,
            blue: 127.0 / 255.0,
            alpha: 1.0
        )
        bubbleView.layer.cornerRadius = 16
        bubbleView.clipsToBounds = true

        // Main vertical stack
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 6

        // Attachment image
        attachmentImageView.translatesAutoresizingMaskIntoConstraints = false
        attachmentImageView.contentMode = .scaleAspectFill
        attachmentImageView.clipsToBounds = true
        attachmentImageView.layer.cornerRadius = 12
        attachmentImageView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        attachmentImageView.isHidden = true

        // Message
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        messageLabel.textColor = .white
        // CRITICAL: stops 1-character-wide wrapping
        messageLabel.preferredMaxLayoutWidth = maxBubbleWidth - 24

        messageLabel.setContentHuggingPriority(.required, for: .vertical)
        messageLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        // Time
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        timeLabel.textAlignment = .right
        timeLabel.numberOfLines = 1
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)

        // Tick
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        checkImageView.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            checkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkImageView.heightAnchor.constraint(equalToConstant: 14)
        ])

        // Time row: [spacer] [time] [tick]
        timeRowStack.axis = .horizontal
        timeRowStack.alignment = .center
        timeRowStack.spacing = 4
        timeRowStack.translatesAutoresizingMaskIntoConstraints = false

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        timeRowStack.addArrangedSubview(spacer)
        timeRowStack.addArrangedSubview(timeLabel)
        timeRowStack.addArrangedSubview(checkImageView)

        // Assemble stacks
        mainStack.addArrangedSubview(attachmentImageView)
        mainStack.addArrangedSubview(messageLabel)
        mainStack.addArrangedSubview(timeRowStack)

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(mainStack)

        // Image size (updated when showing/hiding image)
        let imgH = attachmentImageView.heightAnchor.constraint(equalToConstant: 0)
        let imgW = attachmentImageView.widthAnchor.constraint(equalToConstant: 0)
        imgH.priority = UILayoutPriority(999)
        imgW.priority = UILayoutPriority(999)
        imageHeightConstraint = imgH
        imageWidthConstraint = imgW

        // Cap bubble width so it never stretches full screen
        let maxW = bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: maxBubbleWidth)
        bubbleMaxWidthConstraint = maxW

        // Hug content horizontally so text bubbles size to text (not 1 char)
        bubbleView.setContentHuggingPriority(.required, for: .horizontal)
        bubbleView.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([

            // Bubble pinned to trailing (right side chat)
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            bubbleView.leadingAnchor.constraint(
                greaterThanOrEqualTo: contentView.leadingAnchor,
                constant: 60
            ),
            maxW,

            // Stack inside bubble
            mainStack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            mainStack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),

            imgH,
            imgW
        ])

        applyTickStatus(.delivered)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep preferred width in sync with rotation / size changes
        let width = maxBubbleWidth - 24
        if messageLabel.preferredMaxLayoutWidth != width {
            messageLabel.preferredMaxLayoutWidth = width
        }
        bubbleMaxWidthConstraint?.constant = maxBubbleWidth
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        messageLabel.text = nil
        messageLabel.isHidden = false
        timeLabel.text = nil

        checkImageView.image = nil
        checkImageView.isHidden = false

        hideImage()
        currentImageURL = nil

        applyTickStatus(.delivered)
    }

    // MARK: - Configure (text only – backward compatible)

    func configure(
        text: String,
        time: String,
        tickStatus: MessageTickStatus = .delivered
    ) {
        configure(
            text: text,
            time: time,
            tickStatus: tickStatus,
            attachmentUrls: nil,
            localImageData: nil
        )
    }

    // MARK: - Configure (with attachments)

    func configure(
        text: String,
        time: String,
        tickStatus: MessageTickStatus,
        attachmentUrls: [String]? = nil,
        localImageData: Data? = nil
    ) {

        timeLabel.text = formatMessageTime(from: time)
        applyTickStatus(tickStatus)
        checkImageView.isHidden = false

        // Clean text – hide paperclip / filename placeholders
        let trimmed = cleanedMessageText(text)
        let hasText = !trimmed.isEmpty

        messageLabel.text = hasText ? trimmed : nil
        messageLabel.isHidden = !hasText

        // preferred width so label measures correctly
        messageLabel.preferredMaxLayoutWidth = maxBubbleWidth - 24

        // Image priority: local preview → remote URL → none
        if let data = localImageData, let image = UIImage(data: data) {
            showImage(image)
        } else if let urlString = firstImageURL(from: attachmentUrls) {
            currentImageURL = urlString
            showPlaceholderImage()
            loadImage(from: urlString)
        } else if looksLikeImageFilename(trimmed),
                  let urlString = firstImageURL(from: attachmentUrls) {
            // safety fallback
            currentImageURL = urlString
            showPlaceholderImage()
            loadImage(from: urlString)
        } else {
            hideImage()
        }

        // If text is only a filename and we have/show an image, hide the text
        if attachmentImageView.isHidden == false && looksLikeImageFilename(trimmed) {
            messageLabel.text = nil
            messageLabel.isHidden = true
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Text helpers

    private func cleanedMessageText(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func looksLikeImageFilename(_ text: String) -> Bool {
        let t = text.lowercased()
        if t.isEmpty { return false }
        if t.hasPrefix("📎") { return true }
        if t.hasPrefix("photo_") { return true }
        let imageExt = [".jpg", ".jpeg", ".png", ".gif", ".heic", ".webp"]
        if imageExt.contains(where: { t.hasSuffix($0) }) && !t.contains(" ") {
            return true
        }
        return false
    }

    private func firstImageURL(from urls: [String]?) -> String? {
        guard let urls = urls else { return nil }
        return urls.first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    // MARK: - Image show / hide

    private func showImage(_ image: UIImage) {
        attachmentImageView.isHidden = false
        attachmentImageView.image = image

        // Fit image inside max bubble width
        let targetWidth = min(220, maxBubbleWidth - 20)
        let ratio = image.size.height / max(image.size.width, 1)
        let targetHeight = min(max(targetWidth * ratio, 120), 260)

        imageWidthConstraint?.constant = targetWidth
        imageHeightConstraint?.constant = targetHeight
    }

    private func showPlaceholderImage() {
        attachmentImageView.isHidden = false
        attachmentImageView.image = nil

        let targetWidth = min(220, maxBubbleWidth - 20)
        imageWidthConstraint?.constant = targetWidth
        imageHeightConstraint?.constant = 180
    }

    private func hideImage() {
        attachmentImageView.isHidden = true
        attachmentImageView.image = nil
        imageWidthConstraint?.constant = 0
        imageHeightConstraint?.constant = 0
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        if let cached = ChatImageCache.shared.image(for: urlString) {
            showImage(cached)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else { return }

            ChatImageCache.shared.set(image, for: urlString)

            DispatchQueue.main.async {
                guard self.currentImageURL == urlString else { return }
                self.showImage(image)
                self.refreshTableRowHeight()
            }
        }.resume()
    }

    private func refreshTableRowHeight() {
        guard let tableView = parentTableView() else { return }
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    private func parentTableView() -> UITableView? {
        var view: UIView? = superview
        while let current = view {
            if let table = current as? UITableView { return table }
            view = current.superview
        }
        return nil
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
                color: UIColor(red: 0.41, green: 0.82, blue: 1.0, alpha: 1.0)
            )
        }
    }

    private func createTickImage(doubleTick: Bool, color: UIColor) -> UIImage {
        let width: CGFloat = doubleTick ? 20 : 12
        let height: CGFloat = 12

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))

        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setStrokeColor(color.cgColor)
            cgContext.setLineWidth(1.8)
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)

            if doubleTick {
                let firstPath = UIBezierPath()
                firstPath.move(to: CGPoint(x: 1.0, y: 6.0))
                firstPath.addLine(to: CGPoint(x: 4.0, y: 9.0))
                firstPath.addLine(to: CGPoint(x: 10.0, y: 2.5))
                cgContext.addPath(firstPath.cgPath)
                cgContext.strokePath()

                let secondPath = UIBezierPath()
                secondPath.move(to: CGPoint(x: 7.0, y: 6.0))
                secondPath.addLine(to: CGPoint(x: 10.0, y: 9.0))
                secondPath.addLine(to: CGPoint(x: 16.5, y: 2.5))
                cgContext.addPath(secondPath.cgPath)
                cgContext.strokePath()
            } else {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 1.5, y: 6.0))
                path.addLine(to: CGPoint(x: 4.5, y: 9.0))
                path.addLine(to: CGPoint(x: 10.5, y: 2.5))
                cgContext.addPath(path.cgPath)
                cgContext.strokePath()
            }
        }
    }

    // MARK: - Format Message Time

    private func formatMessageTime(from dateString: String) -> String {
        guard let date = parseServerDate(dateString) else {
            return dateString
        }

        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "hh:mm a"
        let time = timeFormatter.string(from: date)

        if calendar.isDateInToday(date) {
            return time
        }

        if calendar.isDateInYesterday(date) {
            return "\(time) • Yesterday"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd MMM yyyy"
        return "\(time) • \(dateFormatter.string(from: date))"
    }

    private func parseServerDate(_ dateString: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()

        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) { return date }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) { return date }

        let customFormatter = DateFormatter()
        customFormatter.locale = Locale(identifier: "en_US_POSIX")

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "dd MMM yyyy, hh:mm a",
            "hh:mm a",
            "yyyy-MM-dd"
        ]

        for format in formats {
            customFormatter.dateFormat = format
            if let date = customFormatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
}

// MARK: - Image Cache

final class ChatImageCache {
    static let shared = ChatImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 100
    }

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func set(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

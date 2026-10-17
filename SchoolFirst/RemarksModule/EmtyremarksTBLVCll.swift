//
//  EmtyremarksTBLVCll.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 15/10/26.
//

import UIKit

class EmtyremarksTBLVCll: UITableViewCell {

    // MARK: - Views
    private let cardView = UIView()
    
    // MARK: - Top Header Views
    private let headerTitleLabel = UILabel()
    private let headerSubtitleLabel = UILabel()
    
    private let iconBackgroundView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    // MARK: - New Notification Banner Views
    private let notificationBannerView = UIView()
    private let bannerStackView = UIStackView()
    private let bellImageView = UIImageView()
    private let notificationLabel = UILabel()

    private let stackView = UIStackView()

    private var isConfigured = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Setup UI
    private func setupUI() {
        guard !isConfigured else { return }
        isConfigured = true

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupCardView()
        setupHeaderLabels()
        setupIconView()
        setupLabels()
        setupNotificationBanner()
        setupStackView()
        setupConstraints()
        configureDefaultContent()
    }

    private func setupCardView() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 0.89, green: 0.91, blue: 0.95, alpha: 1.0).cgColor
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
    }
    
    private func setupHeaderLabels() {
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Your remarks"
        headerTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        headerTitleLabel.textColor = UIColor(red: 0.12, green: 0.16, blue: 0.24, alpha: 1.0)
        
        headerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtitleLabel.text = "Stay updated on your child's feedback and observations."
        headerSubtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        headerSubtitleLabel.textColor = UIColor(red: 0.42, green: 0.48, blue: 0.60, alpha: 1.0)
        headerSubtitleLabel.numberOfLines = 0
        
        cardView.addSubview(headerTitleLabel)
        cardView.addSubview(headerSubtitleLabel)
    }

    private func setupIconView() {
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.backgroundColor = UIColor(red: 16/255.0, green: 185/255.0, blue: 129/255.0, alpha: 1.0)
        iconBackgroundView.layer.cornerRadius = 32
        iconBackgroundView.clipsToBounds = true

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor.white
        iconImageView.image = UIImage(systemName: "text.bubble")

        iconBackgroundView.addSubview(iconImageView)
    }

    private func setupLabels() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.12, green: 0.16, blue: 0.24, alpha: 1.0)
        titleLabel.numberOfLines = 0

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.42, green: 0.48, blue: 0.60, alpha: 1.0)
        subtitleLabel.numberOfLines = 0
    }
    
    private func setupNotificationBanner() {
        notificationBannerView.translatesAutoresizingMaskIntoConstraints = false
        notificationBannerView.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1.0)
        notificationBannerView.layer.cornerRadius = 12
        
        bannerStackView.translatesAutoresizingMaskIntoConstraints = false
        bannerStackView.axis = .horizontal
        bannerStackView.alignment = .center
        bannerStackView.spacing = 10
        
        bellImageView.translatesAutoresizingMaskIntoConstraints = false
        bellImageView.image = UIImage(systemName: "bell")
        bellImageView.tintColor = UIColor(red: 0.48, green: 0.64, blue: 0.94, alpha: 1.0)
        bellImageView.contentMode = .scaleAspectFit
        
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.text = "New remarks will show up here and we'll\nnotify you."
        notificationLabel.font = .systemFont(ofSize: 13, weight: .medium)
        notificationLabel.textColor = UIColor(red: 0.34, green: 0.40, blue: 0.52, alpha: 1.0)
        notificationLabel.numberOfLines = 0
        notificationLabel.textAlignment = .center
        
        bannerStackView.addArrangedSubview(bellImageView)
        bannerStackView.addArrangedSubview(notificationLabel)
        notificationBannerView.addSubview(bannerStackView)
    }

    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16

        stackView.addArrangedSubview(iconBackgroundView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(notificationBannerView)
        
        // Add extra spacing above the new banner to match Figma exactly
        stackView.setCustomSpacing(24, after: subtitleLabel)

        cardView.addSubview(stackView)
    }

    private func setupConstraints() {
        let cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        cardBottomConstraint.priority = .defaultHigh

        // Stack view top constraint updated to avoid overlapping the new header
        let stackTopConstraint = stackView.topAnchor.constraint(greaterThanOrEqualTo: headerSubtitleLabel.bottomAnchor, constant: 40)
        let stackBottomConstraint = stackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -28)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardBottomConstraint,
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 240),
            
            // MARK: - Header Constraints
            headerTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            headerTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            headerTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            headerSubtitleLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 6),
            headerSubtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            headerSubtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            // MARK: - Empty State Stack Constraints
            stackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            stackTopConstraint,
            stackBottomConstraint,
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            iconBackgroundView.widthAnchor.constraint(equalToConstant: 64),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 64),

            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            // MARK: - Banner Constraints
            bellImageView.widthAnchor.constraint(equalToConstant: 16),
            bellImageView.heightAnchor.constraint(equalToConstant: 16),
            
            bannerStackView.topAnchor.constraint(equalTo: notificationBannerView.topAnchor, constant: 14),
            bannerStackView.bottomAnchor.constraint(equalTo: notificationBannerView.bottomAnchor, constant: -14),
            bannerStackView.leadingAnchor.constraint(equalTo: notificationBannerView.leadingAnchor, constant: 16),
            bannerStackView.trailingAnchor.constraint(equalTo: notificationBannerView.trailingAnchor, constant: -16)
        ])
    }

    private func configureDefaultContent() {
        titleLabel.text = "No Remarks Yet"
        subtitleLabel.text = "There are no remarks available for your child at the moment."
    }

    // MARK: - Optional Configure
    func configure(title: String = "No Remarks Yet",
                   subtitle: String = "There are no remarks available for your child at the moment.") {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

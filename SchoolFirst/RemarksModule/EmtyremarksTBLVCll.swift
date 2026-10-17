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
    private let iconBackgroundView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
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
        setupIconView()
        setupLabels()
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

    private func setupIconView() {
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.backgroundColor = UIColor(red: 16/255.0, green: 185/255.0, blue: 129/255.0, alpha: 1.0)
        iconBackgroundView.layer.cornerRadius = 32
        iconBackgroundView.clipsToBounds = true

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(red: 0xFF/255.0, green: 0xFF/255.0, blue: 0xFF/255.0, alpha: 1.0)
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

    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16

        stackView.addArrangedSubview(iconBackgroundView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        cardView.addSubview(stackView)
    }

    private func setupConstraints() {
        let cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        cardBottomConstraint.priority = .defaultHigh

        let stackTopConstraint = stackView.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: 28)
        let stackBottomConstraint = stackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -28)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardBottomConstraint,
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 240),

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
            subtitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }

    private func configureDefaultContent() {
        titleLabel.text = "No remarks yet"
        subtitleLabel.text = "There are no remarks available for your child atthe moment."
    }

    // MARK: - Optional Configure
    func configure(title: String = "No remarks yet",
                   subtitle: String = "There are no remarks available for your child at the moment.") {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

//
//  EmtyalbumsTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/09/26.
//

import UIKit

class EmtyalbumsTableViewCell: UITableViewCell {

    // MARK: - UI Elements
    private let mainStack = UIStackView()
    
    private let illustrationContainer = UIView()
    private let illustrationImageView = UIImageView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let browseButton = UIButton(type: .system)
    
    private let infoBanner = UIView()
    private let infoIconView = UIView()
    private let infoLabel = UILabel()

    // Callback when user taps "Browse all albums"
    var onBrowseAllTapped: (() -> Void)?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Main vertical stack
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = 0
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)

        // 1. Illustration
        illustrationContainer.translatesAutoresizingMaskIntoConstraints = false
        illustrationImageView.contentMode = .scaleAspectFit
        illustrationImageView.tintColor = UIColor(red: 0.07, green: 0.42, blue: 0.72, alpha: 1)
        // System image that looks closest to Figma (stacked photos + search)
        illustrationImageView.image = UIImage(systemName: "Empty illustration")
        illustrationImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .light)
        illustrationImageView.translatesAutoresizingMaskIntoConstraints = false
        illustrationContainer.addSubview(illustrationImageView)
        
        // Light blue circle background behind icon (like Figma)
        let circle = UIView()
        circle.backgroundColor = UIColor(red: 0.90, green: 0.95, blue: 1.0, alpha: 1)
        circle.layer.cornerRadius = 60
        circle.translatesAutoresizingMaskIntoConstraints = false
        illustrationContainer.insertSubview(circle, at: 0)

        // 2. Title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.09, green: 0.14, blue: 0.22, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 3. Subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.45, green: 0.53, blue: 0.60, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 4. Browse all albums button
        browseButton.setTitle("  Browse all albums", for: .normal)
        browseButton.setImage(UIImage(systemName: "square.grid.2x2.fill"), for: .normal)
        browseButton.tintColor = .white
        browseButton.setTitleColor(.white, for: .normal)
        browseButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        browseButton.backgroundColor = UIColor(red: 0.04, green: 0.28, blue: 0.50, alpha: 1) // dark navy like Figma
        browseButton.layer.cornerRadius = 22
        browseButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        browseButton.translatesAutoresizingMaskIntoConstraints = false
        browseButton.addTarget(self, action: #selector(browseTapped), for: .touchUpInside)

        // 5. Bottom info banner
        infoBanner.backgroundColor = UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1)
        infoBanner.layer.cornerRadius = 12
        infoBanner.translatesAutoresizingMaskIntoConstraints = false

        infoIconView.backgroundColor = UIColor(red: 0.07, green: 0.42, blue: 0.72, alpha: 1)
        infoIconView.translatesAutoresizingMaskIntoConstraints = false

        infoLabel.text = "You'll see new albums automatically—no refresh needed."
        infoLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        infoLabel.textColor = UIColor(red: 0.25, green: 0.35, blue: 0.45, alpha: 1)
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        infoBanner.addSubview(infoIconView)
        infoBanner.addSubview(infoLabel)

        // Add everything to stack
        mainStack.addArrangedSubview(illustrationContainer)
        mainStack.setCustomSpacing(28, after: illustrationContainer)
        
        mainStack.addArrangedSubview(titleLabel)
        mainStack.setCustomSpacing(10, after: titleLabel)
        
        mainStack.addArrangedSubview(subtitleLabel)
        mainStack.setCustomSpacing(28, after: subtitleLabel)
        
        mainStack.addArrangedSubview(browseButton)
        mainStack.setCustomSpacing(32, after: browseButton)
        
        mainStack.addArrangedSubview(infoBanner)

        // Constraints
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

            // Illustration
            illustrationContainer.widthAnchor.constraint(equalToConstant: 120),
            illustrationContainer.heightAnchor.constraint(equalToConstant: 120),
            
            circle.centerXAnchor.constraint(equalTo: illustrationContainer.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: illustrationContainer.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 120),
            circle.heightAnchor.constraint(equalToConstant: 120),
            
            illustrationImageView.centerXAnchor.constraint(equalTo: illustrationContainer.centerXAnchor),
            illustrationImageView.centerYAnchor.constraint(equalTo: illustrationContainer.centerYAnchor),
            illustrationImageView.widthAnchor.constraint(equalToConstant: 64),
            illustrationImageView.heightAnchor.constraint(equalToConstant: 64),

            // Button height
            browseButton.heightAnchor.constraint(equalToConstant: 44),

            // Info banner
            infoBanner.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            infoBanner.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            
            infoIconView.leadingAnchor.constraint(equalTo: infoBanner.leadingAnchor),
            infoIconView.topAnchor.constraint(equalTo: infoBanner.topAnchor, constant: 14),
            infoIconView.bottomAnchor.constraint(equalTo: infoBanner.bottomAnchor, constant: -14),
            infoIconView.widthAnchor.constraint(equalToConstant: 4),

            infoLabel.leadingAnchor.constraint(equalTo: infoIconView.trailingAnchor, constant: 12),
            infoLabel.trailingAnchor.constraint(equalTo: infoBanner.trailingAnchor, constant: -14),
            infoLabel.topAnchor.constraint(equalTo: infoBanner.topAnchor, constant: 14),
            infoLabel.bottomAnchor.constraint(equalTo: infoBanner.bottomAnchor, constant: -14)
        ])
    }

    // MARK: - Configure
    func configure(category: String) {
        if category.lowercased() == "all" {
            titleLabel.text = "No albums yet"
            subtitleLabel.text = "When the school shares photos and videos,\nthey’ll appear here."
        } else {
            titleLabel.text = "No \(category) albums yet"
            subtitleLabel.text = "When the school shares \(category.lowercased()) tours, facilities or infrastructure moments, they’ll appear here."
        }
    }

    // MARK: - Actions
    @objc private func browseTapped() {
        onBrowseAllTapped?()
    }
}

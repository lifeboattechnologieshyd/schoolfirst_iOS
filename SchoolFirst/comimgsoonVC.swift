//
//  comimgsoonVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/09/26.
//

import UIKit

class comimgsoonVC: UIViewController {

    // MARK: - Configurable Properties
    var driverName: String?
    var driverStatus: String?
    var driverImageURL: String?
    var driverMobile: String?

    // MARK: - UI Elements (Header)
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20 // Circular 40x40
        iv.backgroundColor = .systemGray5 // Placeholder background
        iv.image = UIImage(named: "driver_avatar") // Fallback image asset
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Driver"
        label.font = UIFont(name: "HankenGrotesk-Bold", size: 15) ?? .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusDotView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0) // Green #22C55E
        view.layer.cornerRadius = 3.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Active now • Driver"
        label.font = UIFont(name: "HankenGrotesk-Regular", size: 12) ?? .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let phoneButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        button.setImage(UIImage(systemName: "phone", withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let headerDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - UI Elements (Center Card)
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        // Soft Shadow matching Figma
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let busImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "Illustration Placeholder") // Make sure this asset exists
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let comingSoonLabel: UILabel = {
        let label = UILabel()
        label.text = "Coming Soon"
        label.font = UIFont(name: "HankenGrotesk-Bold", size: 18) ?? .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        configureData()
    }

    // MARK: - Configure Data
    
    private func configureData() {
        // Set Driver Name
        if let name = driverName, !name.isEmpty {
            nameLabel.text = name
        }
        
        // Set Status
        if let status = driverStatus, !status.isEmpty {
            statusLabel.text = "\(status) • Driver"
        } else {
            statusLabel.text = "Active now • Driver"
        }
        
        // Load Driver Profile Image from URL
        if let imageURLString = driverImageURL, let url = URL(string: imageURLString) {
            loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }.resume()
    }

    // MARK: - Setup Layout
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Header Subviews
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(avatarImageView)
        
        // Status Stack
        let statusStack = UIStackView(arrangedSubviews: [statusDotView, statusLabel])
        statusStack.axis = .horizontal
        statusStack.spacing = 5
        statusStack.alignment = .center

        // Driver Info Stack
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, statusStack])
        infoStack.axis = .vertical
        infoStack.spacing = 2
        infoStack.alignment = .leading
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(infoStack)
        headerView.addSubview(phoneButton)
        headerView.addSubview(headerDivider)

        // Center Card Subviews
        view.addSubview(cardContainerView)
        cardContainerView.addSubview(busImageView)
        cardContainerView.addSubview(comingSoonLabel)

        // Layout Constraints
        NSLayoutConstraint.activate([
            // --- Header Constraints ---
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),

            avatarImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            avatarImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            statusDotView.widthAnchor.constraint(equalToConstant: 7),
            statusDotView.heightAnchor.constraint(equalToConstant: 7),

            infoStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            infoStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            phoneButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            phoneButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            phoneButton.widthAnchor.constraint(equalToConstant: 30),
            phoneButton.heightAnchor.constraint(equalToConstant: 30),

            headerDivider.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerDivider.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerDivider.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            headerDivider.heightAnchor.constraint(equalToConstant: 1),

            // --- Card Constraints ---
            cardContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            busImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 28),
            busImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 20),
            busImageView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -20),
            busImageView.heightAnchor.constraint(equalToConstant: 150),

            comingSoonLabel.topAnchor.constraint(equalTo: busImageView.bottomAnchor, constant: 20),
            comingSoonLabel.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            comingSoonLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            comingSoonLabel.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -28)
        ])
    }

    // MARK: - Actions
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        phoneButton.addTarget(self, action: #selector(didTapPhone), for: .touchUpInside)
    }

    @objc private func didTapBack() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func didTapPhone() {
        guard let mobile = driverMobile, !mobile.isEmpty,
              let url = URL(string: "tel://\(mobile)"),
              UIApplication.shared.canOpenURL(url) else {
            print("Invalid or missing phone number: \(driverMobile ?? "None")")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

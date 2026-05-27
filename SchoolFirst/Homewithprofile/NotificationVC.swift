//
//  NotificationVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/05/26.
//


import UIKit

// MARK: - Notification Model
struct NotificationModel {
    let icon: String
    let iconBackgroundColor: UIColor
    let iconColor: UIColor
    let title: String
    let titleColor: UIColor
    let description: String
    let timestamp: String
    let timestampColor: UIColor
    let badgeText: String?
    let badgeBackgroundColor: UIColor?
    let badgeTextColor: UIColor?
    let isUnread: Bool
    
    init(
        icon: String,
        iconBackgroundColor: UIColor,
        iconColor: UIColor = .systemBlue,
        title: String,
        titleColor: UIColor = .black,
        description: String,
        timestamp: String = "",
        timestampColor: UIColor = .gray,
        badgeText: String? = nil,
        badgeBackgroundColor: UIColor? = nil,
        badgeTextColor: UIColor? = nil,
        isUnread: Bool = false
    ) {
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.iconColor = iconColor
        self.title = title
        self.titleColor = titleColor
        self.description = description
        self.timestamp = timestamp
        self.timestampColor = timestampColor
        self.badgeText = badgeText
        self.badgeBackgroundColor = badgeBackgroundColor
        self.badgeTextColor = badgeTextColor
        self.isUnread = isUnread
    }
}

// MARK: - NotificationVC
class NotificationVC: UIViewController {
    
    // MARK: - Properties
    private let primaryColor = UIColor(red: 0.05, green: 0.27, blue: 0.55, alpha: 1)
    
    private var notifications: [NotificationModel] = []
    
    // MARK: - UI Components
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        button.tintColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notifications"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
   
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(white: 0.97, alpha: 1)
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        return table
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupNotifications()
        setupUI()
    }
    
    // MARK: - Setup Data
    private func setupNotifications() {
        notifications = [
            NotificationModel(
                icon: "bookmark.fill",
                iconBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.1),
                iconColor: .systemBlue,
                title: "New Assignment: Advance...",
                description: "Dr. Sarah Miller posted a new module: Integration Techniques.",
                timestamp: "2m ago",
                isUnread: true
            ),
            NotificationModel(
                icon: "creditcard.fill",
                iconBackgroundColor: UIColor.systemYellow.withAlphaComponent(0.2),
                iconColor: .systemYellow,
                title: "Fee Payment Success",
                description: "Your second-quarter tuition fee payment of $1,250 has been processed.",
                timestamp: "3h ago"
            ),
            NotificationModel(
                icon: "megaphone.fill",
                iconBackgroundColor: UIColor.systemOrange.withAlphaComponent(0.2),
                iconColor: .systemOrange,
                title: "Annual Science Fair",
                description: "Registrations for the Science Fair are now open for Grade 10 students.",
                timestamp: "Yesterday"
            ),
            NotificationModel(
                icon: "party.popper.fill",
                iconBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.1),
                iconColor: .systemBlue,
                title: "Joined  School",
                titleColor: primaryColor,
                description: "Academic Year 23-24",
                timestamp: "Aug 2023"
            ),
            NotificationModel(
                icon: "checkmark.circle.fill",
                iconBackgroundColor: UIColor.systemGreen.withAlphaComponent(0.2),
                iconColor: .systemGreen,
                title: "Q1 Fees Paid",
                description: "Invoice #SF-9021",
                badgeText: "Paid",
                badgeBackgroundColor: UIColor.systemGreen.withAlphaComponent(0.2),
                badgeTextColor: .systemGreen
            ),
            NotificationModel(
                icon: "exclamationmark.circle.fill",
                iconBackgroundColor: UIColor.systemRed.withAlphaComponent(0.15),
                iconColor: .systemRed,
                title: "Q2 Fees Due",
                description: "$1,250.00 Balance",
                badgeText: "Due Oct 15",
                badgeBackgroundColor: UIColor.systemRed.withAlphaComponent(0.15),
                badgeTextColor: .systemRed
            ),
            NotificationModel(
                icon: "square.and.pencil",
                iconBackgroundColor: UIColor.systemGray.withAlphaComponent(0.15),
                iconColor: .darkGray,
                title: "Teacher Note",
                description: "\"Excellent progress in lab...\"",
                timestamp: "2h ago"
            ),
            NotificationModel(
                icon: "doc.text.fill",
                iconBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.1),
                iconColor: .systemBlue,
                title: "PhysicsAssignment",
                description: "Quantum Mechanics Lab",
                badgeText: "Due Today",
                badgeBackgroundColor: primaryColor,
                badgeTextColor: .white
            ),
            NotificationModel(
                icon: "graduationcap.fill",
                iconBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.1),
                iconColor: .systemBlue,
                title: "Mid-Term Exams",
                description: "Starts in 12 days",
                timestamp: "UPCOMING",
                timestampColor: primaryColor
            ),
            NotificationModel(
                icon: "exclamationmark.triangle.fill",
                iconBackgroundColor: UIColor.systemGray.withAlphaComponent(0.15),
                iconColor: .darkGray,
                title: "Low Attendance",
                description: "Below 75% threshold",
                timestamp: "72%",
                timestampColor: UIColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 1)
            ),
            NotificationModel(
                icon: "person.3.fill",
                iconBackgroundColor: .systemYellow,
                iconColor: .white,
                title: "Science Fair",
                description: "Nov 24, 2023",
                timestamp: "UPCOMING",
                timestampColor: UIColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 1)
            )
        ]
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            
           
            // TableView
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
   
}

// MARK: - UITableView DataSource & Delegate
extension NotificationVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "NotificationCell",
            for: indexPath
        ) as? NotificationCell else {
            return UITableViewCell()
        }
        cell.configure(with: notifications[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = notifications[indexPath.row]
        print("Tapped: \(item.title)")
    }
}

// MARK: - NotificationCell
class NotificationCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 22
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let unreadDot: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let badgeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(timestampLabel)
        containerView.addSubview(unreadDot)
        containerView.addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // Icon Container
            iconContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Icon Image
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timestampLabel.leadingAnchor, constant: -8),
            
            // Timestamp
            timestampLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            timestampLabel.trailingAnchor.constraint(equalTo: unreadDot.leadingAnchor, constant: -6),
            
            // Unread Dot
            unreadDot.centerYAnchor.constraint(equalTo: timestampLabel.centerYAnchor),
            unreadDot.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            unreadDot.widthAnchor.constraint(equalToConstant: 8),
            unreadDot.heightAnchor.constraint(equalToConstant: 8),
            
            // Badge
            badgeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            badgeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configure
    func configure(with model: NotificationModel) {
        iconContainer.backgroundColor = model.iconBackgroundColor
        iconImageView.image = UIImage(systemName: model.icon)
        iconImageView.tintColor = model.iconColor
        
        titleLabel.text = model.title
        titleLabel.textColor = model.titleColor
        
        descriptionLabel.text = model.description
        
        // Handle Badge or Timestamp
        if let badgeText = model.badgeText {
            badgeLabel.isHidden = false
            badgeLabel.text = badgeText
            badgeLabel.backgroundColor = model.badgeBackgroundColor
            badgeLabel.textColor = model.badgeTextColor
            timestampLabel.isHidden = true
            unreadDot.isHidden = true
        } else {
            badgeLabel.isHidden = true
            timestampLabel.isHidden = false
            timestampLabel.text = model.timestamp
            timestampLabel.textColor = model.timestampColor
            
            if model.timestamp == "UPCOMING" {
                timestampLabel.font = .systemFont(ofSize: 12, weight: .bold)
            } else if model.timestamp == "72%" {
                timestampLabel.font = .systemFont(ofSize: 20, weight: .bold)
            } else {
                timestampLabel.font = .systemFont(ofSize: 12, weight: .regular)
            }
            
            unreadDot.isHidden = !model.isUnread
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        badgeLabel.isHidden = true
        unreadDot.isHidden = true
        timestampLabel.isHidden = false
    }
}

// MARK: - Padding Label (for Badges)
class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}

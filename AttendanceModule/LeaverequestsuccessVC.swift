//
//  LeaverequestsuccessVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 22/10/26.
//

import UIKit

// MARK: - Data passed from LeaveapplyVC

struct LeaveSuccessDisplayData {
    let leaveID: String
    let startDate: String          // "yyyy-MM-dd" from API
    let endDate: String            // "yyyy-MM-dd" from API
    let status: String             // "PENDING"
    let documentAttached: Bool
    let sentToText: String         // e.g. "Class teacher · Class 10-A"
}

final class LeaverequestsuccessVC: UIViewController {

    // MARK: - Input

    var displayData: LeaveSuccessDisplayData?

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let navBar = UIView()
    private let backButton = UIButton(type: .system)
    private let navTitleLabel = UILabel()
    private let navSubtitleLabel = UILabel()
    private let bellButton = UIButton(type: .system)

    private let checkContainer = UIView()
    private let checkOuter = UIView()
    private let checkInner = UIView()
    private let checkImageView = UIImageView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let statusBadge = UILabel()

    private let summaryCard = UIView()
    private let summaryTitleLabel = UILabel()
    private let summaryIDLabel = UILabel()
    private let summaryDivider = UIView()

    private let datesKeyLabel = UILabel()
    private let datesValueLabel = UILabel()
    private let sentToKeyLabel = UILabel()
    private let sentToValueLabel = UILabel()
    private let documentKeyLabel = UILabel()
    private let documentValueLabel = UILabel()

    private let infoBanner = UIView()
    private let infoIcon = UIImageView()
    private let infoLabel = UILabel()

    private let backToRequestsButton = UIButton(type: .system)

    // MARK: - Colors (Figma)

    private let navy = UIColor(red: 0.02, green: 0.19, blue: 0.38, alpha: 1)       // #052F61-ish
    private let titleColor = UIColor(red: 0.10, green: 0.14, blue: 0.20, alpha: 1)
    private let bodyGray = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1)
    private let keyGray = UIColor(red: 0.55, green: 0.58, blue: 0.62, alpha: 1)
    private let cardBorder = UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1)
    private let pendingBg = UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1)
    private let pendingText = UIColor(red: 0.80, green: 0.52, blue: 0.05, alpha: 1)
    private let greenCheck = UIColor(red: 0.18, green: 0.73, blue: 0.45, alpha: 1)
    private let infoBg = UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1)
    private let infoText = UIColor(red: 0.25, green: 0.40, blue: 0.70, alpha: 1)

    // MARK: - Formatters

    private static let apiFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "d MMM yyyy"
        return f
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        buildUI()
        applyConstraints()
        populate()
    }

    // MARK: - Build UI

    private func buildUI() {
        // Scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Nav bar
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = navy
        view.addSubview(navBar)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(didTapBackToRequests), for: .touchUpInside)
        navBar.addSubview(backButton)

        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navTitleLabel.text = "Apply for leave"
        navTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        navTitleLabel.textColor = .white
        navBar.addSubview(navTitleLabel)

        navSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navSubtitleLabel.text = "Goes to the class teacher"
        navSubtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        navSubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        navBar.addSubview(navSubtitleLabel)

        bellButton.translatesAutoresizingMaskIntoConstraints = false
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = .white
        navBar.addSubview(bellButton)

        // Success check
        checkContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkContainer)

        checkOuter.translatesAutoresizingMaskIntoConstraints = false
        checkOuter.backgroundColor = greenCheck.withAlphaComponent(0.15)
        checkOuter.layer.cornerRadius = 48
        checkContainer.addSubview(checkOuter)

        checkInner.translatesAutoresizingMaskIntoConstraints = false
        checkInner.backgroundColor = greenCheck
        checkInner.layer.cornerRadius = 32
        checkOuter.addSubview(checkInner)

        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.image = UIImage(systemName: "checkmark")
        checkImageView.tintColor = .white
        checkImageView.contentMode = .scaleAspectFit
        checkInner.addSubview(checkImageView)

        // Titles
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Request submitted"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = titleColor
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Your leave request has gone to the class teacher."
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = bodyGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        contentView.addSubview(subtitleLabel)

        // Pending badge
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.text = "  Pending  "
        statusBadge.font = .systemFont(ofSize: 12, weight: .semibold)
        statusBadge.textColor = pendingText
        statusBadge.backgroundColor = pendingBg
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 10
        statusBadge.clipsToBounds = true
        contentView.addSubview(statusBadge)

        // Summary card
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.backgroundColor = .white
        summaryCard.layer.cornerRadius = 14
        summaryCard.layer.borderWidth = 1
        summaryCard.layer.borderColor = cardBorder.cgColor
        contentView.addSubview(summaryCard)

        summaryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryTitleLabel.text = "Submission summary"
        summaryTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        summaryTitleLabel.textColor = titleColor
        summaryCard.addSubview(summaryTitleLabel)

        summaryIDLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryIDLabel.font = .systemFont(ofSize: 12, weight: .medium)
        summaryIDLabel.textColor = bodyGray
        summaryIDLabel.textAlignment = .right
        summaryCard.addSubview(summaryIDLabel)

        summaryDivider.translatesAutoresizingMaskIntoConstraints = false
        summaryDivider.backgroundColor = cardBorder
        summaryCard.addSubview(summaryDivider)

        configureKey(datesKeyLabel, text: "DATES")
        configureValue(datesValueLabel)
        configureKey(sentToKeyLabel, text: "SENT TO")
        configureValue(sentToValueLabel)
        configureKey(documentKeyLabel, text: "DOCUMENT")
        configureValue(documentValueLabel)

        summaryCard.addSubview(datesKeyLabel)
        summaryCard.addSubview(datesValueLabel)
        summaryCard.addSubview(sentToKeyLabel)
        summaryCard.addSubview(sentToValueLabel)
        summaryCard.addSubview(documentKeyLabel)
        summaryCard.addSubview(documentValueLabel)

        // Info banner
        infoBanner.translatesAutoresizingMaskIntoConstraints = false
        infoBanner.backgroundColor = infoBg
        infoBanner.layer.cornerRadius = 12
        contentView.addSubview(infoBanner)

        infoIcon.translatesAutoresizingMaskIntoConstraints = false
        infoIcon.image = UIImage(systemName: "bell.fill")
        infoIcon.tintColor = infoText
        infoIcon.contentMode = .scaleAspectFit
        infoBanner.addSubview(infoIcon)

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.text = "Most feedback receives an update within 2 school days."
        infoLabel.font = .systemFont(ofSize: 13, weight: .medium)
        infoLabel.textColor = infoText
        infoLabel.numberOfLines = 0
        infoBanner.addSubview(infoLabel)

        // Bottom button
        backToRequestsButton.translatesAutoresizingMaskIntoConstraints = false
        backToRequestsButton.setTitle("Back to Leave requests", for: .normal)
        backToRequestsButton.setTitleColor(navy, for: .normal)
        backToRequestsButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        backToRequestsButton.backgroundColor = .white
        backToRequestsButton.layer.cornerRadius = 12
        backToRequestsButton.layer.borderWidth = 1.5
        backToRequestsButton.layer.borderColor = navy.cgColor
        backToRequestsButton.addTarget(self, action: #selector(didTapBackToRequests), for: .touchUpInside)
        view.addSubview(backToRequestsButton)
    }

    private func configureKey(_ label: UILabel, text: String) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = keyGray
    }

    private func configureValue(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = titleColor
        label.numberOfLines = 0
    }

    // MARK: - Constraints

    private func applyConstraints() {
        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Nav
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.bottomAnchor.constraint(equalTo: safe.topAnchor, constant: 56),

            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 12),
            backButton.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -14),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            navTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
            navTitleLabel.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -28),

            navSubtitleLabel.leadingAnchor.constraint(equalTo: navTitleLabel.leadingAnchor),
            navSubtitleLabel.topAnchor.constraint(equalTo: navTitleLabel.bottomAnchor, constant: 2),

            bellButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16),
            bellButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 28),
            bellButton.heightAnchor.constraint(equalToConstant: 28),

            // Bottom button fixed
            backToRequestsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backToRequestsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            backToRequestsButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),
            backToRequestsButton.heightAnchor.constraint(equalToConstant: 52),

            // Scroll
            scrollView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: backToRequestsButton.topAnchor, constant: -12),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Check
            checkContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 36),
            checkContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            checkContainer.widthAnchor.constraint(equalToConstant: 96),
            checkContainer.heightAnchor.constraint(equalToConstant: 96),

            checkOuter.centerXAnchor.constraint(equalTo: checkContainer.centerXAnchor),
            checkOuter.centerYAnchor.constraint(equalTo: checkContainer.centerYAnchor),
            checkOuter.widthAnchor.constraint(equalToConstant: 96),
            checkOuter.heightAnchor.constraint(equalToConstant: 96),

            checkInner.centerXAnchor.constraint(equalTo: checkOuter.centerXAnchor),
            checkInner.centerYAnchor.constraint(equalTo: checkOuter.centerYAnchor),
            checkInner.widthAnchor.constraint(equalToConstant: 64),
            checkInner.heightAnchor.constraint(equalToConstant: 64),

            checkImageView.centerXAnchor.constraint(equalTo: checkInner.centerXAnchor),
            checkImageView.centerYAnchor.constraint(equalTo: checkInner.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 28),
            checkImageView.heightAnchor.constraint(equalToConstant: 28),

            // Title / subtitle / badge
            titleLabel.topAnchor.constraint(equalTo: checkContainer.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            statusBadge.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            statusBadge.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),

            // Summary card
            summaryCard.topAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: 28),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            summaryTitleLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 16),
            summaryTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            summaryIDLabel.centerYAnchor.constraint(equalTo: summaryTitleLabel.centerYAnchor),
            summaryIDLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),
            summaryIDLabel.leadingAnchor.constraint(greaterThanOrEqualTo: summaryTitleLabel.trailingAnchor, constant: 8),

            summaryDivider.topAnchor.constraint(equalTo: summaryTitleLabel.bottomAnchor, constant: 12),
            summaryDivider.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            summaryDivider.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),
            summaryDivider.heightAnchor.constraint(equalToConstant: 1),

            // Dates row
            datesKeyLabel.topAnchor.constraint(equalTo: summaryDivider.bottomAnchor, constant: 14),
            datesKeyLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            datesKeyLabel.widthAnchor.constraint(equalToConstant: 88),

            datesValueLabel.centerYAnchor.constraint(equalTo: datesKeyLabel.centerYAnchor),
            datesValueLabel.leadingAnchor.constraint(equalTo: datesKeyLabel.trailingAnchor, constant: 8),
            datesValueLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),

            // Sent to row
            sentToKeyLabel.topAnchor.constraint(equalTo: datesKeyLabel.bottomAnchor, constant: 14),
            sentToKeyLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            sentToKeyLabel.widthAnchor.constraint(equalToConstant: 88),

            sentToValueLabel.centerYAnchor.constraint(equalTo: sentToKeyLabel.centerYAnchor),
            sentToValueLabel.leadingAnchor.constraint(equalTo: sentToKeyLabel.trailingAnchor, constant: 8),
            sentToValueLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),

            // Document row
            documentKeyLabel.topAnchor.constraint(equalTo: sentToKeyLabel.bottomAnchor, constant: 14),
            documentKeyLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            documentKeyLabel.widthAnchor.constraint(equalToConstant: 88),

            documentValueLabel.centerYAnchor.constraint(equalTo: documentKeyLabel.centerYAnchor),
            documentValueLabel.leadingAnchor.constraint(equalTo: documentKeyLabel.trailingAnchor, constant: 8),
            documentValueLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),
            documentValueLabel.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -16),

            // Info banner
            infoBanner.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 16),
            infoBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoBanner.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            infoIcon.leadingAnchor.constraint(equalTo: infoBanner.leadingAnchor, constant: 14),
            infoIcon.centerYAnchor.constraint(equalTo: infoBanner.centerYAnchor),
            infoIcon.widthAnchor.constraint(equalToConstant: 18),
            infoIcon.heightAnchor.constraint(equalToConstant: 18),

            infoLabel.topAnchor.constraint(equalTo: infoBanner.topAnchor, constant: 14),
            infoLabel.bottomAnchor.constraint(equalTo: infoBanner.bottomAnchor, constant: -14),
            infoLabel.leadingAnchor.constraint(equalTo: infoIcon.trailingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: infoBanner.trailingAnchor, constant: -14)
        ])
    }

    // MARK: - Populate from data

    private func populate() {
        guard let data = displayData else {
            // Safe defaults if opened without data
            summaryIDLabel.text = "—"
            datesValueLabel.text = "—"
            sentToValueLabel.text = "Class teacher"
            documentValueLabel.text = "No document"
            statusBadge.text = "  Pending  "
            return
        }

        // ID — short friendly code from leave UUID
        summaryIDLabel.text = friendlyLeaveCode(from: data.leaveID)

        // Dates
        datesValueLabel.text = formattedDateRange(start: data.startDate, end: data.endDate)

        // Sent to
        sentToValueLabel.text = data.sentToText

        // Document
        documentValueLabel.text = data.documentAttached ? "Medical slip attached" : "No document"

        // Status badge
        let status = data.status.trimmingCharacters(in: .whitespacesAndNewlines)
        if status.isEmpty {
            statusBadge.text = "  Pending  "
        } else {
            statusBadge.text = "  \(status.capitalized)  "
        }
    }

    /// e.g. "FB-2026-0816" style code from leave id + year
    private func friendlyLeaveCode(from leaveID: String) -> String {
        let year = Calendar.current.component(.year, from: Date())
        let compact = leaveID
            .replacingOccurrences(of: "-", with: "")
            .uppercased()
        let suffix = String(compact.prefix(4))
        return "FB-\(year)-\(suffix)"
    }

    private func formattedDateRange(start: String, end: String) -> String {
        let startDate = Self.apiFormatter.date(from: start)
        let endDate = Self.apiFormatter.date(from: end)

        if let s = startDate, let e = endDate {
            let sText = Self.displayFormatter.string(from: s)
            let eText = Self.displayFormatter.string(from: e)
            if sText == eText { return sText }
            return "\(sText) – \(eText)"
        }

        if start == end { return start }
        return "\(start) – \(end)"
    }

    // MARK: - Actions

    @objc private func didTapBackToRequests() {
        // Pop back to leave list (skip apply screen)
        if let nav = navigationController {
            for controller in nav.viewControllers {
                // Prefer popping to a leave-list VC if present
                let name = String(describing: type(of: controller))
                if name.lowercased().contains("leave") && controller !== self && !(controller is LeaveapplyVC) {
                    nav.popToViewController(controller, animated: true)
                    return
                }
            }
            // Fallback: pop to root of this stack, or pop 2 levels
            if nav.viewControllers.count >= 3 {
                let target = nav.viewControllers[nav.viewControllers.count - 3]
                nav.popToViewController(target, animated: true)
            } else {
                nav.popToRootViewController(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
}

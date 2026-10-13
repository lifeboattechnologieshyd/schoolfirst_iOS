//
//  FeedbackoverviewVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 10/10/26.
//

import UIKit
import SwiftUI

class FeedbackSubmissionsuccessfulVC: UIViewController {

    // MARK: - ✅ Passed-in API Data (from SubmitnewfeedbackVC after successful submission)
    var feedbackData: FeedbackCreateData?

    // MARK: - Properties (Data holders — populated dynamically from feedbackData if available)
    var parentName: String = "Parent"
    var childName: String = ""
    var childGrade: String = ""
    var category: String = ""
    var subject: String = ""
    var feedbackId: String = ""
    var statusRawValue: String = "SUBMITTED"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide native navigation bar to use custom header
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        populateFromAPIDataIfAvailable()
        setupSwiftUIView()
    }

    // MARK: - ✅ Populate static properties with real API response data
    private func populateFromAPIDataIfAvailable() {

        guard let data = feedbackData else {
            print("⚠️ FeedbackSubmissionsuccessfulVC — feedbackData is nil, using default placeholder values")
            return
        }

        print("📦 FeedbackSubmissionsuccessfulVC — configuring with feedbackId:", data.id)

        // Child name from API
        childName = data.student.name

        // Grade — not returned by this API, fallback to locally resolved grade
        let resolvedGrade = UserManager.shared.resolvedGradeSection
        childGrade = resolvedGrade.isEmpty ? "" : "Grade \(resolvedGrade)"

        // Category from API
        category = data.category.name

        // Subject from API
        subject = data.subject

        // Feedback ID — short readable format from UUID
        feedbackId = "#" + String(data.id.prefix(8)).uppercased()

        // Status from API (e.g. "SUBMITTED")
        statusRawValue = data.status

        // Parent name — not part of this API response; falls back to default "Parent"
        parentName = "Parent"
    }

    // MARK: - Status Display Helpers
    private func statusDisplayText() -> String {
        switch statusRawValue.uppercased() {
        case "SUBMITTED", "PENDING":
            return "Pending"
        case "IN_REVIEW", "IN REVIEW":
            return "In Review"
        case "RESOLVED":
            return "Resolved"
        default:
            return statusRawValue.capitalized
        }
    }

    // MARK: - Embed SwiftUI View
    private func setupSwiftUIView() {
        // Prepare SwiftUI View with closures for button actions
        let swiftUIView = FeedbackSuccessView(
            parentName: parentName,
            childName: childName,
            childGrade: childGrade,
            category: category,
            subject: subject,
            feedbackId: feedbackId,
            statusText: statusDisplayText(),
            onBackTapped: { [weak self] in
                self?.handleBack()
            },
            onNotificationTapped: {
                print("🔔 Notification tapped")
            },
            onViewDetailsTapped: {
                print("📄 View Details tapped")
            },
            onBackToFeedbackTapped: { [weak self] in
                self?.handleBack()
            }
        )

        // Host SwiftUI inside UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Set up Auto Layout constraints to fill the view edge-to-edge
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    // MARK: - Navigation Action
    private func handleBack() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// ==========================================
// MARK: - SwiftUI View Code
// ==========================================

struct FeedbackSuccessView: View {
    // Data Properties
    var parentName: String
    var childName: String
    var childGrade: String
    var category: String
    var subject: String
    var feedbackId: String
    var statusText: String
    
    // Callbacks for UIKit Actions
    var onBackTapped: (() -> Void)?
    var onNotificationTapped: (() -> Void)?
    var onViewDetailsTapped: (() -> Void)?
    var onBackToFeedbackTapped: (() -> Void)?
    
    // Colors matching Figma
    private let primaryBlue = Color(red: 43/255, green: 96/255, blue: 223/255)
    private let successGreen = Color(red: 76/255, green: 191/255, blue: 130/255)
    private let warningOrange = Color(red: 239/255, green: 143/255, blue: 50/255)
    private let reviewBlue = Color(red: 61/255, green: 130/255, blue: 247/255)

    // MARK: - Status Color (dynamic based on statusText)
    private var statusColor: Color {
        switch statusText {
        case "In Review":
            return reviewBlue
        case "Resolved":
            return successGreen
        default:
            return warningOrange
        }
    }

    private var statusIcon: String {
        switch statusText {
        case "In Review":
            return "hourglass"
        case "Resolved":
            return "checkmark.circle"
        default:
            return "clock"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Blue Header
            customHeader
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // 2. Success Status Section
                    successStatusSection
                    
                    // 3. Summary Card
                    summaryCard
                    
                    // 4. Info Banner
                    infoBanner
                    
                    Spacer(minLength: 20)
                    
                    // 5. Action Buttons
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 20)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - SwiftUI Subviews
extension FeedbackSuccessView {
    
    private var customHeader: some View {
        HStack(alignment: .center) {
            Button(action: {
                onBackTapped?()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Feedback Sent")
                    .font(.system(size: 18, weight: .bold))
                Text("School moments, all in one place")
                    .font(.system(size: 11, weight: .regular))
                    .opacity(0.9)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Button(action: {
                onNotificationTapped?()
            }) {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .padding(.top, safeAreaTop() + 10)
        .background(primaryBlue)
        .ignoresSafeArea(edges: .top)
    }
    
    private var successStatusSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(successGreen)
                    .frame(width: 64, height: 64)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Thank you, \(parentName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Your feedback has been submitted. We'll notify you\nwhen the school begins reviewing it.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            HStack(spacing: 4) {
                Image(systemName: statusIcon)
                    .font(.system(size: 12, weight: .medium))
                Text(statusText)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(statusColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.15))
            .cornerRadius(12)
        }
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Submission summary")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(feedbackId)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(primaryBlue)
            }
            .padding(.bottom, 4)
            
            SummaryRowView(title: "CHILD", value: childGrade.isEmpty ? childName : "\(childName) • \(childGrade)")
            SummaryRowView(title: "CATEGORY", value: category)
            SummaryRowView(title: "SUBJECT", value: subject)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var infoBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "bell")
                .font(.system(size: 16))
                .foregroundColor(primaryBlue)
                .padding(.top, 2)
            
            Text("Most feedback receives an update within 2 school days.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
                .lineSpacing(2)
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(primaryBlue.opacity(0.06))
        .cornerRadius(8)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                onViewDetailsTapped?()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                    Text("View feedback details")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(primaryBlue)
                .cornerRadius(10)
            }
            
            Button(action: {
                onBackToFeedbackTapped?()
            }) {
                Text("Back to feedback")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(UIColor.darkGray))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
        }
    }
    
    private func safeAreaTop() -> CGFloat {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let topPadding = window.windows.first?.safeAreaInsets.top else {
            return 44
        }
        return topPadding
    }
}

// MARK: - Reusable Row Component
struct SummaryRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.gray.opacity(0.8))
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
    }
}

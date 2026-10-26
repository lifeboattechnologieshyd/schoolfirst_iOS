//
//  NotesubmitsuccessVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 26/10/26.
//

import UIKit
import SwiftUI

class NotesubmitsuccessVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the default navigation bar since we are building a custom header in SwiftUI
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        // Initialize the SwiftUI view and pass navigation actions
        let successView = NoteSubmitSuccessView(
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onBackToLeaveRequests: { [weak self] in
                // Attempt to pop back to the Leave requests screen if it exists in the stack
                if let nav = self?.navigationController {
                    for vc in nav.viewControllers {
                        // Assuming "leaverequestsVC" is the name of your leave requests controller
                        if String(describing: type(of: vc)) == "leaverequestsVC" {
                            nav.popToViewController(vc, animated: true)
                            return
                        }
                    }
                    // Fallback if not found
                    nav.popViewController(animated: true)
                }
            }
        )
        
        let hostingController = UIHostingController(rootView: successView)
        
        // Add Hosting Controller as a child
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Setup Constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}

// MARK: - SwiftUI View

struct NoteSubmitSuccessView: View {
    var onBack: () -> Void
    var onBackToLeaveRequests: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Custom Navigation Header
            HStack(spacing: 16) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Note submitted")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("Goes to the class teacher")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bell")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, topSafeAreaPadding()) // Adjust for device notch/dynamic island
            .padding(.bottom, 20)
            .background(Color(red: 27/255, green: 71/255, blue: 137/255)) // Dark Blue Background
            
            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Success Checkmark Icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 76/255, green: 191/255, blue: 133/255).opacity(0.15))
                            .frame(width: 110, height: 110)
                        
                        Circle()
                            .fill(Color(red: 76/255, green: 191/255, blue: 133/255)) // Green
                            .frame(width: 75, height: 75)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    // Main Title & Description
                    VStack(spacing: 8) {
                        Text("Late note submitted")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 30/255, green: 41/255, blue: 59/255))
                        
                        Text("Your note has been sent to the class teacher.\nThe attendance record will be updated accordingly.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    // Summary Card
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("Submission summary")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 30/255, green: 41/255, blue: 59/255))
                            Spacer()
                            Text("FB-2026-0816")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 45/255, green: 100/255, blue: 200/255))
                        }
                        .padding(.bottom, 4)
                        
                        // ✅ Changed from SummaryRowView to NoteSummaryRowView to prevent collision
                        NoteSummaryRowView(title: "STUDENT", value: "Kabir Singh")
                        NoteSummaryRowView(title: "DATE", value: "10 Sep 2026")
                        NoteSummaryRowView(title: "NOTE", value: "Bus issue")
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                    
                    // Info Banner
                    HStack(spacing: 12) {
                        Image(systemName: "bell")
                            .foregroundColor(Color(red: 45/255, green: 100/255, blue: 200/255))
                            .font(.system(size: 16))
                        
                        Text("Most feedback receives an update within 2 school days.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 30/255, green: 41/255, blue: 59/255))
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(red: 236/255, green: 244/255, blue: 255/255))
                    .cornerRadius(12)
                    
                    // Action Button
                    Button(action: onBackToLeaveRequests) {
                        Text("Back to Leave requests")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 30/255, green: 41/255, blue: 59/255))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 230/255, green: 232/255, blue: 235/255), lineWidth: 1)
                            )
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color(red: 248/255, green: 250/255, blue: 252/255)) // Very Light Gray/Blueish Background
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // Helper to dynamically calculate safe area for the custom nav bar
    private func topSafeAreaPadding() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 50 // fallback padding
        }
        return window.safeAreaInsets.top > 0 ? window.safeAreaInsets.top + 10 : 30
    }
}

// MARK: - Summary Row Subview (Renamed to prevent 'invalid redeclaration' error)
struct NoteSummaryRowView: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.gray)
                .frame(width: 90, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 30/255, green: 41/255, blue: 59/255))
            
            Spacer()
        }
    }
}

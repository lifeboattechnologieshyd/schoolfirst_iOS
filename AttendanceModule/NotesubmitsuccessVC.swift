//
//  NotesubmitsuccessVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 26/10/26.
//

import UIKit
import SwiftUI

class NotesubmitsuccessVC: UIViewController {
    
    // MARK: - Data received from AddleavenoteVC
    var responseData: AttendanceLateNoteData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        let successView = NoteSubmitSuccessView(
            responseData: responseData,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onBackToAttendanceDashboard: { [weak self] in
                guard let self = self, let nav = self.navigationController else { return }
                
                // If attendancedashboardVC already exists in the stack, pop to it
                if let existing = nav.viewControllers.first(where: { $0 is attendancedashboardVC }) {
                    nav.popToViewController(existing, animated: true)
                    return
                }
                
                // Otherwise, instantiate from storyboard to get IBOutlets connected
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let dashboardVC = storyboard.instantiateViewController(
                    withIdentifier: "attendancedashboardVC"
                ) as? attendancedashboardVC {
                    nav.pushViewController(dashboardVC, animated: true)
                }
            }
        )
        
        let hostingController = UIHostingController(rootView: successView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
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
    var responseData: AttendanceLateNoteData?
    var onBack: () -> Void
    var onBackToAttendanceDashboard: () -> Void
    
    // MARK: - Dynamic Data Properties
    
    private var isLate: Bool {
        (responseData?.status ?? "").uppercased() == "LATE"
    }
    
    private var titleText: String {
        isLate ? "Late note submitted" : "Absent note submitted"
    }
    
    private var referenceID: String {
        let id = (responseData?.id ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return id.isEmpty ? "—" : String(id.prefix(8).uppercased())
    }
    
    private var studentName: String {
        let name = (responseData?.student?.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? UserManager.shared.resolvedStudentName : name
    }
    
    private var dateString: String {
        let raw = (responseData?.attendanceDate ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return "—" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: raw) else { return raw }
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: date)
    }
    
    private var noteText: String {
        let late = (responseData?.lateNote ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let absent = (responseData?.absentNote ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !late.isEmpty { return late }
        if !absent.isEmpty { return absent }
        return "—"
    }
    
    private var statusText: String {
        let raw = (responseData?.status ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return raw.isEmpty ? "—" : raw.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
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
            .padding(.top, topSafeAreaPadding())
            .padding(.bottom, 20)
            .background(Color(red: 27/255, green: 71/255, blue: 137/255))
            
            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Success Checkmark Icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 76/255, green: 191/255, blue: 133/255).opacity(0.15))
                            .frame(width: 110, height: 110)
                        
                        Circle()
                            .fill(Color(red: 76/255, green: 191/255, blue: 133/255))
                            .frame(width: 75, height: 75)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    // Main Title & Description
                    VStack(spacing: 8) {
                        Text(titleText)
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
                            Text(referenceID)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 45/255, green: 100/255, blue: 200/255))
                        }
                        .padding(.bottom, 4)
                        
                        NoteSummaryRowView(title: "STUDENT", value: studentName)
                        NoteSummaryRowView(title: "STATUS", value: statusText)
                        NoteSummaryRowView(title: "DATE", value: dateString)
                        NoteSummaryRowView(title: "NOTE", value: noteText)
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
                    Button(action: onBackToAttendanceDashboard) {
                        HStack(spacing: 8) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 16, weight: .bold))
                            Text("Back to Attendance dashboard")
                                .font(.system(size: 16, weight: .bold))
                        }
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
            .background(Color(red: 248/255, green: 250/255, blue: 252/255))
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private func topSafeAreaPadding() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 50
        }
        return window.safeAreaInsets.top > 0 ? window.safeAreaInsets.top + 10 : 30
    }
}

// MARK: - Summary Row Subview
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

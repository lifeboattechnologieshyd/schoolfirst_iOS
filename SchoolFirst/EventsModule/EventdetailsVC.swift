//
//  EventdetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 02/11/26.
//

import UIKit
import SwiftUI

class EventdetailsVC: UIViewController {
    
    // API Data passed from EventsdashboardVC
    var event: CalendarEventItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        let swiftUIView = EventDetailsView(event: event)
        
        let hostingController = UIHostingController(rootView: swiftUIView)
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

// MARK: - Theming Engine

enum EventDetailTheme {
    case ptm, fee, exam, holiday, event, announcement, homework, assignment, transport, library, other
    
    var primary: Color {
        switch self {
        case .ptm:          return Color(red: 0.49, green: 0.23, blue: 0.93) // #7C3AED Purple
        case .fee:          return Color(red: 0.85, green: 0.47, blue: 0.02) // #D97706 Orange/Gold
        case .exam:         return Color(red: 0.86, green: 0.15, blue: 0.15) // #DC2626 Red
        case .holiday:      return Color(red: 0.27, green: 0.52, blue: 0.35) // #45855A Muted Green
        case .event:        return Color(red: 0.18, green: 0.40, blue: 0.29) // #2F664A Dark Green
        case .announcement: return Color(red: 0.39, green: 0.40, blue: 0.95) // #6366F1 Indigo
        case .homework:     return Color(red: 0.15, green: 0.39, blue: 0.92) // #2563EB Blue
        case .assignment:   return Color(red: 0.73, green: 0.11, blue: 0.11) // #B91C1C Dark Red
        case .transport:    return Color(red: 0.71, green: 0.33, blue: 0.04) // #B45309 Brown/Orange
        case .library:      return Color(red: 0.11, green: 0.31, blue: 0.85) // #1D4ED8 Royal Blue
        case .other:        return Color(red: 0.28, green: 0.33, blue: 0.41) // #475569 Slate
        }
    }
    
    var lightBg: Color {
        primary.opacity(0.12)
    }
    
    var highlightBg: Color {
        primary.opacity(0.08)
    }
    
    var navTitle: String {
        switch self {
        case .ptm: return "PTM"
        case .fee: return "Fee"
        case .exam: return "Exam"
        case .holiday: return "Holiday"
        case .event: return "Event"
        case .announcement: return "Announcement"
        case .homework: return "Homework"
        case .assignment: return "Assignment"
        case .transport: return "Transport"
        case .library: return "Library"
        case .other: return "Other"
        }
    }
    
    // Primary action title per Figma; nil = no primary button (Set Reminder becomes the main button)
    var primaryActionTitle: String? {
        switch self {
        case .ptm:        return "Confirm PTM"
        case .fee:        return "Pay Fee"
        case .exam:       return "View Exam Details"
        case .homework:   return "View Homework"
        case .assignment: return "View Assignment"
        case .transport:  return "Track Bus"
        case .library:    return "View Library Account"
        case .holiday, .event, .announcement, .other:
            return nil
        }
    }
    
    static func from(apiType: String?) -> EventDetailTheme {
        switch (apiType ?? "").uppercased() {
        case "PTM":          return .ptm
        case "FEE":          return .fee
        case "EXAM":         return .exam
        case "HOLIDAY":      return .holiday
        case "EVENT":        return .event
        case "ANNOUNCEMENT": return .announcement
        case "HOMEWORK":     return .homework
        case "ASSIGNMENT":   return .assignment
        case "TRANSPORT":    return .transport
        case "LIBRARY":      return .library
        default:             return .other
        }
    }
}

// MARK: - SwiftUI View

struct EventDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    let event: CalendarEventItem?
    
    @State private var notesText: String = ""
    
    private var theme: EventDetailTheme {
        EventDetailTheme.from(apiType: event?.eventType)
    }
    
    // MARK: - Student Info Extraction
    private var studentName: String {
        let name = UserManager.shared.resolvedStudentName
        return name.isEmpty ? "Student Name" : name
    }
    
    private var studentInitials: String {
        let name = UserManager.shared.resolvedStudentName
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        } else if parts.count == 1 {
            return "\(parts[0].prefix(2))".uppercased()
        }
        return "ST"
    }
    
    private var gradeSectionString: String {
        let grade = UserManager.shared.resolvedGradeSection
        let section = UserManager.shared.resolvedStudentSection
        if grade.isEmpty && section.isEmpty { return "Grade · Section" }
        if section.isEmpty { return grade }
        return "\(grade) · Section \(section)"
    }
    
    private var tags: [String] {
        var list: [String] = []
        let grade = UserManager.shared.resolvedGradeSection
        let section = UserManager.shared.resolvedStudentSection
        if !grade.isEmpty { list.append(grade) }
        if !section.isEmpty { list.append("Section \(section)") }
        list.append("Main Campus")
        return list
    }
    
    // MARK: - Date / Time Extraction
    private var dateStr: String {
        guard let dateStr = event?.eventDate, let d = parseDate(dateStr) else { return "TBA" }
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df.string(from: d)
    }
    
    private var dateSub: String {
        return event?.eventDate ?? "Date not available"
    }
    
    private var timeStr: String {
        if event?.isAllDay == true {
            return "All Day"
        }
        let st = formatTime(event?.startTime)
        let et = formatTime(event?.endTime)
        if !st.isEmpty && !et.isEmpty {
            return "\(st) - \(et)"
        } else if !st.isEmpty {
            return st
        }
        return "TBA"
    }
    
    private var timeSub: String {
        if event?.isAllDay == true {
            return "Full-day event"
        }
        if event?.endTime != nil {
            return "Start – end"
        }
        return "Start time"
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // 1. Top White Navigation Bar
            navBarView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // 2. Colored Header Banner
                    coloredHeaderBanner
                    
                    // 3. Content Area
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Student Card & Tags
                        VStack(alignment: .leading, spacing: 16) {
                            studentInfoCard
                            tagsRow
                        }
                        
                        // Details Card (Date, Time, Branch)
                        detailsCard
                        
                        // What to know Section
                        whatToKnowSection
                        
                        // Notes Section
                        notesSection
                        
                        // Action Buttons
                        actionButtonsSection
                        
                    }
                    .padding(20)
                    .background(Color.white)
                }
            }
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.white)
    }
    
    // MARK: - Subviews
    
    private var navBarView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: topSafeAreaHeight)
            
            HStack(spacing: 0) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                }
                
                Text(theme.navTitle)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                    .padding(.leading, 12)
                
                Spacer()
                
                Button(action: {
                    // Notifications
                }) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(theme.primary)
                }
                
                ZStack {
                    Circle()
                        .fill(theme.lightBg)
                        .frame(width: 32, height: 32)
                    Text(studentInitials)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(theme.primary)
                }
                .padding(.leading, 14)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(Color.white)
    }
    
    private var coloredHeaderBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                // Badges
                HStack(spacing: 4) {
                    Image(systemName: "tag")
                        .font(.system(size: 10))
                    Text(theme.navTitle.uppercased())
                        .font(.system(size: 10, weight: .bold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                
                if event?.status?.uppercased() == "ACTIVE" {
                    Text("ACTIVE")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event?.title ?? "Event Details")
                    .font(.system(size: 22, weight: .bold))
                
                // Dynamic Academic Year calculation
                let currentYear = Calendar.current.component(.year, from: Date())
                Text("Academic year \(currentYear)-\(currentYear+1)")
                    .font(.system(size: 13, weight: .regular))
                    .opacity(0.9)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.primary)
    }
    
    private var studentInfoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Student")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(theme.lightBg)
                        .frame(width: 40, height: 40)
                    Text(studentInitials)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(studentName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                    Text(gradeSectionString)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
                }
            }
        }
    }
    
    private var tagsRow: some View {
        HStack(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(theme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(theme.lightBg)
                    .cornerRadius(12)
            }
        }
    }
    
    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRowView(
                icon: "calendar",
                title: "Date",
                value: dateStr,
                subValue: dateSub
            )
            
            Divider().padding(.leading, 60)
            
            detailRowView(
                icon: "clock",
                title: "Time",
                value: timeStr,
                subValue: timeSub
            )
            
            Divider().padding(.leading, 60)
            
            // Branch row uses asset "Icon 37"
            detailRowView(
                icon: "Icon 37",
                title: "Branch",
                value: "Main Campus",
                subValue: "Campus",
                isAssetIcon: true
            )
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.90, green: 0.92, blue: 0.95), lineWidth: 1)
        )
    }
    
    private func detailRowView(icon: String, title: String, value: String, subValue: String, isAssetIcon: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.lightBg)
                    .frame(width: 44, height: 44)
                
                if isAssetIcon {
                    Image(icon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(theme.primary)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(theme.primary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65))
                
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                
                Text(subValue)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65))
            }
            .padding(.top, 2)
            
            Spacer()
        }
        .padding(16)
    }
    
    private var whatToKnowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What to know")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                .padding(.bottom, 4)
            
            // Full-width box matching Figma
            if let desc = event?.description, !desc.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.primary)
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Important Details")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(theme.primary)
                        Text(desc)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(theme.primary.opacity(0.85))
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.highlightBg)
                .cornerRadius(10)
            } else {
                Text("No additional information provided.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.98, green: 0.98, blue: 0.99))
                    .cornerRadius(10)
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Notes")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
            
            TextField("Add a note for this \(theme.navTitle.lowercased())...", text: $notesText)
                .font(.system(size: 14))
                .padding(14)
                .background(Color(red: 0.98, green: 0.98, blue: 0.99))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0.90, green: 0.92, blue: 0.95), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Action Buttons (Figma per event type)
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            
            if let primaryTitle = theme.primaryActionTitle {
                // Primary (filled)
                Button(action: {
                    // Primary Action
                }) {
                    Text(primaryTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.primary)
                        .cornerRadius(24)
                }
                
                // Set Reminder (light)
                Button(action: {
                    // Set Reminder action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .medium))
                        Text("Set Reminder")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(theme.lightBg)
                    .cornerRadius(24)
                }
                
            } else {
                // Holiday / Event / Announcement / Other → Set Reminder is the main filled button
                Button(action: {
                    // Set Reminder action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .medium))
                        Text("Set Reminder")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(theme.primary)
                    .cornerRadius(24)
                }
            }
            
            // Share Details
            Button(action: {
                shareDetails()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .medium))
                    Text("Share Details")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(theme.primaryActionTitle == nil
                                 ? theme.primary
                                 : Color(red: 0.45, green: 0.48, blue: 0.55))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(theme.primaryActionTitle == nil ? theme.lightBg : Color.clear)
                .cornerRadius(24)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 32)
    }
    
    // MARK: - Share Functionality
    
    private var shareText: String {
        var lines: [String] = []
        lines.append("📌 \(event?.title ?? "Event Details")")
        lines.append("Type: \(theme.navTitle)")
        lines.append("Date: \(dateStr)")
        lines.append("Time: \(timeStr)")
        lines.append("Branch: Main Campus")
        if let desc = event?.description, !desc.isEmpty {
            lines.append("")
            lines.append("Details: \(desc)")
        }
        lines.append("")
        lines.append("Student: \(studentName) · \(gradeSectionString)")
        lines.append("")
        lines.append("Shared via SchoolFirst")
        return lines.joined(separator: "\n")
    }
    
    private func shareDetails() {
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }),
              var topVC = window.rootViewController else { return }
        
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        // iPad popover support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX,
                                        y: topVC.view.bounds.maxY - 80,
                                        width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        topVC.present(activityVC, animated: true)
    }
    
    // MARK: - Date/Time Helper methods
    
    private func parseDate(_ str: String) -> Date? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: str)
    }
    
    private func formatTime(_ str: String?) -> String {
        guard let str = str else { return "" }
        let inFormats = ["HH:mm:ss", "HH:mm"]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        
        for fmt in inFormats {
            df.dateFormat = fmt
            if let d = df.date(from: str) {
                let out = DateFormatter()
                out.locale = Locale(identifier: "en_US_POSIX")
                out.dateFormat = "hh:mm a"
                return out.string(from: d)
            }
        }
        return str
    }
    
    private var topSafeAreaHeight: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return window?.safeAreaInsets.top ?? 47
    }
}

//
//  ALLeventsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/10/26.
//

import UIKit
import SwiftUI

class EventsdashboardVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        var swiftUIView = AllEventsView()
        
        // Handle Event Tap Navigation
        swiftUIView.onEventTapped = { [weak self] selectedEvent in
            let detailVC = EventdetailsVC()
            detailVC.event = selectedEvent // Pass the API data
            self?.navigationController?.pushViewController(detailVC, animated: true)
        }
        
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

// MARK: - Event Theme (Matches Event Detail Screens)

enum EventCardTheme {
    case ptm          // Purple
    case fee          // Orange / Finance
    case exam         // Red
    case holiday      // Green
    case event        // Dark Grey
    case announcement // Purple-ish
    case homework     // Blue
    case assignment   // Red
    case transport    // Orange / Brown
    case library      // Blue
    case other        // Dark Grey
    
    var backgroundColor: Color {
        switch self {
        case .ptm:          return Color(red: 0.90, green: 0.85, blue: 1.00)
        case .fee:          return Color(red: 1.00, green: 0.92, blue: 0.83)
        case .exam:         return Color(red: 1.00, green: 0.87, blue: 0.87)
        case .holiday:      return Color(red: 0.84, green: 0.95, blue: 0.87)
        case .event:        return Color(red: 0.86, green: 0.89, blue: 0.93)
        case .announcement: return Color(red: 0.89, green: 0.84, blue: 1.00)
        case .homework:     return Color(red: 0.86, green: 0.92, blue: 1.00)
        case .assignment:   return Color(red: 1.00, green: 0.87, blue: 0.87)
        case .transport:    return Color(red: 1.00, green: 0.90, blue: 0.78)
        case .library:      return Color(red: 0.84, green: 0.91, blue: 1.00)
        case .other:        return Color(red: 0.86, green: 0.89, blue: 0.93)
        }
    }
    
    var textColor: Color {
        switch self {
        case .ptm:          return Color(red: 0.35, green: 0.15, blue: 0.75)
        case .fee:          return Color(red: 0.55, green: 0.35, blue: 0.15)
        case .exam:         return Color(red: 0.60, green: 0.10, blue: 0.15)
        case .holiday:      return Color(red: 0.15, green: 0.45, blue: 0.25)
        case .event:        return Color(red: 0.15, green: 0.20, blue: 0.30)
        case .announcement: return Color(red: 0.40, green: 0.20, blue: 0.70)
        case .homework:     return Color(red: 0.15, green: 0.35, blue: 0.65)
        case .assignment:   return Color(red: 0.60, green: 0.10, blue: 0.15)
        case .transport:    return Color(red: 0.60, green: 0.35, blue: 0.10)
        case .library:      return Color(red: 0.15, green: 0.35, blue: 0.70)
        case .other:        return Color(red: 0.15, green: 0.20, blue: 0.30)
        }
    }
    
    var displayName: String {
        switch self {
        case .ptm:          return "PTM"
        case .fee:          return "Fee"
        case .exam:         return "Exam"
        case .holiday:      return "Holiday"
        case .event:        return "Event"
        case .announcement: return "Announcement"
        case .homework:     return "Homework"
        case .assignment:   return "Assignment"
        case .transport:    return "Transport"
        case .library:      return "Library"
        case .other:        return "Other"
        }
    }
    
    static func from(apiType: String?) -> EventCardTheme {
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

struct AllEventsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var onEventTapped: ((CalendarEventItem) -> Void)?
    
    @State private var events: [CalendarEventItem] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if isLoading && events.isEmpty {
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                Spacer()
            } else if events.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 44))
                        .foregroundColor(.gray.opacity(0.5))
                    Text(errorMessage ?? "No events available.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(events) { event in
                            Button(action: {
                                onEventTapped?(event) // Trigger navigation
                            }) {
                                EventCardView(event: event)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                }
                .background(Color.white)
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            fetchEvents()
        }
    }
    
    // MARK: - API Call
    
    private func fetchEvents() {
        let schoolID = UserManager.shared.resolvedSchoolID
        let studentID = UserManager.shared.resolvedStudentID
        let sectionID = UserDefaults.standard.string(forKey: "STUDENT_SECTION") ?? ""
        
        guard !schoolID.isEmpty, !studentID.isEmpty else {
            self.errorMessage = "Student or school info unavailable."
            return
        }
        
        isLoading = true
        
        var parameters: [String: Any] = [
            "student_id": studentID
        ]
        if !sectionID.isEmpty {
            parameters["section_id"] = sectionID
        }
        
        let headers: [String: String] = [
            "X-School-ID": schoolID
        ]
        
        NetworkManager.shared.request(
            urlString: API.GET_CALENDAR_EVENTS,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { (result: Result<APIResponse<[CalendarEventItem]>, NetworkError>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.events = data.sorted { lhs, rhs in
                            (lhs.eventDate ?? "") < (rhs.eventDate ?? "")
                        }
                        self.errorMessage = nil
                    } else {
                        self.events = []
                        self.errorMessage = response.description.isEmpty ? "No events available." : response.description
                    }
                case .failure(let error):
                    self.events = []
                    self.errorMessage = error.localizedDescription
                    print("❌ Calendar events fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: topSafeAreaHeight)
            
            HStack(spacing: 0) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                }
                
                Text("Events")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                    .padding(.leading, 12)
                
                Spacer()
                
                Button(action: {
                    // Notifications
                }) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                }
                
                ZStack {
                    Circle()
                        .fill(Color(red: 0.90, green: 0.91, blue: 0.96))
                        .frame(width: 32, height: 32)
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
                }
                .padding(.leading, 14)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(height: 100)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color(red: 0.90, green: 0.91, blue: 0.93))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var topSafeAreaHeight: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return window?.safeAreaInsets.top ?? 47
    }
}

// MARK: - Reusable Card Component

struct EventCardView: View {
    let event: CalendarEventItem
    
    private var theme: EventCardTheme {
        EventCardTheme.from(apiType: event.eventType)
    }
    
    private var topLineText: String {
        var parts: [String] = []
        if event.isAllDay == true {
            parts.append("All day")
        } else if let st = event.startTime, let et = event.endTime {
            parts.append("\(formatTime(st)) - \(formatTime(et))")
        } else if let st = event.startTime {
            parts.append(formatTime(st))
        } else if let dateStr = event.eventDate, let d = parseDate(dateStr) {
            let df = DateFormatter()
            df.dateFormat = "d MMM yyyy"
            parts.append(df.string(from: d))
        }
        parts.append(theme.displayName)
        return parts.joined(separator: " · ")
    }
    
    private var titleText: String {
        event.title ?? "Untitled"
    }
    
    private var dateBadgeText: String? {
        guard let dateStr = event.eventDate, let d = parseDate(dateStr) else { return nil }
        let df = DateFormatter()
        df.dateFormat = "d MMM, yyyy"
        return df.string(from: d)
    }
    
    private var isDueToday: Bool {
        guard let dateStr = event.eventDate, let d = parseDate(dateStr) else { return false }
        return Calendar.current.isDateInToday(d)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(topLineText)
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(theme.textColor.opacity(0.85))
            
            Text(titleText)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.textColor)
                .fixedSize(horizontal: false, vertical: true)
            
            if let desc = event.description, !desc.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image("Icon 37")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 13, height: 13)
                        .padding(.top, 2)
                    
                    Text(desc)
                        .font(.system(size: 13, weight: .regular))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundColor(theme.textColor.opacity(0.85))
            }
            
            if let dateBadge = dateBadgeText {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(dateBadge)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(theme.textColor.opacity(0.85))
            }
            
            if isDueToday && (theme == .fee || theme == .homework || theme == .assignment) {
                HStack(spacing: 4) {
                    Text("!")
                        .font(.system(size: 11, weight: .heavy))
                    Text("Due Today")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 1.0, green: 0.9, blue: 0.8))
                .cornerRadius(12)
            }
            
            Button(action: {
                // Set Reminder action logic for the cell
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "alarm")
                        .font(.system(size: 14))
                    Text("Set Reminder")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(theme.textColor)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(theme.backgroundColor)
        .cornerRadius(16)
    }
    
    private func parseDate(_ str: String) -> Date? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: str)
    }
    
    private func formatTime(_ str: String) -> String {
        let inFormats = ["HH:mm:ss", "HH:mm"]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        
        for fmt in inFormats {
            df.dateFormat = fmt
            if let d = df.date(from: str) {
                let out = DateFormatter()
                out.locale = Locale(identifier: "en_US_POSIX")
                out.dateFormat = "h:mm a"
                return out.string(from: d)
            }
        }
        return str
    }
}

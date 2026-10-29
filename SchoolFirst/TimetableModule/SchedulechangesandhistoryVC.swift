//
//  SchedulechangesandhistoryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI

class SchedulechangesandhistoryVC: UIViewController {
    
    // API Data passed from PerioddetailsVC
    var timetableData: StudentTimetableData?
    var baseDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupSwiftUIView() {
        // Embed the SwiftUI view inside the UIViewController, passing the data
        let swiftUIView = ScheduleChangesView(timetableData: timetableData, baseDate: baseDate)
        
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

// MARK: - UI Models

enum ScheduleTab {
    case upcoming
    case history
}

enum ChangeThemeType {
    case teacher
    case room
    case time
    
    var color: Color {
        switch self {
        case .teacher: return .orange
        case .room: return Color(red: 0.1, green: 0.6, blue: 0.6) // Teal
        case .time: return .purple
        }
    }
    
    var iconName: String {
        switch self {
        case .teacher: return "person.2"
        case .room: return "building.2"
        case .time: return "calendar.badge.clock"
        }
    }
}

struct ScheduleChangeModel: Identifiable {
    let id = UUID()
    let type: ChangeThemeType
    let title: String
    let subtitle: String
    let dateBadge: String
    let originalValue: String
    let updatedValue: String
    let footerNote: String
    let completedDateString: String?
    let hasViewDetailsLink: Bool
    let exactDate: Date
}

// MARK: - SwiftUI View

struct ScheduleChangesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: ScheduleTab = .upcoming
    
    // API Dependencies
    let timetableData: StudentTimetableData?
    let baseDate: Date
    
    // State arrays populated dynamically
    @State private var upcomingData: [ScheduleChangeModel] = []
    @State private var historyData: [ScheduleChangeModel] = []
    
    let mainBlue = Color(red: 11/255, green: 86/255, blue: 154/255) // #0B569A
    
    // MARK: - User Manager References & Computed Properties
    
    private var studentFirstName: String {
        UserManager.shared.resolvedStudentName.components(separatedBy: " ").first ?? "Student"
    }
    
    private var studentFullName: String {
        UserManager.shared.resolvedStudentName
    }
    
    private var studentGradeSection: String {
        let grade = UserManager.shared.resolvedGradeSection
        let section = UserManager.shared.resolvedStudentSection
        if section.isEmpty { return grade }
        return "\(grade) · Section \(section)"
    }
    
    private var studentPhotoURL: URL? {
        URL(string: UserManager.shared.resolvedStudentPhotoURL)
    }
    
    private var termName: String {
        timetableData?.term?.name ?? "Term"
    }
    
    private var currentDateString: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE, d MMMM yyyy"
        return df.string(from: Date())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    activeChildSection
                    
                    if selectedTab == .history {
                        contextTagsView
                            .padding(.top, -8)
                    }
                    
                    tabSwitcherView
                    
                    if selectedTab == .upcoming {
                        upcomingSection
                    } else {
                        historySection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground).opacity(0.4))
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .onAppear {
            processTimetableData()
        }
    }
    
    // MARK: - Data Processing
    
    private func processTimetableData() {
        guard let schedule = timetableData?.schedule else { return }
        
        var allChanges: [ScheduleChangeModel] = []
        let calendar = Calendar.current
        
        // Helper to find dates for current week relative to baseDate
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: baseDate)) ?? baseDate
        
        // Dictionary mapping weekday (1=Sun, 2=Mon...) to its exact Date in the week
        var weekDates: [Int: Date] = [:]
        for i in 1...7 {
            if let dateForDay = calendar.date(byAdding: .day, value: i - 1, to: startOfWeek) {
                weekDates[i] = dateForDay
            }
        }
        
        // Closure to map array of periods into ViewModels
        let parsePeriods = { (periods: [TimetablePeriodEntry]?, weekday: Int) in
            guard let periods = periods, let dateForDay = weekDates[weekday] else { return }
            
            for period in periods {
                // Check if it's a change
                let isTeacherSub = period.hasSubstitution == true
                let isRoomChange = (period.notes?.lowercased().contains("room") == true) && !isTeacherSub
                
                if isTeacherSub || isRoomChange {
                    let type: ChangeThemeType = isTeacherSub ? .teacher : .room
                    
                    let title = isTeacherSub ? "Teacher substitution" : "Room change"
                    let subjectName = period.subject?.name?.capitalized ?? "Subject"
                    let periodNum = period.period?.periodNumber ?? 0
                    let subtitle = "\(subjectName) · Period \(periodNum)"
                    
                    // Date Format
                    let dateBadge: String
                    if calendar.isDateInToday(dateForDay) {
                        dateBadge = "TODAY"
                    } else {
                        let df = DateFormatter()
                        df.dateFormat = "d MMM"
                        dateBadge = df.string(from: dateForDay).uppercased()
                    }
                    
                    // Values
                    var original = ""
                    var updated = ""
                    var footer = ""
                    
                    if isTeacherSub {
                        original = period.substitution?.originalTeacher?.name ?? period.regularTeacher?.name ?? "Regular Teacher"
                        updated = period.substitution?.substituteTeacher?.name ?? period.teacher?.name ?? "Substitute Teacher"
                        
                        let reason = period.substitution?.reason ?? ""
                        footer = reason.isEmpty ? "Time and room remain unchanged." : "\(reason) · Time and room remain unchanged."
                    } else if isRoomChange {
                        original = "Classroom" // Fallback since original room isn't explicitly in API
                        updated = period.notes ?? "New Room"
                        let teacher = period.teacher?.name ?? period.regularTeacher?.name ?? "Teacher"
                        footer = "Teacher \(teacher) is unchanged."
                    }
                    
                    // History completed string
                    let fullDateFormatter = DateFormatter()
                    fullDateFormatter.dateFormat = "EEEE, d MMMM"
                    let completedStr = "\(fullDateFormatter.string(from: dateForDay)) · Completed"
                    
                    let model = ScheduleChangeModel(
                        type: type,
                        title: title,
                        subtitle: subtitle,
                        dateBadge: dateBadge,
                        originalValue: original,
                        updatedValue: updated,
                        footerNote: footer,
                        completedDateString: completedStr,
                        hasViewDetailsLink: true,
                        exactDate: dateForDay
                    )
                    
                    allChanges.append(model)
                }
            }
        }
        
        // Parse all days (Calendar weekday: 1=Sun, 2=Mon...)
        parsePeriods(schedule.sunday, 1)
        parsePeriods(schedule.monday, 2)
        parsePeriods(schedule.tuesday, 3)
        parsePeriods(schedule.wednesday, 4)
        parsePeriods(schedule.thursday, 5)
        parsePeriods(schedule.friday, 6)
        parsePeriods(schedule.saturday, 7)
        
        // Sort and separate into Upcoming / History based on start of today
        let todayStart = calendar.startOfDay(for: Date())
        
        // Sort by date closest first
        allChanges.sort { $0.exactDate < $1.exactDate }
        
        self.upcomingData = allChanges.filter { calendar.startOfDay(for: $0.exactDate) >= todayStart }
        self.historyData = allChanges.filter { calendar.startOfDay(for: $0.exactDate) < todayStart }
        
        // History should show most recent first
        self.historyData.sort { $0.exactDate > $1.exactDate }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Schedule changes")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Read-only updates for \(studentFirstName)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(height: 100, alignment: .bottom)
        .background(mainBlue)
    }
    
    private var activeChildSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ACTIVE CHILD")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                // Async image loading using UserManager Photo URL
                AsyncImage(url: studentPhotoURL) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else if phase.error != nil {
                        placeholderAvatar
                    } else {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(studentFullName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text(studentGradeSection)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var placeholderAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.yellow.opacity(0.3))
                .frame(width: 40, height: 40)
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
    }
    
    private var contextTagsView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(mainBlue)
                
                Text("AY \((Calendar.current.component(.year, from: Date())))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(mainBlue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(mainBlue.opacity(0.1))
            .cornerRadius(20)
            
            Text(termName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            Spacer()
        }
    }
    
    private var tabSwitcherView: some View {
        HStack(spacing: 0) {
            tabButton(title: "Upcoming · \(upcomingData.count)", tab: .upcoming)
            tabButton(title: "History\(historyData.count > 0 ? " · \(historyData.count)" : "")", tab: .history)
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func tabButton(title: String, tab: ScheduleTab) -> some View {
        let isSelected = selectedTab == tab
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? mainBlue : Color.clear)
                .cornerRadius(20)
        }
    }
    
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming updates")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text(termName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(mainBlue)
            }
            .padding(.top, 8)
            
            if upcomingData.isEmpty {
                emptyStateView(message: "No upcoming schedule changes.")
            } else {
                ForEach(upcomingData) { item in
                    ChangeCardView(item: item)
                }
            }
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("As of \(currentDateString)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
            
            HStack {
                Text("Completed updates")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text(termName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(mainBlue)
            }
            
            if historyData.isEmpty {
                emptyStateView(message: "No completed schedule changes.")
            } else {
                ForEach(historyData) { item in
                    ChangeCardView(item: item)
                }
                
                // Info Box Summary
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(historyData.count) completed change\(historyData.count > 1 ? "s" : "")")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    
                    if upcomingData.count > 0 {
                        Text("There are still \(upcomingData.count) item(s) in Upcoming.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                            .lineSpacing(2)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Bottom Action Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .bold))
                    Text("Back to timetable")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(mainBlue)
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
    
    private func emptyStateView(message: String) -> some View {
        VStack {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.bottom, 8)
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Reusable Card Component

struct ChangeCardView: View {
    let item: ScheduleChangeModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Top Header Row
            HStack(alignment: .top) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.type.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: item.type.iconName)
                        .foregroundColor(item.type.color)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                // Titles
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text(item.subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                // Date Badge
                Text(item.dateBadge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(item.type.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.type.color.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // History Completed Status Line
            if let completedStr = item.completedDateString {
                Text(completedStr)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // Transformation Box (Original -> Updated)
            HStack(spacing: 8) {
                // Original Side
                VStack(alignment: .leading, spacing: 4) {
                    Text("ORIGINAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Text(item.originalValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                
                // Arrow
                Image(systemName: "arrow.right")
                    .foregroundColor(item.type.color)
                    .font(.system(size: 14, weight: .bold))
                
                // Updated Side
                VStack(alignment: .leading, spacing: 4) {
                    Text("UPDATED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(item.type.color)
                    Text(item.updatedValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(item.type.color.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Footer Note
            Text(item.footerNote)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .lineSpacing(2)
            
            // History Specific Link
            if item.hasViewDetailsLink {
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Text("View period details")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

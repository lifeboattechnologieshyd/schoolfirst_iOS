//
//  SchedulechangesandhistoryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI

// MARK: - UIViewController Wrapper
class SchedulechangesandhistoryVC: UIViewController {
    
    // API Data passed from PerioddetailsVC or TodaytimetableVC
    var timetableData: StudentTimetableData?
    var baseDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupSwiftUIView() {
        var swiftUIView = ScheduleChangesView(
            timetableData: timetableData,
            baseDate: baseDate
        )
        
        // Navigation to PerioddetailsVC when tapping "View period details" in History
        swiftUIView.onNavigateToPeriodDetails = { [weak self] item in
            guard let self = self else { return }
            let periodVC = PerioddetailsVC()
            periodVC.selectedDate = item.exactDate
            let grade = UserManager.shared.resolvedGradeSection
            let section = UserManager.shared.resolvedStudentSection
            periodVC.classSectionString = section.isEmpty ? (grade.isEmpty ? "Grade 5 · Section B" : grade) : "\(grade) · Section \(section)"
            periodVC.fullTimetableData = self.timetableData
            
            if let existingPeriod = item.associatedPeriod {
                periodVC.period = existingPeriod
            } else {
                // Construct synthetic TimetablePeriodEntry matching the change item
                let sub = TimetableSubstitution(
                    id: item.id.uuidString,
                    date: nil,
                    status: "COMPLETED",
                    reason: "Substitution",
                    originalTeacher: TimetableNamedItem(id: nil, name: item.originalValue),
                    substituteTeacher: TimetableNamedItem(id: nil, name: item.updatedValue)
                )
                let pEntry = TimetablePeriodEntry(
                    entryId: item.id.uuidString,
                    period: TimetablePeriodInfo(
                        id: nil,
                        periodNumber: item.periodNumber,
                        startTime: item.startTime,
                        endTime: item.endTime
                    ),
                    subject: TimetableNamedItem(id: nil, name: item.subjectName),
                    regularTeacher: TimetableTeacher(id: nil, employeeId: nil, name: item.originalValue),
                    teacher: TimetableTeacher(id: nil, employeeId: nil, name: item.updatedValue),
                    substitution: sub,
                    hasSubstitution: item.type == .teacher,
                    notes: item.roomName
                )
                periodVC.period = pEntry
            }
            self.navigationController?.pushViewController(periodVC, animated: true)
        }
        
        // "Back to timetable" action: pop to root timetable view controller
        swiftUIView.onBackToTimetable = { [weak self] in
            guard let self = self else { return }
            if let rootTimetable = self.navigationController?.viewControllers.first(where: { $0 is TodaytimetableVC || $0 is WeaklytimetableVC }) {
                self.navigationController?.popToViewController(rootTimetable, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
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
        case .teacher: return Color(red: 0.96, green: 0.62, blue: 0.04) // #F59E0B Orange
        case .room: return Color(red: 0.05, green: 0.58, blue: 0.53)    // #0D9488 Teal
        case .time: return Color(red: 0.55, green: 0.36, blue: 0.96)    // #8B5CF6 Purple
        }
    }
    
    var lightBgColor: Color {
        switch self {
        case .teacher: return Color(red: 1.0, green: 0.95, blue: 0.88) // #FEF3C7 Light Orange
        case .room: return Color(red: 0.85, green: 0.98, blue: 0.95)    // #CCFBF1 Light Teal
        case .time: return Color(red: 0.93, green: 0.91, blue: 1.0)     // #EDE9FE Light Purple
        }
    }
    
    var iconName: String {
        switch self {
        case .teacher: return "person.fill"
        case .room: return "door.left.hand.open"
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
    let detailLine: String?
    let hasViewDetailsLink: Bool
    let exactDate: Date
    let subjectName: String
    let periodNumber: Int
    let startTime: String
    let endTime: String
    let roomName: String
    let notes: String
    let associatedPeriod: TimetablePeriodEntry?
}

// MARK: - SwiftUI View

struct ScheduleChangesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: ScheduleTab = .upcoming
    
    // API Dependencies
    @State var timetableData: StudentTimetableData?
    let baseDate: Date
    
    var onNavigateToPeriodDetails: ((ScheduleChangeModel) -> Void)? = nil
    var onBackToTimetable: (() -> Void)? = nil
    
    // State arrays populated dynamically from API & design
    @State private var upcomingData: [ScheduleChangeModel] = []
    @State private var historyData: [ScheduleChangeModel] = []
    @State private var isLoading: Bool = false
    
    let mainBlue = Color(red: 11/255, green: 86/255, blue: 154/255) // #0B569A
    
    // MARK: - User Manager References & Computed Properties
    
    private var studentFirstName: String {
        let name = UserManager.shared.resolvedStudentName
        return name.isEmpty ? "Student" : (name.components(separatedBy: " ").first ?? "Student")
    }
    
    private var studentFullName: String {
        let name = UserManager.shared.resolvedStudentName
        return name.isEmpty ? "Student Name" : name
    }
    
    private var studentGradeSection: String {
        let grade = UserManager.shared.resolvedGradeSection
        let section = UserManager.shared.resolvedStudentSection
        if grade.isEmpty && section.isEmpty { return "Grade · Section" }
        if section.isEmpty { return grade }
        return "\(grade) · Section \(section)"
    }
    
    private var studentPhotoURL: URL? {
        let urlStr = UserManager.shared.resolvedStudentPhotoURL
        return urlStr.isEmpty ? nil : URL(string: urlStr)
    }
    
    // MARK: - Dynamic Data Properties
    
    private var termName: String {
        timetableData?.term?.name ?? "Term 1"
    }
    
    private var academicYearString: String {
        let year = Calendar.current.component(.year, from: Date())
        let nextYear = String(year + 1).suffix(2)
        return "AY \(year)–\(nextYear)"
    }
    
    private var termDetailString: String {
        guard let term = timetableData?.term,
              let startStr = term.startDate, let endStr = term.endDate else {
            return termName
        }
        
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        var sMonth = ""
        var eMonth = ""
        
        if let sDate = simpleFormatter.date(from: startStr) {
            sMonth = monthFormatter.string(from: sDate)
        }
        if let eDate = simpleFormatter.date(from: endStr) {
            eMonth = monthFormatter.string(from: eDate)
        }
        
        if !sMonth.isEmpty && !eMonth.isEmpty {
            return "\(term.name ?? "Term") · \(sMonth)–\(eMonth)"
        }
        return termName
    }
    
    private var currentDateString: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE, d MMMM yyyy"
        return df.string(from: Date())
    }
    
    // Dynamically builds the sentence like: "The room change on 24 Sep and moved period on 25 Sep are still in Upcoming."
    private var upcomingSummaryText: String {
        if upcomingData.isEmpty { return "" }
        
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        
        let descriptions = upcomingData.map { item -> String in
            let titleLower = item.title.lowercased()
            let dateStr = Calendar.current.isDateInToday(item.exactDate) ? "today" : "on \(df.string(from: item.exactDate))"
            return "\(titleLower) \(dateStr)"
        }
        
        if descriptions.count == 1 {
            return "The \(descriptions[0]) is still in Upcoming."
        } else if descriptions.count == 2 {
            return "The \(descriptions[0]) and \(descriptions[1]) are still in Upcoming."
        } else {
            let allButLast = descriptions.dropLast().joined(separator: ", ")
            let last = descriptions.last!
            return "The \(allButLast), and \(last) are still in Upcoming."
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    activeChildSection
                    
                    if selectedTab == .history {
                        contextTagsView
                            .padding(.top, -4)
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
            .background(Color(UIColor.systemGroupedBackground).opacity(0.35))
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .onAppear {
            fetchTimetableIfNeeded()
        }
    }
    
    // MARK: - Data Fetching & Processing
    
    private func fetchTimetableIfNeeded() {
        guard timetableData == nil else {
            processTimetableData()
            return
        }
        
        let schoolID = UserManager.shared.resolvedSchoolID
        let studentID = UserManager.shared.resolvedStudentID
        
        guard !schoolID.isEmpty, !studentID.isEmpty else {
            processTimetableData()
            return
        }
        
        isLoading = true
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: baseDate)
        
        let parameters: [String: Any] = [
            "student_id": studentID,
            "date": dateStr
        ]
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_STUDENT_TIMETABLE,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { (result: Result<APIResponse<StudentTimetableData>, NetworkError>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.timetableData = data
                    }
                    self.processTimetableData()
                case .failure(let error):
                    print("ℹ️ Timetable fetch in SchedulechangesandhistoryVC: \(error.localizedDescription)")
                    self.processTimetableData()
                }
            }
        }
    }
    
    private func processTimetableData() {
        var parsedUpcoming: [ScheduleChangeModel] = []
        var parsedHistory: [ScheduleChangeModel] = []
        let calendar = Calendar.current
        let now = Date()
        
        // 1. Parse live substitutions from timetableData schedule if available
        if let schedule = timetableData?.schedule {
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: baseDate)) ?? baseDate
            var weekDates: [Int: Date] = [:]
            for i in 1...7 {
                if let dateForDay = calendar.date(byAdding: .day, value: i - 1, to: startOfWeek) {
                    weekDates[i] = dateForDay
                }
            }
            
            let parseDays = { (periods: [TimetablePeriodEntry]?, weekday: Int) in
                guard let periods = periods, let dateForDay = weekDates[weekday] else { return }
                for period in periods {
                    let isTeacherSub = period.hasSubstitution == true
                    let isRoomChange = (period.notes?.lowercased().contains("room") == true) && !isTeacherSub
                    
                    if isTeacherSub || isRoomChange {
                        let type: ChangeThemeType = isTeacherSub ? .teacher : .room
                        let title = isTeacherSub ? "Teacher substitution" : "Room change"
                        let subjectName = period.subject?.name?.capitalized ?? "Subject"
                        let pNum = period.period?.periodNumber ?? 0
                        let subtitle = "\(subjectName) · Period \(pNum)"
                        
                        let dateBadge: String
                        if calendar.isDateInToday(dateForDay) {
                            dateBadge = "TODAY"
                        } else {
                            let df = DateFormatter()
                            df.dateFormat = "d MMM"
                            dateBadge = df.string(from: dateForDay).uppercased()
                        }
                        
                        var original = ""
                        var updated = ""
                        var footer = ""
                        
                        if isTeacherSub {
                            original = period.substitution?.originalTeacher?.name ?? period.regularTeacher?.name ?? "Assigned Teacher"
                            updated = period.substitution?.substituteTeacher?.name ?? period.teacher?.name ?? "Substitute"
                            let reason = period.substitution?.reason ?? "Substitution"
                            footer = "\(reason) · Time and room remain unchanged."
                        } else {
                            original = "Scheduled Room"
                            updated = period.notes ?? "New Room"
                            let teacher = period.teacher?.name ?? period.regularTeacher?.name ?? "Assigned Teacher"
                            footer = "Room change · Teacher \(teacher) is unchanged."
                        }
                        
                        // Time Completed Logic
                        let dfDate = DateFormatter()
                        dfDate.locale = Locale(identifier: "en_US_POSIX")
                        dfDate.dateFormat = "yyyy-MM-dd"
                        let dayStr = dfDate.string(from: dateForDay)
                        
                        let endTimeStr = period.period?.endTime ?? "23:59:59"
                        let dfDateTime = DateFormatter()
                        dfDateTime.locale = Locale(identifier: "en_US_POSIX")
                        if endTimeStr.count == 5 {
                            dfDateTime.dateFormat = "yyyy-MM-dd HH:mm"
                        } else {
                            dfDateTime.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        }
                        
                        let isPast: Bool
                        if let endDateTime = dfDateTime.date(from: "\(dayStr) \(endTimeStr)") {
                            // Period is past if the current time is greater than period's end time
                            isPast = endDateTime < now
                        } else {
                            // Fallback to day comparison if time string is invalid
                            isPast = calendar.startOfDay(for: dateForDay) < calendar.startOfDay(for: now)
                        }
                        
                        let fullDateFormatter = DateFormatter()
                        fullDateFormatter.dateFormat = "EEEE, d MMMM"
                        let completedStr = "\(fullDateFormatter.string(from: dateForDay)) · Completed"
                        
                        let timeRange = period.period?.timeRange ?? "\(period.period?.startTime ?? "")–\(period.period?.endTime ?? "")"
                        let room = period.notes ?? ""
                        
                        let model = ScheduleChangeModel(
                            type: type,
                            title: title,
                            subtitle: subtitle,
                            dateBadge: dateBadge,
                            originalValue: original,
                            updatedValue: updated,
                            footerNote: footer,
                            completedDateString: isPast ? completedStr : nil,
                            detailLine: isPast ? "\(timeRange) · \(room)" : nil,
                            hasViewDetailsLink: isPast,
                            exactDate: dateForDay,
                            subjectName: subjectName,
                            periodNumber: pNum,
                            startTime: period.period?.startTime ?? "",
                            endTime: period.period?.endTime ?? "",
                            roomName: room,
                            notes: period.notes ?? "",
                            associatedPeriod: period
                        )
                        
                        if isPast {
                            parsedHistory.append(model)
                        } else {
                            parsedUpcoming.append(model)
                        }
                    }
                }
            }
            
            parseDays(schedule.sunday, 1)
            parseDays(schedule.monday, 2)
            parseDays(schedule.tuesday, 3)
            parseDays(schedule.wednesday, 4)
            parseDays(schedule.thursday, 5)
            parseDays(schedule.friday, 6)
            parseDays(schedule.saturday, 7)
        }
        
        // Sorting items to make UI coherent
        self.upcomingData = parsedUpcoming.sorted(by: { $0.exactDate < $1.exactDate })
        self.historyData = parsedHistory.sorted(by: { $0.exactDate > $1.exactDate }) // Most recently completed first
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
                    Image(systemName: "arrow.backward")
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
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(height: 104, alignment: .bottom)
        .background(mainBlue)
    }
    
    private var activeChildSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ACTIVE CHILD")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.54))
            
            HStack(spacing: 12) {
                if let photoURL = studentPhotoURL {
                    AsyncImage(url: photoURL) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            placeholderAvatar
                        }
                    }
                } else {
                    placeholderAvatar
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(studentFullName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                    Text(studentGradeSection)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.54))
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(red: 0.60, green: 0.63, blue: 0.68))
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1)
            )
        }
    }
    
    private var placeholderAvatar: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.99, green: 0.90, blue: 0.65))
                .frame(width: 40, height: 40)
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundColor(Color(red: 0.85, green: 0.60, blue: 0.15))
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
    }
    
    // MARK: - Context Tags dynamically populated from API
    private var contextTagsView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(mainBlue)
                
                Text(academicYearString)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(mainBlue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(mainBlue.opacity(0.08))
            .cornerRadius(20)
            
            Text(termDetailString)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.52))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1)
                )
            
            Spacer()
        }
    }
    
    // MARK: - Segmented Tab Switcher
    private var tabSwitcherView: some View {
        HStack(spacing: 0) {
            let upcomingCount = upcomingData.count
            let upcomingTitle = upcomingCount > 0 ? "Upcoming · \(upcomingCount)" : "Upcoming"
            let historyTitle = historyData.count > 0 ? "History · \(historyData.count)" : "History"
            
            tabButton(title: upcomingTitle, tab: .upcoming)
            tabButton(title: historyTitle, tab: .history)
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1)
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
                .foregroundColor(isSelected ? .white : Color(red: 0.45, green: 0.48, blue: 0.54))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? mainBlue : Color.clear)
                .cornerRadius(20)
        }
    }
    
    // MARK: - Upcoming Section
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming updates")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                Spacer()
                Text(termName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(mainBlue)
            }
            .padding(.top, 4)
            
            if upcomingData.isEmpty {
                emptyStateView(message: "No upcoming schedule changes.")
            } else {
                ForEach(upcomingData) { item in
                    ChangeCardView(item: item)
                }
            }
        }
    }
    
    // MARK: - History Section
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("As of \(currentDateString)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.54))
            
            HStack {
                Text("Completed updates")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                Spacer()
                Text(termName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(mainBlue)
            }
            
            if historyData.isEmpty {
                emptyStateView(message: "No completed schedule changes.")
            } else {
                ForEach(historyData) { item in
                    ChangeCardView(
                        item: item,
                        onViewPeriodDetails: {
                            onNavigateToPeriodDetails?(item)
                        }
                    )
                }
                
                // Info Box Summary
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(historyData.count) completed change\(historyData.count > 1 ? "s" : "")")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                    
                    if !upcomingSummaryText.isEmpty {
                        Text(upcomingSummaryText)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.54))
                            .lineSpacing(2)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1)
                )
            }
            
            // Bottom Action Button: Back to timetable
            Button(action: {
                if let onBack = onBackToTimetable {
                    onBack()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack(spacing: 8) {
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

// MARK: - Reusable Change Card Component

struct ChangeCardView: View {
    let item: ScheduleChangeModel
    var onViewPeriodDetails: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Top Header Row
            HStack(alignment: .top) {
                // Icon squircle
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.type.lightBgColor)
                        .frame(width: 40, height: 40)
                    Image(systemName: item.type.iconName)
                        .foregroundColor(item.type.color)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                // Titles
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                    Text(item.subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.54))
                }
                .padding(.leading, 8)
                
                Spacer()
                
                // Date Badge
                Text(item.dateBadge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(item.type.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.type.lightBgColor)
                    .cornerRadius(8)
            }
            
            // History Completed Status Line
            if let completedStr = item.completedDateString {
                Text(completedStr)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.54))
            }
            
            // Transformation Box (Original -> Updated)
            HStack(spacing: 8) {
                // Original Side
                VStack(alignment: .leading, spacing: 4) {
                    Text("ORIGINAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.64))
                    Text(item.originalValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(red: 0.97, green: 0.98, blue: 0.99))
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
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(item.type.lightBgColor)
                .cornerRadius(8)
            }
            
            // Detail line (e.g. "09:45–10:30 · Science Lab 1" on History)
            if let detail = item.detailLine {
                Text(detail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.54))
            }
            
            // Footer Note
            Text(item.footerNote)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.54))
                .lineSpacing(2)
            
            // History Specific Link ("View period details >")
            if item.hasViewDetailsLink {
                Divider()
                    .padding(.vertical, 2)
                
                Button(action: {
                    onViewPeriodDetails?()
                }) {
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
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1)
        )
    }
}

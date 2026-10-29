//
//  WeaklytimetableVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI
import Combine

// MARK: - View Model
class WeeklyTimetableViewModel: ObservableObject {
    @Published var terms: [TimetableTermItem] = []
    @Published var weekSchedule: TimetableSchedule?
    
    @Published var selectedDate: Date = Date()
    @Published var weekStartDate: Date = Date()
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        updateWeekStart(for: Date())
    }
    
    // MARK: - Fetch Terms
    func fetchTerms() {
        // Prevent refetching if we already have data to avoid the timetable disappearing when returning from navigation
        guard terms.isEmpty else { return }
        
        let schoolID = UserManager.shared.resolvedSchoolID
        guard !schoolID.isEmpty else { return }
        
        isLoading = true
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_TIMETABLE_TERMS,
            method: .GET,
            requiresAuth: true,
            parameters: nil,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<[TimetableTermItem]>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self?.terms = response.data ?? []
                        self?.fetchWeeklyTimetable()
                    } else {
                        self?.isLoading = false
                        self?.errorMessage = response.description
                    }
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Fetch Weekly Timetable
    func fetchWeeklyTimetable() {
        let schoolID = UserManager.shared.resolvedSchoolID
        let studentID = UserManager.shared.resolvedStudentID
        guard !schoolID.isEmpty, !studentID.isEmpty else { return }
        
        isLoading = true
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        // Use Monday of the current week to fetch the whole week's schedule
        let dateStr = formatter.string(from: weekStartDate)
        
        var parameters: [String: Any] = [
            "student_id": studentID,
            "date": dateStr
        ]
        
        if let termID = activeTerm?.id {
            parameters["term_id"] = termID
        }
        
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_STUDENT_TIMETABLE,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<StudentTimetableData>, NetworkError>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self?.weekSchedule = data.schedule
                    }
                case .failure(let error):
                    print("❌ Error fetching weekly timetable: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Date Navigation Logic
    func updateWeekStart(for date: Date) {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        if let monday = cal.date(from: comps) {
            weekStartDate = monday
        }
    }
    
    func nextWeek() {
        if let next = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: weekStartDate) {
            weekStartDate = next
            selectedDate = next
            fetchWeeklyTimetable()
        }
    }
    
    func previousWeek() {
        if let prev = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: weekStartDate) {
            weekStartDate = prev
            selectedDate = prev
            fetchWeeklyTimetable()
        }
    }
    
    func jumpToToday() {
        let today = Date()
        selectedDate = today
        updateWeekStart(for: today)
        fetchWeeklyTimetable()
    }
    
    // Day generation for Mon-Sat (0 to 5)
    var weekDays: [(date: Date, dayName: String, dateString: String)] {
        var days: [(Date, String, String)] = []
        let cal = Calendar.current
        for i in 0..<6 { // Monday to Saturday
            if let d = cal.date(byAdding: .day, value: i, to: weekStartDate) {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                let dayName = formatter.string(from: d)
                formatter.dateFormat = "d MMM"
                let dateString = formatter.string(from: d)
                days.append((d, dayName, dateString))
            }
        }
        return days
    }
    
    var periodsForSelectedDate: [TimetablePeriodEntry] {
        guard let schedule = weekSchedule else { return [] }
        return schedule.periods(for: selectedDate).sorted { ($0.period?.periodNumber ?? 0) < ($1.period?.periodNumber ?? 0) }
    }
    
    // MARK: - Formatted Strings
    private var activeTerm: TimetableTermItem? {
        let active = terms.first { term in
            guard let start = parseDate(term.startDate), let end = parseDate(term.endDate) else { return false }
            return weekStartDate >= start && weekStartDate <= end
        }
        return active ?? terms.first
    }
    
    var headerSubtitle: String {
        let termName = activeTerm?.name ?? "Term N/A"
        return "\(academicYearText) · \(termName)"
    }
    
    var weekRangeString: String {
        let cal = Calendar.current
        if let saturday = cal.date(byAdding: .day, value: 5, to: weekStartDate) {
            let startF = DateFormatter()
            startF.dateFormat = "d"
            let endF = DateFormatter()
            endF.dateFormat = "d MMMM"
            return "\(startF.string(from: weekStartDate))–\(endF.string(from: saturday))"
        }
        return ""
    }
    
    var weekSubtextString: String {
        let termName = activeTerm?.name ?? "Term"
        let weekNum = Calendar.current.component(.weekOfYear, from: weekStartDate)
        return "\(termName) · Week \(weekNum)"
    }
    
    var dateSectionHeaderString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE · d MMM"
        return f.string(from: selectedDate)
    }
    
    var selectedDayName: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: selectedDate)
    }
    
    var isSelectedDateToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    var academicYearText: String {
        guard let ay = activeTerm?.academicYear?.name else { return "AY N/A" }
        let parts = ay.components(separatedBy: "-")
        if parts.count == 2, let last = parts.last, last.count == 4 {
            let shortYear = String(last.suffix(2))
            return "AY \(parts[0])–\(shortYear)"
        }
        return "AY \(ay)"
    }
    
    var termBadgeText: String {
        guard let term = activeTerm else { return "Term N/A" }
        let name = term.name ?? "Term"
        let start = formatMonth(term.startDate)
        let end = formatMonth(term.endDate)
        if !start.isEmpty && !end.isEmpty {
            return "\(name) · \(start)–\(end)"
        }
        return name
    }
    
    private func parseDate(_ dateStr: String?) -> Date? {
        guard let dateStr = dateStr else { return nil }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: dateStr)
    }
    
    private func formatMonth(_ dateStr: String?) -> String {
        guard let date = parseDate(dateStr) else { return "" }
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f.string(from: date)
    }
}

// MARK: - ViewController
class WeaklytimetableVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupSwiftUIView() {
        var weeklyTimetableView = WeeklyTimetableView()
        
        // Navigation Callback for period cells
        weeklyTimetableView.onPeriodTapped = { [weak self] period in
            let detailsVC = PerioddetailsVC()
            self?.navigationController?.pushViewController(detailsVC, animated: true)
        }
        
        let hostingController = UIHostingController(rootView: weeklyTimetableView)
        
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

// MARK: - Custom Button Style (Prevents fading/flashing when tapping)
struct NoTapAnimationStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
    }
}

// MARK: - SwiftUI View
struct WeeklyTimetableView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = WeeklyTimetableViewModel()
    
    // Callback for navigation
    var onPeriodTapped: ((TimetablePeriodEntry) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Custom Header respecting safe area
            headerView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    weekNavigatorView
                    
                    daysScrollView
                    
                    contextTagsView
                    
                    dateSectionHeaderView
                    
                    // ZStack ensures the timetable is ALWAYS shown and doesn't disappear while loading
                    ZStack(alignment: .top) {
                        if viewModel.periodsForSelectedDate.isEmpty && !viewModel.isLoading {
                            // MARK: Custom Empty State View (Matches Figma)
                            VStack(spacing: 16) {
                                ZStack {
                                    // Light blue circular background
                                    Circle()
                                        .fill(Color(red: 238/255, green: 245/255, blue: 255/255))
                                        .frame(width: 90, height: 90)
                                    
                                    // Calendar Icon with Red Dot Badge
                                    ZStack(alignment: .bottomTrailing) {
                                        Image(systemName: "calendar")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color(red: 24/255, green: 104/255, blue: 228/255))
                                            .font(Font.title.weight(.semibold))
                                        
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 10, height: 10)
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .offset(x: 2, y: -2)
                                    }
                                }
                                .padding(.bottom, 4)
                                
                                VStack(spacing: 6) {
                                    Text("No classes on \(viewModel.selectedDayName)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(red: 16/255, green: 40/255, blue: 70/255))
                                    
                                    Text("There are no periods scheduled for this day.")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 60)
                            
                        } else {
                            periodsListView
                                .opacity(viewModel.isLoading ? 0.5 : 1.0) // Dim slightly while loading new week
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 40)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            // Only fetch if empty to prevent timetable disappearing when returning from PerioddetailsVC
            if viewModel.terms.isEmpty {
                viewModel.fetchTerms()
            }
        }
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack(alignment: .center) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Weekly timetable")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(viewModel.headerSubtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {
                // Action for notifications
            }) {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(Color(red: 11/255, green: 86/255, blue: 154/255).ignoresSafeArea(edges: .top))
    }
    
    private var weekNavigatorView: some View {
        HStack {
            Button(action: { viewModel.previousWeek() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                    .font(.system(size: 16, weight: .bold))
                    .padding(8)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(viewModel.weekRangeString)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Text(viewModel.weekSubtextString)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { viewModel.nextWeek() }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                    .font(.system(size: 16, weight: .bold))
                    .padding(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
    
    private var daysScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.weekDays, id: \.date) { day in
                    let isSelected = Calendar.current.isDate(day.date, inSameDayAs: viewModel.selectedDate)
                    
                    VStack(spacing: 4) {
                        Text(day.dayName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isSelected ? .white : .primary)
                        Text(day.dateString)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isSelected ? .white : .gray)
                    }
                    .frame(width: 65, height: 65)
                    .background(isSelected ? Color(red: 11/255, green: 86/255, blue: 154/255) : Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedDate = day.date
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var contextTagsView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                Text(viewModel.academicYearText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(red: 11/255, green: 86/255, blue: 154/255).opacity(0.1))
            .cornerRadius(20)
            
            Text(viewModel.termBadgeText)
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
        .padding(.horizontal, 16)
    }
    
    private var dateSectionHeaderView: some View {
        HStack {
            Text(viewModel.dateSectionHeaderString)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if !viewModel.isSelectedDateToday {
                Button(action: {
                    viewModel.jumpToToday()
                }) {
                    Text("Today")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                }
            } else {
                Text("Today")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var periodsListView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.periodsForSelectedDate) { period in
                Button(action: {
                    onPeriodTapped?(period)
                }) {
                    WeeklyPeriodCardView(period: period, isSelectedDateToday: viewModel.isSelectedDateToday)
                }
                .buttonStyle(NoTapAnimationStyle()) // Prevents the cell from fading out when tapped
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Period UI States
enum WeeklyPeriodViewState {
    case normal
    case current
    case changed
}

// MARK: - Period Card View
struct WeeklyPeriodCardView: View {
    let period: TimetablePeriodEntry
    let isSelectedDateToday: Bool
    
    var state: WeeklyPeriodViewState {
        if period.hasSubstitution == true { return .changed }
        if isCurrent { return .current }
        return .normal
    }
    
    var isCurrent: Bool {
        guard isSelectedDateToday else { return false }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let currentTime = timeFormatter.string(from: Date())
        
        guard let start = period.period?.startTime, let end = period.period?.endTime else { return false }
        return currentTime >= start && currentTime <= end
    }
    
    // Mapping API responses to the UI texts
    var periodNumberString: String {
        return period.period?.periodLabel ?? "Period"
    }
    
    var timeString: String {
        let s = String(period.period?.startTime?.prefix(5) ?? "")
        let e = String(period.period?.endTime?.prefix(5) ?? "")
        if s.isEmpty || e.isEmpty { return "Time N/A" }
        return "\(s)–\(e)"
    }
    
    var subjectString: String {
        return period.subject?.name?.capitalized ?? "Subject N/A"
    }
    
    var teacherString: String {
        if state == .changed, let subName = period.teacher?.name, let original = period.substitution?.originalTeacher?.name ?? period.regularTeacher?.name {
            return "\(subName) · Substitute for \(original)"
        }
        return period.teacher?.name ?? period.regularTeacher?.name ?? "Teacher N/A"
    }
    
    var roomString: String {
        if let notes = period.notes, !notes.isEmpty, notes != "Regular class" {
            return notes
        }
        return "Classroom"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Status Indicator Line
            RoundedRectangle(cornerRadius: 4)
                .fill(indicatorColor)
                .frame(width: 4)
                .padding(.vertical, 16)
                .padding(.leading, 12)
            
            HStack(alignment: .top) {
                // Period Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(periodNumberString)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(indicatorColor)
                    
                    Text(timeString)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(width: 85, alignment: .leading)
                
                // Subject Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(subjectString)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if state == .current {
                            badgeView(text: "Current", bgColor: .white, fgColor: indicatorColor, bdColor: indicatorColor)
                        } else if state == .changed {
                            badgeView(text: "Changed", bgColor: Color.orange.opacity(0.2), fgColor: .orange, bdColor: .clear)
                        }
                    }
                    
                    Text(teacherString)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 10))
                        Text(roomString)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 14, weight: .bold))
                    .padding(.top, 4)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }
    
    // Dynamic Colors based on State
    private var indicatorColor: Color {
        switch state {
        case .normal: return Color(red: 11/255, green: 86/255, blue: 154/255).opacity(0.6)
        case .current: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .changed: return Color.orange
        }
    }
    
    private var cardBackgroundColor: Color {
        switch state {
        case .current: return Color(red: 11/255, green: 86/255, blue: 154/255).opacity(0.05)
        case .changed: return Color.orange.opacity(0.08)
        default: return Color.white
        }
    }
    
    private var cardBorderColor: Color {
        switch state {
        case .current: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .changed: return Color.orange.opacity(0.5)
        default: return Color.gray.opacity(0.2)
        }
    }
    
    private func badgeView(text: String, bgColor: Color, fgColor: Color, bdColor: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(fgColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(bgColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(bdColor, lineWidth: bdColor == .clear ? 0 : 1)
            )
    }
}

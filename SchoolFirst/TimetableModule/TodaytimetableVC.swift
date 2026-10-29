//
//  TodaytimetableVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI
import Combine

// MARK: - API Extension
// Assuming these are in your API struct, they are left here for reference or should be in your API constants file


// MARK: - View Model
class TodayTimetableViewModel: ObservableObject {
    @Published var terms: [TimetableTermItem] = []
    @Published var dailyPeriods: [TimetablePeriodEntry] = []
    @Published var substitutionCount: Int = 0
    @Published var substitutionMessage: String = ""
    @Published var classSectionString: String = ""
    
    @Published var currentDate: Date = Date()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Fetch Terms
    func fetchTerms() {
        let schoolID = UserManager.shared.resolvedSchoolID
        guard !schoolID.isEmpty else {
            print("❌ No School ID found")
            return
        }
        
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
                        self?.fetchDailyTimetable()
                    } else {
                        self?.isLoading = false
                        self?.errorMessage = response.description
                    }
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error fetching terms: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Fetch Daily Timetable
    func fetchDailyTimetable() {
        let schoolID = UserManager.shared.resolvedSchoolID
        let studentID = UserManager.shared.resolvedStudentID
        
        guard !schoolID.isEmpty, !studentID.isEmpty else { return }
        
        isLoading = true
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: currentDate)
        
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
                        self?.processTimetableData(data)
                    } else {
                        self?.dailyPeriods = []
                        self?.substitutionCount = 0
                    }
                case .failure(let error):
                    print("❌ Error fetching daily timetable: \(error.localizedDescription)")
                    self?.dailyPeriods = []
                    self?.substitutionCount = 0
                }
            }
        }
    }
    
    // MARK: - Process Timetable Data
    private func processTimetableData(_ data: StudentTimetableData) {
        self.substitutionCount = data.substitutionCount ?? 0
        
        // Class / Section from API
        let grade = data.student?.grade?.name ?? ""
        let section = data.student?.section?.name ?? ""
        if !grade.isEmpty && !section.isEmpty {
            self.classSectionString = "\(grade) · Section \(section)"
        } else if !grade.isEmpty {
            self.classSectionString = grade
        } else {
            self.classSectionString = "Class / Section"
        }
        
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        var periods: [TimetablePeriodEntry] = []
        
        switch weekday {
        case 1: periods = data.schedule?.sunday ?? []
        case 2: periods = data.schedule?.monday ?? []
        case 3: periods = data.schedule?.tuesday ?? []
        case 4: periods = data.schedule?.wednesday ?? []
        case 5: periods = data.schedule?.thursday ?? []
        case 6: periods = data.schedule?.friday ?? []
        case 7: periods = data.schedule?.saturday ?? []
        default: break
        }
        
        self.dailyPeriods = periods.sorted { ($0.period?.periodNumber ?? 0) < ($1.period?.periodNumber ?? 0) }
        
        if let firstSub = self.dailyPeriods.first(where: { $0.hasSubstitution == true }) {
            let subj = firstSub.subject?.name?.capitalized ?? "A subject"
            let pNum = firstSub.period?.periodNumber ?? 0
            self.substitutionMessage = "\(subj) has a teacher substitution in Period \(pNum)."
        } else {
            self.substitutionMessage = "Schedule changes available."
        }
    }
    
    // MARK: - Categorize Periods (Now, Next, Later)
    var categorizedPeriods: (now: TimetablePeriodEntry?, next: TimetablePeriodEntry?, later: [TimetablePeriodEntry]) {
        let isToday = Calendar.current.isDateInToday(currentDate)
        
        if !isToday {
            return (nil, nil, dailyPeriods)
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let currentTime = timeFormatter.string(from: Date())
        
        var nowP: TimetablePeriodEntry?
        var nextP: TimetablePeriodEntry?
        var laterP: [TimetablePeriodEntry] = []
        
        for period in dailyPeriods {
            guard let start = period.period?.startTime, let end = period.period?.endTime else {
                laterP.append(period)
                continue
            }
            
            if currentTime >= start && currentTime <= end {
                nowP = period
            } else if currentTime < start && nowP == nil && nextP == nil {
                nextP = period
            } else if currentTime < start && nowP != nil && nextP == nil {
                nextP = period
            } else if currentTime < start {
                laterP.append(period)
            } else {
                laterP.append(period)
            }
        }
        
        return (nowP, nextP, laterP)
    }
    
    // MARK: - Date Navigation
    func nextDay() {
        if let next = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            currentDate = next
            fetchDailyTimetable()
        }
    }
    
    func previousDay() {
        if let prev = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            currentDate = prev
            fetchDailyTimetable()
        }
    }
    
    // MARK: - Formatted Strings
    var headerDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    var pagerDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        return formatter.string(from: currentDate)
    }
    
    var pagerRelativeString: String {
        if Calendar.current.isDateInToday(currentDate) { return "Today" }
        if Calendar.current.isDateInYesterday(currentDate) { return "Yesterday" }
        if Calendar.current.isDateInTomorrow(currentDate) { return "Tomorrow" }
        return ""
    }
    
    // MARK: - Term Logic
    private var activeTerm: TimetableTermItem? {
        let active = terms.first { term in
            guard let start = parseDate(term.startDate), let end = parseDate(term.endDate) else { return false }
            return currentDate >= start && currentDate <= end
        }
        return active ?? terms.first
    }
    
    var academicYearText: String {
        guard let ay = activeTerm?.academicYear?.name else { return "AY N/A" }
        let parts = ay.components(separatedBy: "-")
        if parts.count == 2, let last = parts.last, last.count == 4 {
            let shortYear = String(last.suffix(2))
            return "AY \(parts[0])-\(shortYear)"
        }
        return "AY \(ay)"
    }
    
    var termText: String {
        guard let term = activeTerm else { return "Term N/A" }
        let name = term.name ?? "Term"
        let start = formatMonth(term.startDate)
        let end = formatMonth(term.endDate)
        
        if !start.isEmpty && !end.isEmpty {
            return "\(name) - \(start)-\(end)"
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
class TodaytimetableVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        var swiftUIView = TodayTimetableView()
        
        swiftUIView.onWeekViewTapped = { [weak self] in
            let weeklyVC = WeaklytimetableVC()
            self?.navigationController?.pushViewController(weeklyVC, animated: true)
        }
        
        // Navigation to PerioddetailsVC with API data
        swiftUIView.onPeriodTapped = { [weak self] period, date, classSection in
            let detailsVC = PerioddetailsVC()
            detailsVC.period = period
            detailsVC.selectedDate = date
            detailsVC.classSectionString = classSection
            self?.navigationController?.pushViewController(detailsVC, animated: true)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Custom Button Style (Prevents Fading/Flashing on Tap)
struct TodayNoTapAnimationStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

// MARK: - Local Period State
enum LocalPeriodState {
    case now
    case next
    case later
}

// MARK: - SwiftUI View & Components
struct TodayTimetableView: View {
    @StateObject private var viewModel = TodayTimetableViewModel()
    var onWeekViewTapped: (() -> Void)? = nil
    var onPeriodTapped: ((TimetablePeriodEntry, Date, String) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            TimetableHeader(headerDateText: viewModel.headerDateString)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // Tags Row
                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12, weight: .bold))
                            Text(viewModel.academicYearText)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                        
                        Text(viewModel.termText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Date Pager
                    HStack {
                        Button(action: {
                            viewModel.previousDay()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                                .font(.system(size: 16, weight: .bold))
                                .padding(10)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text(viewModel.pagerDateString)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            
                            if !viewModel.pagerRelativeString.isEmpty {
                                Text(viewModel.pagerRelativeString)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.nextDay()
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                                .font(.system(size: 16, weight: .bold))
                                .padding(10)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal)
                    
                    // Alert Banner
                    if viewModel.substitutionCount > 0 {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "bell")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(viewModel.substitutionCount) schedule change\(viewModel.substitutionCount > 1 ? "s" : "") today")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.primary)
                                Text(viewModel.substitutionMessage)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.orange)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding()
                        .background(Color(red: 1.0, green: 0.96, blue: 0.89))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal)
                    }
                    
                    if viewModel.isLoading && viewModel.dailyPeriods.isEmpty {
                        ProgressView("Loading Timetable...")
                            .padding(.top, 40)
                    } else if viewModel.dailyPeriods.isEmpty {
                        Text("No classes scheduled for this day.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    } else {
                        let categories = viewModel.categorizedPeriods
                        
                        // Now & Next Section
                        if categories.now != nil || categories.next != nil {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Now & next")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        onWeekViewTapped?()
                                    }) {
                                        Text("Week view")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                                    }
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    if let nowP = categories.now {
                                        Button(action: {
                                            onPeriodTapped?(nowP, viewModel.currentDate, viewModel.classSectionString)
                                        }) {
                                            APIPeriodCardView(entry: nowP, state: .now)
                                        }
                                        .buttonStyle(TodayNoTapAnimationStyle())
                                    }
                                    if let nextP = categories.next {
                                        Button(action: {
                                            onPeriodTapped?(nextP, viewModel.currentDate, viewModel.classSectionString)
                                        }) {
                                            APIPeriodCardView(entry: nextP, state: .next)
                                        }
                                        .buttonStyle(TodayNoTapAnimationStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 8)
                        }
                        
                        // Later / Schedule Section
                        if !categories.later.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(Calendar.current.isDateInToday(viewModel.currentDate) ? "Later today" : "Schedule")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if categories.now == nil && categories.next == nil {
                                        Button(action: {
                                            onWeekViewTapped?()
                                        }) {
                                            Text("Week view")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                                        }
                                    } else {
                                        Text("\(categories.later.count) periods remaining")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                                    }
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    ForEach(categories.later) { period in
                                        Button(action: {
                                            onPeriodTapped?(period, viewModel.currentDate, viewModel.classSectionString)
                                        }) {
                                            APIPeriodCardView(entry: period, state: .later)
                                        }
                                        .buttonStyle(TodayNoTapAnimationStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 8)
                        }
                    }
                    
                    Spacer().frame(height: 30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchTerms()
        }
    }
}

// MARK: - Header Component
struct TimetableHeader: View {
    @Environment(\.presentationMode) var presentationMode
    var headerDateText: String
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Timetable")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(headerDateText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.leading, 12)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(Color(red: 11/255, green: 86/255, blue: 154/255).ignoresSafeArea(edges: .top))
    }
}

// MARK: - API Period Card View
struct APIPeriodCardView: View {
    let entry: TimetablePeriodEntry
    let state: LocalPeriodState
    
    var bgColor: Color {
        switch state {
        case .now: return Color.blue.opacity(0.05)
        case .next: return Color(red: 1.0, green: 0.96, blue: 0.89)
        case .later: return Color.white
        }
    }
    
    var borderColor: Color {
        switch state {
        case .now: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .next: return Color.orange.opacity(0.5)
        case .later: return Color.gray.opacity(0.2)
        }
    }
    
    var leftBarColor: Color {
        switch state {
        case .now: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .next: return .orange
        case .later: return Color(red: 11/255, green: 86/255, blue: 154/255)
        }
    }
    
    var periodTextColor: Color {
        switch state {
        case .now: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .next: return .orange
        case .later: return Color(red: 11/255, green: 86/255, blue: 154/255)
        }
    }
    
    var isChanged: Bool {
        return entry.hasSubstitution == true
    }
    
    var timeRangeString: String {
        let s = String(entry.period?.startTime?.prefix(5) ?? "")
        let e = String(entry.period?.endTime?.prefix(5) ?? "")
        if s.isEmpty || e.isEmpty { return "Time N/A" }
        return "\(s)-\(e)"
    }
    
    var teacherString: String {
        if isChanged, let subName = entry.teacher?.name, let original = entry.substitution?.originalTeacher?.name ?? entry.regularTeacher?.name {
            return "\(subName) - Substitute for \(original)"
        }
        return entry.teacher?.name ?? entry.regularTeacher?.name ?? "Teacher N/A"
    }
    
    var roomString: String {
        if let notes = entry.notes, !notes.isEmpty, notes != "Regular class" {
            return notes
        }
        return "Classroom"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            
            RoundedRectangle(cornerRadius: 3)
                .fill(leftBarColor)
                .frame(width: 4)
                .padding(.vertical, 12)
                .padding(.leading, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                let pNum = entry.period?.periodNumber ?? 0
                
                if state == .now {
                    Text("Period \(pNum) • ")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(periodTextColor) +
                    Text("Now")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(periodTextColor)
                } else if state == .next {
                    Text("Period \(pNum) • ")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(periodTextColor) +
                    Text("Next")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(periodTextColor)
                } else {
                    Text("Period \(pNum)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(periodTextColor)
                }
                
                Text(timeRangeString)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(width: 90, alignment: .leading)
            .padding(.vertical, 16)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1)
                .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(entry.subject?.name?.capitalized ?? "Subject")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if isChanged {
                        Text("Changed")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                Text(teacherString)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                    Text(roomString)
                        .font(.system(size: 12, weight: .regular))
                }
                .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
                .font(.system(size: 14, weight: .bold))
                .padding(.trailing, 16)
        }
        .background(bgColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

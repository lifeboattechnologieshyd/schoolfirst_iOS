//
//  ExamscheduleVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 27/10/26.
//

import UIKit
import SwiftUI
import Combine

// MARK: - ViewModel (drives SwiftUI refresh when API responds)
final class ExamScheduleViewModel: ObservableObject {
    @Published var examDetail: ExamDetail?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
}

class ExamscheduleVC: UIViewController {
    
    // ✅ Exam id received from Home screen (tapped exam)
    var examID: String?
    
    // ✅ Shared state between UIKit <-> SwiftUI
    private let viewModel = ExamScheduleViewModel()
    private var hostingController: UIHostingController<ExamScheduleView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the default navigation bar since we have a custom blue header in SwiftUI
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupSwiftUIView()
        fetchExamDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Embed SwiftUI View
    private func setupSwiftUIView() {
        
        // Create the SwiftUI view and pass a closure to handle the back button
        let examScheduleView = ExamScheduleView(viewModel: viewModel) { [weak self] in
            guard let self = self else { return }
            // ✅ Pop navigation on back (dismiss fallback if presented modally)
            if let nav = self.navigationController, nav.viewControllers.count > 1 {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        // Embed SwiftUI View into this View Controller using UIHostingController
        let hosting = UIHostingController(rootView: examScheduleView)
        hostingController = hosting
        
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
        
        // Setup Constraints
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - API Integration (GET_EXAM_DETAIL)
    private func fetchExamDetail() {
        
        let studentID = UserManager.shared.resolvedStudentID
        let schoolID  = UserManager.shared.resolvedSchoolID
        let examId    = (examID ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("📘 Exam Detail → examination_id: \(examId) | student_id: \(studentID) | school_id: \(schoolID)")
        
        guard !examId.isEmpty, !studentID.isEmpty, !schoolID.isEmpty else {
            viewModel.isLoading = false
            viewModel.errorMessage = "Unable to load exam details."
            return
        }
        
        viewModel.isLoading = true
        
        // ✅ FIXED: Server expects "examination_id" (NOT "exam_id")
        let parameters: [String: Any] = [
            "student_id": studentID,
            "examination_id": examId
        ]
        
        // ✅ school id in header
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_EXAM_DETAIL,
            method: .GET,
            requiresAuth: true,                 // ✅ authentication required
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<ExamDetail>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.viewModel.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.success, let detail = response.data {
                        self.viewModel.examDetail = detail
                        self.viewModel.errorMessage = nil
                        print("✅ Exam detail loaded: \(detail.name ?? "-") | schedules: \(detail.schedules?.count ?? 0)")
                    } else {
                        self.viewModel.errorMessage = response.description.isEmpty
                            ? "No exam details found."
                            : response.description
                    }
                    
                case .failure(let error):
                    self.viewModel.errorMessage = error.localizedDescription
                    print("❌ Failed to fetch exam detail: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - SwiftUI Views

struct ExamScheduleView: View {
    
    @ObservedObject var viewModel: ExamScheduleViewModel
    var onBackTapped: () -> Void
    
    @State private var selectedMonth: String = ""
    
    // MARK: - Derived data from API
    
    private var detail: ExamDetail? { viewModel.examDetail }
    
    private var papers: [ExamPaper] {
        ExamPaper.map(from: detail)
    }
    
    /// Unique months (in order) present in the schedules
    private var months: [String] {
        var seen = Set<String>()
        var result: [String] = []
        for m in papers.map({ $0.monthName }) where !m.isEmpty {
            if seen.insert(m).inserted { result.append(m) }
        }
        return result
    }
    
    private var activeMonth: String {
        if !selectedMonth.isEmpty, months.contains(selectedMonth) { return selectedMonth }
        return months.first ?? ""
    }
    
    private var filteredPapers: [ExamPaper] {
        guard !activeMonth.isEmpty else { return papers }
        let filtered = papers.filter { $0.monthName == activeMonth }
        return filtered.isEmpty ? papers : filtered
    }
    
    /// e.g. "Sep 21-23, 2026"
    private var dateRangeTitle: String {
        guard let s = detail?.startDate, let e = detail?.endDate else {
            return detail?.name ?? "Exam Schedule"
        }
        return ExamDateHelper.rangeTitle(start: s, end: e)
    }
    
    private var titleSubtitle: String {
        let count = papers.count
        guard count > 0 else { return "All times are shown in school local time." }
        return "\(count) paper\(count == 1 ? "" : "s") scheduled. All times are shown in school local time."
    }
    
    /// First paper start time, e.g. "9:30"
    private var usualStart: String {
        guard let raw = detail?.schedules?.compactMap({ $0.startTime }).first else { return "--" }
        return ExamDateHelper.shortTime(raw)
    }
    
    /// 30 minutes before usual start, e.g. "9:00"
    private var reportBy: String {
        guard let raw = detail?.schedules?.compactMap({ $0.startTime }).first else { return "--" }
        return ExamDateHelper.shortTime(raw, minusMinutes: 30)
    }
    
    /// e.g. "SEPTEMBER 2026"
    private var sectionHeaderTitle: String {
        let year = filteredPapers.first?.year ?? ExamDateHelper.year(from: detail?.startDate)
        guard !activeMonth.isEmpty else { return year }
        return "\(activeMonth) \(year)".uppercased()
    }
    
    private var statusText: String {
        guard let status = detail?.status, !status.isEmpty else { return "Upcoming" }
        return status.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    private var summarySubtitle: String {
        let type = detail?.examinationType?.name ?? "Examination"
        let year = detail?.academicYear?.name ?? "-"
        return "\(type) • Academic Year \(year)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Blue Header
            CustomHeaderView(title: "Exam Schedule",
                             subtitle: "School moments, all in one place",
                             onBack: onBackTapped)
            
            if viewModel.isLoading {
                // Loading State
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading exam schedule...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                        .padding(.top, 12)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.98, green: 0.99, blue: 1.0))
                
            } else if detail == nil {
                // Error / Empty State
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                    Text(viewModel.errorMessage ?? "No exam details available.")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                        .padding(.horizontal, 32)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.98, green: 0.99, blue: 1.0))
                
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // 2. Title Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dateRangeTitle)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 0.07, green: 0.09, blue: 0.15))
                            
                            Text(titleSubtitle)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                                .lineSpacing(4)
                        }
                        .padding(.top, 24)
                        
                        // 3. Summary Card
                        ExamSummaryCard(
                            examName: detail?.name ?? "Examination",
                            subtitle: summarySubtitle,
                            statusText: statusText,
                            subjects: "\(papers.count)",
                            usualStart: usualStart,
                            reportBy: reportBy
                        )
                        
                        // 4. Custom Month Picker (only when months exist)
                        if !months.isEmpty {
                            CustomMonthPicker(
                                months: months,
                                selectedMonth: Binding(
                                    get: { activeMonth },
                                    set: { selectedMonth = $0 }
                                )
                            )
                        }
                        
                        // 5. Section Header
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sectionHeaderTitle)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                                    .textCase(.uppercase)
                                
                                Text("Examination papers")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(red: 0.07, green: 0.09, blue: 0.15))
                            }
                            Spacer()
                            
                            Button(action: {
                                // Download PDF Action
                            }) {
                                Text("Download PDF")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.85))
                            }
                        }
                        
                        // 6. Exam Papers List (API data)
                        if filteredPapers.isEmpty {
                            Text("No papers scheduled yet.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 24)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredPapers) { paper in
                                    ExamPaperCard(paper: paper)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .background(Color(red: 0.98, green: 0.99, blue: 1.0)) // Off-white background
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Subcomponents

struct CustomHeaderView: View {
    var title: String
    var subtitle: String
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: safeAreaTop()) // Safe Area padding for Notch/Dynamic Island
            
            HStack(alignment: .center, spacing: 16) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: {
                    // Bell action
                }) {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(red: 0.11, green: 0.31, blue: 0.58)) // Primary Blue
    }
    
    private func safeAreaTop() -> CGFloat {
        guard let window = UIApplication.shared.windows.first else { return 44 }
        return window.safeAreaInsets.top
    }
}

struct ExamSummaryCard: View {
    // ✅ Driven by API data
    var examName: String
    var subtitle: String
    var statusText: String
    var subjects: String
    var usualStart: String
    var reportBy: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(examName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.07, green: 0.09, blue: 0.15))
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                }
                Spacer()
                
                // Status Badge
                Text(statusText)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.90, green: 0.96, blue: 1.0))
                    .cornerRadius(8)
            }
            
            HStack(alignment: .center) {
                StatItem(value: subjects, label: "Subjects")
                Spacer()
                StatItem(value: usualStart, label: "Usual start")
                Spacer()
                StatItem(value: reportBy, label: "Report by")
                Spacer() // Keeps alignment left-weighted as per Figma
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.92, green: 0.94, blue: 0.96), lineWidth: 1)
        )
    }
}

struct StatItem: View {
    var value: String
    var label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.07, green: 0.09, blue: 0.15))
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
        }
    }
}

struct CustomMonthPicker: View {
    let months: [String]
    @Binding var selectedMonth: String
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(months, id: \.self) { month in
                Text(month)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(selectedMonth == month ? Color(red: 0.15, green: 0.45, blue: 0.85) : Color(red: 0.42, green: 0.45, blue: 0.50))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedMonth == month ? Color.white : Color.clear)
                    .cornerRadius(8)
                    .shadow(color: selectedMonth == month ? Color.black.opacity(0.05) : Color.clear, radius: 4, x: 0, y: 2)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMonth = month
                        }
                    }
            }
        }
        .padding(4)
        .background(Color(red: 0.95, green: 0.96, blue: 0.97)) // Gray container background
        .cornerRadius(10)
    }
}

struct ExamPaperCard: View {
    let paper: ExamPaper
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                
                // Date Box
                VStack(spacing: 2) {
                    Text(paper.day)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.85)) // Blue day
                    Text(paper.date)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.07, green: 0.09, blue: 0.15))
                }
                .frame(width: 50, height: 56)
                .background(Color(red: 0.95, green: 0.97, blue: 0.99))
                .cornerRadius(10)
                
                // Subject Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(paper.subject)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.07, green: 0.09, blue: 0.15))
                        .lineLimit(2)
                    
                    Text(paper.subtitleText)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                }
                
                Spacer()
                
                // Status Badge
                Text(paper.badgeText)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(paper.badgeState.textColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(paper.badgeState.backgroundColor)
                    .cornerRadius(8)
            }
            .padding(16)
            
            Divider()
                .background(Color(red: 0.92, green: 0.94, blue: 0.96))
                .padding(.horizontal, 16)
            
            // Bottom Details
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                    Text(paper.time)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.07, green: 0.09, blue: 0.15))
                }
                
                Spacer()
                
                Text(paper.duration)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                
                Spacer()
                
                Text(paper.room)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.92, green: 0.94, blue: 0.96), lineWidth: 1)
        )
    }
}

// MARK: - UI Model (built from API response)

struct ExamPaper: Identifiable {
    let id = UUID()
    let day: String
    let date: String
    let subject: String
    let subtitleText: String
    let badgeText: String
    let badgeState: BadgeState
    let time: String
    let duration: String
    let room: String
    let monthName: String
    let year: String
    
    enum BadgeState {
        case scheduled, ready, draft
        
        var backgroundColor: Color {
            switch self {
            case .scheduled: return Color(red: 0.88, green: 0.97, blue: 0.92) // Light Green
            case .ready:     return Color(red: 0.90, green: 0.96, blue: 1.0)  // Light Blue
            case .draft:     return Color(red: 1.0,  green: 0.95, blue: 0.88) // Light Orange
            }
        }
        
        var textColor: Color {
            switch self {
            case .scheduled: return Color(red: 0.13, green: 0.55, blue: 0.35) // Dark Green
            case .ready:     return Color(red: 0.15, green: 0.45, blue: 0.85) // Dark Blue
            case .draft:     return Color(red: 0.85, green: 0.45, blue: 0.15) // Dark Orange
            }
        }
    }
    
    // ✅ Map ExamDetail (API) → [ExamPaper]
    static func map(from detail: ExamDetail?) -> [ExamPaper] {
        guard let schedules = detail?.schedules, !schedules.isEmpty else { return [] }
        
        let status = (detail?.status ?? "SCHEDULED").uppercased()
        let badgeState: BadgeState
        let badgeText: String
        
        switch status {
        case "DRAFT":
            badgeState = .draft;     badgeText = "Draft"
        case "CANCELLED", "CANCELED":
            badgeState = .draft;     badgeText = "Cancelled"
        case "ONGOING", "IN_PROGRESS":
            badgeState = .ready;     badgeText = "Ongoing"
        case "COMPLETED", "RESULT_PUBLISHED", "RESULTS_PUBLISHED":
            badgeState = .ready;     badgeText = "Completed"
        default:
            badgeState = .scheduled; badgeText = "Scheduled"
        }
        
        return schedules.map { schedule in
            let d = ExamDateHelper.components(from: schedule.examDate)
            
            let timeText = ExamDateHelper.displayTime(schedule.startTime)
            let durationText = ExamDateHelper.duration(start: schedule.startTime, end: schedule.endTime)
            
            let roomText: String = {
                guard let r = schedule.roomNumber?.trimmingCharacters(in: .whitespaces), !r.isEmpty else { return "--" }
                return "Room \(r)"
            }()
            
            // API has no subject code → show max marks (as per available data)
            let subtitle: String = {
                if let marks = schedule.maximumMarks, !marks.isEmpty {
                    return "Max marks \(ExamDateHelper.trimDecimals(marks))"
                }
                return schedule.grade?.name ?? "Subject details"
            }()
            
            return ExamPaper(
                day: d.day,
                date: d.dayNumber,
                subject: schedule.subject?.name?.capitalized ?? "Subject",
                subtitleText: subtitle,
                badgeText: badgeText,
                badgeState: badgeState,
                time: timeText,
                duration: durationText,
                room: roomText,
                monthName: d.month,
                year: d.year
            )
        }
    }
}

// MARK: - Date / Time Helpers

enum ExamDateHelper {
    
    private static func makeFormatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = format
        return f
    }
    
    private static let apiDate  = makeFormatter("yyyy-MM-dd")
    private static let apiTime  = makeFormatter("HH:mm:ss")
    private static let outDay   = makeFormatter("EEE")
    private static let outDayNo = makeFormatter("d")
    private static let outMonth = makeFormatter("MMMM")
    private static let outMonS  = makeFormatter("MMM")
    private static let outYear  = makeFormatter("yyyy")
    private static let outTime  = makeFormatter("hh:mm a")
    private static let outShort = makeFormatter("h:mm")
    
    static func components(from dateString: String?) -> (day: String, dayNumber: String, month: String, year: String) {
        guard let raw = dateString, let date = apiDate.date(from: raw) else {
            return ("--", "--", "", "")
        }
        return (outDay.string(from: date).uppercased(),
                outDayNo.string(from: date),
                outMonth.string(from: date),
                outYear.string(from: date))
    }
    
    static func year(from dateString: String?) -> String {
        guard let raw = dateString, let date = apiDate.date(from: raw) else { return "" }
        return outYear.string(from: date)
    }
    
    /// "09:30 AM"
    static func displayTime(_ timeString: String?) -> String {
        guard let raw = timeString, let t = apiTime.date(from: raw) else { return "--" }
        return outTime.string(from: t)
    }
    
    /// "9:30" (optionally minus N minutes)
    static func shortTime(_ timeString: String?, minusMinutes: Int = 0) -> String {
        guard let raw = timeString, let t = apiTime.date(from: raw) else { return "--" }
        return outShort.string(from: t.addingTimeInterval(TimeInterval(-minusMinutes * 60)))
    }
    
    /// "3 Hours" / "2 Hours 30 Mins"
    static func duration(start: String?, end: String?) -> String {
        guard let s = start, let e = end,
              let sd = apiTime.date(from: s), let ed = apiTime.date(from: e) else { return "--" }
        let mins = Int(ed.timeIntervalSince(sd) / 60)
        guard mins > 0 else { return "--" }
        let h = mins / 60, m = mins % 60
        if h == 0 { return "\(m) Mins" }
        if m == 0 { return "\(h) Hour\(h == 1 ? "" : "s")" }
        return "\(h) Hour\(h == 1 ? "" : "s") \(m) Mins"
    }
    
    /// "Sep 21-23, 2026"  |  "Aug 28 - Sep 02, 2026"
    static func rangeTitle(start: String, end: String) -> String {
        guard let s = apiDate.date(from: start), let e = apiDate.date(from: end) else { return "" }
        let sMonth = outMonS.string(from: s)
        let eMonth = outMonS.string(from: e)
        let sDay   = outDayNo.string(from: s)
        let eDay   = outDayNo.string(from: e)
        let year   = outYear.string(from: e)
        
        if start == end { return "\(sMonth) \(sDay), \(year)" }
        if sMonth == eMonth { return "\(sMonth) \(sDay)-\(eDay), \(year)" }
        return "\(sMonth) \(sDay) - \(eMonth) \(eDay), \(year)"
    }
    
    /// "100.00" → "100"
    static func trimDecimals(_ value: String) -> String {
        if let d = Double(value) {
            return d == d.rounded() ? String(Int(d)) : String(format: "%.2f", d)
        }
        return value
    }
}

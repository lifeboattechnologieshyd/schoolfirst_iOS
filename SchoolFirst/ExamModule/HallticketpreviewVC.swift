//
//  HallticketpreviewVC.swift
//  SchoolFirst
//

import UIKit
import SwiftUI
import Combine

// MARK: - API Models
struct HTPreviewAPIResponse: Codable {
    let success: Bool?
    let description: String?
    let data: HTPreviewData?
}

struct HTPreviewData: Codable {
    let hallTicket: HTPreviewInfo?
    let student: HTPreviewStudent?
    let examination: HTPreviewExamination?
    let schedules: [HTPreviewSchedule]?
    
    enum CodingKeys: String, CodingKey {
        case hallTicket = "hall_ticket"
        case student
        case examination
        case schedules
    }
}

struct HTPreviewInfo: Codable {
    let id: String?
    let hallTicketNumber: String?
    let school: HTPreviewSchool?
    let status: String?
    let generatedAt: String?
    let publishedAt: String?
    let pdf: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case hallTicketNumber = "hall_ticket_number"
        case school
        case status
        case generatedAt = "generated_at"
        case publishedAt = "published_at"
        case pdf
    }
}

struct HTPreviewSchool: Codable {
    let id: String?
    let name: String?
    let address: String?
    let board: String?
}

struct HTPreviewStudent: Codable {
    let id: String?
    let name: String?
    let admissionNumber: String?
    let grade: HTPreviewNameId?
    let section: HTPreviewNameId?
    let branch: HTPreviewNameId?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case admissionNumber = "admission_number"
        case grade
        case section
        case branch
    }
}

struct HTPreviewNameId: Codable {
    let id: String?
    let name: String?
}

struct HTPreviewExamination: Codable {
    let id: String?
    let name: String?
    let examinationType: HTPreviewNameId?
    let academicYear: HTPreviewNameId?
    let startDate: String?
    let endDate: String?
    let resultDate: String?
    let instructions: String?
    let reportingDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case examinationType = "examination_type"
        case academicYear = "academic_year"
        case startDate = "start_date"
        case endDate = "end_date"
        case resultDate = "result_date"
        case instructions
        case reportingDate = "reporting_date"
    }
}

struct HTPreviewSchedule: Codable, Identifiable {
    let id: String?
    let subject: HTPreviewNameId?
    let examDate: String?
    let startTime: String?
    let endTime: String?
    let roomNumber: String?
    let maximumMarks: String?
    let passingMarks: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case subject
        case examDate = "exam_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case roomNumber = "room_number"
        case maximumMarks = "maximum_marks"
        case passingMarks = "passing_marks"
    }
}

// MARK: - View Model
class HTPreviewViewModel: ObservableObject {
    @Published var hallTicketData: HTPreviewData?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var isNotAvailable: Bool = false
    @Published var isDownloading: Bool = false
    
    private var pendingExamIDs: [String] = []
    
    func fetchHallTicket(examIDs: [String]) {
        let studentID = UserManager.shared.resolvedStudentID
        let schoolID = UserManager.shared.resolvedSchoolID
        
        var seen = Set<String>()
        let ids = examIDs
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && seen.insert($0).inserted }
        
        guard !ids.isEmpty, !studentID.isEmpty, !schoolID.isEmpty else {
            self.isLoading = false
            self.errorMessage = "Missing required details to fetch Hall Ticket."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        self.isNotAvailable = false
        self.pendingExamIDs = ids
        
        tryNextExam(studentID: studentID, schoolID: schoolID)
    }
    
    private func tryNextExam(studentID: String, schoolID: String) {
        guard !pendingExamIDs.isEmpty else {
            self.isLoading = false
            self.isNotAvailable = true
            self.errorMessage = "Your hall ticket has not been published yet."
            return
        }
        
        let examID = pendingExamIDs.removeFirst()
        
        let parameters: [String: Any] = [
            "student_id": studentID,
            "examination_id": examID
        ]
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        // Make sure API.GET_HALL_TICKET exists in your constants
        NetworkManager.shared.request(
            urlString: API.GET_HALL_TICKET,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers,
            showErrorAlert: false
        ) { [weak self] (result: Result<APIResponse<HTPreviewData>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data, data.hallTicket != nil {
                        self.isLoading = false
                        self.hallTicketData = data
                    } else {
                        self.tryNextExam(studentID: studentID, schoolID: schoolID)
                    }
                case .failure(_):
                    self.tryNextExam(studentID: studentID, schoolID: schoolID)
                }
            }
        }
    }
}

// MARK: - UIViewController Wrapper
class HallticketpreviewVC: UIViewController {
    var examID: String = ""
    var candidateExamIDs: [String] = []
    
    private let viewModel = HTPreviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupSwiftUI()
        
        let allIDs = [examID] + candidateExamIDs
        viewModel.fetchHallTicket(examIDs: allIDs)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupSwiftUI() {
        let swiftUIView = HTPreviewMainView(viewModel: viewModel, onBack: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })

        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}

// MARK: - SwiftUI View
struct HTPreviewMainView: View {
    @ObservedObject var viewModel: HTPreviewViewModel
    var onBack: () -> Void
    
    // Theme Colors
    private let navyColor = Color(red: 0.11, green: 0.31, blue: 0.58)
    private let darkNavyButton = Color(red: 0.11, green: 0.18, blue: 0.35)
    private let screenBgColor = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let textDark = Color(red: 0.08, green: 0.11, blue: 0.19)
    private let textGray = Color(red: 0.45, green: 0.48, blue: 0.54)
    private let lightBlueBg = Color(red: 0.94, green: 0.97, blue: 1.0)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if viewModel.isLoading {
                Spacer()
                ProgressView("Fetching Hall Ticket...")
                    .progressViewStyle(CircularProgressViewStyle(tint: navyColor))
                Spacer()
            } else if viewModel.isNotAvailable {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(navyColor)
                    Text("Hall ticket not available")
                        .font(.headline)
                    Text(viewModel.errorMessage ?? "Your hall ticket has not been published yet.")
                        .font(.subheadline)
                        .foregroundColor(textGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            } else if let data = viewModel.hallTicketData {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        pageTitleSection(data: data)
                        documentCard(data: data)
                        downloadButton()
                        
                        let issuedDate = HTPreviewDateHelper.formatFullDate(data.hallTicket?.publishedAt ?? data.hallTicket?.generatedAt)
                        Text("Issued \(issuedDate) • Keep this document secure.")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(textGray)
                            .padding(.bottom, 24)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .background(screenBgColor.ignoresSafeArea())
    }
    
    // MARK: - Nav Header
    private var headerView: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Hall Ticket")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text("School moments, all in one place")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(navyColor.ignoresSafeArea(edges: .top))
    }
    
    // MARK: - Title Section
    private func pageTitleSection(data: HTPreviewData) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hall Ticket")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(textDark)
                
                Text(data.examination?.name ?? "Examination 2026")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(textGray)
            }
            Spacer()
            
            let status = (data.hallTicket?.status ?? "Ready").capitalized
            Text(status)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(navyColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(lightBlueBg)
                .cornerRadius(10)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - The Main Hall Ticket Document
    private func documentCard(data: HTPreviewData) -> some View {
        VStack(spacing: 24) {
            
            // 1. School Header
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(lightBlueBg)
                        .frame(width: 48, height: 48)
                    Image(systemName: "building.columns.fill")
                        .foregroundColor(navyColor)
                        .font(.system(size: 20))
                }
                .padding(.bottom, 4)
                
                Text(data.hallTicket?.school?.name ?? "School Name")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textDark)
                    .multilineTextAlignment(.center)
                
                let address = data.hallTicket?.school?.address ?? ""
                let board = data.hallTicket?.school?.board ?? ""
                let subtitle = board.isEmpty ? address : (address.isEmpty ? "Affiliated to \(board)" : "\(address) • Affiliated to \(board)")
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(textGray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // 2. Exam Title
            VStack(spacing: 6) {
                Text("HALL TICKET")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(textDark)
                    .tracking(1.5)
                
                Text(data.examination?.name ?? "Examination 2026")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(textGray)
                
                Text(data.hallTicket?.hallTicketNumber ?? "HT-PENDING")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(navyColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(lightBlueBg)
                    .cornerRadius(6)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // 3. Student Details Grid
            VStack(spacing: 16) {
                let sName = data.student?.name ?? "Student Name"
                let rNum = data.hallTicket?.hallTicketNumber ?? "--"
                
                let grade = data.student?.grade?.name ?? ""
                let section = data.student?.section?.name ?? ""
                let classSec = grade.isEmpty ? "--" : "\(grade)-\(section)"
                let admNum = data.student?.admissionNumber ?? "--"
                
                HStack(alignment: .top) {
                    studentDetailItem(title: "STUDENT NAME", value: sName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    studentDetailItem(title: "ROLL NUMBER", value: rNum)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(alignment: .top) {
                    studentDetailItem(title: "CLASS & SECTION", value: classSec)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    studentDetailItem(title: "ADMISSION NO.", value: admNum)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // 4. Timetable
            VStack(spacing: 0) {
                HStack {
                    Text("SUBJECT / TIME")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("DATE")
                        .frame(width: 60, alignment: .leading)
                    Text("ROOM")
                        .frame(width: 45, alignment: .trailing)
                }
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(navyColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(lightBlueBg)
                .cornerRadius(6)
                .padding(.bottom, 12)
                
                let schedules = data.schedules ?? []
                ForEach(Array(schedules.enumerated()), id: \.offset) { index, schedule in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            let subjName = schedule.subject?.name?.capitalized ?? "Subject"
                            let subjId = schedule.subject?.id ?? ""
                            
                            // FIX APPLIED HERE:
                            // Check if the id is a long UUID string. If yes, DO NOT show it.
                            let isUUID = UUID(uuidString: subjId) != nil
                            let displaySubject = (subjId.isEmpty || isUUID || subjId.count > 10) ? subjName : "\(subjName) (\(subjId))"
                            
                            Text(displaySubject)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(textDark)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(HTPreviewDateHelper.formatTime(schedule.startTime))
                                .font(.system(size: 9, weight: .regular))
                                .foregroundColor(textGray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(HTPreviewDateHelper.formatShortDate(schedule.examDate))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(textDark)
                            .frame(width: 60, alignment: .leading)
                        
                        Text(schedule.roomNumber ?? "--")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(textGray)
                            .frame(width: 45, alignment: .trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    
                    if index < schedules.count - 1 {
                        Divider().background(Color(red: 0.9, green: 0.9, blue: 0.9))
                            .padding(.horizontal, 12)
                    }
                }
            }
            
            // 5. Venue Box
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(navyColor)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("EXAMINATION VENUE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(textGray)
                    
                    let branch = data.student?.branch?.name ?? ""
                    let sName = data.hallTicket?.school?.name ?? "School Name"
                    let venueTitle = branch.isEmpty ? sName : "\(sName) - \(branch)"
                    
                    Text(venueTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(textDark)
                    
                    Text(HTPreviewDateHelper.reportingText(data.examination?.reportingDate))
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(textGray)
                }
                Spacer()
            }
            .padding(14)
            .background(screenBgColor)
            .cornerRadius(10)
            
            // 6. Instructions
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                    Text("Important instructions")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(textDark)
                }
                
                let lines = HTPreviewDateHelper.instructionLines(data.examination?.instructions)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(lines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(textGray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1))
            
            // 7. Signatures
            HStack(spacing: 20) {
                signatureBlock(title: "Class Teacher")
                Spacer()
                signatureBlock(title: "Principal")
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Download Button
    private func downloadButton() -> some View {
        Button(action: {
            print("Download Hall Ticket Tapped")
        }) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                Text("Download Hall Ticket")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(darkNavyButton)
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - UI Helpers
    private func studentDetailItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(textGray)
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(textDark)
        }
    }
    
    private func signatureBlock(title: String) -> some View {
        VStack(spacing: 8) {
            Text("-------------------")
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                .lineLimit(1)
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(textGray)
        }
    }
}

// MARK: - Date Formatting Helper
struct HTPreviewDateHelper {
    private static let posix = Locale(identifier: "en_US_POSIX")
    
    static func parseDate(_ raw: String?) -> Date? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: raw) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: raw) { return d }
        
        let f = DateFormatter()
        f.locale = posix
        for format in ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd"] {
            f.dateFormat = format
            if let d = f.date(from: raw) { return d }
        }
        return nil
    }
    
    static func formatShortDate(_ dateStr: String?) -> String {
        guard let date = parseDate(dateStr) else { return dateStr ?? "--" }
        let out = DateFormatter()
        out.locale = posix
        out.dateFormat = "MMM dd"
        return out.string(from: date)
    }
    
    static func formatTime(_ timeStr: String?) -> String {
        guard let timeStr = timeStr, !timeStr.isEmpty else { return "--" }
        let inFormatter = DateFormatter()
        inFormatter.locale = posix
        inFormatter.dateFormat = timeStr.count > 5 ? "HH:mm:ss" : "HH:mm"
        guard let date = inFormatter.date(from: timeStr) else { return timeStr }
        
        let out = DateFormatter()
        out.locale = posix
        out.dateFormat = "hh:mm a"
        return out.string(from: date)
    }
    
    static func formatFullDate(_ dateStr: String?) -> String {
        guard let date = parseDate(dateStr) else { return dateStr ?? "--" }
        let out = DateFormatter()
        out.locale = posix
        out.dateFormat = "MMM dd, yyyy"
        return out.string(from: date)
    }
    
    static func reportingText(_ raw: String?) -> String {
        let fallback = "Report at the assigned room 30 minutes before the exam."
        guard let raw = raw, !raw.isEmpty, let date = parseDate(raw) else { return fallback }
        
        let out = DateFormatter()
        out.locale = posix
        
        if raw.contains("T") || raw.contains(":") {
            out.dateFormat = "h:mm a"
            return "Report at the assigned room by \(out.string(from: date))."
        } else {
            out.dateFormat = "MMM dd, yyyy"
            return "Report at the assigned room on \(out.string(from: date))."
        }
    }
    
    static func instructionLines(_ raw: String?) -> [String] {
        let fallback = [
            "• Carry this Hall Ticket and school ID card to every paper.",
            "• Report 30 minutes before the scheduled time.",
            "• Electronic items, calculators and mobile devices are prohibited."
        ]
        
        guard let raw = raw, !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return fallback }
        return raw.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { line -> String in
                if line.hasPrefix("•") { return line }
                if line.hasPrefix("-") { return "• " + String(line.dropFirst()).trimmingCharacters(in: .whitespaces) }
                return "• \(line)"
            }
    }
}

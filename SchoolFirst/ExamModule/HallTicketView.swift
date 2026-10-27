import SwiftUI
import UIKit
import Combine

// MARK: - View Model for API Integration
class HallTicketViewModel: ObservableObject {
    @Published var hallTicketData: HallTicketData?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var isNotAvailable: Bool = false     // ✅ "not generated yet" state
    @Published var resolvedExamID: String?
    @Published var isDownloading: Bool = false      // ✅ NEW: download in progress
    
    private var pendingExamIDs: [String] = []
    
    /// Tries each exam ID in order until a published hall ticket is found.
    func fetchHallTicket(examIDs: [String]) {
        let studentID = UserManager.shared.resolvedStudentID
        let schoolID = UserManager.shared.resolvedSchoolID
        
        // Clean + de-duplicate while keeping order
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
        self.hallTicketData = nil
        self.pendingExamIDs = ids
        
        tryNextExam(studentID: studentID, schoolID: schoolID)
    }
    
    private func tryNextExam(studentID: String, schoolID: String) {
        guard !pendingExamIDs.isEmpty else {
            // No exam has a published hall ticket
            self.isLoading = false
            self.isNotAvailable = true
            self.errorMessage = "Your hall ticket has not been published yet. Please check back later."
            return
        }
        
        let examID = pendingExamIDs.removeFirst()
        
        print("🎫 Hall Ticket | examination_id: \(examID) | student_id: \(studentID)")
        
        // ✅ Params: student_id + examination_id | Header: X-School-ID | Auth: Bearer
        let parameters: [String: Any] = [
            "student_id": studentID,
            "examination_id": examID
        ]
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_HALL_TICKET,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers,
            showErrorAlert: false            // ✅ No generic "Error" popup
        ) { [weak self] (result: Result<APIResponse<HallTicketData>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data, data.hallTicket != nil || data.student != nil {
                        self.isLoading = false
                        self.hallTicketData = data
                        self.resolvedExamID = examID
                        print("✅ Hall Ticket: \(data.hallTicket?.hallTicketNumber ?? "-") | papers: \(data.schedules?.count ?? 0)")
                    } else {
                        print("ℹ️ No hall ticket for exam \(examID): \(response.description)")
                        self.tryNextExam(studentID: studentID, schoolID: schoolID)
                    }
                    
                case .failure(let error):
                    switch error {
                    case .noInternet, .noaccess:
                        // Stop trying — real connectivity / session problem
                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                    default:
                        // e.g. 400 "Hall ticket not found." → try next exam
                        print("ℹ️ Hall ticket not found for exam \(examID): \(error.localizedDescription)")
                        self.tryNextExam(studentID: studentID, schoolID: schoolID)
                    }
                }
            }
        }
    }
    
    // MARK: - ✅ NEW: Download PDF from API URL
    /// Downloads the hall ticket PDF and saves it to Documents/HallTickets.
    /// Completion is called on the main queue with the saved file URL (nil on failure).
    func downloadHallTicketPDF(urlString: String, fileName: String, completion: @escaping (URL?) -> Void) {
        guard let url = HallTicketFileHelper.resolveURL(urlString) else {
            print("❌ Invalid Hall Ticket PDF URL: \(urlString)")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        // Only attach auth headers for our own server (S3 / signed URLs reject extra auth)
        if HallTicketFileHelper.isOwnServer(url) {
            if let token = UserDefaults.standard.string(forKey: "ACCESSTOKEN"), !token.isEmpty {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let schoolID = UserManager.shared.resolvedSchoolID
            if !schoolID.isEmpty {
                request.setValue(schoolID, forHTTPHeaderField: "X-School-ID")
            }
        }
        
        print("⬇️ Downloading Hall Ticket PDF: \(url)")
        
        URLSession.shared.downloadTask(with: request) { tempURL, response, error in
            var savedURL: URL?
            
            if let error = error {
                print("❌ Hall Ticket PDF download error: \(error.localizedDescription)")
            } else if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                print("❌ Hall Ticket PDF download status: \(http.statusCode)")
            } else if let tempURL = tempURL {
                // Temp file is deleted after this closure → move it now
                let destination = HallTicketFileHelper.outputURL(fileName: fileName)
                do {
                    if FileManager.default.fileExists(atPath: destination.path) {
                        try FileManager.default.removeItem(at: destination)
                    }
                    try FileManager.default.moveItem(at: tempURL, to: destination)
                    
                    if HallTicketFileHelper.isPDF(at: destination) {
                        savedURL = destination
                        print("✅ Hall Ticket PDF saved: \(destination.path)")
                    } else {
                        print("❌ Downloaded file is not a valid PDF")
                        try? FileManager.default.removeItem(at: destination)
                    }
                } catch {
                    print("❌ Saving Hall Ticket PDF failed: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async { completion(savedURL) }
        }.resume()
    }
}

// MARK: - ✅ NEW: File Helper
enum HallTicketFileHelper {
    
    /// "HallTicket_HT-2026-9023" → safe file name
    static func sanitizedFileName(_ raw: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let cleaned = raw.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }
        let name = String(cleaned).trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        return name.isEmpty ? "HallTicket" : name
    }
    
    /// Documents/HallTickets/<fileName>.pdf
    static func outputURL(fileName: String) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let folder = docs.appendingPathComponent("HallTickets", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent("\(fileName).pdf")
    }
    
    /// Supports absolute URLs and relative paths ("/media/hall_ticket.pdf")
    static func resolveURL(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        let full: String
        if trimmed.lowercased().hasPrefix("http") {
            full = trimmed
        } else {
            let base = API.BASE_URL.hasSuffix("/") ? String(API.BASE_URL.dropLast()) : API.BASE_URL
            let path = trimmed.hasPrefix("/") ? trimmed : "/\(trimmed)"
            full = base + path
        }
        
        if let url = URL(string: full) { return url }
        if let encoded = full.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: encoded)
        }
        return nil
    }
    
    static func isOwnServer(_ url: URL) -> Bool {
        guard let baseHost = URL(string: API.BASE_URL)?.host, let host = url.host else { return false }
        return baseHost == host
    }
    
    /// Validates "%PDF" header so we don't share an HTML error page as a PDF
    static func isPDF(at url: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
        defer { handle.closeFile() }
        let header = handle.readData(ofLength: 4)
        return String(data: header, encoding: .ascii) == "%PDF"
    }
}

// MARK: - ✅ NEW: Share Sheet Presenter
@MainActor
enum HallTicketSharePresenter {
    
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    static func topViewController() -> UIViewController? {
        var top = keyWindow?.rootViewController
        while true {
            if let presented = top?.presentedViewController, !presented.isBeingDismissed {
                top = presented
            } else if let nav = top as? UINavigationController, let visible = nav.visibleViewController, visible !== nav {
                top = visible
            } else if let tab = top as? UITabBarController, let selected = tab.selectedViewController {
                top = selected
            } else {
                break
            }
        }
        return top
    }
    
    /// Opens iOS share sheet → Save to Files / Print / AirDrop / WhatsApp / Mail
    static func present(fileURL: URL) {
        guard let top = topViewController() else { return }
        
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        // iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = top.view
            popover.sourceRect = CGRect(x: top.view.bounds.midX, y: top.view.bounds.maxY - 80, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        top.present(activityVC, animated: true)
    }
}

// MARK: - ✅ NEW: Local PDF Renderer (fallback when API has no PDF)
@MainActor
enum HallTicketPDFRenderer {
    
    static func render<Content: View>(_ content: Content, width: CGFloat, to url: URL) -> Bool {
        try? FileManager.default.removeItem(at: url)
        
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: content)
            renderer.proposedSize = ProposedViewSize(width: width, height: nil)
            
            var success = false
            renderer.render { size, draw in
                guard size.width > 0, size.height > 0 else { return }
                var box = CGRect(origin: .zero, size: size)
                guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
                pdfContext.beginPDFPage(nil)
                draw(pdfContext)
                pdfContext.endPDFPage()
                pdfContext.closePDF()
                success = true
            }
            return success
        } else {
            // iOS 15 and below
            let host = UIHostingController(rootView: content)
            host.view.backgroundColor = .white
            
            let fitted = host.sizeThatFits(in: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            let height = max(fitted.height, 1)
            
            // Attach off-screen so SwiftUI lays out/renders
            host.view.frame = CGRect(x: -width * 3, y: 0, width: width, height: height)
            HallTicketSharePresenter.keyWindow?.addSubview(host.view)
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            defer { host.view.removeFromSuperview() }
            
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)
            let pdfRenderer = UIGraphicsPDFRenderer(bounds: bounds)
            do {
                try pdfRenderer.writePDF(to: url) { ctx in
                    ctx.beginPage()
                    host.view.layer.render(in: ctx.cgContext)
                }
                return true
            } catch {
                print("❌ Local Hall Ticket PDF failed: \(error.localizedDescription)")
                return false
            }
        }
    }
}

// MARK: - Date Formatting Helper
struct HallTicketDateHelper {
    
    private static let posix = Locale(identifier: "en_US_POSIX")
    
    /// Parses "2026-08-18", "2026-08-18 10:00:00", "2026-08-18T10:00:00Z", "2026-08-18T10:00:00.000Z"
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
    
    /// "2026-08-25" → "Aug 25"
    static func formatShortDate(_ dateStr: String?) -> String {
        guard let dateStr = dateStr, !dateStr.isEmpty else { return "--" }
        guard let date = parseDate(dateStr) else { return dateStr }
        let out = DateFormatter()
        out.locale = posix
        out.dateFormat = "MMM dd"
        return out.string(from: date)
    }
    
    /// "09:00:00" / "09:00" → "09:00 AM"
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
    
    /// "2026-08-18T10:00:00Z" → "Aug 18, 2026"
    static func formatFullDate(_ dateStr: String?) -> String {
        guard let dateStr = dateStr, !dateStr.isEmpty else { return "--" }
        guard let date = parseDate(dateStr) else { return dateStr }
        let out = DateFormatter()
        out.locale = posix
        out.dateFormat = "MMM dd, yyyy"
        return out.string(from: date)
    }
    
    /// Builds venue reporting line from `reporting_date`
    static func reportingText(_ raw: String?) -> String {
        let fallback = "Report at the assigned room 30 minutes before the exam."
        guard let raw = raw, !raw.isEmpty, let date = parseDate(raw) else { return fallback }
        
        let out = DateFormatter()
        out.locale = posix
        
        // Date + time → show time, date only → show date
        if raw.contains("T") || raw.contains(":") {
            out.dateFormat = "h:mm a"
            return "Report at the assigned room by \(out.string(from: date))."
        } else {
            out.dateFormat = "MMM dd, yyyy"
            return "Report at the assigned room on \(out.string(from: date))."
        }
    }
}

// MARK: - Main SwiftUI View
struct HallTicketView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = HallTicketViewModel()
    
    let examID: String
    var candidateExamIDs: [String] = []      // ✅ fallback exams
    var onBack: (() -> Void)? = nil
    
    // ✅ NEW: download failure alert
    @State private var showDownloadAlert: Bool = false
    @State private var downloadAlertMessage: String = ""
    
    let themeBlue = Color(red: 0.13, green: 0.30, blue: 0.53) // Dark Blue
    let lightBlueBg = Color(red: 0.93, green: 0.95, blue: 0.98)
    
    /// Primary exam first, then the rest
    private var allExamIDs: [String] {
        [examID] + candidateExamIDs
    }
    
    var body: some View {
        VStack(spacing: 0) {
            customNavBar
            
            if viewModel.isLoading {
                Spacer()
                ProgressView("Fetching Hall Ticket...")
                    .progressViewStyle(CircularProgressViewStyle(tint: themeBlue))
                Spacer()
                
            } else if viewModel.isNotAvailable {
                // ✅ Friendly "not published yet" state (no error popup)
                Spacer()
                notAvailableView
                Spacer()
                
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: { viewModel.fetchHallTicket(examIDs: allExamIDs) }) {
                        Text("Try Again")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(themeBlue)
                            .cornerRadius(8)
                    }
                }
                Spacer()
                
            } else if let data = viewModel.hallTicketData {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection(data: data)
                        
                        hallTicketCard(data: data)
                        
                        downloadButton(data: data)      // ✅ UPDATED
                        
                        Text("Issued \(HallTicketDateHelper.formatFullDate(data.hallTicket?.publishedAt ?? data.hallTicket?.generatedAt)) • Keep this document secure.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                    }
                }
                .background(Color(white: 0.98))
            } else {
                Spacer()
            }
        }
        .background(Color(white: 0.98).edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            // Avoid re-fetching every time the view re-appears
            if viewModel.hallTicketData == nil && !viewModel.isNotAvailable {
                viewModel.fetchHallTicket(examIDs: allExamIDs)
            }
        }
        .alert(isPresented: $showDownloadAlert) {
            Alert(
                title: Text("Download Failed"),
                message: Text(downloadAlertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Not Available State
    private var notAvailableView: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(themeBlue)
                .padding(20)
                .background(lightBlueBg)
                .clipShape(Circle())
            
            Text("Hall ticket not available")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(red: 0.07, green: 0.09, blue: 0.15))
            
            Text(viewModel.errorMessage ?? "Your hall ticket has not been published yet. Please check back later.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: { viewModel.fetchHallTicket(examIDs: allExamIDs) }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh").fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(themeBlue)
                .cornerRadius(8)
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - UI Subviews
    private var customNavBar: some View {
        HStack(spacing: 16) {
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Hall Ticket")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("School moments, all in one place")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .frame(height: 100, alignment: .bottom)
        .background(themeBlue)
    }
    
    private func headerSection(data: HallTicketData) -> some View {
        let statusText = (data.hallTicket?.status ?? "Ready")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hall Ticket")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeBlue)
                Text(data.examination?.name ?? "Examination")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(statusText)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(themeBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(lightBlueBg)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
    
    private func hallTicketCard(data: HallTicketData) -> some View {
        // ── Data resolution (API → fallbacks) ─────────────────────────
        let schoolName = data.hallTicket?.school?.name ?? "School Name"
        let address = data.hallTicket?.school?.address ?? ""
        let board = data.hallTicket?.school?.board ?? ""
        let schoolSubtitle: String = {
            if address.isEmpty && board.isEmpty { return "" }
            if board.isEmpty { return address }
            if address.isEmpty { return "Affiliated to \(board)" }
            return "\(address) • Affiliated to \(board)"
        }()
        
        let grade = data.student?.grade?.name ?? ""
        let section = data.student?.section?.name ?? ""
        let classSec: String = {
            if grade.isEmpty && section.isEmpty { return "--" }
            if section.isEmpty { return grade }
            if grade.isEmpty { return section }
            return "\(grade)-\(section)"
        }()
        
        let branchName = data.student?.branch?.name ?? ""
        let venueTitle = branchName.isEmpty ? schoolName : "\(schoolName) • \(branchName)"
        
        let schedules = data.schedules ?? []
        let lines = instructionLines(data.examination?.instructions)
        
        return VStack(spacing: 20) {
            // School Info
            VStack(spacing: 6) {
                Image(systemName: "building.columns.fill")
                    .foregroundColor(themeBlue)
                    .padding(12)
                    .background(lightBlueBg)
                    .clipShape(Circle())
                
                Text(schoolName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if !schoolSubtitle.isEmpty {
                    Text(schoolSubtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 10)
            
            // Ticket Info
            VStack(spacing: 4) {
                Text("HALL TICKET")
                    .font(.title3)
                    .fontWeight(.heavy)
                Text(data.examination?.name ?? "Examination")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(data.hallTicket?.hallTicketNumber ?? "HT-Pending")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(themeBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(lightBlueBg)
                    .cornerRadius(8)
            }
            
            Divider()
            
            // Student Details
            VStack(spacing: 16) {
                HStack {
                    detailItem(title: "STUDENT NAME", value: data.student?.name ?? "--")
                    Spacer()
                    detailItem(title: "ROLL NUMBER", value: data.hallTicket?.hallTicketNumber ?? data.student?.id ?? "--", alignment: .leading)
                        .frame(width: 130, alignment: .leading)
                }
                HStack {
                    detailItem(title: "CLASS & SECTION", value: classSec)
                    Spacer()
                    detailItem(title: "ADMISSION NO.", value: data.student?.admissionNumber ?? "--", alignment: .leading)
                        .frame(width: 130, alignment: .leading)
                }
            }
            
            // Exam Table
            VStack(spacing: 0) {
                HStack {
                    Text("SUBJECT / TIME")
                    Spacer()
                    Text("DATE")
                        .frame(width: 60, alignment: .leading)
                    Text("ROOM")
                        .frame(width: 50, alignment: .trailing)
                }
                .font(.caption)
                .foregroundColor(themeBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(lightBlueBg)
                .cornerRadius(6)
                .padding(.bottom, 12)
                
                if schedules.isEmpty {
                    Text("No schedule available")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Using offset as id (API ids may be nil)
                    ForEach(Array(schedules.enumerated()), id: \.offset) { index, schedule in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(schedule.subject?.name?.capitalized ?? "--")
                                    .font(.system(size: 13, weight: .bold))
                                Text(HallTicketDateHelper.formatTime(schedule.startTime))
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(HallTicketDateHelper.formatShortDate(schedule.examDate))
                                .font(.system(size: 12, weight: .medium))
                                .frame(width: 60, alignment: .leading)
                            Text(roomText(schedule.roomNumber))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(width: 50, alignment: .trailing)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        
                        if index < schedules.count - 1 {
                            Divider().padding(.horizontal, 12)
                        }
                    }
                }
            }
            
            // Venue
            HStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(themeBlue)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("EXAMINATION VENUE")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text(venueTitle)
                        .font(.system(size: 13, weight: .bold))
                    Text(HallTicketDateHelper.reportingText(data.examination?.reportingDate))
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(12)
            .background(lightBlueBg)
            .cornerRadius(8)
            
            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.orange)
                    Text("Important instructions")
                        .font(.system(size: 15, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    if !lines.isEmpty {
                        ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                            instructionBullet(line)
                        }
                    } else {
                        // Fallback matching Figma if API is empty
                        instructionBullet("• Carry this Hall Ticket and school ID card to every paper.")
                        instructionBullet("• Report 30 minutes before the scheduled time.")
                        instructionBullet("• Electronic items, calculators and mobile devices are prohibited.")
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            
            // Signatures
            HStack {
                VStack {
                    Text("-------------------").foregroundColor(.gray).lineLimit(1)
                    Text("Class Teacher").font(.caption2).foregroundColor(.gray)
                }
                Spacer()
                VStack {
                    Text("-------------------").foregroundColor(.gray).lineLimit(1)
                    Text("Principal").font(.caption2).foregroundColor(.gray)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .padding(.horizontal)
    }
    
    // MARK: - ✅ UPDATED: Download Button (download + save + share)
    private func downloadButton(data: HallTicketData) -> some View {
        Button(action: {
            Task { @MainActor in
                handleDownload(data: data)
            }
        }) {
            HStack(spacing: 8) {
                if viewModel.isDownloading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Downloading...").fontWeight(.bold)
                } else {
                    Image(systemName: "square.and.arrow.down")
                    Text("Download Hall Ticket").fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(themeBlue.opacity(viewModel.isDownloading ? 0.7 : 1.0))
            .cornerRadius(10)
        }
        .disabled(viewModel.isDownloading)
        .padding(.horizontal)
    }
    
    // MARK: - ✅ NEW: Download Flow
    /// 1. API PDF available → download & share
    /// 2. No PDF / download failed → generate PDF from on-screen hall ticket & share
    @MainActor
    private func handleDownload(data: HallTicketData) {
        guard !viewModel.isDownloading else { return }
        viewModel.isDownloading = true
        
        let baseName = data.hallTicket?.hallTicketNumber
            ?? data.examination?.name
            ?? "Exam"
        let fileName = HallTicketFileHelper.sanitizedFileName("HallTicket_\(baseName)")
        
        let pdfRaw = data.hallTicket?.pdf?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !pdfRaw.isEmpty else {
            print("ℹ️ No PDF URL from API → generating hall ticket PDF locally")
            generateAndShareLocalPDF(data: data, fileName: fileName)
            return
        }
        
        viewModel.downloadHallTicketPDF(urlString: pdfRaw, fileName: fileName) { fileURL in
            Task { @MainActor in
                if let fileURL = fileURL {
                    viewModel.isDownloading = false
                    HallTicketSharePresenter.present(fileURL: fileURL)
                } else {
                    print("ℹ️ API PDF download failed → generating hall ticket PDF locally")
                    generateAndShareLocalPDF(data: data, fileName: fileName)
                }
            }
        }
    }
    
    @MainActor
    private func generateAndShareLocalPDF(data: HallTicketData, fileName: String) {
        let outputURL = HallTicketFileHelper.outputURL(fileName: fileName)
        let width = UIScreen.main.bounds.width
        
        let success = HallTicketPDFRenderer.render(
            printableHallTicket(data: data, width: width),
            width: width,
            to: outputURL
        )
        
        viewModel.isDownloading = false
        
        if success {
            print("✅ Local Hall Ticket PDF saved: \(outputURL.path)")
            HallTicketSharePresenter.present(fileURL: outputURL)
        } else {
            downloadAlertMessage = "Unable to download the hall ticket right now. Please try again."
            showDownloadAlert = true
        }
    }
    
    /// Same layout as the screen (header + card + footer) on a white page
    private func printableHallTicket(data: HallTicketData, width: CGFloat) -> some View {
        VStack(spacing: 16) {
            headerSection(data: data)
            hallTicketCard(data: data)
            Text("Issued \(HallTicketDateHelper.formatFullDate(data.hallTicket?.publishedAt ?? data.hallTicket?.generatedAt)) • Keep this document secure.")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 24)
        .frame(width: width)
        .background(Color.white)
    }
    
    // MARK: - Helpers
    private func roomText(_ room: String?) -> String {
        let r = room?.trimmingCharacters(in: .whitespaces) ?? ""
        return r.isEmpty ? "--" : r
    }
    
    private func instructionLines(_ raw: String?) -> [String] {
        guard let raw = raw, !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return raw
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { line -> String in
                if line.hasPrefix("•") { return line }
                if line.hasPrefix("-") {
                    return "• " + String(line.dropFirst()).trimmingCharacters(in: .whitespaces)
                }
                return "• \(line)"
            }
    }
    
    private func detailItem(title: String, value: String, alignment: HorizontalAlignment = .leading) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(title).font(.system(size: 10, weight: .semibold)).foregroundColor(.gray)
            Text(value).font(.system(size: 14, weight: .bold))
        }
    }
    
    private func instructionBullet(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(.gray)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Preview
struct HallTicketView_Previews: PreviewProvider {
    static var previews: some View {
        HallTicketView(examID: "")
    }
}

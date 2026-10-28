//
//  ReportcardpreviewVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI
import Combine

// MARK: - API Models

// MARK: - View Model
final class ReportcardpreviewViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var reportData: ReportCardData?
    @Published var errorMessage: String?
    
    var studentID: String = ""
    var schoolID: String = ""
    var examinationID: String = ""
    
    func fetchReportCard() {
        guard !studentID.isEmpty, !schoolID.isEmpty, !examinationID.isEmpty else {
            print("⚠️ Report Card: missing studentID / schoolID / examinationID")
            return
        }
        
        isLoading = true
        
        let parameters: [String: Any] = [
            "student_id": studentID,
            "examination_id": examinationID
        ]
        let headers: [String: String] = [
            "X-School-ID": schoolID
        ]
        
        NetworkManager.shared.request(
            urlString: API.GET_REPORT_CARD,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<ReportCardData>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.success == true {
                        self.reportData = response.data
                    } else {
                        self.errorMessage = response.description ?? "Failed to load report card"
                        print("❌ Report Card API success=false: \(self.errorMessage ?? "")")
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Error fetching report card: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UIViewController Wrapper
final class ReportcardpreviewVC: UIViewController {
    
    var studentID: String = ""
    var schoolID: String = ""
    var examinationID: String = ""
    
    private let viewModel = ReportcardpreviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        viewModel.studentID = studentID
        viewModel.schoolID = schoolID
        viewModel.examinationID = examinationID
        
        setupSwiftUI()
        viewModel.fetchReportCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupSwiftUI() {
        let swiftUIView = ReportcardpreviewSwiftUIView(
            viewModel: viewModel,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
        
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

// MARK: - Main SwiftUI View
struct ReportcardpreviewSwiftUIView: View {
    @ObservedObject var viewModel: ReportcardpreviewViewModel
    var onBack: () -> Void = {}
    
    // Theme Colors
    private let navyColor = Color(red: 0.11, green: 0.31, blue: 0.58)
    private let darkNavyButton = Color(red: 0.11, green: 0.18, blue: 0.35)
    private let screenBgColor = Color(red: 0.96, green: 0.97, blue: 0.99)
    private let textDark = Color(red: 0.08, green: 0.11, blue: 0.19)
    private let textGray = Color(red: 0.45, green: 0.48, blue: 0.54)
    private let borderColor = Color(red: 0.89, green: 0.91, blue: 0.94)
    
    // Badge Colors
    private let badgeGreenBg = Color(red: 0.88, green: 0.97, blue: 0.92)
    private let badgeGreenText = Color(red: 0.12, green: 0.58, blue: 0.35)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if viewModel.isLoading && viewModel.reportData == nil {
                Spacer()
                ProgressView("Loading Report Card...")
                    .foregroundColor(textGray)
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        pageTitleSection
                        documentCard
                        
                        Button(action: {
                            print("Download tapped")
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Download Report Card")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(darkNavyButton)
                            .cornerRadius(12)
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 16)
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
                Text("Report Card")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text("School moments, all in one place")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.75))
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
    private var pageTitleSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Report Card")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(textDark)
                
                let rawDate = viewModel.reportData?.reportCard?.publishedAt ?? viewModel.reportData?.examination?.resultDate ?? "2026-09-10"
                Text("Published \(formatDate(rawDate)) • Signed copy")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(textGray)
            }
            
            Spacer()
            
            let status = viewModel.reportData?.reportCard?.status ?? "Published"
            Text(status.capitalized)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(badgeGreenText)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(badgeGreenBg)
                .cornerRadius(10)
        }
    }
    
    // MARK: - Document Card
    private var documentCard: some View {
        VStack(spacing: 24) {
            
            // 1. School Header
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.90, green: 0.95, blue: 1.0))
                        .frame(width: 48, height: 48)
                    Image(systemName: "building.columns.fill")
                        .foregroundColor(navyColor)
                        .font(.system(size: 20))
                }
                .padding(.bottom, 4)
                
                Text("Oasis Public School")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textDark)
                Text("New Delhi, India • Affiliated to CBSE")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(textGray)
            }
            
            // 2. Exam Title
            VStack(spacing: 4) {
                Text("REPORT CARD")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(textDark)
                    .tracking(1.5)
                
                let examName = viewModel.reportData?.examination?.name ?? "Examination"
                Text(examName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(textGray)
            }
            
            // 3. Student Details
            VStack(spacing: 16) {
                let sName = viewModel.reportData?.student?.name ?? "--"
                let rNum = viewModel.reportData?.student?.admissionNumber ?? "--"
                
                let grade = viewModel.reportData?.student?.grade ?? ""
                let section = viewModel.reportData?.student?.section ?? ""
                let classSec = grade.isEmpty ? section : (section.isEmpty ? grade : "\(grade)-\(section)")
                let acYear = viewModel.reportData?.examination?.academicYear ?? "--"
                
                HStack {
                    studentDetailItem(title: "STUDENT NAME", value: sName)
                    Spacer()
                    studentDetailItem(title: "ROLL NUMBER", value: rNum)
                        .frame(width: 130, alignment: .leading)
                }
                
                HStack {
                    studentDetailItem(title: "CLASS & SECTION", value: classSec.isEmpty ? "--" : classSec)
                    Spacer()
                    studentDetailItem(title: "ACADEMIC YEAR", value: acYear)
                        .frame(width: 130, alignment: .leading)
                }
            }
            
            // 4. Overall Grade Banner
            let overallPct = viewModel.reportData?.reportCard?.percentage ?? 0.0
            let overallObtained = Int(viewModel.reportData?.reportCard?.obtainedMarks ?? 0)
            let overallMax = Int(viewModel.reportData?.reportCard?.totalMarks ?? 0)
            let overallGrade = viewModel.reportData?.reportCard?.grade ?? "—"
            let overallRes = viewModel.reportData?.reportCard?.result ?? "PASS"
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(borderColor, lineWidth: 5)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(overallPct / 100.0))
                        .stroke(badgeGreenText, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 64, height: 64)
                    
                    VStack(spacing: 1) {
                        Text(String(format: "%.1f%%", overallPct))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(textDark)
                        Text("\(overallObtained) / \(overallMax)")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(textGray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("OVERALL GRADE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(textGray)
                    
                    Text(overallGrade)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(textDark)
                    
                    Text("\(overallRes.capitalized) - Strong performance")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(badgeGreenText)
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color(red: 0.94, green: 0.97, blue: 1.0))
            .cornerRadius(12)
            
            // 5. Marks Table
            VStack(spacing: 16) {
                HStack {
                    Text("SUBJECT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(textGray)
                    Spacer()
                    
                    Group {
                        Text("MAX")
                            .frame(width: 35, alignment: .trailing)
                        Text("SCORE")
                            .frame(width: 45, alignment: .trailing)
                        Text("GRADE")
                            .frame(width: 45, alignment: .trailing)
                    }
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(textGray)
                }
                
                Divider().background(borderColor)
                
                let safeSubjects = getDisplaySubjects()
                
                ForEach(safeSubjects) { subject in
                    HStack {
                        let subjName = subject.subject?.name?.capitalized ?? "Subject"
                        let subjId = subject.subject?.id ?? ""
                        
                        // Mask long database UUIDs from breaking the UI UI
                        let isUUID = UUID(uuidString: subjId) != nil
                        let displaySubject = (subjId.isEmpty || isUUID || subjId.count > 10) ? subjName : "\(subjName) (\(subjId))"
                        
                        Text(displaySubject)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(textDark)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(Int(subject.maximumMarks ?? 100))")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(textGray)
                            .frame(width: 35, alignment: .trailing)
                        
                        Text("\(Int(subject.marks?.marksObtained ?? 0))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(textDark)
                            .frame(width: 45, alignment: .trailing)
                        
                        gradePill(grade: subject.grade ?? "—")
                            .frame(width: 45, alignment: .trailing)
                    }
                    
                    Divider().background(borderColor).opacity(0.5)
                }
                
                HStack {
                    Text("Total")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(textDark)
                    
                    Spacer()
                    
                    Text("\(overallMax)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(textDark)
                        .frame(width: 35, alignment: .trailing)
                    
                    Text("\(overallObtained)")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(textDark)
                        .frame(width: 45, alignment: .trailing)
                    
                    Text(overallGrade)
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(navyColor)
                        .frame(width: 45, alignment: .trailing)
                }
                .padding(.top, 4)
            }
            
            // 6. Stats (fallback dummy — not in API)
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ATTENDANCE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(textGray)
                    Text("92.8%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(navyColor)
                    Text("254 / 268 days")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(textGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(screenBgColor)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("CLASS RANK")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(textGray)
                    Text("8 / 42")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(navyColor)
                    Text("Top 20%")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(textGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(screenBgColor)
                .cornerRadius(12)
            }
            
            // 7. Teacher Remarks
            let remarks = viewModel.reportData?.reportCard?.teacherRemarks ?? "Excellent performance. Student shows consistent improvement across subjects."
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Text("NK")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(navyColor)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mrs. Neha Kapoor")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(textDark)
                        Text("Class Teacher")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(textGray)
                    }
                }
                
                Text("\"\(remarks)\"")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(textDark)
                    .lineSpacing(3)
                    .italic()
            }
            .padding(14)
            .background(screenBgColor)
            .cornerRadius(12)
            
            // 8. Signatures
            HStack(spacing: 20) {
                signatureBlock(title: "Class Teacher")
                Spacer()
                signatureBlock(title: "Principal")
                Spacer()
                signatureBlock(title: "Parent / Guardian")
            }
            .padding(.top, 30)
            .padding(.bottom, 10)
            .padding(.horizontal, 10)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    // MARK: - Helpers
    
    private func getDisplaySubjects() -> [ReportCardSubject] {
        if let apiSubjects = viewModel.reportData?.subjects, !apiSubjects.isEmpty {
            return apiSubjects
        }
        
        // Fallback dummy subjects when API data is null/empty during testing
        return [
            ReportCardSubject(
                resultId: "1",
                subject: ReportCardSubjectInfo(id: "041", name: "Mathematics"),
                examDate: nil,
                maximumMarks: 100,
                passingMarks: nil,
                marks: ReportCardMarks(internalMarks: nil, externalMarks: nil, practicalMarks: nil, marksObtained: 78),
                grade: "B1",
                gradePoint: nil,
                remarks: nil
            ),
            ReportCardSubject(
                resultId: "2",
                subject: ReportCardSubjectInfo(id: "086", name: "Science"),
                examDate: nil,
                maximumMarks: 100,
                passingMarks: nil,
                marks: ReportCardMarks(internalMarks: nil, externalMarks: nil, practicalMarks: nil, marksObtained: 85),
                grade: "A2",
                gradePoint: nil,
                remarks: nil
            ),
            ReportCardSubject(
                resultId: "3",
                subject: ReportCardSubjectInfo(id: "184", name: "English"),
                examDate: nil,
                maximumMarks: 100,
                passingMarks: nil,
                marks: ReportCardMarks(internalMarks: nil, externalMarks: nil, practicalMarks: nil, marksObtained: 92),
                grade: "A1",
                gradePoint: nil,
                remarks: nil
            )
        ]
    }
    
    private func studentDetailItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(textGray)
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(textDark)
        }
    }
    
    private func gradePill(grade: String) -> some View {
        let isA = grade.uppercased().hasPrefix("A")
        return Text(grade)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(isA ? badgeGreenText : navyColor)
            .frame(width: 24, height: 24)
            .background(isA ? badgeGreenBg : Color(red: 0.90, green: 0.95, blue: 1.0))
            .clipShape(Circle())
    }
    
    private func signatureBlock(title: String) -> some View {
        VStack(spacing: 8) {
            ReportCardDashLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                .foregroundColor(textGray.opacity(0.5))
                .frame(height: 1)
            
            Text(title)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(textGray)
                .multilineTextAlignment(.center)
        }
    }
    
    private func formatDate(_ raw: String) -> String {
        let inF = DateFormatter()
        inF.locale = Locale(identifier: "en_US_POSIX")
        inF.dateFormat = "yyyy-MM-dd"
        
        if let d = inF.date(from: raw) {
            let outF = DateFormatter()
            outF.dateFormat = "MMM d, yyyy"
            return outF.string(from: d)
        }
        return raw
    }
}

// MARK: - Dash Line
struct ReportCardDashLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

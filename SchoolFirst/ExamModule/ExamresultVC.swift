//
//  ExamresultVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI
import Combine

// MARK: - Subject Item Extension
extension ExamResultSubjectItem {
    var isDistinctionOrA: Bool {
        (grade ?? "").uppercased().starts(with: "A")
    }
}

// MARK: - View Model
class ExamResultViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var examResultsList: [ExamResultItem] = []
    @Published var resultDetail: ExamResultDetailData?
    @Published var errorMessage: String?
    
    var studentID: String = ""
    var schoolID: String = ""
    var examinationID: String = ""
    
    // API 1: Fetch list of exam results
    func fetchResultsList() {
        guard !studentID.isEmpty, !schoolID.isEmpty else { return }
        
        isLoading = true
        let parameters: [String: Any] = ["student_id": studentID]
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_EXAM_RESULTS,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<[ExamResultItem]>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.examResultsList = response.data ?? []
                    
                    let matchingExam = self.examResultsList.first(where: { $0.examination?.id == self.examinationID })
                    
                    if let validID = matchingExam?.examination?.id {
                        self.examinationID = validID
                        self.fetchResultDetail()
                    } else if let latestExamID = self.examResultsList.first?.examination?.id {
                        self.examinationID = latestExamID
                        self.fetchResultDetail()
                    } else {
                        self.isLoading = false
                    }
                    
                case .failure(let error):
                    self.isLoading = false
                    print("❌ Error fetching results list: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // API 2: Fetch exam result detail
    func fetchResultDetail() {
        guard !studentID.isEmpty, !schoolID.isEmpty, !examinationID.isEmpty else { return }
        
        isLoading = true
        let parameters: [String: Any] = [
            "student_id": studentID,
            "examination_id": examinationID
        ]
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_EXAM_RESULT_DETAIL,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<ExamResultDetailData>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.success {
                        self.resultDetail = response.data
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Error fetching result detail: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var highestSubjectInfo: (name: String, percentage: Int)? {
        guard let subjects = resultDetail?.subjects, !subjects.isEmpty else { return nil }
        let sorted = subjects.sorted { $0.percentageDouble > $1.percentageDouble }
        if let top = sorted.first {
            return (top.subject?.name?.capitalized ?? "Subject", Int((top.percentageDouble * 100).rounded()))
        }
        return nil
    }
}

// MARK: - UIViewController Wrapper
class ExamresultVC: UIViewController {
    
    var studentID: String = ""
    var schoolID: String = ""
    var examinationID: String = ""
    
    private let viewModel = ExamResultViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        viewModel.studentID = studentID
        viewModel.schoolID = schoolID
        viewModel.examinationID = examinationID
        
        setupSwiftUI()
        viewModel.fetchResultsList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupSwiftUI() {
        let resultsSwiftUIView = ExamResultView(
            viewModel: viewModel,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onReportCardTap: { [weak self] in
                // Navigation to ReportcardpreviewVC called here
                self?.navigateToReportCard()
            },
            onSubjectTap: { [weak self] subject in
                self?.navigateToSubjectDetail(subject: subject)
            }
        )
        
        let hostingController = UIHostingController(rootView: resultsSwiftUIView)
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
    
    // MARK: - Navigation to Subject Detail
    private func navigateToSubjectDetail(subject: ExamResultSubjectItem) {
        let subjectVC = SubjectResultVC()
        subjectVC.subjectItem = subject
        subjectVC.resultDetail = viewModel.resultDetail
        navigationController?.pushViewController(subjectVC, animated: true)
    }
    
    // MARK: - Navigation to Report Card
    private func navigateToReportCard() {
        let reportVC = ReportcardpreviewVC()
        
        // Pass the required IDs and selected exam result detail from the ViewModel to the Report Card
        reportVC.studentID = viewModel.studentID.isEmpty ? UserManager.shared.resolvedStudentID : viewModel.studentID
        reportVC.schoolID = viewModel.schoolID.isEmpty ? UserManager.shared.resolvedSchoolID : viewModel.schoolID
        reportVC.examinationID = viewModel.examinationID
        reportVC.examResultDetail = viewModel.resultDetail
        
        navigationController?.pushViewController(reportVC, animated: true)
    }
    
    // MARK: - Main SwiftUI View
    struct ExamResultView: View {
        @ObservedObject var viewModel: ExamResultViewModel
        var onBack: () -> Void = {}
        var onReportCardTap: () -> Void = {}
        var onSubjectTap: (ExamResultSubjectItem) -> Void = { _ in }
        
        private let navyColor = Color(red: 0.11, green: 0.31, blue: 0.58)
        private let darkNavyButton = Color(red: 0.11, green: 0.18, blue: 0.35)
        private let screenBgColor = Color(red: 0.96, green: 0.97, blue: 0.99)
        private let textDark = Color(red: 0.08, green: 0.11, blue: 0.19)
        private let textGray = Color(red: 0.45, green: 0.48, blue: 0.54)
        private let borderColor = Color(red: 0.89, green: 0.91, blue: 0.94)
        
        var body: some View {
            VStack(spacing: 0) {
                headerView
                
                if viewModel.isLoading && viewModel.resultDetail == nil && viewModel.examResultsList.isEmpty {
                    Spacer()
                    ProgressView("Loading examination results...")
                        .foregroundColor(textGray)
                    Spacer()
                } else if viewModel.examResultsList.isEmpty || viewModel.resultDetail == nil {
                    // Pending / Empty State
                    ScrollView(.vertical, showsIndicators: false) {
                        pendingStateView
                    }
                } else {
                    // Success State
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Exam results")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(textDark)
                                
                                let studentName = viewModel.resultDetail?.student?.name ?? "student"
                                Text("Choose \(studentName)'s class history and an exam to review published subject results.")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(textGray)
                                    .lineSpacing(3)
                            }
                            .padding(.top, 16)
                            
                            selectionCard
                            step3Header
                            overallPerformanceCard
                            subjectResultsSection
                            reportCardSection
                                .padding(.bottom, 30)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .background(screenBgColor.ignoresSafeArea())
        }
        
        // MARK: - Pending / Not Published State
        private var pendingStateView: some View {
            VStack(spacing: 16) {
                // Title Section
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Results pending")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(textDark)
                        
                        Text("Examination")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(textGray)
                    }
                    Spacer()
                    Text("Not published")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.85, green: 0.47, blue: 0.0))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(red: 1.0, green: 0.95, blue: 0.90))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Main White Card
                VStack(spacing: 24) {
                    // Icon Header
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.96, blue: 0.92))
                            .frame(width: 80, height: 80)
                        Image(systemName: "clock")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 0.95, green: 0.61, blue: 0.07))
                    }
                    .padding(.top, 20)
                    
                    // Explanatory Text
                    VStack(spacing: 8) {
                        Text("The school is preparing the student's results")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(textDark)
                            .multilineTextAlignment(.center)
                        
                        Text("Marks are being reviewed and verified by the school before publication.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(textGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .lineSpacing(4)
                    }
                    
                    // Button
                    Button(action: {
                        print("Notify me tapped")
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "bell")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Notify me when published")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(darkNavyButton)
                        .cornerRadius(12)
                    }
                    .padding(.bottom, 10)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 1)
                )
                .padding(.horizontal, 16)
            }
        }
        
        // MARK: - Header
        private var headerView: some View {
            HStack(alignment: .center, spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Exam Results")
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
        
        private var selectionCard: some View {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        stepNumberBadge(number: "1")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Choose class & year")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(textDark)
                            Text("Select from student's academic history")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(textGray)
                        }
                    }
                    
                    let gradeName = viewModel.resultDetail?.student?.grade?.name ?? "Class"
                    let sectionName = viewModel.resultDetail?.student?.section?.name ?? ""
                    let classTitle = sectionName.isEmpty ? gradeName : "\(gradeName)-\(sectionName)"
                    let academicYear = viewModel.resultDetail?.examination?.academicYear?.name ?? "Academic Year"
                    
                    HStack(spacing: 12) {
                        iconBox(systemName: "graduationcap.fill")
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CLASS HISTORY")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(textGray)
                            Text(classTitle)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(textDark)
                            Text(academicYear)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(textGray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(textGray)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        stepNumberBadge(number: "2")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Choose examination")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(textDark)
                            Text("Only exams held in this class and year are shown")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(textGray)
                        }
                    }
                    
                    let currentExamName = viewModel.resultDetail?.examination?.name ?? "Examination"
                    let examType = viewModel.resultDetail?.examination?.examinationType?.name ?? "Exam"
                    let resDate = formatDate(viewModel.resultDetail?.examination?.resultDate)
                    let subText = "\(examType) • Results published \(resDate)"
                    
                    Menu {
                        ForEach(viewModel.examResultsList) { item in
                            Button(action: {
                                if let id = item.examination?.id {
                                    viewModel.examinationID = id
                                    viewModel.fetchResultDetail()
                                }
                            }) {
                                Text(item.examination?.name ?? "Exam")
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            iconBox(systemName: "doc.text.fill")
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SELECTED EXAM")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(textGray)
                                Text(currentExamName)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(textDark)
                                Text(subText)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(textGray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(textGray)
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        
        private var step3Header: some View {
            HStack(alignment: .center, spacing: 10) {
                stepNumberBadge(number: "3")
                
                let examName = viewModel.resultDetail?.examination?.name ?? "Examination"
                VStack(alignment: .leading, spacing: 2) {
                    Text("Review results")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(textDark)
                    Text(examName)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(textGray)
                }
                
                Spacer()
                
                let badgeText = viewModel.resultDetail?.summary?.result?.capitalized ?? "Published"
                Text(badgeText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 0.12, green: 0.58, blue: 0.35))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.88, green: 0.97, blue: 0.92))
                    .cornerRadius(10)
            }
        }
        
        private var overallPerformanceCard: some View {
            let summary = viewModel.resultDetail?.summary
            let subjectsCount = viewModel.resultDetail?.subjects?.count ?? 0
            let obtained = Int(summary?.obtainedMarksDouble ?? 0)
            let total = Int(summary?.totalMarksDouble ?? 0)
            let percent = summary?.percentageDouble ?? 0.0
            let grade = summary?.grade ?? "—"
            let isPass = summary?.isPass ?? true
            
            return VStack(spacing: 16) {
                HStack(spacing: 10) {
                    iconBox(systemName: "chart.bar.fill")
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Overall performance")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(textDark)
                        Text("\(subjectsCount) subjects • \(obtained) of \(total) marks")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(textGray)
                    }
                    
                    Spacer()
                    
                    Text(isPass ? "Pass" : "Fail")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isPass ? Color(red: 0.12, green: 0.58, blue: 0.35) : .red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(isPass ? Color(red: 0.88, green: 0.97, blue: 0.92) : Color.red.opacity(0.12))
                        .cornerRadius(8)
                }
                
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(borderColor, lineWidth: 6)
                            .frame(width: 68, height: 68)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(max(percent / 100.0, 0.0), 1.0)))
                            .stroke(isPass ? Color(red: 0.12, green: 0.65, blue: 0.40) : Color.red, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 68, height: 68)
                        
                        VStack(spacing: 1) {
                            Text(String(format: "%.1f%%", percent))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(textDark)
                            Text("\(obtained) / \(total)")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(textGray)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("OVERALL GRADE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(textGray)
                        
                        Text(grade)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(textDark)
                        
                        let remarks = summary?.teacherRemarks ?? "Strong performance across subjects"
                        Text(remarks)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.11, green: 0.35, blue: 0.48))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(Color(red: 0.94, green: 0.97, blue: 1.0))
                .cornerRadius(12)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("GRADE POINT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(textGray)
                        let gp = summary?.gradePoint ?? "—"
                        Text(gp)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(navyColor)
                        Text("Performance scale")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(textGray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(screenBgColor)
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("HIGHEST SCORE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(textGray)
                        
                        if let top = viewModel.highestSubjectInfo {
                            Text("\(top.percentage)%")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(navyColor)
                            Text(top.name)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(textGray)
                        } else {
                            Text("—")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(navyColor)
                            Text("All subjects")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(textGray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(screenBgColor)
                    .cornerRadius(10)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        
        private var subjectResultsSection: some View {
            let subjects = viewModel.resultDetail?.subjects ?? []
            return VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Subject results")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(textDark)
                        Text("Tap a subject for marks and teacher feedback.")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(textGray)
                    }
                    
                    Spacer()
                    
                    Text("\(subjects.count) subjects")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(navyColor)
                }
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(subjects) { subject in
                        Button(action: {
                            onSubjectTap(subject)
                        }) {
                            subjectCard(subject)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        
        private func subjectCard(_ subject: ExamResultSubjectItem) -> some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(subject.subject?.name?.capitalized ?? "Subject")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(textDark)
                            .lineLimit(1)
                        let maxM = Int(Double(subject.maximumMarks ?? "100") ?? 100)
                        Text("Max \(maxM) marks")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(textGray)
                    }
                    
                    Spacer()
                    
                    Text(subject.grade ?? "—")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(subject.isDistinctionOrA ? Color(red: 0.12, green: 0.58, blue: 0.35) : navyColor)
                        .frame(width: 26, height: 26)
                        .background(subject.isDistinctionOrA ? Color(red: 0.88, green: 0.97, blue: 0.92) : Color(red: 0.90, green: 0.95, blue: 1.0))
                        .clipShape(Circle())
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(subject.marksObtainedInt)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textDark)
                    
                    Text("/ \(subject.maxMarksInt) marks")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(textGray)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(borderColor)
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(subject.isDistinctionOrA ? Color(red: 0.12, green: 0.65, blue: 0.40) : navyColor)
                            .frame(width: geo.size.width * CGFloat(min(max(subject.percentageDouble, 0.0), 1.0)), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        
        private var reportCardSection: some View {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    iconBox(systemName: "doc.text.fill")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            stepNumberBadge(number: "4")
                            
                            Text("OPTIONAL")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(textGray)
                        }
                        
                        Text("Open the official Report Card")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(textDark)
                        
                        Text("View the signed school document on a separate screen.")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(textGray)
                    }
                    
                    Spacer()
                }
                
                Button(action: onReportCardTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 14, weight: .semibold))
                        Text("View Report Card")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(darkNavyButton)
                    .cornerRadius(10)
                }
                
                let updatedDate = formatDate(viewModel.resultDetail?.examination?.resultDate)
                Text("Results last updated \(updatedDate)")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(textGray)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        
        private func stepNumberBadge(number: String) -> some View {
            Text(number)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(darkNavyButton)
                .clipShape(Circle())
        }
        
        private func iconBox(systemName: String) -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.90, green: 0.95, blue: 1.0))
                    .frame(width: 38, height: 38)
                
                Image(systemName: systemName)
                    .font(.system(size: 16))
                    .foregroundColor(navyColor)
            }
        }
        
        private func formatDate(_ raw: String?) -> String {
            guard let raw = raw, !raw.isEmpty else { return "—" }
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
}

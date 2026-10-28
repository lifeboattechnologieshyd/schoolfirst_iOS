//
//  ExamhomeVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 27/10/26.
//

import UIKit

// MARK: - API Models


class ExamhomeVC: UIViewController {

    // MARK: - UI Components
    private let headerView = UIView()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    // Data property for API
    private var exams: [ExamItem] = []
    
    // ✅ NEW: Exam detail (for hero card + upcoming papers)
    private var examDetail: ExamDetail?
    private var nextExamID: String?
    private var isDetailLoading: Bool = false
    
    // ✅ NEW: Shared date parser
    private static let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    // Theme Colors based on Figma
    private struct Colors {
        static let primaryBlue = UIColor(red: 0.11, green: 0.31, blue: 0.58, alpha: 1.0)
        static let background = UIColor(red: 0.97, green: 0.98, blue: 0.99, alpha: 1.0)
        static let textDark = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0)
        static let textGray = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0)
        static let cardBorder = UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1.0)
        
        static let badgeBlueBg = UIColor(red: 0.90, green: 0.96, blue: 1.0, alpha: 1.0)
        static let badgeBlueText = UIColor(red: 0.15, green: 0.45, blue: 0.85, alpha: 1.0)
        
        static let badgeGreenBg = UIColor(red: 0.88, green: 0.97, blue: 0.92, alpha: 1.0)
        static let badgeGreenText = UIColor(red: 0.13, green: 0.55, blue: 0.35, alpha: 1.0)
        
        static let buttonDark = UIColor(red: 0.11, green: 0.18, blue: 0.35, alpha: 1.0)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        setupHeaderView()
        setupScrollView()
        
        // Initial build before API finishes
        buildContent()
        
        // Fetch data from API
        fetchExams()
    }
    
    // MARK: - API Integration (Exams List)
    private func fetchExams() {
        let studentID = UserManager.shared.resolvedStudentID
        let schoolID = UserManager.shared.resolvedSchoolID
        
        guard !studentID.isEmpty, !schoolID.isEmpty else { return }
        
        let parameters: [String: Any] = ["student_id": studentID]
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        // Use the globally defined API constant if available, or replace with string directly
        // Assuming API.GET_EXAMS is defined as: static let GET_EXAMS = BASE_URL + "examination/exam"
        let endpoint = API.GET_EXAMS
        
        NetworkManager.shared.request(
            urlString: endpoint,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<[ExamItem]>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.exams = response.data ?? []
                    self.buildContent() // Rebuild UI with fresh data
                    
                    // ✅ NEW: Load details of the next upcoming exam
                    if let next = self.resolveNextExam(from: self.exams),
                       let id = next.id, !id.isEmpty {
                        self.nextExamID = id
                        self.fetchExamDetail(examID: id)
                    }
                    
                case .failure(let error):
                    print("Failed to fetch exams: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - ✅ NEW: API Integration (Exam Detail)
    private func fetchExamDetail(examID: String) {
        
        let studentID = UserManager.shared.resolvedStudentID
        let schoolID  = UserManager.shared.resolvedSchoolID
        
        guard !examID.isEmpty, !studentID.isEmpty, !schoolID.isEmpty else { return }
        
        print("📘 Home → Exam Detail | examination_id: \(examID) | student_id: \(studentID)")
        
        isDetailLoading = true
        
        let parameters: [String: Any] = [
            "student_id": studentID,
            "examination_id": examID
        ]
        let headers: [String: String] = ["X-School-ID": schoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_EXAM_DETAIL,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<ExamDetail>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isDetailLoading = false
                
                switch result {
                case .success(let response):
                    if response.success, let detail = response.data {
                        self.examDetail = detail
                        print("✅ Home exam detail: \(detail.name ?? "-") | papers: \(detail.schedules?.count ?? 0)")
                    }
                case .failure(let error):
                    print("❌ Home exam detail failed: \(error.localizedDescription)")
                }
                self.buildContent() // Rebuild hero + upcoming papers
            }
        }
    }
    
    // MARK: - ✅ NEW: Pick nearest upcoming exam (fallback = first)
    private func resolveNextExam(from list: [ExamItem]) -> ExamItem? {
        guard !list.isEmpty else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        
        let dated = list.compactMap { exam -> (ExamItem, Date)? in
            guard let raw = exam.startDate,
                  let d = Self.apiDateFormatter.date(from: raw) else { return nil }
            return (exam, d)
        }.sorted { $0.1 < $1.1 }
        
        if let upcoming = dated.first(where: { $0.1 >= today }) { return upcoming.0 }
        return dated.last?.0 ?? list.first
    }
    
    // MARK: - ✅ NEW: Sorted schedules (upcoming first)
    private var sortedSchedules: [ExamSchedule] {
        guard let schedules = examDetail?.schedules, !schedules.isEmpty else { return [] }
        let today = Calendar.current.startOfDay(for: Date())
        
        let dated = schedules.compactMap { s -> (ExamSchedule, Date)? in
            guard let raw = s.examDate,
                  let d = Self.apiDateFormatter.date(from: raw) else { return nil }
            return (s, d)
        }.sorted { $0.1 < $1.1 }
        
        let future = dated.filter { $0.1 >= today }
        let source = future.isEmpty ? dated : future
        return source.map { $0.0 }
    }
    
    // MARK: - Setup Base Views
    private func setupMainView() {
        view.backgroundColor = Colors.background
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = Colors.primaryBlue
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        // Back Button
        let backButton = UIButton(type: .system)
        let backImage = UIImage(systemName: "arrow.backward", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Titles
        let titleLabel = UILabel()
        titleLabel.text = "Exams"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "School moments, all in one place"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 2
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Bell Button
        let bellButton = UIButton(type: .system)
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = .white
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(backButton)
        headerView.addSubview(titleStack)
        headerView.addSubview(bellButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: titleStack.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleStack.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            bellButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            bellButton.centerYAnchor.constraint(equalTo: titleStack.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 30),
            bellButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 30, right: 16)
        
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapBack() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // ✅ Navigate to Exam Details screen on tapping an exam item
    @objc private func examItemTapped(_ gesture: UITapGestureRecognizer) {
        let index = gesture.view?.tag ?? 0
        guard exams.indices.contains(index) else { return }
        
        let selectedExam = exams[index]
        openExamDetail(examID: selectedExam.id)
    }
    
    // ✅ Navigate to All Exams History
    @objc private func didTapSeeAllExams() {
        let historyVC = Allexamshistorywithsearch()
        historyVC.studentID = UserManager.shared.resolvedStudentID
        historyVC.schoolID = UserManager.shared.resolvedSchoolID
        historyVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    // ✅ NEW: Hero "View details" / "Full schedule" / "See all" / paper row
    @objc private func openNextExamDetail() {
        openExamDetail(examID: nextExamID ?? exams.first?.id)
    }
    
    // ✅ NEW: Hero "View details" → ExamdetailsoverviewVC
    @objc private func openExamDetailsOverview() {
        let overviewVC = ExamdetailsoverviewVC()
        overviewVC.examDetail = examDetail
        overviewVC.examID = nextExamID ?? exams.first?.id
        overviewVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(overviewVC, animated: true)
    }
    
    @objc private func paperRowTapped(_ gesture: UITapGestureRecognizer) {
        openNextExamDetail()
    }
    
    // ✅ Navigate to ExamresultVC when tapping results card
    @objc private func resultsCardTapped() {
            let resultsVC = ExamresultVC()
            resultsVC.studentID = UserManager.shared.resolvedStudentID
            resultsVC.schoolID = UserManager.shared.resolvedSchoolID
            resultsVC.examinationID = nextExamID ?? exams.first?.id ?? ""
            resultsVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(resultsVC, animated: true)
        }
    
    // ✅ Navigate to HallticketpreviewVC when tapping Hall Ticket card
    @objc private func hallTicketCardTapped() {
        let hallTicketVC = HallticketpreviewVC()
        
        // Primary = next upcoming exam
        let primaryID = nextExamID ?? exams.first?.id ?? ""
        hallTicketVC.examID = primaryID
        
        // Fallbacks = all other exams (tried in order if primary has no hall ticket)
        hallTicketVC.candidateExamIDs = exams
            .compactMap { $0.id }
            .filter { !$0.isEmpty && $0 != primaryID }
        
        navigationController?.pushViewController(hallTicketVC, animated: true)
    }

    private func openExamDetail(examID: String?) {
        guard let id = examID, !id.isEmpty else { return }
        let detailVC = ExamscheduleVC()
        detailVC.examID = id
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Build Content Sections
    private func buildContent() {
        // Clear stack before rebuilding
        contentStackView.arrangedSubviews.forEach {
            contentStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        // Get configured strings from UserManager
        let studentName = UserManager.shared.resolvedStudentName
        let gradeSection = UserManager.shared.resolvedGradeSection
        let parentName = UserManager.shared.resolvedFatherName.isEmpty ? "Parent" : UserManager.shared.resolvedFatherName
        let studentFirstName = studentName.components(separatedBy: " ").first ?? "Student"
        let initials = getInitials(from: studentName)
        let rollNumber = UserManager.shared.resolvedStudentID
        
        let detailsString = "\(gradeSection)"
        
        // 1. Student Selector
        let studentSelector = createStudentSelector(initialsText: initials, studentName: studentName, details: detailsString)
        let studentWrapper = UIView()
        studentWrapper.backgroundColor = .white
        studentWrapper.addSubview(studentSelector)
        studentSelector.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            studentSelector.topAnchor.constraint(equalTo: studentWrapper.topAnchor, constant: 12),
            studentSelector.bottomAnchor.constraint(equalTo: studentWrapper.bottomAnchor, constant: -12),
            studentSelector.leadingAnchor.constraint(equalTo: studentWrapper.leadingAnchor, constant: 16),
            studentSelector.trailingAnchor.constraint(equalTo: studentWrapper.trailingAnchor, constant: -16)
        ])
        
        let fullWidthWrapper = UIView()
        fullWidthWrapper.addSubview(studentWrapper)
        studentWrapper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            studentWrapper.topAnchor.constraint(equalTo: fullWidthWrapper.topAnchor),
            studentWrapper.bottomAnchor.constraint(equalTo: fullWidthWrapper.bottomAnchor),
            studentWrapper.leadingAnchor.constraint(equalTo: fullWidthWrapper.leadingAnchor, constant: -16),
            studentWrapper.trailingAnchor.constraint(equalTo: fullWidthWrapper.trailingAnchor, constant: 16)
        ])
        contentStackView.addArrangedSubview(fullWidthWrapper)
        
        // 2. Greeting (✅ now uses live countdown text)
        let greetingView = createGreetingSection(parentName: parentName,
                                                 studentFirstName: studentFirstName,
                                                 event: greetingEventText())
        contentStackView.addArrangedSubview(greetingView)
        
        // 3. Hero Card (Next Examination) — ✅ API data
        let heroCard = createUpcomingExamHeroCard()
        contentStackView.addArrangedSubview(heroCard)
        
        // 4. Action Cards (Results & Hall Ticket)
        let actionCards = createActionCards()
        contentStackView.addArrangedSubview(actionCards)
        
        // 5. Exams List Section (API data)
        let examsSection = createExamsListSection(examsData: exams)
        contentStackView.addArrangedSubview(examsSection)
        
        // 6. Upcoming Papers Section — ✅ API data
        let upcomingSection = createUpcomingPapersSection()
        contentStackView.addArrangedSubview(upcomingSection)
    }
    
    // MARK: - Helper Methods
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ").filter { !$0.isEmpty }
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "ST"
    }
    
    // ✅ NEW: Days until the next paper
    private func daysUntilNextPaper() -> Int? {
        guard let raw = sortedSchedules.first?.examDate,
              let target = Self.apiDateFormatter.date(from: raw) else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        let d = Calendar.current.startOfDay(for: target)
        return Calendar.current.dateComponents([.day], from: today, to: d).day
    }
    
    // ✅ NEW: "upcoming exams." / "mid-term examination begins in 8 days."
    private func greetingEventText() -> String {
        guard let detail = examDetail else { return "upcoming exams." }
        let name = detail.name ?? "examination"
        if let days = daysUntilNextPaper() {
            if days > 1  { return "\(name) begins in \(days) days." }
            if days == 1 { return "\(name) begins tomorrow." }
            if days == 0 { return "\(name) begins today." }
        }
        return "\(name) schedule is ready."
    }
}

// MARK: - UI Builders (Extensions keep code clean)
extension ExamhomeVC {
    
    private func createStudentSelector(initialsText: String, studentName: String, details: String) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 12
        
        // Avatar
        let avatarView = UIView()
        avatarView.backgroundColor = Colors.badgeBlueBg
        avatarView.layer.cornerRadius = 20
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let initials = UILabel()
        initials.text = initialsText
        initials.font = .systemFont(ofSize: 14, weight: .bold)
        initials.textColor = Colors.primaryBlue
        initials.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(initials)
        NSLayoutConstraint.activate([
            initials.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            initials.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ])
        
        // Info
        let nameLabel = UILabel()
        nameLabel.text = studentName
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = Colors.textDark
        
        let detailsLabel = UILabel()
        detailsLabel.text = details
        detailsLabel.font = .systemFont(ofSize: 12, weight: .regular)
        detailsLabel.textColor = Colors.textGray
        
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, detailsLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 2
        
        // Icon
        let iconView = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down"))
        iconView.tintColor = Colors.textGray
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        
        container.addArrangedSubview(avatarView)
        container.addArrangedSubview(infoStack)
        container.addArrangedSubview(iconView)
        
        return container
    }
    
    private func createGreetingSection(parentName: String, studentFirstName: String, event: String) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 6
        
        let title = UILabel()
        title.text = "Good morning, \(parentName)"
        title.font = .systemFont(ofSize: 24, weight: .bold)
        title.textColor = Colors.textDark
        
        let subtitle = UILabel()
        subtitle.text = "\(studentFirstName)'s \(event)"
        subtitle.font = .systemFont(ofSize: 15, weight: .regular)
        subtitle.textColor = Colors.textGray
        subtitle.numberOfLines = 0
        
        container.addArrangedSubview(title)
        container.addArrangedSubview(subtitle)
        return container
    }
    
    // ✅ UPDATED: Hero card now renders API data
    private func createUpcomingExamHeroCard() -> UIView {
        let card = createBaseCard()
        
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        // ── Data resolution (API → fallbacks) ─────────────────────────────
        let nextExamItem = resolveNextExam(from: exams)
        
        let examName = examDetail?.name
            ?? nextExamItem?.name
            ?? (isDetailLoading || exams.isEmpty ? "Loading examination..." : "No examination")
        
        let examTypeName = examDetail?.examinationType?.name
            ?? nextExamItem?.examinationType?.name
            ?? "Examination"
        
        let startDate = examDetail?.startDate ?? nextExamItem?.startDate
        let endDate   = examDetail?.endDate   ?? nextExamItem?.endDate
        
        var rangeShort = "--"
        if let s = startDate, let e = endDate {
            let full = ExamDateHelper.rangeTitle(start: s, end: e)   // "Sep 21-23, 2026"
            rangeShort = full.components(separatedBy: ", ").first ?? full
        }
        
        let subjectCount = examDetail?.schedules?.count ?? 0
        let subjectsText = subjectCount > 0 ? "\(subjectCount) subjects" : "Subjects TBA"
        let subtitleText = "\(rangeShort) • \(subjectsText) • \(examTypeName)"
        
        let statusRaw = (examDetail?.status ?? nextExamItem?.status ?? "SCHEDULED")
        let statusText = statusRaw.replacingOccurrences(of: "_", with: " ").capitalized
        
        // Countdown
        var daysText = "--"
        var untilText = "Schedule pending"
        if let days = daysUntilNextPaper() {
            if days > 1       { daysText = "\(days) days" }
            else if days == 1 { daysText = "1 day" }
            else if days == 0 { daysText = "Today" }
            else              { daysText = "Completed" }
            
            if let subj = sortedSchedules.first?.subject?.name {
                untilText = days < 0 ? "last paper \(subj.capitalized)" : "until \(subj.capitalized)"
            } else {
                untilText = "until first paper"
            }
        }
        
        // ── Top Row (Icon + Text + Badge) ─────────────────────────────────
        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 8
        
        let calendarIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calendarIcon.tintColor = Colors.primaryBlue
        calendarIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        calendarIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        let nextLabel = UILabel()
        nextLabel.text = "NEXT EXAMINATION"
        nextLabel.font = .systemFont(ofSize: 12, weight: .bold)
        nextLabel.textColor = Colors.textGray
        
        let badge = createBadge(text: statusText, bg: Colors.badgeBlueBg, textCol: Colors.badgeBlueText)
        
        topRow.addArrangedSubview(calendarIcon)
        topRow.addArrangedSubview(nextLabel)
        topRow.addArrangedSubview(UIView()) // Spacer
        topRow.addArrangedSubview(badge)
        
        // Titles
        let titleStack = UIStackView()
        titleStack.axis = .vertical
        titleStack.spacing = 4
        
        let examTitle = UILabel()
        examTitle.text = examName
        examTitle.font = .systemFont(ofSize: 18, weight: .bold)
        examTitle.textColor = Colors.textDark
        examTitle.numberOfLines = 2
        
        let examDetails = UILabel()
        examDetails.text = subtitleText
        examDetails.font = .systemFont(ofSize: 13, weight: .regular)
        examDetails.textColor = Colors.textGray
        examDetails.numberOfLines = 2
        
        titleStack.addArrangedSubview(examTitle)
        titleStack.addArrangedSubview(examDetails)
        
        // Bottom Row (Countdown + Button)
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        
        let countdownStack = UIStackView()
        countdownStack.axis = .vertical
        
        let daysLabel = UILabel()
        daysLabel.text = daysText
        daysLabel.font = .systemFont(ofSize: 20, weight: .bold)
        daysLabel.textColor = Colors.textDark
        
        let untilLabel = UILabel()
        untilLabel.text = untilText
        untilLabel.font = .systemFont(ofSize: 12, weight: .regular)
        untilLabel.textColor = Colors.textGray
        
        countdownStack.addArrangedSubview(daysLabel)
        countdownStack.addArrangedSubview(untilLabel)
        
        let viewBtn = UIButton(type: .system)
        viewBtn.setTitle("View details", for: .normal)
        viewBtn.setTitleColor(.white, for: .normal)
        viewBtn.backgroundColor = Colors.buttonDark
        viewBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        viewBtn.layer.cornerRadius = 8
        viewBtn.translatesAutoresizingMaskIntoConstraints = false
        viewBtn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        // ✅ UPDATED: navigate to ExamdetailsoverviewVC
        viewBtn.addTarget(self, action: #selector(openExamDetailsOverview), for: .touchUpInside)
        
        bottomRow.addArrangedSubview(countdownStack)
        bottomRow.addArrangedSubview(UIView()) // Spacer
        bottomRow.addArrangedSubview(viewBtn)
        
        mainStack.addArrangedSubview(topRow)
        mainStack.addArrangedSubview(titleStack)
        mainStack.addArrangedSubview(bottomRow)
        
        return card
    }
    
    private func createActionCards() -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        
        let card1 = createSmallCard(icon: "chart.bar.fill", badge: "A2", badgeBg: Colors.badgeGreenBg, badgeText: Colors.badgeGreenText, title: "Go to results", subtitle: "View the available result")
        let card2 = createSmallCard(icon: "doc.text.fill", badge: "Ready", badgeBg: Colors.badgeGreenBg, badgeText: Colors.badgeGreenText, title: "Hall ticket", subtitle: "HT-2026-9023")
        
        // ✅ ADDED TAP GESTURE AND INTERACTION FOR RESULTS CARD
        card1.isUserInteractionEnabled = true
        let resultsTapGesture = UITapGestureRecognizer(target: self, action: #selector(resultsCardTapped))
        card1.addGestureRecognizer(resultsTapGesture)
        
        // ✅ ADDED TAP GESTURE AND INTERACTION FOR HALL TICKET CARD
        card2.isUserInteractionEnabled = true
        let hallTicketTapGesture = UITapGestureRecognizer(target: self, action: #selector(hallTicketCardTapped))
        card2.addGestureRecognizer(hallTicketTapGesture)
        
        stack.addArrangedSubview(card1)
        stack.addArrangedSubview(card2)
        return stack
    }
    
    private func createExamsListSection(examsData: [ExamItem]) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        
        // ✅ UPDATED: Passes #selector(didTapSeeAllExams) to navigate to the new history view
        let header = createSectionHeader(title: "Exams", actionTitle: "See all", action: #selector(didTapSeeAllExams))
        container.addArrangedSubview(header)
        
        let listStack = UIStackView()
        listStack.axis = .vertical
        listStack.spacing = 10
        
        if examsData.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Loading upcoming exams..."
            emptyLabel.font = .systemFont(ofSize: 14, weight: .medium)
            emptyLabel.textColor = Colors.textGray
            emptyLabel.textAlignment = .center
            emptyLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            listStack.addArrangedSubview(emptyLabel)
        } else {
            // Map the API Response items
            for (index, exam) in examsData.enumerated() {
                let examTitle = exam.name ?? "Exam"
                
                // Construct a date string safely
                var dateStr = "Scheduled"
                if let start = exam.startDate, let end = exam.endDate {
                    dateStr = start == end ? start : "\(start) to \(end)"
                } else if let start = exam.startDate {
                    dateStr = start
                }
                
                let examStatus = exam.status?.capitalized ?? "Scheduled"
                
                let item = createExamListItem(title: examTitle, date: dateStr, statusBadge: examStatus)
                
                // ✅ Make item tappable → navigates to Exam Details screen
                item.tag = index
                item.isUserInteractionEnabled = true
                item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(examItemTapped(_:))))
                
                listStack.addArrangedSubview(item)
            }
        }
        
        container.addArrangedSubview(listStack)
        return container
    }
    
    // ✅ UPDATED: Upcoming papers now built from exam detail API
    private func createUpcomingPapersSection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        
        // ✅ UPDATED: Passes #selector(openNextExamDetail) to navigate to full schedule
        let header = createSectionHeader(title: "Upcoming papers", actionTitle: "Full schedule", action: #selector(openNextExamDetail))
        container.addArrangedSubview(header)
        
        // Card wrapping the list
        let card = createBaseCard()
        let listStack = UIStackView()
        listStack.axis = .vertical
        listStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(listStack)
        
        NSLayoutConstraint.activate([
            listStack.topAnchor.constraint(equalTo: card.topAnchor),
            listStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            listStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            listStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        
        let papers = Array(sortedSchedules.prefix(3))
        
        if papers.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = isDetailLoading ? "Loading upcoming papers..." : "No upcoming papers."
            emptyLabel.font = .systemFont(ofSize: 14, weight: .medium)
            emptyLabel.textColor = Colors.textGray
            emptyLabel.textAlignment = .center
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            listStack.addArrangedSubview(emptyLabel)
            emptyLabel.heightAnchor.constraint(equalToConstant: 72).isActive = true
        } else {
            for (index, schedule) in papers.enumerated() {
                let d = ExamDateHelper.components(from: schedule.examDate)
                let timeText = ExamDateHelper.displayTime(schedule.startTime)
                
                // "Room 105 • 09:30 AM"  /  "Max marks 100 • 09:30 AM"
                var leading = ""
                if let r = schedule.roomNumber?.trimmingCharacters(in: .whitespaces), !r.isEmpty {
                    leading = "Room \(r)"
                } else if let m = schedule.maximumMarks, !m.isEmpty {
                    leading = "Max marks \(ExamDateHelper.trimDecimals(m))"
                }
                let detailsText = leading.isEmpty ? timeText : "\(leading) • \(timeText)"
                
                let row = createPaperRow(
                    day: d.day,
                    date: d.dayNumber,
                    subject: schedule.subject?.name?.capitalized ?? "Subject",
                    details: detailsText,
                    showSeparator: index < papers.count - 1
                )
                
                // ✅ NEW: tap → open full schedule
                row.isUserInteractionEnabled = true
                row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(paperRowTapped(_:))))
                
                listStack.addArrangedSubview(row)
            }
        }
        
        container.addArrangedSubview(card)
        return container
    }
    
    // MARK: - Helper UI Builders
    private func createBaseCard() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.cardBorder.cgColor
        return view
    }
    
    private func createBadge(text: String, bg: UIColor, textCol: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = bg
        view.layer.cornerRadius = 10
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = textCol
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        return view
    }
    
    private func createSmallCard(icon: String, badge: String, badgeBg: UIColor, badgeText: UIColor, title: String, subtitle: String) -> UIView {
        let card = createBaseCard()
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        // Top row (icon + badge)
        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .center
        
        let iconBg = UIView()
        iconBg.backgroundColor = Colors.badgeBlueBg
        iconBg.layer.cornerRadius = 8
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 32),
            iconBg.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = Colors.primaryBlue
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(img)
        NSLayoutConstraint.activate([
            img.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            img.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            img.widthAnchor.constraint(equalToConstant: 16),
            img.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        let badgeView = createBadge(text: badge, bg: badgeBg, textCol: badgeText)
        
        topRow.addArrangedSubview(iconBg)
        topRow.addArrangedSubview(UIView())
        topRow.addArrangedSubview(badgeView)
        
        // Text
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 15, weight: .bold)
        titleLbl.textColor = Colors.textDark
        
        let subLbl = UILabel()
        subLbl.text = subtitle
        subLbl.font = .systemFont(ofSize: 11, weight: .regular)
        subLbl.textColor = Colors.textGray
        subLbl.numberOfLines = 2
        
        textStack.addArrangedSubview(titleLbl)
        textStack.addArrangedSubview(subLbl)
        
        stack.addArrangedSubview(topRow)
        stack.addArrangedSubview(textStack)
        
        return card
    }
    
    // ✅ UPDATED: Added target action dynamic injection
    private func createSectionHeader(title: String, actionTitle: String, action: Selector) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 18, weight: .bold)
        titleLbl.textColor = Colors.textDark
        
        let actionBtn = UIButton(type: .system)
        actionBtn.setTitle(actionTitle, for: .normal)
        actionBtn.setTitleColor(Colors.primaryBlue, for: .normal)
        actionBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        // ✅ NEW: Uses the passed-in selector
        actionBtn.addTarget(self, action: action, for: .touchUpInside)
        
        stack.addArrangedSubview(titleLbl)
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(actionBtn)
        return stack
    }
    
    private func createExamListItem(title: String, date: String, statusBadge: String) -> UIView {
        let card = createBaseCard()
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        // Icon
        let iconBg = UIView()
        iconBg.backgroundColor = Colors.badgeBlueBg
        iconBg.layer.cornerRadius = 8
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let img = UIImageView(image: UIImage(systemName: "doc.plaintext.fill"))
        img.tintColor = Colors.primaryBlue
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(img)
        NSLayoutConstraint.activate([
            img.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            img.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            img.widthAnchor.constraint(equalToConstant: 20),
            img.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Titles
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 15, weight: .bold)
        titleLbl.textColor = Colors.textDark
        
        let dateLbl = UILabel()
        dateLbl.text = date
        dateLbl.font = .systemFont(ofSize: 12, weight: .regular)
        dateLbl.textColor = Colors.textGray
        
        textStack.addArrangedSubview(titleLbl)
        textStack.addArrangedSubview(dateLbl)
        
        // Dynamic Badge Styling based on text
        let isScheduled = statusBadge.lowercased().contains("scheduled")
        let bgCol = isScheduled ? Colors.badgeGreenBg : Colors.badgeBlueBg
        let txtCol = isScheduled ? Colors.badgeGreenText : Colors.badgeBlueText
        let badge = createBadge(text: statusBadge, bg: bgCol, textCol: txtCol)
        
        stack.addArrangedSubview(iconBg)
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(UIView()) // Push badge right
        stack.addArrangedSubview(badge)
        
        return card
    }
    
    private func createPaperRow(day: String, date: String, subject: String, details: String, showSeparator: Bool) -> UIView {
        let container = UIView()
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        // Date Box
        let dateBox = UIView()
        dateBox.backgroundColor = Colors.badgeBlueBg
        dateBox.layer.cornerRadius = 8
        dateBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateBox.widthAnchor.constraint(equalToConstant: 44),
            dateBox.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let dateStack = UIStackView()
        dateStack.axis = .vertical
        dateStack.alignment = .center
        dateStack.translatesAutoresizingMaskIntoConstraints = false
        
        let dayLbl = UILabel()
        dayLbl.text = day
        dayLbl.font = .systemFont(ofSize: 10, weight: .bold)
        dayLbl.textColor = Colors.primaryBlue
        
        let dateLbl = UILabel()
        dateLbl.text = date
        dateLbl.font = .systemFont(ofSize: 18, weight: .bold)
        dateLbl.textColor = Colors.textDark
        
        dateStack.addArrangedSubview(dayLbl)
        dateStack.addArrangedSubview(dateLbl)
        dateBox.addSubview(dateStack)
        NSLayoutConstraint.activate([
            dateStack.centerXAnchor.constraint(equalTo: dateBox.centerXAnchor),
            dateStack.centerYAnchor.constraint(equalTo: dateBox.centerYAnchor)
        ])
        
        // Titles
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let subjLbl = UILabel()
        subjLbl.text = subject
        subjLbl.font = .systemFont(ofSize: 15, weight: .bold)
        subjLbl.textColor = Colors.textDark
        
        let detLbl = UILabel()
        detLbl.text = details
        detLbl.font = .systemFont(ofSize: 12, weight: .regular)
        detLbl.textColor = Colors.textGray
        
        textStack.addArrangedSubview(subjLbl)
        textStack.addArrangedSubview(detLbl)
        
        // Chevron
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 12).isActive = true
        
        stack.addArrangedSubview(dateBox)
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(chevron)
        
        if showSeparator {
            let sep = UIView()
            sep.backgroundColor = Colors.cardBorder
            sep.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(sep)
            NSLayoutConstraint.activate([
                sep.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                sep.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                sep.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                sep.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
        
        return container
    }
}

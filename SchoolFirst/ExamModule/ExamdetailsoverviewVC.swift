//
//  ExamdetailsoverviewVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit

// MARK: - UI Models
struct ExamChecklistItem {
    let title: String
    let trailingText: String
    let isDone: Bool
    let isPending: Bool
}

struct ExamSubjectItem {
    let name: String
    let code: String
    let dateTime: String
    let maxMarks: Int
    let passMarks: Int
    let status: String   // Scheduled / Ready / Draft / Completed
}

class ExamdetailsoverviewVC: UIViewController {

    // MARK: - API Data (passed from ExamhomeVC)
    var examDetail: ExamDetail?
    var examID: String?

    // MARK: - Derived Data (from API)
    private var examTitle: String {
        examDetail?.name ?? "Examination"
    }

    private var examSubtitle: String {
        var parts: [String] = []
        let grade = examDetail?.student?.grade?.name ?? ""
        let section = examDetail?.student?.section?.name ?? ""
        if !grade.isEmpty || !section.isEmpty {
            parts.append([grade, section].filter { !$0.isEmpty }.joined(separator: "-"))
        }
        if let type = examDetail?.examinationType?.name, !type.isEmpty {
            parts.append(type)
        }
        let range = shortRange(examDetail?.startDate, examDetail?.endDate)
        if !range.isEmpty { parts.append(range) }
        return parts.isEmpty ? "—" : parts.joined(separator: " · ")
    }

    private var examStatus: String {
        let raw = (examDetail?.status ?? "UPCOMING")
            .replacingOccurrences(of: "_", with: " ")
        return raw.capitalized
    }

    // No checklist data in API → derived from available data
    private var checklist: [ExamChecklistItem] {
        let hasSchedule = !(examDetail?.schedules ?? []).isEmpty
        return [
            ExamChecklistItem(title: "Schedule reviewed",
                              trailingText: hasSchedule ? "Today" : "Pending",
                              isDone: hasSchedule, isPending: !hasSchedule),
            ExamChecklistItem(title: "Hall ticket downloaded",
                              trailingText: shortDate(examDetail?.reportingDate) ?? "Pending",
                              isDone: examDetail?.reportingDate != nil,
                              isPending: examDetail?.reportingDate == nil),
            ExamChecklistItem(title: "Confirm transport for exam week",
                              trailingText: "Pending", isDone: false, isPending: true)
        ]
    }

    private var subjects: [ExamSubjectItem] {
        let schedules = examDetail?.schedules ?? []
        let examStatusRaw = (examDetail?.status ?? "").uppercased()
        let today = Calendar.current.startOfDay(for: Date())

        return schedules
            .sorted { (Self.apiDate.date(from: $0.examDate ?? "") ?? .distantFuture) <
                      (Self.apiDate.date(from: $1.examDate ?? "") ?? .distantFuture) }
            .map { s in
                var dateTime = shortDate(s.examDate) ?? "TBA"
                if let t = displayTime(s.startTime) { dateTime += " · \(t)" }

                let status: String
                if examStatusRaw == "DRAFT" {
                    status = "Draft"
                } else if let d = Self.apiDate.date(from: s.examDate ?? ""), d < today {
                    status = "Completed"
                } else if examStatusRaw == "PUBLISHED" || examStatusRaw == "READY" {
                    status = "Ready"
                } else {
                    status = "Scheduled"
                }

                return ExamSubjectItem(
                    name: s.subject?.name?.capitalized ?? "Subject",
                    code: s.roomNumber ?? "",
                    dateTime: dateTime,
                    maxMarks: Int(Double(s.maximumMarks ?? "") ?? 0),
                    passMarks: Int(Double(s.passingMarks ?? "") ?? 0),
                    status: status
                )
            }
    }

    private var schoolName: String { examDetail?.school?.name ?? "School" }
    private var schoolPhone: String { examDetail?.school?.phoneNumber ?? "" }

    // MARK: - Date Helpers
    private static let apiDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func shortDate(_ raw: String?) -> String? {          // "Sep 17"
        guard let raw = raw, let d = Self.apiDate.date(from: raw) else { return nil }
        let f = DateFormatter(); f.dateFormat = "MMM d"
        return f.string(from: d)
    }

    private func longDate(_ raw: String?) -> String {            // "September 10, 2026"
        guard let raw = raw, let d = Self.apiDate.date(from: raw) else { return "—" }
        let f = DateFormatter(); f.dateFormat = "MMMM d, yyyy"
        return f.string(from: d)
    }

    private func shortRange(_ start: String?, _ end: String?) -> String {   // "Aug 25–30"
        guard let s = start, let sd = Self.apiDate.date(from: s) else { return "" }
        let f = DateFormatter(); f.dateFormat = "MMM d"
        guard let e = end, let ed = Self.apiDate.date(from: e), ed != sd else { return f.string(from: sd) }
        let sameMonth = Calendar.current.isDate(sd, equalTo: ed, toGranularity: .month)
        let dayOnly = DateFormatter(); dayOnly.dateFormat = "d"
        return sameMonth ? "\(f.string(from: sd))–\(dayOnly.string(from: ed))"
                         : "\(f.string(from: sd))–\(f.string(from: ed))"
    }

    private func fullRange(_ start: String?, _ end: String?) -> String {    // "Aug 25–30, 2026"
        let r = shortRange(start, end)
        guard !r.isEmpty, let s = start, let sd = Self.apiDate.date(from: s) else { return "—" }
        let y = DateFormatter(); y.dateFormat = "yyyy"
        return "\(r), \(y.string(from: sd))"
    }

    private func displayTime(_ raw: String?) -> String? {        // "09:00:00" → "09:00 AM"
        guard let raw = raw, !raw.isEmpty else { return nil }
        let inF = DateFormatter(); inF.locale = Locale(identifier: "en_US_POSIX")
        for fmt in ["HH:mm:ss", "HH:mm"] {
            inF.dateFormat = fmt
            if let d = inF.date(from: raw) {
                let out = DateFormatter(); out.dateFormat = "hh:mm a"
                return out.string(from: d)
            }
        }
        return raw
    }

    private func passingCriteriaText() -> String {
        if let s = examDetail?.schedules?.first,
           let max = Double(s.maximumMarks ?? ""), max > 0,
           let pass = Double(s.passingMarks ?? "") {
            let pct = Int((pass / max * 100).rounded())
            return "Minimum \(pct)% marks required per subject to pass."
        }
        if let desc = examDetail?.description, !desc.isEmpty { return desc }
        return "Passing criteria will be shared by the school."
    }

    // MARK: - Colors
    private let navy = UIColor(red: 0.07, green: 0.20, blue: 0.47, alpha: 1)
    private let bgColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
    private let textDark = UIColor(red: 0.10, green: 0.14, blue: 0.24, alpha: 1)
    private let textGray = UIColor(red: 0.45, green: 0.50, blue: 0.58, alpha: 1)
    private let borderGray = UIColor(red: 0.89, green: 0.91, blue: 0.94, alpha: 1)

    // MARK: - Views
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        buildScreen()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Layout
    private func setupLayout() {
        let header = makeHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = bgColor
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            // Header is pinned to the top with exact height of 100 as per Figma
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 100),

            // ScrollView cleanly starts immediately below the 100pt header
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Cards sit cleanly on the gray background below the header
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    private func buildScreen() {
        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        contentStack.addArrangedSubview(makeExamCard())
        contentStack.addArrangedSubview(makeReadinessSection())
        contentStack.addArrangedSubview(makeExamInfoSection())
        contentStack.addArrangedSubview(makeSubjectsSection())
        contentStack.addArrangedSubview(makeFooterCard())
    }

    // MARK: - Header
    private func makeHeader() -> UIView {
        let header = UIView()
        header.backgroundColor = navy

        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        back.tintColor = .white
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        let title = UILabel()
        title.text = "Exam Details"
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.textColor = .white

        let subtitle = UILabel()
        subtitle.text = "School moments, all in one place"
        subtitle.font = .systemFont(ofSize: 11)
        subtitle.textColor = UIColor.white.withAlphaComponent(0.75)

        let titles = UIStackView(arrangedSubviews: [title, subtitle])
        titles.axis = .vertical
        titles.spacing = 2

        let bell = UIButton(type: .system)
        bell.setImage(UIImage(systemName: "bell"), for: .normal)
        bell.tintColor = .white

        [back, titles, bell].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            header.addSubview($0)
        }

        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            back.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -12),
            back.widthAnchor.constraint(equalToConstant: 32),
            back.heightAnchor.constraint(equalToConstant: 32),

            titles.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 8),
            titles.centerYAnchor.constraint(equalTo: back.centerYAnchor),

            bell.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            bell.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            bell.widthAnchor.constraint(equalToConstant: 32),
            bell.heightAnchor.constraint(equalToConstant: 32)
        ])
        return header
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Exam Card
    private func makeExamCard() -> UIView {
        let card = makeCard()

        let icon = makeIconBox(systemName: "calendar", tint: navy, bg: navy.withAlphaComponent(0.08))

        let title = makeLabel(examTitle, size: 17, weight: .bold, color: textDark)
        title.numberOfLines = 2
        let sub = makeLabel(examSubtitle, size: 11, color: textGray)
        sub.numberOfLines = 2

        let titles = UIStackView(arrangedSubviews: [title, sub])
        titles.axis = .vertical
        titles.spacing = 3

        let chip = makePill(examStatus, textColor: navy, bg: navy.withAlphaComponent(0.1))
        chip.setContentHuggingPriority(.required, for: .horizontal)
        chip.setContentCompressionResistancePriority(.required, for: .horizontal)

        let top = UIStackView(arrangedSubviews: [icon, titles, chip])
        top.axis = .horizontal
        top.alignment = .top
        top.spacing = 10

        let hallTicket = makeButton(title: "Hall ticket", systemName: "ticket", filled: true)
        hallTicket.addTarget(self, action: #selector(didTapHallTicket), for: .touchUpInside)
        let share = makeButton(title: "Share", systemName: "square.and.arrow.up", filled: false)
        share.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)

        let buttons = UIStackView(arrangedSubviews: [hallTicket, share])
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 10

        let stack = UIStackView(arrangedSubviews: [top, buttons])
        stack.axis = .vertical
        stack.spacing = 14
        embed(stack, in: card, inset: 14)
        return card
    }

    @objc private func didTapHallTicket() {
        let hallTicketVC = HallticketpreviewVC()
        hallTicketVC.examID = examID ?? examDetail?.id ?? ""
        navigationController?.pushViewController(hallTicketVC, animated: true)
    }

    @objc private func didTapShare() {
        let text = "\(examTitle)\n\(examSubtitle)\nDates: \(fullRange(examDetail?.startDate, examDetail?.endDate))"
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(vc, animated: true)
    }

    // MARK: - Exam Readiness
    private func makeReadinessSection() -> UIView {
        let section = UIStackView()
        section.axis = .vertical
        section.spacing = 8

        let eyebrow = makeLabel("PARENT CHECKLIST", size: 10, weight: .semibold, color: textGray)
        let heading = makeLabel("Exam readiness", size: 15, weight: .bold, color: textDark)
        section.addArrangedSubview(eyebrow)
        section.addArrangedSubview(heading)

        let card = makeCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12

        let items = checklist
        let done = items.filter { $0.isDone }.count
        let percent = Int((Double(done) / Double(max(items.count, 1))) * 100)

        let progressTitle = makeLabel("\(done) of \(items.count) actions complete", size: 13, weight: .semibold, color: textDark)
        let percentLabel = makeLabel("\(percent)%", size: 13, weight: .bold, color: navy)
        let progressRow = UIStackView(arrangedSubviews: [progressTitle, UIView(), percentLabel])
        progressRow.axis = .horizontal

        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = navy
        progress.trackTintColor = borderGray
        progress.progress = Float(percent) / 100
        progress.layer.cornerRadius = 3
        progress.clipsToBounds = true
        progress.heightAnchor.constraint(equalToConstant: 6).isActive = true

        inner.addArrangedSubview(progressRow)
        inner.addArrangedSubview(progress)
        inner.addArrangedSubview(makeSeparator())

        for item in items {
            inner.addArrangedSubview(makeChecklistRow(item))
        }

        embed(inner, in: card, inset: 14)
        section.addArrangedSubview(card)
        section.setCustomSpacing(10, after: heading)
        return section
    }

    private func makeChecklistRow(_ item: ExamChecklistItem) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: item.isDone ? "checkmark.circle.fill" : "circle"))
        icon.tintColor = item.isDone ? navy : UIColor.systemOrange
        icon.contentMode = .scaleAspectFit
        icon.widthAnchor.constraint(equalToConstant: 18).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 18).isActive = true

        let title = makeLabel(item.title, size: 13, color: textDark)

        let trailing: UIView
        if item.isPending {
            trailing = makePill(item.trailingText,
                                textColor: UIColor(red: 0.70, green: 0.42, blue: 0.0, alpha: 1),
                                bg: UIColor(red: 1.0, green: 0.93, blue: 0.78, alpha: 1))
        } else {
            trailing = makeLabel(item.trailingText, size: 11, color: textGray)
        }
        trailing.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [icon, title, trailing])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        return row
    }

    // MARK: - Exam Information
    private func makeExamInfoSection() -> UIView {
        let section = UIStackView()
        section.axis = .vertical
        section.spacing = 10

        section.addArrangedSubview(makeLabel("Exam information", size: 15, weight: .bold, color: textDark))

        let card = makeCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 14

        let subjectCount = examDetail?.schedules?.count ?? 0
        let totalSubjects = subjectCount > 0 ? "\(subjectCount) Subjects" : "—"

        inner.addArrangedSubview(makeInfoRow(
            left: ("EXAM TYPE", examDetail?.examinationType?.name ?? "—"),
            right: ("TERM", examDetail?.academicYear?.name ?? "—")))
        inner.addArrangedSubview(makeInfoRow(
            left: ("EXAM DATES", fullRange(examDetail?.startDate, examDetail?.endDate)),
            right: ("TOTAL SUBJECTS", totalSubjects)))
        inner.addArrangedSubview(makeInfoRow(
            left: ("EXPECTED RESULT", longDate(examDetail?.resultDate)),
            right: ("REPORTING DATE", longDate(examDetail?.reportingDate))))

        // Passing criteria box
        let box = UIView()
        box.backgroundColor = bgColor
        box.layer.cornerRadius = 10
        let boxStack = UIStackView(arrangedSubviews: [
            makeLabel("PASSING CRITERIA", size: 10, weight: .semibold, color: textGray),
            makeLabel(passingCriteriaText(), size: 12, color: textDark)
        ])
        boxStack.axis = .vertical
        boxStack.spacing = 4
        boxStack.arrangedSubviews.forEach { ($0 as? UILabel)?.numberOfLines = 0 }
        embed(boxStack, in: box, inset: 12)
        inner.addArrangedSubview(box)

        embed(inner, in: card, inset: 14)
        section.addArrangedSubview(card)
        return section
    }

    private func makeInfoRow(left: (String, String), right: (String, String)) -> UIView {
        let row = UIStackView(arrangedSubviews: [makeInfoItem(left.0, left.1), makeInfoItem(right.0, right.1)])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.alignment = .top
        row.spacing = 12
        return row
    }

    private func makeInfoItem(_ label: String, _ value: String) -> UIView {
        let l = makeLabel(label, size: 10, weight: .semibold, color: textGray)
        let v = makeLabel(value, size: 13, weight: .semibold, color: textDark)
        v.numberOfLines = 0
        let s = UIStackView(arrangedSubviews: [l, v])
        s.axis = .vertical
        s.spacing = 3
        return s
    }

    // MARK: - Subjects & Status
    private func makeSubjectsSection() -> UIView {
        let section = UIStackView()
        section.axis = .vertical
        section.spacing = 10

        let heading = makeLabel("Subjects & status", size: 15, weight: .bold, color: textDark)
        let viewSchedule = UIButton(type: .system)
        viewSchedule.setTitle("View schedule", for: .normal)
        viewSchedule.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        viewSchedule.setTitleColor(navy, for: .normal)
        viewSchedule.addTarget(self, action: #selector(didTapViewSchedule), for: .touchUpInside)

        let headRow = UIStackView(arrangedSubviews: [heading, UIView(), viewSchedule])
        headRow.axis = .horizontal
        headRow.alignment = .center
        section.addArrangedSubview(headRow)

        let list = subjects
        if list.isEmpty {
            let card = makeCard()
            let empty = makeLabel("No subjects scheduled yet.", size: 13, color: textGray)
            empty.textAlignment = .center
            embed(empty, in: card, inset: 16)
            section.addArrangedSubview(card)
        } else {
            for subject in list {
                section.addArrangedSubview(makeSubjectRow(subject))
            }
        }
        return section
    }

    @objc private func didTapViewSchedule() {
        guard let id = examID ?? examDetail?.id, !id.isEmpty else { return }
        let scheduleVC = ExamscheduleVC()
        scheduleVC.examID = id
        navigationController?.pushViewController(scheduleVC, animated: true)
    }

    private func makeSubjectRow(_ s: ExamSubjectItem) -> UIView {
        let card = makeCard()

        let barColor: UIColor
        let pillText: UIColor
        let pillBg: UIColor
        switch s.status {
        case "Ready", "Completed":
            barColor = UIColor(red: 0.13, green: 0.70, blue: 0.40, alpha: 1)
            pillText = UIColor(red: 0.03, green: 0.45, blue: 0.27, alpha: 1)
            pillBg = UIColor(red: 0.82, green: 0.96, blue: 0.88, alpha: 1)
        case "Draft":
            barColor = UIColor.systemOrange
            pillText = textGray
            pillBg = borderGray
        default:
            barColor = navy
            pillText = navy
            pillBg = navy.withAlphaComponent(0.1)
        }

        let bar = UIView()
        bar.backgroundColor = barColor
        bar.layer.cornerRadius = 2
        bar.widthAnchor.constraint(equalToConstant: 4).isActive = true

        let nameText = s.code.isEmpty ? s.name : "\(s.name) (Room \(s.code))"
        let name = makeLabel(nameText, size: 13, weight: .bold, color: textDark)
        name.numberOfLines = 2
        let date = makeLabel(s.dateTime, size: 11, color: textGray)
        let left = UIStackView(arrangedSubviews: [name, date])
        left.axis = .vertical
        left.spacing = 3

        let marksText = s.maxMarks > 0 ? "\(s.maxMarks) / \(s.passMarks)" : "—"
        let marks = makeLabel(marksText, size: 12, weight: .semibold, color: textDark)
        marks.textAlignment = .right
        let pill = makePill(s.status, textColor: pillText, bg: pillBg)
        let right = UIStackView(arrangedSubviews: [marks, pill])
        right.axis = .vertical
        right.alignment = .trailing
        right.spacing = 4
        right.setContentHuggingPriority(.required, for: .horizontal)
        right.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [bar, left, right])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        embed(row, in: card, inset: 12)
        return card
    }

    // MARK: - Footer
    private func makeFooterCard() -> UIView {
        let card = makeCard()
        let icon = makeIconBox(systemName: "building.2", tint: navy, bg: navy.withAlphaComponent(0.08))
        let name = makeLabel(schoolName, size: 13, weight: .bold, color: textDark)
        name.numberOfLines = 2
        let contactText = schoolPhone.isEmpty ? "Exam Office" : "Exam Office · \(schoolPhone)"
        let contact = makeLabel(contactText, size: 11, color: textGray)
        let texts = UIStackView(arrangedSubviews: [name, contact])
        texts.axis = .vertical
        texts.spacing = 3

        let phone = UIButton(type: .system)
        phone.setImage(UIImage(systemName: "phone"), for: .normal)
        phone.tintColor = navy
        phone.isHidden = schoolPhone.isEmpty
        phone.addTarget(self, action: #selector(didTapCall), for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [icon, texts, phone])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        embed(row, in: card, inset: 14)
        return card
    }

    @objc private func didTapCall() {
        let digits = schoolPhone.filter { "+0123456789".contains($0) }
        guard !digits.isEmpty, let url = URL(string: "tel://\(digits)") else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Helpers
    private func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = borderGray.cgColor
        return v
    }

    private func embed(_ child: UIView, in parent: UIView, inset: CGFloat) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: inset),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -inset),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -inset)
        ])
    }

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = color
        return l
    }

    private func makePill(_ text: String, textColor: UIColor, bg: UIColor) -> UIView {
        let wrap = UIView()
        wrap.backgroundColor = bg
        wrap.layer.cornerRadius = 10
        let l = makeLabel(text, size: 10, weight: .semibold, color: textColor)
        l.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 4),
            l.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -4),
            l.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 10),
            l.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -10)
        ])
        return wrap
    }

    private func makeIconBox(systemName: String, tint: UIColor, bg: UIColor) -> UIView {
        let box = UIView()
        box.backgroundColor = bg
        box.layer.cornerRadius = 10
        box.widthAnchor.constraint(equalToConstant: 40).isActive = true
        box.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let iv = UIImageView(image: UIImage(systemName: systemName))
        iv.tintColor = tint
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 20),
            iv.heightAnchor.constraint(equalToConstant: 20)
        ])
        return box
    }

    private func makeButton(title: String, systemName: String, filled: Bool) -> UIButton {
        let b = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: systemName)
        config.imagePadding = 6
        config.baseForegroundColor = filled ? .white : textDark
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 13, weight: .semibold)]))
        b.configuration = config
        b.backgroundColor = filled ? navy : .white
        b.layer.cornerRadius = 10
        b.layer.borderWidth = filled ? 0 : 1
        b.layer.borderColor = borderGray.cgColor
        b.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return b
    }

    private func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = borderGray
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }
}

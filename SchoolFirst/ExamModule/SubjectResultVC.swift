//
//  SubjectResultVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI

// MARK: - UI Models (Kept for backward compatibility / mock)
struct SubjectDetailModel {
    let subjectName: String
    let subjectCode: String
    let examName: String
    let marksObtained: Int
    let maxMarks: Int
    let grade: String
    let gradeDescription: String
    let gradeRange: String
    let comparisonText: String
    
    let theoryMarks: Int
    let theoryMax: Int
    let theoryDuration: String
    
    let internalMarks: Int
    let internalMax: Int
    let internalDesc: String
    
    let passingMarks: Int
    
    let classAverage: String
    let classRank: String
    let rankSubtitle: String
    let highestScore: String
    let lowestScore: String
    let passRate: String
    
    let teacherName: String
    let teacherRole: String
    let teacherFeedback: String
    let tags: [FeedbackTag]
}

struct FeedbackTag: Identifiable {
    let id = UUID()
    let text: String
    let isPositive: Bool
}

// MARK: - UIViewController Wrapper
class SubjectResultVC: UIViewController {
    
    // Passed from ExamresultVC
    var subjectItem: ExamResultSubjectItem?
    var resultDetail: ExamResultDetailData?
    
    // Optional: Still support old model
    var subjectDetail: SubjectDetailModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupSwiftUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupSwiftUI() {
        // Build model from API data if available
        let model: SubjectDetailModel
        if let item = subjectItem {
            model = buildModelFromAPI(subject: item, detail: resultDetail)
        } else {
            model = subjectDetail ?? SubjectResultDetailView.mockData
        }
        
        let swiftUIView = SubjectResultDetailView(
            data: model,
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
    
    // MARK: - Build SubjectDetailModel from API
    private func buildModelFromAPI(subject: ExamResultSubjectItem, detail: ExamResultDetailData?) -> SubjectDetailModel {
        
        let subjectName = subject.subject?.name?.capitalized ?? "Subject"
        let subjectCode = subject.subject?.id ?? "—"
        let examName = detail?.examination?.name ?? "Examination"
        
        let marksObtained = subject.marksObtainedInt
        let maxMarks = subject.maxMarksInt
        let grade = subject.grade ?? "—"
        
        // Grade description based on grade letter
        let gradeDescription = gradeDescription(for: grade)
        let gradeRange = gradeRange(for: grade)
        
        // Comparison text (placeholder since class average isn't in API, you can enhance later)
        let percentage = maxMarks > 0 ? (Double(marksObtained) / Double(maxMarks)) * 100.0 : 0.0
        let comparisonText = String(format: "Scored %.1f%% in this subject", percentage)
        
        // Theory & Internal
        let externalMarks = Int(Double(subject.externalMarks ?? "0") ?? 0)
        let internalMarks = Int(Double(subject.internalMarks ?? "0") ?? 0)
        let practicalMarks = Int(Double(subject.practicalMarks ?? "0") ?? 0)
        
        // Approximate max distribution (theory=80, internal=20 if nothing else) - fallback logic
        let theoryMax: Int
        let internalMax: Int
        if externalMarks > 0 || internalMarks > 0 {
            // Use ratio from marks or default split
            theoryMax = max(externalMarks, Int(Double(maxMarks) * 0.8))
            internalMax = max(internalMarks, maxMarks - theoryMax)
        } else {
            theoryMax = Int(Double(maxMarks) * 0.8)
            internalMax = maxMarks - theoryMax
        }
        
        let theoryMarks = externalMarks > 0 ? externalMarks : marksObtained
        let internalMarksFinal = internalMarks
        
        let passingMarks = Int(Double(subject.passingMarks ?? "0") ?? Double(maxMarks) / 3.0)
        
        // Performance context - placeholders (API doesn't provide class rank/average)
        let classAverage = "—"
        let classRank = "—"
        let rankSubtitle = "Not available"
        let highestScore = "—"
        let lowestScore = "—"
        let passRate = "—"
        
        // Teacher feedback
        let teacherName = "Subject Teacher"
        let teacherRole = "\(subjectName) teacher"
        let teacherFeedback = subject.remarks ?? "No remarks provided for this subject."
        
        // Build tags from grade
        var tags: [FeedbackTag] = []
        if (subject.grade ?? "").uppercased().starts(with: "A") {
            tags.append(FeedbackTag(text: "Excellent performance", isPositive: true))
        } else if (subject.grade ?? "").uppercased().starts(with: "B") {
            tags.append(FeedbackTag(text: "Good performance", isPositive: true))
            tags.append(FeedbackTag(text: "Scope for improvement", isPositive: false))
        } else {
            tags.append(FeedbackTag(text: "Needs improvement", isPositive: false))
        }
        
        return SubjectDetailModel(
            subjectName: subjectName,
            subjectCode: subjectCode,
            examName: examName,
            marksObtained: marksObtained,
            maxMarks: maxMarks,
            grade: grade,
            gradeDescription: gradeDescription,
            gradeRange: gradeRange,
            comparisonText: comparisonText,
            theoryMarks: theoryMarks,
            theoryMax: theoryMax,
            theoryDuration: "Written examination",
            internalMarks: internalMarksFinal,
            internalMax: internalMax,
            internalDesc: "Classwork, activities and portfolio",
            passingMarks: passingMarks,
            classAverage: classAverage,
            classRank: classRank,
            rankSubtitle: rankSubtitle,
            highestScore: highestScore,
            lowestScore: lowestScore,
            passRate: passRate,
            teacherName: teacherName,
            teacherRole: teacherRole,
            teacherFeedback: teacherFeedback,
            tags: tags
        )
    }
    
    private func gradeDescription(for grade: String) -> String {
        let g = grade.uppercased()
        if g.contains("A+") { return "Outstanding" }
        if g == "A" || g == "A1" { return "Excellent" }
        if g == "A2" { return "Very Good" }
        if g == "B+" || g == "B1" { return "Good" }
        if g == "B" || g == "B2" { return "Above Average" }
        if g.starts(with: "C") { return "Average" }
        if g.starts(with: "D") { return "Below Average" }
        if g.starts(with: "E") || g.starts(with: "F") { return "Needs Improvement" }
        return "—"
    }
    
    private func gradeRange(for grade: String) -> String {
        let g = grade.uppercased()
        if g.contains("A+") { return "91–100" }
        if g == "A" || g == "A1" { return "81–90" }
        if g == "A2" { return "71–80" }
        if g == "B+" || g == "B1" { return "61–70" }
        if g == "B" || g == "B2" { return "51–60" }
        if g.starts(with: "C") { return "41–50" }
        if g.starts(with: "D") { return "33–40" }
        return "—"
    }
}

// MARK: - Main SwiftUI View
struct SubjectResultDetailView: View {
    let data: SubjectDetailModel
    var onBack: () -> Void = {}

    private let navyColor = Color(red: 0.11, green: 0.31, blue: 0.58)
    private let screenBgColor = Color(red: 0.96, green: 0.97, blue: 0.99)
    private let textDark = Color(red: 0.08, green: 0.11, blue: 0.19)
    private let textGray = Color(red: 0.45, green: 0.48, blue: 0.54)
    private let borderColor = Color(red: 0.89, green: 0.91, blue: 0.94)

    private let badgeGreenBg = Color(red: 0.88, green: 0.97, blue: 0.92)
    private let badgeGreenText = Color(red: 0.12, green: 0.58, blue: 0.35)

    private let badgeAmberBg = Color(red: 1.0, green: 0.95, blue: 0.88)
    private let badgeAmberText = Color(red: 0.76, green: 0.45, blue: 0.12)

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard
                    marksBreakdownSection
                    performanceContextSection
                    teacherFeedbackSection
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .background(screenBgColor.ignoresSafeArea())
    }

    private var headerView: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Subject Result")
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

    private var heroCard: some View {
        let isPassed = data.marksObtained >= data.passingMarks
        return VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                iconBox(systemName: "number.square.fill")

                VStack(alignment: .leading, spacing: 3) {
                    Text(data.subjectName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(textDark)

                    Text("Subject code \(data.subjectCode) • \(data.examName)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(textGray)
                }

                Spacer()

                Text(isPassed ? "Passed" : "Failed")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isPassed ? badgeGreenText : .red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(isPassed ? badgeGreenBg : Color.red.opacity(0.12))
                    .cornerRadius(10)
            }

            HStack(spacing: 20) {
                let percentage = Double(data.marksObtained) / Double(max(data.maxMarks, 1))
                ZStack {
                    Circle()
                        .stroke(borderColor, lineWidth: 7)
                        .frame(width: 76, height: 76)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(max(percentage, 0.0), 1.0)))
                        .stroke(navyColor, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 76, height: 76)

                    VStack(spacing: 1) {
                        Text("\(data.marksObtained)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(textDark)

                        Text("out of \(data.maxMarks)")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(textGray)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("GRADE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(textGray)

                    Text(data.grade)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(textDark)

                    Text("\(data.gradeDescription) • Grade range \(data.gradeRange)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(textGray)
                }

                Spacer()
            }
            .padding(.top, 4)

            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(navyColor)

                Text(data.comparisonText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(navyColor)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(red: 0.93, green: 0.96, blue: 1.0))
            .cornerRadius(10)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var marksBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("MARKS & GRADING")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(textGray)

                Text("Marks breakdown")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textDark)
            }

            VStack(spacing: 16) {
                marksRow(
                    title: "Theory paper",
                    subtitle: data.theoryDuration,
                    obtained: data.theoryMarks,
                    maxScore: data.theoryMax
                )

                marksRow(
                    title: "Internal assessment",
                    subtitle: data.internalDesc,
                    obtained: data.internalMarks,
                    maxScore: data.internalMax
                )

                HStack {
                    Text("Passing marks")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(textDark)

                    Spacer()

                    Text("\(data.passingMarks) / \(data.maxMarks)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(badgeGreenText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(screenBgColor)
                .cornerRadius(10)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
    }

    private func marksRow(title: String, subtitle: String, obtained: Int, maxScore: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(textDark)

                    Text(subtitle)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(textGray)
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(obtained)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(textDark)

                    Text("/\(maxScore)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(textGray)
                }
            }

            GeometryReader { geo in
                let ratio = CGFloat(obtained) / CGFloat(max(maxScore, 1))
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(borderColor)
                        .frame(height: 5)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(navyColor)
                        .frame(width: geo.size.width * min(max(ratio, 0.0), 1.0), height: 5)
                }
            }
            .frame(height: 5)
        }
    }

    private var performanceContextSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Performance context")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textDark)

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CLASS AVERAGE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(textGray)

                        Text(data.classAverage)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(navyColor)

                        Text("Not available")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(textGray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("CLASS RANK")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(textGray)

                        Text(data.classRank)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(badgeGreenText)

                        Text(data.rankSubtitle)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(textGray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )
                }

                HStack(spacing: 0) {
                    statColumn(title: "HIGHEST", value: data.highestScore)
                    statColumn(title: "LOWEST", value: data.lowestScore)
                    statColumn(title: "PASS RATE", value: data.passRate)
                }
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )
            }
        }
    }

    private func statColumn(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(textGray)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textDark)
        }
        .frame(maxWidth: .infinity)
    }

    private var teacherFeedbackSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Teacher feedback")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textDark)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Text(getInitials(data.teacherName))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(navyColor)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(data.teacherName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(textDark)

                        Text(data.teacherRole)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(textGray)
                    }

                    Spacer()
                }

                Text(data.teacherFeedback)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(textDark)
                    .lineSpacing(4)

                HStack(spacing: 8) {
                    ForEach(data.tags) { tag in
                        Text(tag.text)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(tag.isPositive ? badgeGreenText : badgeAmberText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(tag.isPositive ? badgeGreenBg : badgeAmberBg)
                            .cornerRadius(8)
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
    }

    private func iconBox(systemName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.90, green: 0.95, blue: 1.0))
                .frame(width: 42, height: 42)

            Image(systemName: systemName)
                .font(.system(size: 18))
                .foregroundColor(navyColor)
        }
    }

    private func getInitials(_ name: String) -> String {
        let parts = name.replacingOccurrences(of: "Mr. ", with: "")
                        .replacingOccurrences(of: "Ms. ", with: "")
                        .components(separatedBy: " ")
                        .filter { !$0.isEmpty }
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Mock Data
extension SubjectResultDetailView {
    static let mockData = SubjectDetailModel(
        subjectName: "Mathematics",
        subjectCode: "041",
        examName: "Mid-Term 2026",
        marksObtained: 78,
        maxMarks: 100,
        grade: "B1",
        gradeDescription: "Good",
        gradeRange: "71–80",
        comparisonText: "5.6 points above class average of 72.4%",
        theoryMarks: 58,
        theoryMax: 80,
        theoryDuration: "Written examination • 3 hours",
        internalMarks: 20,
        internalMax: 20,
        internalDesc: "Classwork, activities and portfolio",
        passingMarks: 33,
        classAverage: "72.4%",
        classRank: "12 / 42",
        rankSubtitle: "Top 30% in Mathematics",
        highestScore: "96",
        lowestScore: "42",
        passRate: "90.4%",
        teacherName: "Mr. Rohan Mehta",
        teacherRole: "Mathematics teacher",
        teacherFeedback: "Aarav demonstrates a clear understanding of algebra and geometry. Revise multi-step word problems and show each calculation to avoid losing method marks.",
        tags: [
            FeedbackTag(text: "Strong in algebra", isPositive: true),
            FeedbackTag(text: "Revise word problems", isPositive: false)
        ]
    )
}

struct SubjectResultDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectResultDetailView(data: SubjectResultDetailView.mockData)
    }
}

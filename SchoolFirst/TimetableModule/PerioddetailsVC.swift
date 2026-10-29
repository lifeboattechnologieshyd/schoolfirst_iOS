//
//
//  PerioddetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI

class PerioddetailsVC: UIViewController {
    
    // Data passed from TodaytimetableVC / WeaklytimetableVC
    var period: TimetablePeriodEntry?
    var selectedDate: Date = Date()
    var classSectionString: String = ""
    
    // Add this to receive full data from the previous screen
    var fullTimetableData: StudentTimetableData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        var swiftUIView = PeriodDetailsView(
            period: period,
            selectedDate: selectedDate,
            classSectionString: classSectionString
        )
        
        // Pass API data to SchedulechangesandhistoryVC
        swiftUIView.onViewScheduleChangesTapped = { [weak self] in
            guard let self = self else { return }
            let scheduleVC = SchedulechangesandhistoryVC()
            scheduleVC.timetableData = self.fullTimetableData
            scheduleVC.baseDate = self.selectedDate
            self.navigationController?.pushViewController(scheduleVC, animated: true)
        }
        
        swiftUIView.onBackToTimetableTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
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

// ... [Keep your existing PeriodDetailsView and related enums exactly as they are] ...
// MARK: - Period Detail State (derived from API data)
enum PeriodDetailState {
    case normal
    case teacherSubstitution
    case roomChange
}

// MARK: - SwiftUI View
struct PeriodDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let period: TimetablePeriodEntry?
    let selectedDate: Date
    let classSectionString: String
    
    var onViewScheduleChangesTapped: (() -> Void)? = nil
    var onBackToTimetableTapped: (() -> Void)? = nil
    
    let mainBlue = Color(red: 11/255, green: 86/255, blue: 154/255)
    
    // MARK: - Derived values from API
    
    private var state: PeriodDetailState {
        if period?.hasSubstitution == true { return .teacherSubstitution }
        if let notes = period?.notes?.lowercased(), notes.contains("room") { return .roomChange }
        return .normal
    }
    
    private var periodBadge: String {
        "PERIOD \(period?.period?.periodNumber ?? 0)"
    }
    
    private var subjectName: String {
        period?.subject?.name?.capitalized ?? "Subject"
    }
    
    private var headerDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMMM"
        return f.string(from: selectedDate)
    }
    
    private var fullDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f.string(from: selectedDate)
    }
    
    private var weekdayString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: selectedDate)
    }
    
    private var periodTimeString: String {
        guard let p = period?.period, !p.displayStart.isEmpty, !p.displayEnd.isEmpty else { return "Time N/A" }
        return "\(p.displayStart)–\(p.displayEnd)"
    }
    
    private var regularTeacherName: String {
        period?.regularTeacher?.name ?? period?.substitution?.originalTeacher?.name ?? "Teacher"
    }
    
    private var substituteTeacherName: String {
        period?.teacher?.name ?? period?.substitution?.substituteTeacher?.name ?? "Substitute teacher"
    }
    
    private var teacherDisplayString: String {
        switch state {
        case .teacherSubstitution:
            return "\(substituteTeacherName) · Substitute"
        default:
            return period?.teacher?.name ?? period?.regularTeacher?.name ?? "Teacher N/A"
        }
    }
    
    private var roomString: String {
        if let notes = period?.notes, !notes.isEmpty, notes != "Regular class" {
            return notes
        }
        return "Classroom"
    }
    
    private var substitutionDescription: String {
        if let reason = period?.substitution?.reason, !reason.isEmpty {
            return "\(regularTeacherName) is away (\(reason)). \(substituteTeacherName) will take this period. Time and room are unchanged."
        }
        return "\(regularTeacherName) is away. \(substituteTeacherName) will take this period. Time and room are unchanged."
    }
    
    private var classTimetableString: String {
        "\(weekdayString) · Period \(period?.period?.periodNumber ?? 0)"
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    subjectCardView
                    
                    if state == .teacherSubstitution {
                        substitutionAlertView
                    }
                    
                    if state == .roomChange {
                        roomChangeAlertView
                    }
                    
                    detailsListCardView
                    
                    actionButtons
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(Color.white)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Period details")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(headerDateString)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.leading, 12)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(mainBlue.ignoresSafeArea(edges: .top))
    }
    
    // MARK: - Subject Card
    
    private var subjectCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(periodBadge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(mainBlue)
                    .cornerRadius(12)
                
                Spacer()
                
                if state == .teacherSubstitution {
                    Text("SUBSTITUTION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(12)
                } else if state == .roomChange {
                    Text("ROOM CHANGED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subjectName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(mainBlue)
                
                Text(fullDateString)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(mainBlue.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(mainBlue.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Teacher Substitution Alert
    
    private var substitutionAlertView: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "bell")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.orange)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Teacher substitution today")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Text(substitutionDescription)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .padding()
        .background(Color(red: 1.0, green: 0.98, blue: 0.92))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Room Change Alert
    
    private var roomChangeAlertView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Room changed for this period")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Teacher and time are unchanged.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ORIGINAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Text("Classroom")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("UPDATED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                    Text(roomString)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.orange.opacity(0.4), lineWidth: 1))
            }
        }
        .padding()
        .background(Color(red: 1.0, green: 0.98, blue: 0.92))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Details List
    
    private var detailsListCardView: some View {
        VStack(spacing: 0) {
            DetailRowView(iconName: "clock", title: "PERIOD TIME", value: periodTimeString, showDivider: true)
            DetailRowView(iconName: "person", title: "TEACHER", value: teacherDisplayString, showDivider: true)
            
            if state == .roomChange {
                DetailRowView(iconName: "mappin.and.ellipse", title: "UPDATED ROOM", value: roomString, showDivider: true)
            } else if state == .teacherSubstitution {
                DetailRowView(iconName: "mappin.and.ellipse", title: "ROOM", value: roomString, showDivider: true)
            }
            
            DetailRowView(iconName: "person.2", title: "CLASS / SECTION", value: classSectionString.isEmpty ? "Class / Section" : classSectionString, showDivider: true)
            DetailRowView(iconName: "calendar", title: "CLASS TIMETABLE", value: classTimetableString, showDivider: false)
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private var actionButtons: some View {
        switch state {
        case .teacherSubstitution:
            filledButton(title: "View schedule changes") {
                onViewScheduleChangesTapped?()
            }
            .padding(.top, 8)
            
        case .normal:
            filledButton(title: "Back to \(weekdayString) timetable") {
                onBackToTimetableTapped?()
            }
            .padding(.top, 8)
            
        case .roomChange:
            VStack(spacing: 12) {
                filledButton(title: "View \(weekdayString) timetable") {
                    onBackToTimetableTapped?()
                }
                
                Button(action: {
                    onViewScheduleChangesTapped?()
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .bold))
                        Text("View schedule changes")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(mainBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(mainBlue, lineWidth: 1.5))
                }
            }
            .padding(.top, 8)
        }
    }
    
    private func filledButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(mainBlue)
            .cornerRadius(12)
        }
    }
}

// MARK: - Reusable Detail Row
struct DetailRowView: View {
    let iconName: String
    let title: String
    let value: String
    let showDivider: Bool
    
    let mainBlue = Color(red: 11/255, green: 86/255, blue: 154/255)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(mainBlue.opacity(0.08))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(mainBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Text(value)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            if showDivider {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 1)
                    .padding(.leading, 72)
            }
        }
    }
}

// MARK: - Previews
struct PeriodDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PeriodDetailsView(period: nil, selectedDate: Date(), classSectionString: "Grade 5 · Section B")
    }
}

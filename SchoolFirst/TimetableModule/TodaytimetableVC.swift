//
//  TodaytimetableVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI

class TodaytimetableVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide standard navigation bar to use the custom Figma header
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Initialize the SwiftUI View
        var swiftUIView = TodayTimetableView()
        
        // Setup Navigation Callback
        swiftUIView.onWeekViewTapped = { [weak self] in
            let weeklyVC = WeaklytimetableVC()
            self?.navigationController?.pushViewController(weeklyVC, animated: true)
        }
        
        // Wrap it in a UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Add as a child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Setup Constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}

// MARK: - SwiftUI View & Components

struct TodayTimetableView: View {
    // Navigation Callback
    var onWeekViewTapped: (() -> Void)? = nil
    
    // MARK: - Dummy Data (Ready for API)
    
    let nowPeriod = PeriodModel(
        periodLabel: "Period 2",
        statePrefix: "Now",
        time: "09:00-09:45",
        subject: "Mathematics",
        teacher: "Arun Kapoor",
        room: "Room 201",
        state: .now,
        isChanged: false
    )
    
    let nextPeriod = PeriodModel(
        periodLabel: "Period 3",
        statePrefix: "Next",
        time: "09:45-10:30",
        subject: "Science",
        teacher: "Arun Kapoor - Substitute for Meera Nair",
        room: "Science Lab 1",
        state: .next,
        isChanged: true
    )
    
    let laterPeriods = [
        PeriodModel(periodLabel: "Period 4", statePrefix: nil, time: "10:30-11:15", subject: "English", teacher: "Sunita Rao", room: "Room 105", state: .later, isChanged: false),
        PeriodModel(periodLabel: "Period 5", statePrefix: nil, time: "12:00-12:45", subject: "Social Studies", teacher: "Rajan Verma", room: "Room 203", state: .later, isChanged: false),
        PeriodModel(periodLabel: "Period 6", statePrefix: nil, time: "12:45-13:30", subject: "Computer Science", teacher: "Priya Sharma", room: "CS Lab", state: .later, isChanged: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Blue Header (Fixed Height 100)
            TimetableHeader()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // Tags Row (AY & Term)
                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12, weight: .bold))
                            Text("AY 2026-27")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                        
                        Text("Term 1 - Jun-Oct")
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
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text("Tuesday, 22 Sep")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Today")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal)
                    
                    // Alert Banner
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
                            Text("1 schedule change today")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Science has a teacher substitution in Period 3.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.orange)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding()
                    .background(Color(red: 1.0, green: 0.96, blue: 0.89)) // Light yellow/orange
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal)
                    
                    // Now & Next Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Now & next")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Updated Text to a Button to trigger Navigation
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
                            PeriodCardView(period: nowPeriod)
                            PeriodCardView(period: nextPeriod)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                    // Later Today Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Later today")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("3 periods remaining")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(laterPeriods) { period in
                                PeriodCardView(period: period)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 30) // Bottom scroll padding
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
    }
}

// MARK: - Header Component
struct TimetableHeader: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
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
                Text("Tuesday, 22 September 2026")
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
        .padding(.bottom, 16)
        .frame(height: 100, alignment: .bottom)
        .background(Color(red: 11/255, green: 86/255, blue: 154/255)) // Figma Blue #0B569A
    }
}

// MARK: - Models for Period Cards
enum PeriodState {
    case now
    case next
    case later
}

struct PeriodModel: Identifiable {
    let id = UUID()
    let periodLabel: String
    let statePrefix: String?
    let time: String
    let subject: String
    let teacher: String
    let room: String
    let state: PeriodState
    let isChanged: Bool
}

// MARK: - Reusable Period Card View
struct PeriodCardView: View {
    let period: PeriodModel
    
    // Dynamic styling properties
    var bgColor: Color {
        switch period.state {
        case .now: return Color.blue.opacity(0.05)
        case .next: return Color(red: 1.0, green: 0.96, blue: 0.89) // Light orange
        case .later: return Color.white
        }
    }
    
    var borderColor: Color {
        switch period.state {
        case .now: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .next: return Color.orange.opacity(0.5)
        case .later: return Color.gray.opacity(0.2)
        }
    }
    
    var leftBarColor: Color {
        switch period.state {
        case .now: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .next: return .orange
        case .later: return Color(red: 11/255, green: 86/255, blue: 154/255)
        }
    }
    
    var periodTextColor: Color {
        switch period.state {
        case .now: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .next: return .orange
        case .later: return Color(red: 11/255, green: 86/255, blue: 154/255)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Left Colored Bar
            RoundedRectangle(cornerRadius: 3)
                .fill(leftBarColor)
                .frame(width: 4)
                .padding(.vertical, 12)
                .padding(.leading, 12)
            
            // Left Column (Period & Time)
            VStack(alignment: .leading, spacing: 4) {
                if let prefix = period.statePrefix {
                    Text("\(period.periodLabel) • ")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(periodTextColor) +
                    Text(prefix)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(periodTextColor)
                } else {
                    Text(period.periodLabel)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(periodTextColor)
                }
                
                Text(period.time)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(width: 90, alignment: .leading)
            .padding(.vertical, 16)
            
            // Divider Line
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1)
                .padding(.vertical, 12)
            
            // Middle Column (Subject, Teacher, Room)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(period.subject)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if period.isChanged {
                        Text("Changed")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                Text(period.teacher)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                    Text(period.room)
                        .font(.system(size: 12, weight: .regular))
                }
                .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
            
            Spacer()
            
            // Right Chevron
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

// MARK: - Previews (For Xcode Canvas)
struct TodayTimetableView_Previews: PreviewProvider {
    static var previews: some View {
        TodayTimetableView(onWeekViewTapped: {})
    }
}

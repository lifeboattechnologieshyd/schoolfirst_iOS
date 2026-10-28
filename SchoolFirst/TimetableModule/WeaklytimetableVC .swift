//
//  WeaklytimetableVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI

class WeaklytimetableVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupSwiftUIView() {
        // Embed the SwiftUI view inside the UIViewController
        var weeklyTimetableView = WeeklyTimetableView()
        
        // Navigation Callback for period cells
        weeklyTimetableView.onPeriodTapped = { [weak self] period in
            // Navigate to PerioddetailsVC when a cell is tapped
            let detailsVC = PerioddetailsVC()
            self?.navigationController?.pushViewController(detailsVC, animated: true)
        }
        
        let hostingController = UIHostingController(rootView: weeklyTimetableView)
        
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
}

// MARK: - SwiftUI View
struct WeeklyTimetableView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Callback for navigation
    var onPeriodTapped: ((WeeklyPeriodModel) -> Void)? = nil
    
    // Dummy Data Array for UI Mapping
    let days: [WeeklyDayModel] = [
        WeeklyDayModel(dayName: "Mon", date: "21 Sep", isSelected: false),
        WeeklyDayModel(dayName: "Tue", date: "22 Sep", isSelected: true),
        WeeklyDayModel(dayName: "Wed", date: "23 Sep", isSelected: false),
        WeeklyDayModel(dayName: "Thu", date: "24 Sep", isSelected: false),
        WeeklyDayModel(dayName: "Fri", date: "25 Sep", isSelected: false),
        WeeklyDayModel(dayName: "Sat", date: "26 Sep", isSelected: false)
    ]
    
    let periods: [WeeklyPeriodModel] = [
        WeeklyPeriodModel(periodNum: "Period 1", time: "08:15–09:00", subject: "Hindi", teacher: "Kavitha Iyer", room: "Room 102", state: .normal),
        WeeklyPeriodModel(periodNum: "Period 2", time: "09:00–09:45", subject: "Mathematics", teacher: "Arun Kapoor", room: "Room 201", state: .current),
        WeeklyPeriodModel(periodNum: "Period 3", time: "09:45–10:30", subject: "Science", teacher: "Arun Kapoor · Substitute for Meera Nair", room: "Science Lab 1", state: .changed),
        WeeklyPeriodModel(periodNum: "Period 4", time: "10:30–11:15", subject: "English", teacher: "Sunita Rao", room: "Room 105", state: .normal),
        WeeklyPeriodModel(periodNum: "Lunch Break", time: "11:15–12:00", subject: "Lunch Break", teacher: "No class", room: "Break", state: .breakTime),
        WeeklyPeriodModel(periodNum: "Period 5", time: "12:00–12:45", subject: "Social Studies", teacher: "Rajan Verma", room: "Room 203", state: .normal),
        WeeklyPeriodModel(periodNum: "Period 6", time: "12:45–13:30", subject: "Computer Science", teacher: "Priya Sharma", room: "CS Lab", state: .normal)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Custom Header (Height: 100)
            headerView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    weekNavigatorView
                    
                    daysScrollView
                    
                    contextTagsView
                    
                    dateSectionHeaderView
                    
                    periodsListView
                }
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground).opacity(0.3)) // Slight off-white background
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack(alignment: .center) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Weekly timetable")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                // Binding user data if needed later, using static for Figma match
                Text("AY 2026–27 · Term 1")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {
                // Action for notifications
            }) {
                Image(systemName: "bell")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
        .frame(height: 100, alignment: .bottom) // EXACT height
        .background(Color(red: 11/255, green: 86/255, blue: 154/255)) // #0B569A
    }
    
    private var weekNavigatorView: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                    .font(.system(size: 16, weight: .bold))
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("21–26 September")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Text("Term 1 · Week 16")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
    
    private var daysScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(days, id: \.date) { day in
                    VStack(spacing: 4) {
                        Text(day.dayName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(day.isSelected ? .white : .primary)
                        Text(day.date)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(day.isSelected ? .white : .gray)
                    }
                    .frame(width: 65, height: 65)
                    .background(day.isSelected ? Color(red: 11/255, green: 86/255, blue: 154/255) : Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var contextTagsView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                Text("AY 2026–27")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(red: 11/255, green: 86/255, blue: 154/255).opacity(0.1))
            .cornerRadius(20)
            
            Text("Term 1 · Jun–Oct")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var dateSectionHeaderView: some View {
        HStack {
            Text("Tuesday · 22 Sep")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            Spacer()
            Text("Today")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var periodsListView: some View {
        VStack(spacing: 12) {
            ForEach(periods) { period in
                // Added Button to trigger the callback
                Button(action: {
                    onPeriodTapped?(period)
                }) {
                    WeeklyPeriodCardView(period: period)
                }
                .buttonStyle(PlainButtonStyle()) // Prevents weird system-blue highlight effect
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Dummy Models (Preserved for your API mapping)
struct WeeklyDayModel {
    let dayName: String
    let date: String
    let isSelected: Bool
}

enum WeeklyPeriodState {
    case normal
    case current
    case changed
    case breakTime
}

struct WeeklyPeriodModel: Identifiable {
    let id = UUID()
    let periodNum: String
    let time: String
    let subject: String
    let teacher: String
    let room: String
    let state: WeeklyPeriodState
}

// MARK: - Period Card View
struct WeeklyPeriodCardView: View {
    let period: WeeklyPeriodModel
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Status Indicator Line
            RoundedRectangle(cornerRadius: 4)
                .fill(indicatorColor)
                .frame(width: 4)
                .padding(.vertical, 16)
                .padding(.leading, 12)
            
            HStack(alignment: .top) {
                // Period Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(period.periodNum)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(indicatorColor)
                    
                    Text(period.time)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(width: 85, alignment: .leading)
                
                // Subject Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(period.subject)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        if period.state == .current {
                            badgeView(text: "Current", bgColor: .white, fgColor: indicatorColor, bdColor: indicatorColor)
                        } else if period.state == .changed {
                            badgeView(text: "Changed", bgColor: Color.orange.opacity(0.2), fgColor: .orange, bdColor: .clear)
                        }
                    }
                    
                    Text(period.teacher)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 10))
                        Text(period.room)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 14, weight: .bold))
                    .padding(.top, 4)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }
    
    private var indicatorColor: Color {
        switch period.state {
        case .normal: return Color(red: 11/255, green: 86/255, blue: 154/255).opacity(0.6)
        case .current: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .changed: return Color.orange
        case .breakTime: return Color(red: 11/255, green: 86/255, blue: 154/255).opacity(0.5)
        }
    }
    
    private var cardBackgroundColor: Color {
        switch period.state {
        case .current: return Color(red: 11/255, green: 86/255, blue: 154/255).opacity(0.05)
        case .changed: return Color.orange.opacity(0.08)
        default: return Color.white
        }
    }
    
    private var cardBorderColor: Color {
        switch period.state {
        case .current: return Color(red: 11/255, green: 86/255, blue: 154/255)
        case .changed: return Color.orange.opacity(0.5)
        default: return Color.gray.opacity(0.2)
        }
    }
    
    private func badgeView(text: String, bgColor: Color, fgColor: Color, bdColor: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(fgColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(bgColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(bdColor, lineWidth: bdColor == .clear ? 0 : 1)
            )
    }
}

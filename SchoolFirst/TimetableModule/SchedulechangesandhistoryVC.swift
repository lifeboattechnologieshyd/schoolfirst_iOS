//
//  SchedulechangesandhistoryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI

class SchedulechangesandhistoryVC: UIViewController {
    
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
        let swiftUIView = ScheduleChangesView()
        
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
}

// MARK: - Dummy Models (Preserved for your API mapping)

enum ScheduleTab {
    case upcoming
    case history
}

enum ChangeThemeType {
    case teacher
    case room
    case time
    
    var color: Color {
        switch self {
        case .teacher: return .orange
        case .room: return Color(red: 0.1, green: 0.6, blue: 0.6) // Teal
        case .time: return .purple
        }
    }
    
    var iconName: String {
        switch self {
        case .teacher: return "person.2"
        case .room: return "building.2"
        case .time: return "calendar.badge.clock"
        }
    }
}

struct ScheduleChangeModel: Identifiable {
    let id = UUID()
    let type: ChangeThemeType
    let title: String
    let subtitle: String
    let dateBadge: String
    let originalValue: String
    let updatedValue: String
    let footerNote: String
    // History specific fields
    let completedDateString: String?
    let hasViewDetailsLink: Bool
}

// MARK: - SwiftUI View

struct ScheduleChangesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: ScheduleTab = .upcoming
    
    let mainBlue = Color(red: 11/255, green: 86/255, blue: 154/255) // #0B569A
    
    // Dummy Data
    let upcomingData: [ScheduleChangeModel] = [
        ScheduleChangeModel(type: .teacher, title: "Teacher substitution", subtitle: "Science · Period 3", dateBadge: "TODAY", originalValue: "Meera Nair", updatedValue: "Arun Kapoor", footerNote: "Medical leave · Time and room remain unchanged.", completedDateString: nil, hasViewDetailsLink: false),
        ScheduleChangeModel(type: .room, title: "Room change", subtitle: "Computer Science · Period 5", dateBadge: "24 SEP", originalValue: "CS Lab", updatedValue: "Room 105", footerNote: "Lab maintenance · Teacher Priya Sharma is unchanged.", completedDateString: nil, hasViewDetailsLink: false),
        ScheduleChangeModel(type: .time, title: "Rescheduled period", subtitle: "Mathematics · Period 4", dateBadge: "25 SEP", originalValue: "10:30–11:15", updatedValue: "12:45–13:30", footerNote: "Moved to Period 6. Room 201 and teacher Arun Kapoor are unchanged.", completedDateString: nil, hasViewDetailsLink: false)
    ]
    
    let historyData: [ScheduleChangeModel] = [
        ScheduleChangeModel(type: .teacher, title: "Teacher substitution", subtitle: "Science · Period 3", dateBadge: "22 SEP", originalValue: "Meera Nair", updatedValue: "Arun Kapoor", footerNote: "09:45–10:30 · Science Lab 1\nTime and room remained unchanged.", completedDateString: "Tuesday, 22 September · Completed", hasViewDetailsLink: true)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Blue Header (Height: 100)
            headerView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    activeChildSection
                    
                    if selectedTab == .history {
                        contextTagsView
                            .padding(.top, -8)
                    }
                    
                    tabSwitcherView
                    
                    if selectedTab == .upcoming {
                        upcomingSection
                    } else {
                        historySection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground).opacity(0.4))
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                // Circular translucent back button matching Figma
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Schedule changes")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Read-only updates for Ananya")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(height: 100, alignment: .bottom)
        .background(mainBlue)
    }
    
    private var activeChildSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ACTIVE CHILD")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                // Dummy Avatar
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ananya Sharma")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text("Grade 5 · Section B")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var contextTagsView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(mainBlue)
                Text("AY 2026–27")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(mainBlue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(mainBlue.opacity(0.1))
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
    }
    
    private var tabSwitcherView: some View {
        HStack(spacing: 0) {
            tabButton(title: "Upcoming · \(upcomingData.count)", tab: .upcoming)
            tabButton(title: "History\(historyData.count > 0 ? " · \(historyData.count)" : "")", tab: .history)
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func tabButton(title: String, tab: ScheduleTab) -> some View {
        let isSelected = selectedTab == tab
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? mainBlue : Color.clear)
                .cornerRadius(20)
        }
    }
    
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming updates")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text("Term 1")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(mainBlue)
            }
            .padding(.top, 8)
            
            ForEach(upcomingData) { item in
                ChangeCardView(item: item)
            }
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("As of Wednesday, 23 September 2026")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
            
            HStack {
                Text("Completed updates")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text("Term 1")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(mainBlue)
            }
            
            ForEach(historyData) { item in
                ChangeCardView(item: item)
            }
            
            // Info Box
            VStack(alignment: .leading, spacing: 6) {
                Text("1 completed change")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                Text("The room change on 24 Sep and moved period on 25 Sep are still in Upcoming.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                    .lineSpacing(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            
            // Bottom Action Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .bold))
                    Text("Back to timetable")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(mainBlue)
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Reusable Card Component

struct ChangeCardView: View {
    let item: ScheduleChangeModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Top Header Row
            HStack(alignment: .top) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.type.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: item.type.iconName)
                        .foregroundColor(item.type.color)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                // Titles
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text(item.subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                // Date Badge
                Text(item.dateBadge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(item.type.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.type.color.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // History Completed Status Line (If applicable)
            if let completedStr = item.completedDateString {
                Text(completedStr)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // Transformation Box (Original -> Updated)
            HStack(spacing: 8) {
                // Original Side
                VStack(alignment: .leading, spacing: 4) {
                    Text("ORIGINAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Text(item.originalValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                
                // Arrow
                Image(systemName: "arrow.right")
                    .foregroundColor(item.type.color)
                    .font(.system(size: 14, weight: .bold))
                
                // Updated Side
                VStack(alignment: .leading, spacing: 4) {
                    Text("UPDATED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(item.type.color)
                    Text(item.updatedValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(item.type.color.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Footer Note
            Text(item.footerNote)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .lineSpacing(2)
            
            // History Specific Link
            if item.hasViewDetailsLink {
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Text("View period details")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

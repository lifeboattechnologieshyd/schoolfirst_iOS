//
//  ALLeventsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/10/26.
//

import UIKit
import SwiftUI

class EventsdashboardVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        let swiftUIView = AllEventsView()
        
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

// MARK: - Dummy Models (For future API Integration)

enum EventTheme {
    case academic
    case finance
    case community
    
    var backgroundColor: Color {
        switch self {
        case .academic:  return Color(red: 1.0, green: 0.89, blue: 0.89)  // Light Red
        case .finance:   return Color(red: 1.0, green: 0.95, blue: 0.90)  // Light Orange
        case .community: return Color(red: 0.85, green: 0.77, blue: 1.0)  // Light Purple
        }
    }
    
    var textColor: Color {
        switch self {
        case .academic:  return Color(red: 0.6, green: 0.1, blue: 0.15)   // Dark Red
        case .finance:   return Color(red: 0.55, green: 0.35, blue: 0.15) // Dark Brown/Orange
        case .community: return Color(red: 0.35, green: 0.15, blue: 0.75) // Dark Purple
        }
    }
}

struct EventDummyModel: Identifiable {
    let id = UUID()
    let theme: EventTheme
    let categoryName: String
    let timeOrAmount: String
    let title: String
    let location: String?
    let isDueToday: Bool
    let attendeeCount: Int?
}

// MARK: - SwiftUI View

struct AllEventsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Dummy Data Array
    let events: [EventDummyModel] = [
        EventDummyModel(
            theme: .academic,
            categoryName: "Academic",
            timeOrAmount: "9:00 AM - 11:30 AM",
            title: "Maths Final Exam",
            location: "Gymnasium Hall, Floor 2",
            isDueToday: false,
            attendeeCount: nil
        ),
        EventDummyModel(
            theme: .finance,
            categoryName: "Finance",
            timeOrAmount: "₹4500.00",
            title: "Q2 Tuition Fee Due",
            location: nil,
            isDueToday: true,
            attendeeCount: nil
        ),
        EventDummyModel(
            theme: .community,
            categoryName: "Community",
            timeOrAmount: "4:00 PM",
            title: "Annual PTA Meeting",
            location: "Conference\nRoom C",
            isDueToday: false,
            attendeeCount: 12
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header — total height ~100 (safe area + content)
            headerView
            
            // Events List
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(events) { event in
                        EventCardView(event: event)
                    }
                }
                .padding(16)
            }
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: topSafeAreaHeight)
            
            HStack(spacing: 0) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                }
                
                Text("Events")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.19))
                    .padding(.leading, 12)
                
                Spacer()
                
                Button(action: {
                    // Notifications Action
                }) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color(red: 11/255, green: 86/255, blue: 154/255))
                }
                
                // Profile Avatar
                ZStack {
                    Circle()
                        .fill(Color(red: 0.90, green: 0.91, blue: 0.96))
                        .frame(width: 32, height: 32)
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
                }
                .padding(.leading, 14)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(height: 100) // Figma header height
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color(red: 0.90, green: 0.91, blue: 0.93))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var topSafeAreaHeight: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return window?.safeAreaInsets.top ?? 47
    }
}

// MARK: - Reusable Card Component

struct EventCardView: View {
    let event: EventDummyModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Top Row (Time/Amount & Category)
            HStack {
                Text("\(event.timeOrAmount) · \(event.categoryName)")
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(event.theme.textColor.opacity(0.8))
            
            // Event Title
            Text(event.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(event.theme.textColor)
            
            // Dynamic Middle Content (Location / Due Today / Attendees)
            if event.location != nil || event.isDueToday {
                HStack(alignment: .top, spacing: 24) {
                    
                    // Location (Academic & Community)
                    if let location = event.location {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: event.theme == .community ? "building.2" : "mappin")
                                .font(.system(size: 14))
                                .padding(.top, 2)
                            
                            Text(location)
                                .font(.system(size: 13, weight: .regular))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundColor(event.theme.textColor.opacity(0.85))
                    }
                    
                    // Attendees Pile (Community specifically)
                    if let attendees = event.attendeeCount {
                        HStack(spacing: 8) {
                            attendeesPileView
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("\(attendees)")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Attendees")
                                    .font(.system(size: 10, weight: .regular))
                            }
                            .foregroundColor(event.theme.textColor)
                        }
                    }
                }
            }
            
            // Due Today Badge (Finance specifically)
            if event.isDueToday {
                HStack(spacing: 4) {
                    Text("!")
                        .font(.system(size: 11, weight: .heavy))
                    Text("Due Today")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 1.0, green: 0.9, blue: 0.8))
                .cornerRadius(12)
            }
            
            // Bottom Action (Set Reminder)
            Button(action: {
                // Reminder action
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "alarm")
                        .font(.system(size: 14))
                    Text("Set Reminder")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(event.theme.textColor)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(event.theme.backgroundColor)
        .cornerRadius(16)
    }
    
    // MARK: - Attendees Pile UI
    private var attendeesPileView: some View {
        HStack(spacing: -8) {
            // First mock user
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(Color(red: 0.8, green: 0.9, blue: 0.8))
                )
            // Second mock user
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.9))
                )
            // +9 Badge
            Circle()
                .fill(event.theme.textColor)
                .frame(width: 24, height: 24)
                .overlay(
                    Text("+9")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                )
        }
    }
}

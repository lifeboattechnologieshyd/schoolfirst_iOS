//
//  BulletinListView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/10/26.
//

import SwiftUI

// MARK: - Data Models
struct FilterCategory: Identifiable {
    let id = UUID()
    let name: String
    let count: Int?
}

enum BulletinType {
    case pinned, notice, event, holiday
}

struct BulletinItem: Identifiable {
    let id = UUID()
    let type: BulletinType
    let tags: [String]
    let isUrgent: Bool
    let title: String
    let description: String
    let sender: String
    let time: String
    let isUnread: Bool
}

// MARK: - Main View
struct BulletinListView: View {
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    
    // Mock Data based on your image
    let filters = [
        FilterCategory(name: "All", count: 3),
        FilterCategory(name: "Notices", count: 1),
        FilterCategory(name: "Events", count: 1),
        FilterCategory(name: "Holidays", count: nil)
    ]
    
    let pinnedItem = BulletinItem(type: .pinned, tags: ["PINNED", "Important"], isUrgent: false, title: "Mid-term exam timetable released", description: "Exams begin on 3 Nov. Subject-wise dates and...", sender: "Principal's Office · 21 Oct, 9:30 AM", time: "", isUnread: false)
    
    let todayItems = [
        BulletinItem(type: .notice, tags: ["Notice"], isUrgent: true, title: "Bus Route 7 timing change for tomorrow morning", description: "Pick-up will be 20 minutes earlier than usual.", sender: "Transport Dept", time: "8:10 AM", isUnread: true),
        BulletinItem(type: .event, tags: ["Event"], isUrgent: false, title: "Annual Day rehearsals begin this week", description: "Grade 5 students report at 8:00 AM in the...", sender: "Cultural Committee", time: "7:45 AM", isUnread: true)
    ]
    
    let yesterdayItems = [
        BulletinItem(type: .holiday, tags: ["Holiday"], isUrgent: false, title: "School closed for the Diwali break", description: "Classes resume on Monday, 9 November.", sender: "Admin Office", time: "4:30 PM", isUnread: false)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.96, green: 0.96, blue: 0.98).ignoresSafeArea() // Background color for list
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    
                    VStack(spacing: 20) {
                        filterSection
                        
                        // Reusable Cells in a LazyVStack
                        LazyVStack(spacing: 16) {
                            
                            // Section 1: Pinned
                            sectionHeader(icon: "pin", title: "Pinned")
                            PinnedBulletinCell(item: pinnedItem)
                            
                            // Section 2: Today
                            sectionHeader(icon: nil, title: "Today · 2 new")
                                .padding(.top, 10)
                            ForEach(todayItems) { item in
                                StandardBulletinCell(item: item)
                            }
                            
                            // Section 3: Yesterday
                            sectionHeader(icon: nil, title: "Yesterday")
                                .padding(.top, 10)
                            ForEach(yesterdayItems) { item in
                                StandardBulletinCell(item: item)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .background(Color(red: 0.96, green: 0.96, blue: 0.98)) // Gray background
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer().frame(height: 40) // Status bar spacing
            
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Spacer()
                Text("School Bulletin")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                Button(action: {}) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text("3")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 16, height: 16)
                            .background(Color.yellow)
                            .clipShape(Circle())
                            .offset(x: 5, y: -5)
                    }
                }
            }
            
            Text("News, events and notices from your school, all in one place.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 8)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search announcements", text: $searchText)
                    .foregroundColor(.black)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .padding(.top, 8)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.3, blue: 0.8), Color(red: 0.4, green: 0.3, blue: 0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters) { filter in
                    Button(action: {
                        selectedFilter = filter.name
                    }) {
                        HStack {
                            Text(filter.name)
                                .fontWeight(.semibold)
                            if let count = filter.count {
                                Text("\(count)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(selectedFilter == filter.name ? .black : .gray)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(selectedFilter == filter.name ? Color.yellow : Color.gray.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(selectedFilter == filter.name ? Color(red: 0.2, green: 0.3, blue: 0.8) : Color.white)
                        .foregroundColor(selectedFilter == filter.name ? .white : .black)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
    }
    
    private func sectionHeader(icon: String?, title: String) -> some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
        }
        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
    }
}

// MARK: - Cell Views

struct PinnedBulletinCell: View {
    let item: BulletinItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "pin.fill").font(.system(size: 10))
                    Text(item.tags[0])
                }
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
                
                Text(item.tags[1])
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow)
                    .clipShape(Capsule())
            }
            
            Text(item.title)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(item.description)
                .font(.subheadline)
                .opacity(0.9)
            
            Text(item.sender)
                .font(.caption)
                .opacity(0.7)
                .padding(.top, 4)
        }
        .padding()
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.3, green: 0.4, blue: 0.9), Color(red: 0.5, green: 0.3, blue: 0.9)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color(red: 0.4, green: 0.3, blue: 0.9).opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct StandardBulletinCell: View {
    let item: BulletinItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBackgroundColor)
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
            }
            
            // Right Content
            VStack(alignment: .leading, spacing: 6) {
                // Top Row: Tags & Time
                HStack {
                    Text(item.tags[0])
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(iconColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(iconBackgroundColor)
                        .clipShape(Capsule())
                    
                    if item.isUrgent {
                        Text("Urgent")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    Text(item.time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Title Row
                HStack(alignment: .top) {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    if item.isUnread {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(y: 4)
                    }
                }
                
                // Description
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                // Sender
                Text(item.sender)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    // Helpers for styling based on type
    var iconName: String {
        switch item.type {
        case .notice: return "megaphone"
        case .event: return "calendar"
        case .holiday: return "sun.max"
        default: return "doc"
        }
    }
    
    var iconColor: Color {
        switch item.type {
        case .notice: return Color(red: 0.2, green: 0.3, blue: 0.7)
        case .event: return Color(red: 0.7, green: 0.5, blue: 0.1)
        case .holiday: return Color(red: 0.2, green: 0.6, blue: 0.3)
        default: return .gray
        }
    }
    
    var iconBackgroundColor: Color {
        iconColor.opacity(0.1)
    }
}

// MARK: - Extension for specific corner rounding
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct BulletinListView_Previews: PreviewProvider {
    static var previews: some View {
        BulletinListView()
    }
}

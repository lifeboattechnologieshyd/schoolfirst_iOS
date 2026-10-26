//
//  BulletinListView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/10/26.
//

import SwiftUI

// MARK: - Data Models
struct FilterCategory: Identifiable {
    let id: String
    let name: String
    let count: Int?
    
    init(id: String = UUID().uuidString, name: String, count: Int? = nil) {
        self.id = id
        self.name = name
        self.count = count
    }
}

enum BulletinType {
    case pinned, notice, event, holiday
}

struct BulletinItem: Identifiable {
    let id: String
    let type: BulletinType
    let tags: [String]
    let isUrgent: Bool
    let title: String
    let description: String
    let sender: String
    let time: String
    let isUnread: Bool
    
    init(id: String = UUID().uuidString,
         type: BulletinType,
         tags: [String],
         isUrgent: Bool,
         title: String,
         description: String,
         sender: String,
         time: String,
         isUnread: Bool) {
        self.id = id
        self.type = type
        self.tags = tags
        self.isUrgent = isUrgent
        self.title = title
        self.description = description
        self.sender = sender
        self.time = time
        self.isUnread = isUnread
    }
}

// MARK: - Main View
struct BulletinListView: View {
    var onBack: (() -> Void)? = nil
    var onSelectBulletin: ((BulletinEntry) -> Void)? = nil   // ✅ renamed to match VC
    
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var selectedCategoryId: String? = nil   // nil = "All"
    @State private var filters: [FilterCategory] = [
        FilterCategory(id: "all", name: "All", count: nil)
    ]
    @State private var isLoadingCategories = false
    @State private var categoriesErrorMessage: String? = nil
    
    // ── API-driven bulletin data ────────────────────────────────────
    @State private var bulletins: [BulletinEntry] = []
    @State private var isLoadingBulletins = false
    
    // ── Date helpers (created once) ─────────────────────────────────
    private static let apiDateParser: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private static let apiDateParserFallback = ISO8601DateFormatter()
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.96, green: 0.96, blue: 0.98).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    
                    VStack(spacing: 20) {
                        filterSection
                        
                        bulletinsList
                    }
                    .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .onAppear {
            loadBulletinCategories()
            loadBulletins()
        }
    }
    
    // MARK: - API Integration
    
    private func loadBulletinCategories() {
        isLoadingCategories = true
        categoriesErrorMessage = nil
        
        BulletinCategoriesService.shared.fetchBulletinCategories { result in
            DispatchQueue.main.async {
                self.isLoadingCategories = false
                switch result {
                case .success(let apiCategories):
                    var newFilters: [FilterCategory] = [
                        FilterCategory(id: "all", name: "All", count: nil)
                    ]
                    
                    // Filter only active categories (if isActive is provided)
                    let activeCategories = apiCategories.filter { ($0.isActive ?? true) == true }
                    
                    for cat in activeCategories {
                        newFilters.append(
                            FilterCategory(id: cat.id, name: cat.name, count: nil)
                        )
                    }
                    
                    self.filters = newFilters
                    print("✅ Filter chips updated. Count:", newFilters.count)
                    
                case .failure(let error):
                    self.categoriesErrorMessage = error.localizedDescription
                    print("❌ Failed to load categories:", error.localizedDescription)
                    self.filters = [FilterCategory(id: "all", name: "All", count: nil)]
                }
            }
        }
    }
    
    private func loadBulletins() {
        isLoadingBulletins = true
        
        BulletinCategoriesService.shared.fetchBulletins(categoryId: selectedCategoryId) { result in
            DispatchQueue.main.async {
                self.isLoadingBulletins = false
                switch result {
                case .success(let entries):
                    self.bulletins = entries
                    self.updateFilterCounts()
                case .failure(let error):
                    print("❌ Failed to load bulletins:", error.localizedDescription)
                    self.bulletins = []
                    self.updateFilterCounts()
                }
            }
        }
    }
    
    // Fill the count badges on filter chips from loaded bulletins
    private func updateFilterCounts() {
        var updated: [FilterCategory] = []
        for filter in filters {
            if filter.id == "all" {
                updated.append(FilterCategory(id: filter.id, name: filter.name,
                                              count: bulletins.isEmpty ? nil : bulletins.count))
            } else {
                let count = bulletins.filter { $0.category?.id == filter.id }.count
                updated.append(FilterCategory(id: filter.id, name: filter.name,
                                              count: bulletins.isEmpty ? nil : count))
            }
        }
        filters = updated
    }
    
    // MARK: - Date / Mapping Helpers
    
    private func parseDate(_ string: String?) -> Date? {
        guard let string = string, !string.isEmpty else { return nil }
        if let date = Self.apiDateParser.date(from: string) { return date }
        return Self.apiDateParserFallback.date(from: string)
    }
    
    private func isToday(_ dateString: String?) -> Bool {
        guard let date = parseDate(dateString) else { return false }
        return Calendar.current.isDateInToday(date)
    }
    
    private func isYesterday(_ dateString: String?) -> Bool {
        guard let date = parseDate(dateString) else { return false }
        return Calendar.current.isDateInYesterday(date)
    }
    
    private func matchesSearch(_ item: BulletinItem) -> Bool {
        guard !searchText.isEmpty else { return true }
        return item.title.localizedCaseInsensitiveContains(searchText) ||
               item.description.localizedCaseInsensitiveContains(searchText)
    }
    
    /// Converts an API BulletinEntry into the UI's BulletinItem
    private func mapEntry(_ entry: BulletinEntry) -> BulletinItem {
        let categoryName = entry.category?.name ?? "Notice"
        
        // "Notices" → "Notice" for the tag chip
        let singular = categoryName.count > 1 && categoryName.hasSuffix("s")
            ? String(categoryName.dropLast())
            : categoryName
        
        let type: BulletinType
        switch categoryName.lowercased() {
        case "notice", "notices":   type = .notice
        case "event", "events":     type = .event
        case "holiday", "holidays": type = .holiday
        default:                    type = .notice
        }
        
        let displayTime: String
        if let created = parseDate(entry.createdAt) {
            displayTime = Self.timeFormatter.string(from: created)
        } else {
            displayTime = ""
        }
        
        let pinned = entry.isPinned == true
        
        // Pinned cell shows ["PINNED", banner label]; standard cell shows category tag
        let tags: [String] = pinned
            ? ["PINNED", entry.banner?.label ?? "Important"]
            : [singular]
        
        return BulletinItem(
            id: entry.id,
            type: type,
            tags: tags,
            // AMBER banner treated as Urgent (red chip)
            isUrgent: entry.banner?.bannerColor?.uppercased() == "AMBER",
            title: entry.title,
            description: entry.summary ?? entry.messageBody ?? "",
            sender: categoryName, // API has no sender field — category shown instead
            time: displayTime,
            isUnread: entry.isRead == false
        )
    }
    
    // Find the original API entry for a tapped UI item
    private func entryForItem(_ item: BulletinItem) -> BulletinEntry? {
        return bulletins.first { $0.id == item.id }
    }
    
    // MARK: - Sectioned Data (from API)
    
    private var visiblePinnedItems: [BulletinItem] {
        bulletins
            .filter { $0.isPinned == true }
            .map { mapEntry($0) }
            .filter { matchesSearch($0) }
    }
    
    private var visibleTodayItems: [BulletinItem] {
        bulletins
            .filter { $0.isPinned != true && isToday($0.createdAt) }
            .map { mapEntry($0) }
            .filter { matchesSearch($0) }
    }
    
    private var visibleYesterdayItems: [BulletinItem] {
        bulletins
            .filter { $0.isPinned != true && isYesterday($0.createdAt) }
            .map { mapEntry($0) }
            .filter { matchesSearch($0) }
    }
    
    private var visibleEarlierItems: [BulletinItem] {
        bulletins
            .filter { $0.isPinned != true && !isToday($0.createdAt) && !isYesterday($0.createdAt) }
            .map { mapEntry($0) }
            .filter { matchesSearch($0) }
    }
    
    private var todayTitle: String {
        let newCount = visibleTodayItems.filter { $0.isUnread }.count
        return newCount > 0 ? "Today · \(newCount) new" : "Today"
    }
    
    private var unreadCount: Int {
        bulletins.filter { $0.isRead == false }.count
    }
    
    // MARK: - List (Pinned / Today / Yesterday / Earlier / Empty State)
    
    private var bulletinsList: some View {
        LazyVStack(spacing: 16) {
            if isLoadingBulletins {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading bulletins...")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else if visiblePinnedItems.isEmpty &&
                      visibleTodayItems.isEmpty &&
                      visibleYesterdayItems.isEmpty &&
                      visibleEarlierItems.isEmpty {
                emptyStateView
            } else {
                // Section 1: Pinned
                if !visiblePinnedItems.isEmpty {
                    sectionHeader(icon: "pin", title: "Pinned")
                    ForEach(visiblePinnedItems) { item in
                        PinnedBulletinCell(item: item)
                            .onTapGesture {
                                if let entry = entryForItem(item) {
                                    onSelectBulletin?(entry)   // ✅ renamed
                                }
                            }
                    }
                }
                
                // Section 2: Today
                if !visibleTodayItems.isEmpty {
                    sectionHeader(icon: nil, title: todayTitle)
                        .padding(.top, 10)
                    ForEach(visibleTodayItems) { item in
                        StandardBulletinCell(item: item)
                            .onTapGesture {
                                if let entry = entryForItem(item) {
                                    onSelectBulletin?(entry)   // ✅ renamed
                                }
                            }
                    }
                }
                
                // Section 3: Yesterday
                if !visibleYesterdayItems.isEmpty {
                    sectionHeader(icon: nil, title: "Yesterday")
                        .padding(.top, 10)
                    ForEach(visibleYesterdayItems) { item in
                        StandardBulletinCell(item: item)
                            .onTapGesture {
                                if let entry = entryForItem(item) {
                                    onSelectBulletin?(entry)   // ✅ renamed
                                }
                            }
                    }
                }
                
                // Section 4: Earlier (only appears if older items exist)
                if !visibleEarlierItems.isEmpty {
                    sectionHeader(icon: nil, title: "Earlier")
                        .padding(.top, 10)
                    ForEach(visibleEarlierItems) { item in
                        StandardBulletinCell(item: item)
                            .onTapGesture {
                                if let entry = entryForItem(item) {
                                    onSelectBulletin?(entry)   // ✅ renamed
                                }
                            }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
    
    // MARK: - Empty State ("You're all caught up!")
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 30)
            
            // ── Illustration: card with checkmark + scattered dots ──
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.3, blue: 0.8).opacity(0.06))
                    .frame(width: 210, height: 210)
                
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 11, height: 11)
                    .offset(x: -92, y: -48)
                
                Circle()
                    .fill(Color(red: 0.55, green: 0.35, blue: 0.95))
                    .frame(width: 9, height: 9)
                    .offset(x: 90, y: -42)
                
                Circle()
                    .fill(Color(red: 0.55, green: 0.35, blue: 0.95).opacity(0.6))
                    .frame(width: 7, height: 7)
                    .offset(x: -76, y: 58)
                
                Circle()
                    .fill(Color(red: 0.35, green: 0.55, blue: 0.95))
                    .frame(width: 11, height: 11)
                    .offset(x: 85, y: 62)
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.25, green: 0.3, blue: 0.85))
                            .frame(width: 46, height: 46)
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 7) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 84, height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.18))
                            .frame(width: 60, height: 6)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.8).opacity(0.10), radius: 16, x: 0, y: 8)
            }
            
            Spacer().frame(height: 28)
            
            Text(searchText.isEmpty ? "You're all caught up!" : "No results found")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            
            Spacer().frame(height: 10)
            
            Text(searchText.isEmpty
                 ? "No new announcements right now. New school notices, events and holidays will appear here as soon as they are posted."
                 : "Try searching with a different keyword or browse all announcements.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 44)
            
            Spacer().frame(height: 26)
            
            Button(action: {
                searchText = ""
                selectedFilter = "All"
                selectedCategoryId = nil
                loadBulletins()
            }) {
                Text("Browse all announcements")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 13)
                    .background(Color(red: 0.25, green: 0.3, blue: 0.85))
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 0.25, green: 0.3, blue: 0.85).opacity(0.35), radius: 8, x: 0, y: 4)
            }
            
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer().frame(height: 40)
            
            HStack {
                Button(action: {
                    onBack?()
                }) {
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
                        
                        if unreadCount > 0 {
                            Text("\(unreadCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 16, height: 16)
                                .background(Color.yellow)
                                .clipShape(Circle())
                                .offset(x: 5, y: -5)
                        }
                    }
                }
            }
            
            Text("News, events and notices from your school, all in one place.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 8)
            
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
        VStack(alignment: .leading, spacing: 8) {
            if isLoadingCategories {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading categories...")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filters) { filter in
                        Button(action: {
                            selectedFilter = filter.name
                            selectedCategoryId = filter.id == "all" ? nil : filter.id
                            loadBulletins()
                        }) {
                            HStack(spacing: 6) {
                                Text(filter.name)
                                    .font(.system(size: 12, weight: .semibold))
                                if let count = filter.count {
                                    Text("\(count)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(selectedFilter == filter.name ? .black : .gray)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1)
                                        .background(selectedFilter == filter.name ? Color.yellow : Color.gray.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(selectedFilter == filter.name ? Color(red: 0.2, green: 0.3, blue: 0.8) : Color.white)
                            .foregroundColor(selectedFilter == filter.name ? .white : .black)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, isLoadingCategories ? 4 : 16)
            }
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
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBackgroundColor)
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
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
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
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
    
    // Exhaustive switch — all 4 enum cases + default
    var iconName: String {
        switch item.type {
        case .pinned:  return "pin"
        case .notice:  return "megaphone"
        case .event:   return "calendar"
        case .holiday: return "sun.max"
        default:       return "doc"
        }
    }
    
    // Exhaustive switch — all 4 enum cases + default
    var iconColor: Color {
        switch item.type {
        case .pinned:  return Color(red: 0.4, green: 0.3, blue: 0.9)
        case .notice:  return Color(red: 0.2, green: 0.3, blue: 0.7)
        case .event:   return Color(red: 0.7, green: 0.5, blue: 0.1)
        case .holiday: return Color(red: 0.2, green: 0.6, blue: 0.3)
        default:       return .gray
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

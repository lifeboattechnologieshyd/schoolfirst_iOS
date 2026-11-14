//
//  RecentlyAddedView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 14/11/26.
//

import SwiftUI
import UIKit

// MARK: - FONT
private func recentlyAddedInter(_ weight: Font.Weight, _ size: CGFloat) -> Font {
    let name: String
    if weight == .medium { name = "Inter-Medium" }
    else if weight == .semibold { name = "Inter-SemiBold" }
    else if weight == .bold { name = "Inter-Bold" }
    else { name = "Inter-Regular" }
    if UIFont(name: name, size: size) != nil {
        return .custom(name, size: size)
    }
    return .system(size: size, weight: weight)
}

private struct RecentlyAddedTheme {
    static let bg = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let primary = Color(red: 0.30, green: 0.27, blue: 0.90)
    static let dark = Color(red: 0.11, green: 0.11, blue: 0.20)
    static let gray = Color(red: 0.55, green: 0.56, blue: 0.63)
    static let orangeNew = Color(red: 1.0, green: 0.55, blue: 0.16)
}

// MARK: - MODEL - API READY
struct RecentlyAddedDIYItem: Identifiable, Decodable {
    var id: String
    var title: String
    var category: String
    var topic: String
    var dateGroup: String
    var isNew: Bool
    var mediaType: String
    var duration: String?
    var photosText: String?
    var imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id, title, category, topic
        case dateGroup = "date_group"
        case isNew = "is_new"
        case mediaType = "media_type"
        case duration
        case photosText = "photos_text"
        case imageUrl = "image_url"
    }

    var subtitleText: String { "\(category) · \(topic)" }
    var pillText: String {
        if mediaType == "photos" { return photosText ?? "" }
        return duration ?? ""
    }
    var pillIcon: String {
        if mediaType == "photos" { return "photo.fill" }
        return "clock.fill"
    }
}

struct RecentlyAddedGroup: Identifiable {
    var id: String { date }
    let date: String
    let items: [RecentlyAddedDIYItem]
}

// MARK: - VIEWMODEL - REPLACE MOCK WITH API LATER
class RecentlyAddedViewModel: ObservableObject {
    @Published var allItems: [RecentlyAddedDIYItem] = []
    @Published var selectedFilter = "All"
    @Published var displayLimit = 6

    let filters = ["All", "Crafts", "Science", "Art", "Recycling"]
    let dateOrder = ["29 Oct 2026", "27 Oct 2026", "25 Oct 2026"]

    init() { loadMock() }

    func loadMock() {
        allItems = [
            RecentlyAddedDIYItem(id: "1", title: "Rainbow Fizz Experiment", category: "Science", topic: "Acids and bases", dateGroup: "29 Oct 2026", isNew: true, mediaType: "video", duration: "07:30", photosText: nil, imageUrl: "https://images.unsplash.com/photo-1532094349884-543bc11b234d?q=80&w=600&auto=format&fit=crop"),
            RecentlyAddedDIYItem(id: "2", title: "Pressed Flower Bookmark", category: "Art", topic: "Patterns in nature", dateGroup: "29 Oct 2026", isNew: true, mediaType: "photos", duration: nil, photosText: "6 photos", imageUrl: "https://images.unsplash.com/photo-1452860606245-08befc0ff44b?q=80&w=600&auto=format&fit=crop"),
            RecentlyAddedDIYItem(id: "3", title: "Paper Bag Tree Craft", category: "Crafts", topic: "Reuse and recycling", dateGroup: "27 Oct 2026", isNew: false, mediaType: "photos", duration: nil, photosText: "5 photos", imageUrl: "https://images.unsplash.com/photo-1502082553048-f009c37129b9?q=80&w=600&auto=format&fit=crop"),
            RecentlyAddedDIYItem(id: "4", title: "Plastic Bottle Pencil Holder", category: "Recycling", topic: "Reuse of plastic", dateGroup: "27 Oct 2026", isNew: false, mediaType: "video", duration: "02:20", photosText: nil, imageUrl: "https://images.unsplash.com/photo-1513364776144-60967b0f800f?q=80&w=600&auto=format&fit=crop"),
            RecentlyAddedDIYItem(id: "5", title: "Egg Carton Flower Garden", category: "Crafts", topic: "Parts of a flower", dateGroup: "25 Oct 2026", isNew: false, mediaType: "video", duration: "08:10", photosText: nil, imageUrl: "https://images.unsplash.com/photo-1463320726281-696a485928c7?q=80&w=600&auto=format&fit=crop"),
            RecentlyAddedDIYItem(id: "6", title: "Magic Colour-Changing Milk", category: "Science", topic: "Surface tension", dateGroup: "25 Oct 2026", isNew: false, mediaType: "video", duration: "06:45", photosText: nil, imageUrl: "https://images.unsplash.com/photo-1554475901-4538ddfbccc2?q=80&w=600&auto=format&fit=crop")
        ]
    }

    var filtered: [RecentlyAddedDIYItem] {
        if selectedFilter == "All" { return allItems }
        return allItems.filter { $0.category == selectedFilter }
    }

    var visibleItems: [RecentlyAddedDIYItem] {
        Array(filtered.prefix(displayLimit))
    }

    var groupedVisible: [RecentlyAddedGroup] {
        var groups: [RecentlyAddedGroup] = []
        for date in dateOrder {
            let list = visibleItems.filter { $0.dateGroup == date }
            if !list.isEmpty {
                groups.append(RecentlyAddedGroup(date: date, items: list))
            }
        }
        let others = visibleItems.filter { !dateOrder.contains($0.dateGroup) }
        if !others.isEmpty {
            groups.append(RecentlyAddedGroup(date: others.first!.dateGroup, items: others))
        }
        return groups
    }

    func selectFilter(_ f: String) {
        selectedFilter = f
        displayLimit = 6
    }

    func loadMore() {
        displayLimit += 4
    }
}

// MARK: - MAIN VIEW
struct RecentlyAddedView: View {
    var onBack: (() -> Void)? = nil
    var onSearchTap: (() -> Void)? = nil
    var onItemTap: ((RecentlyAddedDIYItem) -> Void)? = nil
    @StateObject private var vm = RecentlyAddedViewModel()

    var body: some View {
        VStack(spacing: 0) {
            topNavBar
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    headerTitle
                    filterRow
                        .padding(.top, 12)

                    ForEach(vm.groupedVisible) { group in
                        Text(group.date)
                            .font(recentlyAddedInter(.semibold, 12.5))
                            .foregroundColor(RecentlyAddedTheme.dark)
                            .padding(.top, 16)
                            .padding(.bottom, 10)

                        VStack(spacing: 12) {
                            ForEach(group.items) { item in
                                RecentlyAddedCard(item: item, onTap: { onItemTap?(item) })
                            }
                        }
                    }

                    loadMoreButton
                        .padding(.top, 18)
                        .padding(.bottom, 26)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(RecentlyAddedTheme.bg.ignoresSafeArea())
    }

    private var topNavBar: some View {
        HStack {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(RecentlyAddedTheme.dark)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
            }
            Spacer()
            Button(action: { onSearchTap?() }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(RecentlyAddedTheme.dark)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var headerTitle: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Recently added")
                .font(recentlyAddedInter(.bold, 20))
                .foregroundColor(RecentlyAddedTheme.dark)
            Text("Fresh DIY ideas")
                .font(recentlyAddedInter(.regular, 12))
                .foregroundColor(RecentlyAddedTheme.gray)
        }
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.filters, id: \.self) { f in
                    RecentlyAddedFilterPill(
                        title: f,
                        isSelected: vm.selectedFilter == f,
                        action: { withAnimation { vm.selectFilter(f) } }
                    )
                }
            }
        }
    }

    private var loadMoreButton: some View {
        HStack {
            Spacer()
            if vm.visibleItems.count < vm.filtered.count {
                Button(action: { withAnimation { vm.loadMore() } }) {
                    Text("Load more")
                        .font(recentlyAddedInter(.semibold, 12.5))
                        .foregroundColor(RecentlyAddedTheme.primary)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 11)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.gray.opacity(0.14), lineWidth: 1))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                }
            } else {
                Button(action: {}) {
                    Text("Load more")
                        .font(recentlyAddedInter(.semibold, 12.5))
                        .foregroundColor(RecentlyAddedTheme.primary)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 11)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.gray.opacity(0.14), lineWidth: 1))
                }
            }
            Spacer()
        }
    }
}

// MARK: - CARD - FIGMA HEIGHT 178
private struct RecentlyAddedCard: View {
    let item: RecentlyAddedDIYItem
    var onTap: () -> Void = {}
    private let cardHeight: CGFloat = 178 // Figma height

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                AsyncImage(url: URL(string: item.imageUrl)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.15)
                }
                .frame(height: cardHeight)
                .frame(maxWidth: .infinity)
                .clipped()

                LinearGradient(
                    colors: [.black.opacity(0.05), .black.opacity(0.15), .black.opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        if item.isNew {
                            Text("NEW")
                                .font(recentlyAddedInter(.bold, 9))
                                .foregroundColor(.white)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(RecentlyAddedTheme.orangeNew)
                                .clipShape(Capsule())
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: item.pillIcon)
                                .font(.system(size: 8, weight: .bold))
                            Text(item.pillText)
                                .font(recentlyAddedInter(.bold, 10))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.55))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)

                    Spacer()

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(recentlyAddedInter(.bold, 14.5))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(item.subtitleText)
                            .font(recentlyAddedInter(.medium, 11))
                            .foregroundColor(.white.opacity(0.88))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
            }
            .frame(height: cardHeight)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

private struct RecentlyAddedFilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(recentlyAddedInter(.semibold, 12))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? RecentlyAddedTheme.primary : Color.white)
                .foregroundColor(isSelected ? .white : RecentlyAddedTheme.dark)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.gray.opacity(0.14), lineWidth: isSelected ? 0 : 1))
                .shadow(color: .black.opacity(isSelected ? 0.15 : 0.04), radius: 5, x: 0, y: 2)
        }
    }
}

struct RecentlyAddedView_Previews: PreviewProvider {
    static var previews: some View {
        RecentlyAddedView()
    }
}

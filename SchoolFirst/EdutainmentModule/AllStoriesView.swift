//
//  AllStoriesView.swift
//  SchoolFirst
//

import SwiftUI
import UIKit

// MARK: - Inter Font
private func allInter(_ weight: Font.Weight, _ size: CGFloat) -> Font {
    let name: String
    switch weight {
    case .medium:   name = "Inter-Medium"
    case .semibold: name = "Inter-SemiBold"
    case .bold:     name = "Inter-Bold"
    default:        name = "Inter-Regular"
    }
    if UIFont(name: name, size: size) != nil {
        return .custom(name, size: size)
    }
    return .system(size: size, weight: weight)
}

// MARK: - Theme
private enum AllStoriesPalette {
    static let bg         = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let primary    = Color(red: 0.30, green: 0.27, blue: 0.90)
    static let dark       = Color(red: 0.11, green: 0.11, blue: 0.20)
    static let gray       = Color(red: 0.55, green: 0.56, blue: 0.63)
    static let greenBadge = Color(red: 0.13, green: 0.77, blue: 0.55)
}

// MARK: - API Ready Model
struct AllStoryItem: Identifiable, Decodable {
    var id: String
    var title: String
    var category: String
    var mediaType: String // audio | video | pictures
    var duration: String?
    var pages: String?
    var isFromSchool: Bool
    var imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id, title, category, duration, pages
        case mediaType = "media_type"
        case isFromSchool = "is_from_school"
        case imageUrl = "image_url"
    }

    var isVideo: Bool { mediaType == "video" }
    var isAudio: Bool { mediaType == "audio" }
    var isPictures: Bool { mediaType == "pictures" }
    var formatText: String { isVideo ? "Video" : (isAudio ? "Audio" : "Pictures") }
    var subtitleText: String { "\(category) • \(formatText)" }
    var pillIcon: String { isVideo ? "video.fill" : (isAudio ? "headphones" : "book.fill") }
    var pillText: String { isPictures ? (pages ?? "") : (duration ?? "") }
}

// MARK: - ViewModel
final class AllStoriesViewModel: ObservableObject {
    @Published var allStories: [AllStoryItem] = []
    @Published var selectedFilter = "All"
    @Published var sortOption = "Newest"
    @Published var displayLimit = 6

    let filters = ["All", "Videos", "Audio", "Pictures"]
    let sortOptions = ["Newest", "Oldest", "Popular"]

    init() { loadMock() }

    func loadMock() {
        let templates: [AllStoryItem] = [
            AllStoryItem(id: "t1", title: "The Parrot's Spicy Mistake", category: "Bedtime", mediaType: "audio", duration: "12:34", pages: nil, isFromSchool: false, imageUrl: "https://images.unsplash.com/photo-1552728089-57bdde30beb3?q=80&w=600&auto=format&fit=crop"),
            AllStoryItem(id: "t2", title: "The Clever Crow", category: "Fables", mediaType: "pictures", duration: nil, pages: "8 pages", isFromSchool: true, imageUrl: "https://images.unsplash.com/photo-1555169062-013468b47731?q=80&w=600&auto=format&fit=crop"),
            AllStoryItem(id: "t3", title: "The Monkey Who Judged Too Soon", category: "Moral", mediaType: "video", duration: "12:34", pages: nil, isFromSchool: true, imageUrl: "https://images.unsplash.com/photo-1540573133985-87b6da6d54a9?q=80&w=600&auto=format&fit=crop"),
            AllStoryItem(id: "t4", title: "The Honest Woodcutter", category: "Moral", mediaType: "audio", duration: "11:40", pages: nil, isFromSchool: false, imageUrl: "https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=600&auto=format&fit=crop"),
            AllStoryItem(id: "t5", title: "The Hare and the Tortoise", category: "Fables", mediaType: "video", duration: "10:05", pages: nil, isFromSchool: true, imageUrl: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop"),
            AllStoryItem(id: "t6", title: "The Moon and the Pond", category: "Bedtime", mediaType: "pictures", duration: nil, pages: "6 pages", isFromSchool: false, imageUrl: "https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=600&auto=format&fit=crop")
        ]
        // 36 items so "Showing 6 of 36" + Load More works. TODO: Replace with API.
        allStories = (0..<36).map { index in
            let t = templates[index % templates.count]
            return AllStoryItem(id: "\(index + 1)", title: t.title, category: t.category, mediaType: t.mediaType, duration: t.duration, pages: t.pages, isFromSchool: t.isFromSchool, imageUrl: t.imageUrl)
        }
    }

    var filteredAll: [AllStoryItem] {
        var list = allStories
        if selectedFilter == "Videos" { list = list.filter { $0.isVideo } }
        else if selectedFilter == "Audio" { list = list.filter { $0.isAudio } }
        else if selectedFilter == "Pictures" { list = list.filter { $0.isPictures } }
        if sortOption == "Oldest" { list = list.reversed() }
        return list
    }

    var visibleStories: [AllStoryItem] { Array(filteredAll.prefix(displayLimit)) }
    var totalCount: Int { allStories.count }

    func loadMore() { displayLimit += 6 }
    func selectFilter(_ filter: String) { selectedFilter = filter; displayLimit = 6 }
}

// MARK: - Strictly Constrained Image (Fixes Overlap)
private struct AllStoryRemoteImage: View {
    let urlString: String

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            Group {
                if let url = URL(string: urlString), !urlString.isEmpty {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: height)
                                .clipped()
                        } else if phase.error != nil {
                            placeholder
                        } else {
                            ZStack {
                                Color.gray.opacity(0.15)
                                ProgressView()
                            }
                        }
                    }
                } else {
                    placeholder
                }
            }
            .frame(width: width, height: height)
            .clipped()
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.15)
            Image(systemName: "photo").foregroundColor(Color.gray.opacity(0.45))
        }
    }
}

// MARK: - Main View
struct AllStoriesView: View {
    var onBack: (() -> Void)? = nil
    var onSearchTap: (() -> Void)? = nil
    var onStoryTap: ((AllStoryItem) -> Void)? = nil

    @StateObject private var vm = AllStoriesViewModel()

    private let horizontalPadding: CGFloat = 20
    private let gridSpacing: CGFloat = 14

    private var cardWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return floor((screenWidth - (horizontalPadding * 2) - gridSpacing) / 2)
    }
    private var imageHeight: CGFloat { cardWidth * 1.05 }
    private var columns: [GridItem] {
        [GridItem(.fixed(cardWidth), spacing: gridSpacing),
         GridItem(.fixed(cardWidth), spacing: gridSpacing)]
    }

    var body: some View {
        VStack(spacing: 0) {
            topNavBar

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    headerTitle
                    filterRow
                    showingRow
                    storyGrid
                    loadMoreButton
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
        }
        .background(AllStoriesPalette.bg.ignoresSafeArea())
    }

    private var topNavBar: some View {
        HStack {
            navButton(icon: "chevron.left", bold: true) { onBack?() }
            Spacer()
            navButton(icon: "magnifyingglass", bold: false) { onSearchTap?() }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 4)
        .padding(.bottom, 6)
    }

    private func navButton(icon: String, bold: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: bold ? .bold : .semibold))
                .foregroundColor(AllStoriesPalette.dark)
                .frame(width: 38, height: 38)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var headerTitle: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Recently added stories")
                .font(allInter(.bold, 20))
                .foregroundColor(AllStoriesPalette.dark)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            Text("\(vm.totalCount) stories")
                .font(allInter(.regular, 12))
                .foregroundColor(AllStoriesPalette.gray)
        }
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.filters, id: \.self) { filter in
                    AllFilterPill(
                        title: filter,
                        isSelected: vm.selectedFilter == filter,
                        action: { withAnimation(.easeInOut(duration: 0.2)) { vm.selectFilter(filter) } }
                    )
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var showingRow: some View {
        HStack {
            Text("Showing \(vm.visibleStories.count) of \(vm.filteredAll.count)")
                .font(allInter(.medium, 11.5))
                .foregroundColor(AllStoriesPalette.gray)
            Spacer()
            Menu {
                ForEach(vm.sortOptions, id: \.self) { option in
                    Button(action: { vm.sortOption = option }) { Text(option) }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(vm.sortOption).font(allInter(.semibold, 12))
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(AllStoriesPalette.primary)
            }
        }
    }

    private var storyGrid: some View {
        LazyVGrid(columns: columns, spacing: 18) {
            ForEach(vm.visibleStories) { item in
                AllStoryCard(
                    item: item,
                    cardWidth: cardWidth,
                    imageHeight: imageHeight,
                    onTap: { onStoryTap?(item) }
                )
            }
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    private var loadMoreButton: some View {
        if vm.visibleStories.count < vm.filteredAll.count {
            HStack {
                Spacer()
                Button(action: { withAnimation(.easeInOut(duration: 0.25)) { vm.loadMore() } }) {
                    Text("Load more")
                        .font(allInter(.semibold, 13))
                        .foregroundColor(AllStoriesPalette.primary)
                        .padding(.horizontal, 28)
                        .frame(height: 40)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.top, 6)
        }
    }
}

// MARK: - Card (No Spacer, Fixed Size)
private struct AllStoryCard: View {
    let item: AllStoryItem
    let cardWidth: CGFloat
    let imageHeight: CGFloat
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 7) {

                AllStoryRemoteImage(urlString: item.imageUrl)
                    .frame(width: cardWidth, height: imageHeight)
                    .overlay(alignment: .topLeading) {
                        if item.isFromSchool {
                            Text("From school")
                                .font(allInter(.bold, 8))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AllStoriesPalette.greenBadge)
                                .clipShape(Capsule())
                                .padding(8)
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        HStack(spacing: 4) {
                            Image(systemName: item.pillIcon).font(.system(size: 8, weight: .bold))
                            Text(item.pillText).font(allInter(.bold, 9))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.55))
                        .clipShape(Capsule())
                        .padding(8)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Text(item.title)
                    .font(allInter(.bold, 12.5))
                    .foregroundColor(AllStoriesPalette.dark)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: cardWidth, height: 34, alignment: .topLeading)

                Text(item.subtitleText)
                    .font(allInter(.regular, 11))
                    .foregroundColor(AllStoriesPalette.gray)
                    .lineLimit(1)
                    .frame(width: cardWidth, alignment: .leading)
            }
            .frame(width: cardWidth, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Pill
private struct AllFilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    private var iconName: String? {
        if title == "Videos" { return "video" }
        if title == "Audio" { return "headphones" }
        if title == "Pictures" { return "photo" }
        return nil
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon = iconName {
                    Image(systemName: icon).font(.system(size: 11, weight: .semibold))
                }
                Text(title).font(allInter(.semibold, 12.5))
            }
            .padding(.horizontal, 15)
            .frame(height: 34)
            .background(isSelected ? AllStoriesPalette.primary : Color.white)
            .foregroundColor(isSelected ? Color.white : AllStoriesPalette.dark)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct AllStoriesView_Previews: PreviewProvider {
    static var previews: some View { AllStoriesView() }
}

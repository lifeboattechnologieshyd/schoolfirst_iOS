//
//  TrendingView.swift
//  SchoolFirst
//

import SwiftUI
import UIKit

// MARK: - Inter Font
private func trendingNowInter(_ weight: Font.Weight, _ size: CGFloat) -> Font {
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
private enum TrendingNowPalette {
    static let bg           = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let primary      = Color(red: 0.30, green: 0.27, blue: 0.90) // #4F46E5
    static let primaryLight = Color(red: 0.91, green: 0.91, blue: 1.0)
    static let dark         = Color(red: 0.11, green: 0.11, blue: 0.20)
    static let gray         = Color(red: 0.53, green: 0.54, blue: 0.61)
    static let rank         = Color(red: 0.76, green: 0.77, blue: 0.96)
    static let pink         = Color(red: 0.93, green: 0.38, blue: 0.58)
}

// MARK: - Period Filter
enum TrendingNowPeriod: String, CaseIterable, Identifiable {
    case thisWeek = "This week"
    case thisMonth = "This month"
    case allTime = "All time"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .thisWeek:  return "Most made this week"
        case .thisMonth: return "Most made this month"
        case .allTime:   return "Most made of all time"
        }
    }
}

// MARK: - API Ready Model (RENAMED - was TrendingItem)
struct TrendingNowItem: Identifiable, Decodable {
    var id: String
    var title: String
    var category: String
    var topic: String
    var durationText: String
    var imageUrl: String
    var likesCount: Int
    var viewsCount: Int

    enum CodingKeys: String, CodingKey {
        case id, title, category, topic
        case durationText = "duration_text"
        case imageUrl = "image_url"
        case likesCount = "likes_count"
        case viewsCount = "views_count"
    }

    var subtitleText: String { "\(category) · \(topic) · \(durationText)" }
    var likesText: String { trendingNowFormattedCount(likesCount) }
    var viewsText: String { trendingNowFormattedCount(viewsCount) }
}

private func trendingNowFormattedCount(_ value: Int) -> String {
    if value >= 1000 {
        let doubleValue = Double(value) / 1000.0
        if doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(doubleValue))k"
        }
        return String(format: "%.1fk", doubleValue)
    }
    return "\(value)"
}

// MARK: - ViewModel (Dummy Now, API Later)
final class TrendingNowViewModel: ObservableObject {
    @Published var items: [TrendingNowItem] = []
    @Published var selectedPeriod: TrendingNowPeriod = .thisWeek

    init() { loadMock() }

    func loadMock() {
        items = [
            TrendingNowItem(id: "1", title: "Magic Colour-Changing Milk", category: "Science", topic: "Surface tension", durationText: "6 min",
                            imageUrl: "https://images.unsplash.com/photo-1532094349884-543bc11b234d?q=80&w=300&auto=format&fit=crop",
                            likesCount: 640, viewsCount: 3400),
            TrendingNowItem(id: "2", title: "Egg Carton Flower Garden", category: "Crafts", topic: "Parts of a flower", durationText: "8 min",
                            imageUrl: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?q=80&w=300&auto=format&fit=crop",
                            likesCount: 812, viewsCount: 2900),
            TrendingNowItem(id: "3", title: "Plastic Bottle Pencil Holder", category: "Recycling", topic: "Reuse of plastic", durationText: "9 min",
                            imageUrl: "https://images.unsplash.com/photo-1513364776144-60967b0f800f?q=80&w=300&auto=format&fit=crop",
                            likesCount: 455, viewsCount: 2100),
            TrendingNowItem(id: "4", title: "Paper Bag Tree Craft", category: "Crafts", topic: "Reuse and recycling", durationText: "5 photos",
                            imageUrl: "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=300&auto=format&fit=crop",
                            likesCount: 1200, viewsCount: 1800),
            TrendingNowItem(id: "5", title: "Rainbow Fizz Experiment", category: "Science", topic: "Acids and bases", durationText: "7 min",
                            imageUrl: "https://images.unsplash.com/photo-1554475901-4538ddfbccc2?q=80&w=300&auto=format&fit=crop",
                            likesCount: 390, viewsCount: 1500),
            TrendingNowItem(id: "6", title: "Pressed Flower Bookmark", category: "Art", topic: "Patterns in nature", durationText: "6 photos",
                            imageUrl: "https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=300&auto=format&fit=crop",
                            likesCount: 276, viewsCount: 1200)
        ]
    }

    // TODO API:
    // func fetchFromAPI(period: TrendingNowPeriod) async {
    //     // Call API with period, decode [TrendingNowItem], assign items on MainActor
    // }

    var displayedItems: [TrendingNowItem] {
        switch selectedPeriod {
        case .thisWeek:
            return items
        case .thisMonth:
            return items.sorted { $0.viewsCount > $1.viewsCount }
        case .allTime:
            return items.sorted { $0.likesCount > $1.likesCount }
        }
    }
}

// MARK: - Remote Image
private struct TrendingNowRemoteImage: View {
    let urlString: String

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            Group {
                if let url = URL(string: urlString), !urlString.isEmpty {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
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
struct TrendingView: View {
    var onBack: (() -> Void)? = nil
    var onSearchTap: (() -> Void)? = nil
    var onItemTap: ((TrendingNowItem) -> Void)? = nil
    var onPlayTap: ((TrendingNowItem) -> Void)? = nil

    @StateObject private var vm = TrendingNowViewModel()

    var body: some View {
        VStack(spacing: 0) {
            topNavBar

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    headerTitle
                    filterRow
                    trendingList
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .background(TrendingNowPalette.bg.ignoresSafeArea())
    }

    // MARK: Top Bar
    private var topNavBar: some View {
        HStack {
            navCircleButton(icon: "chevron.left", bold: true) { onBack?() }
            Spacer()
            navCircleButton(icon: "magnifyingglass", bold: false) { onSearchTap?() }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 6)
    }

    private func navCircleButton(icon: String, bold: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: bold ? .bold : .semibold))
                .foregroundColor(TrendingNowPalette.dark)
                .frame(width: 38, height: 38)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: Header
    private var headerTitle: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Trending now")
                .font(trendingNowInter(.bold, 22))
                .foregroundColor(TrendingNowPalette.dark)
                .lineLimit(1)

            Text(vm.selectedPeriod.subtitle)
                .font(trendingNowInter(.regular, 12))
                .foregroundColor(TrendingNowPalette.gray)
        }
    }

    // MARK: Filters
    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TrendingNowPeriod.allCases) { period in
                    let isSelected = vm.selectedPeriod == period

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            vm.selectedPeriod = period
                        }
                    }) {
                        Text(period.rawValue)
                            .font(trendingNowInter(.semibold, 12.5))
                            .padding(.horizontal, 17)
                            .frame(height: 36)
                            .background(isSelected ? TrendingNowPalette.primary : Color.white)
                            .foregroundColor(isSelected ? Color.white : TrendingNowPalette.dark)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 1)
        }
    }

    // MARK: List
    private var trendingList: some View {
        VStack(spacing: 0) {
            if vm.displayedItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "flame")
                        .font(.system(size: 26))
                        .foregroundColor(TrendingNowPalette.gray.opacity(0.6))
                    Text("No trending activities found")
                        .font(trendingNowInter(.semibold, 13))
                        .foregroundColor(TrendingNowPalette.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(vm.displayedItems.indices, id: \.self) { index in
                    let item = vm.displayedItems[index]

                    trendingRow(item: item, rank: index + 1)

                    if index < vm.displayedItems.count - 1 {
                        Divider()
                            .background(Color.black.opacity(0.05))
                            .padding(.leading, 108)
                    }
                }
            }
        }
    }

    private func trendingRow(item: TrendingNowItem, rank: Int) -> some View {
        HStack(spacing: 12) {

            Text("\(rank)")
                .font(trendingNowInter(.bold, 30))
                .foregroundColor(TrendingNowPalette.rank)
                .frame(width: 26, alignment: .center)

            TrendingNowRemoteImage(urlString: item.imageUrl)
                .frame(width: 68, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(trendingNowInter(.bold, 13.5))
                    .foregroundColor(TrendingNowPalette.dark)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.subtitleText)
                    .font(trendingNowInter(.regular, 11))
                    .foregroundColor(TrendingNowPalette.gray)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(TrendingNowPalette.pink)
                        Text(item.likesText)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.system(size: 10, weight: .semibold))
                        Text(item.viewsText)
                    }
                }
                .font(trendingNowInter(.medium, 11))
                .foregroundColor(TrendingNowPalette.gray)
            }

            Spacer(minLength: 4)

            Button(action: { onPlayTap?(item) }) {
                Image(systemName: "play.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(TrendingNowPalette.primary)
                    .frame(width: 36, height: 36)
                    .background(TrendingNowPalette.primaryLight)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture { onItemTap?(item) }
    }
}

struct TrendingView_Previews: PreviewProvider {
    static var previews: some View { TrendingView() }
}

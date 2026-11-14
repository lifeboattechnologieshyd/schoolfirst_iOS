import SwiftUI
import UIKit

// MARK: - INTER FONT
private func inter(_ weight: Font.Weight, _ size: CGFloat) -> Font {
    let name: String
    if weight == .medium {
        name = "Inter-Medium"
    } else if weight == .semibold {
        name = "Inter-SemiBold"
    } else if weight == .bold {
        name = "Inter-Bold"
    } else if weight == .heavy || weight == .black {
        name = "Inter-ExtraBold"
    } else {
        name = "Inter-Regular"
    }
    if UIFont(name: name, size: size) != nil {
        return .custom(name, size: size)
    }
    return .system(size: size, weight: weight)
}

// MARK: - COLORS
private struct StoryTheme {
    static let bg = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let primary = Color(red: 0.30, green: 0.27, blue: 0.90)
    static let primaryLight = Color(red: 0.93, green: 0.93, blue: 1.0)
    static let dark = Color(red: 0.11, green: 0.11, blue: 0.20)
    static let gray = Color(red: 0.53, green: 0.54, blue: 0.61)
    static let orangeBadge = Color(red: 1.0, green: 0.55, blue: 0.16)
    static let greenBadge = Color(red: 0.15, green: 0.71, blue: 0.51)
}

// MARK: - API READY MODELS
struct FeaturedStory: Identifiable, Decodable {
    var id: String
    var title: String
    var category: String
    var duration: String
    var imageUrl: String
    var isFromSchool: Bool
    enum CodingKeys: String, CodingKey { case id, title, category, duration, imageUrl = "image_url", isFromSchool = "is_from_school" }
}

struct ContinueListeningItem: Identifiable, Decodable {
    var id: String
    var title: String
    var imageUrl: String
    var progress: Double
    enum CodingKeys: String, CodingKey { case id, title, imageUrl = "image_url", progress }
}

struct StoryShelf: Identifiable, Decodable {
    var id: String
    var title: String
    var countText: String
    var icon: String
    var startHex: String
    var endHex: String
    enum CodingKeys: String, CodingKey { case id, title, countText = "count_text", icon, startHex, endHex }
}

struct RecentStory: Identifiable, Decodable {
    var id: String
    var title: String
    var duration: String
    var isVideo: Bool
    var isFromSchool: Bool
    var imageUrl: String
    enum CodingKeys: String, CodingKey { case id, title, duration, isVideo = "is_video", isFromSchool = "is_from_school", imageUrl = "image_url" }
}

struct PopularStory: Identifiable, Decodable {
    var id: String
    var title: String
    var category: String
    var format: String
    var isVideo: Bool
    var plays: String
    var imageUrl: String
    enum CodingKeys: String, CodingKey { case id, title, category, format, isVideo = "is_video", plays, imageUrl = "image_url" }
}

// MARK: - VIEWMODEL (DUMMY NOW, API LATER)
class StoriesViewModel: ObservableObject {
    @Published var featured: FeaturedStory?
    @Published var continueItem: ContinueListeningItem?
    @Published var shelves: [StoryShelf] = []
    @Published var recent: [RecentStory] = []
    @Published var popular: [PopularStory] = []
    @Published var selectedFilter = "All"
    let filters = ["All","Videos","Audio"]

    init() { loadMock() }

    func loadMock() {
        featured = FeaturedStory(id: "f1", title: "The Monkey Who\nJudged Too Soon", category: "Moral", duration: "12 min", imageUrl: "https://images.unsplash.com/photo-1540573133985-87b6da6d54a9?q=80&w=800&auto=format&fit=crop", isFromSchool: true)
        continueItem = ContinueListeningItem(id: "c1", title: "The Parrot's Spicy Mistake", imageUrl: "https://images.unsplash.com/photo-1552728089-57bdde30beb3?q=80&w=200&auto=format&fit=crop", progress: 0.45)
        shelves = [
            StoryShelf(id: "s1", title: "Moral\nStories", countText: "24 stories", icon: "sparkles", startHex: "#FFC992", endHex: "#F08A4B"),
            StoryShelf(id: "s2", title: "Bedtime\nStories", countText: "18 stories", icon: "moon.stars.fill", startHex: "#FFBDD0", endHex: "#F06B93"),
            StoryShelf(id: "s3", title: "Fables", countText: "15 stories", icon: "book.closed.fill", startHex: "#9BDFB3", endHex: "#43B982")
        ]
        recent = [
            RecentStory(id: "r1", title: "The Parrot's Spicy\nMistake", duration: "12:34", isVideo: false, isFromSchool: false, imageUrl: "https://images.unsplash.com/photo-1552728089-57bdde30beb3?q=80&w=400&auto=format&fit=crop"),
            RecentStory(id: "r2", title: "The Clever Crow", duration: "10:05", isVideo: true, isFromSchool: true, imageUrl: "https://images.unsplash.com/photo-1555169062-013468b47731?q=80&w=400&auto=format&fit=crop"),
            RecentStory(id: "r3", title: "The Honest\nWoodcutter", duration: "11:40", isVideo: false, isFromSchool: false, imageUrl: "https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=400&auto=format&fit=crop")
        ]
        popular = [
            PopularStory(id: "p1", title: "The Monkey Who Judged Too Soon", category: "Moral", format: "Video", isVideo: true, plays: "12k plays", imageUrl: "https://images.unsplash.com/photo-1540573133985-87b6da6d54a9?q=80&w=300&auto=format&fit=crop"),
            PopularStory(id: "p2", title: "The Clever Crow", category: "Fables", format: "Video", isVideo: true, plays: "9.4k plays", imageUrl: "https://images.unsplash.com/photo-1555169062-013468b47731?q=80&w=300&auto=format&fit=crop"),
            PopularStory(id: "p3", title: "The Parrot's Spicy Mistake", category: "Bedtime", format: "Audio", isVideo: false, plays: "7.8k plays", imageUrl: "https://images.unsplash.com/photo-1552728089-57bdde30beb3?q=80&w=300&auto=format&fit=crop")
        ]
    }

    var filteredRecent: [RecentStory] {
        if selectedFilter == "Videos" { return recent.filter { $0.isVideo } }
        if selectedFilter == "Audio" { return recent.filter { !$0.isVideo } }
        return recent
    }
}

// MARK: - FIXED REMOTE IMAGE (Strictly constrained - stops width overflow)
private struct StoryHomeRemoteImage: View {
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

// MARK: - MAIN VIEW
struct StoriesHomeView: View {
    var onBack: (() -> Void)? = nil
    var onDIYTap: (() -> Void)? = nil
    var onSeeAllRecent: (() -> Void)? = nil
    var onWatchNow: (() -> Void)? = nil              // ✅ ADDED
    @StateObject private var vm = StoriesViewModel()

    var body: some View {
        // FIXED: Removed outer fixed ZStack, topBar no longer floats over scrolled content
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroView

                VStack(spacing: 16) {
                    continueCard
                    filterPills
                    shelfSection
                    recentSection
                    popularSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity) // FIXED
            }
            .frame(maxWidth: .infinity) // FIXED: content width = screen width
        }
        .background(StoryTheme.bg)
        .ignoresSafeArea(edges: .top)
        .background(StoryTheme.bg.ignoresSafeArea())
    }

    // MARK: Top Bar
    private var topBar: some View {
        HStack(spacing: 10) {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 0) {
                Button(action: { onDIYTap?() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "wand.and.stars").font(.system(size: 11, weight: .bold))
                        Text("DIY").font(inter(.semibold, 12))
                    }
                    .foregroundColor(.white.opacity(0.95))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                }
                HStack(spacing: 4) {
                    Image(systemName: "book.fill").font(.system(size: 11))
                    Text("Stories").font(inter(.bold, 12))
                }
                .foregroundColor(StoryTheme.primary)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
            }
            .padding(3)
            .background(Color.white.opacity(0.28))
            .clipShape(Capsule())
            Spacer()
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 54)
        .background(
            LinearGradient(colors: [.black.opacity(0.35), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 120).ignoresSafeArea(edges: .top), alignment: .top
        )
    }

    // MARK: Hero
    private var heroView: some View {
        ZStack(alignment: .bottomLeading) {
            // FIXED: Was AsyncImage - now constrained image
            StoryHomeRemoteImage(urlString: vm.featured?.imageUrl ?? "")
                .frame(maxWidth: .infinity)
                .frame(height: 430)
                .clipped()

            LinearGradient(colors: [.black.opacity(0.05), .black.opacity(0.25), .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                .frame(maxWidth: .infinity)
                .frame(height: 430)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text("Featured story").font(inter(.semibold, 10)).foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.white.opacity(0.28)).clipShape(Capsule())
                    Text(vm.featured?.category ?? "Moral").font(inter(.bold, 10)).foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(StoryTheme.orangeBadge).clipShape(Capsule())
                    Text("From your school").font(inter(.bold, 10)).foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(StoryTheme.greenBadge).clipShape(Capsule())
                }
                Text(vm.featured?.title ?? "")
                    .font(inter(.bold, 26)).foregroundColor(.white).lineSpacing(2)

                HStack(spacing: 12) {
                    Label("Listen", systemImage: "headphones").font(inter(.medium, 11))
                    Label("Read", systemImage: "book").font(inter(.medium, 11))
                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.system(size: 11))
                        Text(vm.featured?.duration ?? "12 min").font(inter(.medium, 11))
                    }
                }
                .foregroundColor(.white.opacity(0.92))

                HStack(spacing: 10) {
                    Button(action: { onWatchNow?() }) {                                   // ✅ CHANGED (was `Button(action: {})`)
                        HStack(spacing: 7) {
                            Image(systemName: "play.fill").font(.system(size: 11))
                            Text("Watch now").font(inter(.bold, 14))
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 46)
                        .background(StoryTheme.primary).clipShape(Capsule())
                    }
                    Button(action: {}) {
                        Text("Read").font(inter(.bold, 14)).foregroundColor(.white)
                            .frame(width: 98, height: 46)
                            .background(Color.white.opacity(0.26)).clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20).padding(.bottom, 22)
            .frame(maxWidth: .infinity, alignment: .leading)

            // FIXED: topBar inside hero - scrolls away, no overlap on lower sections
            VStack(spacing: 0) {
                topBar
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 430)
        }
        .frame(height: 430).frame(maxWidth: .infinity)
        .clipShape(BottomRounded(radius: 26))
    }

    // MARK: Continue
    private var continueCard: some View {
        HStack(spacing: 11) {
            // FIXED: Was AsyncImage
            StoryHomeRemoteImage(urlString: vm.continueItem?.imageUrl ?? "")
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 3) {
                Text("Continue listening").font(inter(.semibold, 11)).foregroundColor(StoryTheme.primary)
                Text(vm.continueItem?.title ?? "").font(inter(.bold, 13)).foregroundColor(StoryTheme.dark).lineLimit(1)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(StoryTheme.primary.opacity(0.15)).frame(height: 4)
                        Capsule().fill(StoryTheme.primary).frame(width: geo.size.width * CGFloat(vm.continueItem?.progress ?? 0.45), height: 4)
                    }
                }
                .frame(height: 4).padding(.top, 4)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "play.fill").font(.system(size: 13)).foregroundColor(.white)
                    .frame(width: 40, height: 40).background(StoryTheme.primary).clipShape(Circle())
            }
        }
        .padding(12).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private var filterPills: some View {
        HStack(spacing: 8) {
            ForEach(vm.filters, id: \.self) { f in
                FilterPillButton(
                    title: f,
                    isSelected: vm.selectedFilter == f,
                    action: {
                        withAnimation { vm.selectedFilter = f }
                    }
                )
            }
            Spacer()
        }
    }

    // MARK: Shelves
    private var shelfSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Story shelves").font(inter(.bold, 18)).foregroundColor(StoryTheme.dark)
                Text("Pick a mood").font(inter(.regular, 12)).foregroundColor(StoryTheme.gray)
            }
            HStack(spacing: 10) {
                ForEach(vm.shelves) { s in
                    ZStack(alignment: .topLeading) {
                        LinearGradient(colors: [Color(storyHex: s.startHex), Color(storyHex: s.endHex)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        Circle().fill(Color.white.opacity(0.18)).frame(width: 80, height: 80).offset(x: 50, y: 70)
                        VStack(alignment: .leading, spacing: 0) {
                            Image(systemName: s.icon).font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                                .frame(width: 28, height: 28).background(Color.white.opacity(0.32)).clipShape(Circle())
                            Spacer()
                            Text(s.title).font(inter(.bold, 13)).foregroundColor(.white).lineLimit(2)
                            Text(s.countText).font(inter(.medium, 10.5)).foregroundColor(.white.opacity(0.9)).padding(.top, 2)
                        }
                        .padding(12)
                    }
                    .frame(maxWidth: .infinity).frame(height: 126)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Recent
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recently added").font(inter(.bold, 18)).foregroundColor(StoryTheme.dark)
                    Text("New this week").font(inter(.regular, 12)).foregroundColor(StoryTheme.gray)
                }
                Spacer()
                Button(action: { onSeeAllRecent?() }) {
                    Text("See all").font(inter(.semibold, 12.5)).foregroundColor(StoryTheme.primary)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.filteredRecent) { r in
                        VStack(alignment: .leading, spacing: 7) {
                            // FIXED: Was AsyncImage + Spacer() VStack inside ZStack
                            StoryHomeRemoteImage(urlString: r.imageUrl)
                                .frame(width: 132, height: 160)
                                .overlay(alignment: .top) {
                                    if r.isFromSchool {
                                        Text("From school").font(inter(.bold, 8)).foregroundColor(.white)
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(StoryTheme.greenBadge).clipShape(Capsule())
                                            .padding(.top, 8)
                                    }
                                }
                                .overlay(alignment: .bottomLeading) {
                                    HStack(spacing: 4) {
                                        Image(systemName: r.isVideo ? "video.fill" : "headphones").font(.system(size: 8, weight: .bold))
                                        Text(r.duration).font(inter(.bold, 9.5))
                                    }
                                    .foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 5)
                                    .background(Color.black.opacity(0.62)).clipShape(Capsule())
                                    .padding(8)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 18))

                            Text(r.title).font(inter(.bold, 12)).foregroundColor(StoryTheme.dark).lineLimit(2)
                                .frame(width: 132, height: 32, alignment: .topLeading)
                        }
                        .frame(width: 132)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Popular
    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Popular stories").font(inter(.bold, 18)).foregroundColor(StoryTheme.dark)
                Text("Loved by families").font(inter(.regular, 12)).foregroundColor(StoryTheme.gray)
            }
            VStack(spacing: 0) {
                ForEach(vm.popular.indices, id: \.self) { idx in
                    let p = vm.popular[idx]
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            // FIXED: Was AsyncImage
                            StoryHomeRemoteImage(urlString: p.imageUrl)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 16))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(p.title).font(inter(.bold, 13)).foregroundColor(StoryTheme.dark).lineLimit(2)
                                HStack(spacing: 5) {
                                    Text(p.category).font(inter(.medium, 11))
                                    Text("•").opacity(0.5)
                                    HStack(spacing: 3) {
                                        Image(systemName: p.isVideo ? "video" : "headphones").font(.system(size: 9))
                                        Text(p.format)
                                    }.font(inter(.regular, 11))
                                    Text("•").opacity(0.5)
                                    Text(p.plays).font(inter(.medium, 11))
                                }
                                .foregroundColor(StoryTheme.gray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "play.fill").font(.system(size: 11)).foregroundColor(StoryTheme.primary)
                                    .frame(width: 34, height: 34).background(StoryTheme.primaryLight).clipShape(Circle())
                            }
                        }
                        .padding(.vertical, 11)
                        if idx < vm.popular.count - 1 {
                            Divider().background(Color.gray.opacity(0.12)).padding(.leading, 72)
                        }
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 4)
            .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Subviews
private struct FilterPillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if title == "Videos" {
                    Image(systemName: "video").font(.system(size: 12, weight: .semibold))
                }
                if title == "Audio" {
                    Image(systemName: "headphones").font(.system(size: 12, weight: .semibold))
                }
                Text(title).font(inter(.semibold, 12.5))
            }
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(isSelected ? StoryTheme.primary : Color.white)
            .foregroundColor(isSelected ? .white : StoryTheme.dark)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.gray.opacity(0.12), lineWidth: isSelected ? 0 : 1))
        }
    }
}

// MARK: - Helpers
private struct BottomRounded: Shape {
    var radius: CGFloat = 26
    func path(in rect: CGRect) -> Path {
        let p = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
        return Path(p.cgPath)
    }
}

private extension Color {
    init(storyHex: String) {
        let h = storyHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r, g, b: Double
        if h.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        } else {
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }
}

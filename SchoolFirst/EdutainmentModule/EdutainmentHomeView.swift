//
//  EdutainmentHomeView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 13/11/26.
//

import SwiftUI

// MARK: - Models for API integration readiness
struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let dotColor: Color?
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let categoryColor: Color
    let duration: String
    let topic: String
    let difficulty: String
    let filledDots: Int
    let likes: String
    let imageUrl: String
}

struct TrendingItem: Identifiable {
    let id = UUID()
    let rank: Int
    let title: String
    let categoryTopic: String
    let duration: String
    let likes: String
    let views: String
    let imageUrl: String
}

// MARK: - Font Helper (Configured for "Inter")
extension Font {
    static func inter(_ style: InterWeight = .regular, size: CGFloat) -> Font {
        return .custom(style.rawValue, size: size)
    }
}

enum InterWeight: String {
    case regular = "Inter-Regular"
    case medium = "Inter-Medium"
    case semiBold = "Inter-SemiBold"
    case bold = "Inter-Bold"
    case extraBold = "Inter-ExtraBold"
}

// MARK: - Theme Colors
struct AppColors {
    static let primary = Color(red: 0.31, green: 0.28, blue: 0.92) // #4E46E5
    static let background = Color(red: 0.97, green: 0.98, blue: 1.0)
    static let textDark = Color(red: 0.10, green: 0.10, blue: 0.18)
    static let textGray = Color(red: 0.52, green: 0.53, blue: 0.60)
    static let pillBackground = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let orangeBadge = Color(red: 0.98, green: 0.53, blue: 0.18)
}

// MARK: - Main SwiftUI View
struct EdutainmentHomeView: View {
    // Navigation callbacks
    var onBack: (() -> Void)? = nil
    var onSeeAllExplore: (() -> Void)? = nil
    var onStoriesTap: (() -> Void)? = nil

    @State private var searchText = ""
    @State private var selectedCategoryIndex: Int = 0

    let categories: [CategoryItem] = [
        CategoryItem(name: "All", dotColor: nil),
        CategoryItem(name: "Crafts", dotColor: Color(red: 0.98, green: 0.53, blue: 0.18)),
        CategoryItem(name: "Science", dotColor: Color(red: 0.22, green: 0.72, blue: 0.49)),
        CategoryItem(name: "Art", dotColor: Color(red: 0.92, green: 0.34, blue: 0.55))
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                // 1. Navigation Header
                topBarView

                // 2. Welcome Title
                headerGreetingView

                // 3. Search Bar
                searchBarView

                // 4. DIY / Stories Toggle Switch
                tabSwitcher

                // 5. Category Horizontal Filter Pills
                categoryPillsSection

                // 6. Featured Hero Banner
                featuredCardView

                // 7. Explore DIY Activities Section
                exploreActivitiesSection

                // 8. Trending Now Section
                trendingSection

                // 9. Recently Added Section
                recentlyAddedSection

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(AppColors.background.ignoresSafeArea())
    }

    // MARK: - Top Bar
    private var topBarView: some View {
        HStack {
            Button(action: {
                onBack?()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textDark)
                    .frame(width: 42, height: 42)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            }

            Spacer()

            Button(action: {}) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textDark)
                        .frame(width: 42, height: 42)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)

                    Circle()
                        .fill(AppColors.orangeBadge)
                        .frame(width: 9, height: 9)
                        .offset(x: -8, y: 9)
                }
            }

            // User Profile Circle
            Text("AS")
                .font(.inter(.bold, size: 14))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(AppColors.primary)
                .clipShape(Circle())
        }
    }

    // MARK: - Greeting Section
    private var headerGreetingView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Good morning, Priya")
                .font(.inter(.medium, size: 13))
                .foregroundColor(AppColors.textGray)

            HStack(spacing: 0) {
                Text("What will you \nmake ")
                    .foregroundColor(AppColors.textDark) +
                Text("today?")
                    .foregroundColor(AppColors.primary)
            }
            .font(.inter(.bold, size: 26))
            .lineSpacing(2)
        }
    }

    // MARK: - Search Bar
    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textGray)
                .font(.system(size: 16))

            TextField("Search ideas or enter video no.", text: $searchText)
                .font(.inter(.regular, size: 14))
                .foregroundColor(AppColors.textDark)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - DIY / Stories Segment Switcher
    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            // DIY (Active on this Home screen)
            HStack(spacing: 8) {
                Image(systemName: "scissors")
                    .font(.system(size: 14, weight: .bold))
                Text("DIY")
                    .font(.inter(.bold, size: 14))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(AppColors.primary)
            .clipShape(Capsule())

            // Stories (Index 1 - tapping navigates to StoriesVC)
            Button(action: {
                onStoriesTap?()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 14))
                    Text("Stories")
                        .font(.inter(.medium, size: 14))
                }
                .foregroundColor(AppColors.textGray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.white)
                .clipShape(Capsule())
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Horizontal Category Pills
    private var categoryPillsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<categories.count, id: \.self) { index in
                    let category = categories[index]
                    let isSelected = selectedCategoryIndex == index

                    Button(action: { selectedCategoryIndex = index }) {
                        HStack(spacing: 6) {
                            if let dotColor = category.dotColor {
                                Circle()
                                    .fill(dotColor)
                                    .frame(width: 7, height: 7)
                            }
                            Text(category.name)
                                .font(.inter(.semiBold, size: 13))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(isSelected ? AppColors.primary : Color.white)
                        .foregroundColor(isSelected ? .white : AppColors.textDark)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }

    // MARK: - Featured Hero Card
    private var featuredCardView: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=800&auto=format&fit=crop")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.2))
            }
            .frame(height: 200)
            .clipped()

            // Dark gradient overlay
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Top-left "Featured Today" badge
            VStack {
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                        Text("Featured today")
                            .font(.inter(.bold, size: 10))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())

                    Spacer()
                }
                Spacer()
            }
            .padding(14)

            // Play Icon Button
            HStack {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
            }
            .padding(.trailing, 18)
            .padding(.bottom, 48)

            // Bottom Content Information
            VStack(alignment: .leading, spacing: 5) {
                Text("Paper Bag Tree Craft")
                    .font(.inter(.bold, size: 18))
                    .foregroundColor(.white)

                Text("Crafts · Topic: Reuse and recycling")
                    .font(.inter(.medium, size: 11))
                    .foregroundColor(Color.white.opacity(0.85))

                HStack(spacing: 8) {
                    Text("12 min")
                    Text("·")
                    HStack(spacing: 3) {
                        Text("Easy")
                        Circle().fill(AppColors.orangeBadge).frame(width: 5, height: 5)
                        Circle().fill(AppColors.orangeBadge).frame(width: 5, height: 5)
                        Circle().fill(Color.white.opacity(0.5)).frame(width: 5, height: 5)
                    }
                    Text("·")
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                        Text("1.2k")
                    }
                }
                .font(.inter(.regular, size: 11))
                .foregroundColor(Color.white.opacity(0.9))
                .padding(.top, 2)
            }
            .padding(14)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    // MARK: - Explore DIY Activities
    private var exploreActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "Explore DIY Activities",
                subtitle: "Hands-on ideas for every day",
                onSeeAll: {
                    onSeeAllExplore?()
                }
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ExploreCardView(
                        timeBadge: "08:10",
                        tagText: "Crafts",
                        tagColor: AppColors.orangeBadge,
                        title: "Egg Carton Flower\nGarden",
                        topic: "Parts of a flower",
                        difficulty: "Easy",
                        dots: (1, 2),
                        likes: "812",
                        imageUrl: "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?q=80&w=400&auto=format&fit=crop"
                    )

                    ExploreCardView(
                        timeBadge: "06:45",
                        tagText: "Science",
                        tagColor: AppColors.primary,
                        title: "Magic Colour-\nChanging Milk",
                        topic: "Surface tension",
                        difficulty: "Medium",
                        dots: (2, 1),
                        likes: "640",
                        imageUrl: "https://images.unsplash.com/photo-1530595467537-0b5996c41f2d?q=80&w=400&auto=format&fit=crop"
                    )
                }
            }
        }
    }

    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Trending now", subtitle: "Most made this week")

            VStack(spacing: 14) {
                TrendingRowView(
                    rank: 1,
                    title: "Magic Colour-Changing Milk",
                    subtitle: "Science · Surface tension · 8 min",
                    likes: "640",
                    views: "3.4k",
                    imageUrl: "https://images.unsplash.com/photo-1530595467537-0b5996c41f2d?q=80&w=300&auto=format&fit=crop"
                )

                TrendingRowView(
                    rank: 2,
                    title: "Egg Carton Flower Garden",
                    subtitle: "Crafts · Parts of a flower · 8 min",
                    likes: "812",
                    views: "2.9k",
                    imageUrl: "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?q=80&w=300&auto=format&fit=crop"
                )

                TrendingRowView(
                    rank: 3,
                    title: "Plastic Bottle Pencil Holder",
                    subtitle: "Recycling · Reuse of plastic · 9 min",
                    likes: "455",
                    views: "2.1k",
                    imageUrl: "https://images.unsplash.com/photo-1588072432836-e10032774350?q=80&w=300&auto=format&fit=crop"
                )
            }
        }
    }

    // MARK: - Recently Added Section
    private var recentlyAddedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Recently added", subtitle: "Fresh from this week")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    RecentCardView(
                        badge: "NEW",
                        title: "Paper Bag Tree Craft",
                        subtitle: "Crafts · Reuse and recycling",
                        imageUrl: "https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400&auto=format&fit=crop"
                    )

                    RecentCardView(
                        badge: "NEW",
                        title: "Rainbow Bottle ...",
                        subtitle: "Science · Density ...",
                        imageUrl: "https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?q=80&w=400&auto=format&fit=crop"
                    )
                }
            }
        }
    }
}

// MARK: - Subcomponents

struct SectionHeaderView: View {
    let title: String
    let subtitle: String
    var onSeeAll: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.inter(.bold, size: 18))
                    .foregroundColor(AppColors.textDark)
                Text(subtitle)
                    .font(.inter(.regular, size: 12))
                    .foregroundColor(AppColors.textGray)
            }
            Spacer()
            Button(action: {
                onSeeAll?()
            }) {
                Text("See all")
                    .font(.inter(.semiBold, size: 12))
                    .foregroundColor(AppColors.primary)
            }
        }
    }
}

struct ExploreCardView: View {
    let timeBadge: String
    let tagText: String
    let tagColor: Color
    let title: String
    let topic: String
    let difficulty: String
    let dots: (filled: Int, empty: Int)
    let likes: String
    let imageUrl: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: imageUrl)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.15))
                }
                .frame(width: 170, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(timeBadge)
                    .font(.inter(.bold, size: 9))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Capsule())
                    .padding(8)
            }

            Text(tagText)
                .font(.inter(.semiBold, size: 10))
                .foregroundColor(tagColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(tagColor.opacity(0.12))
                .clipShape(Capsule())

            Text(title)
                .font(.inter(.bold, size: 13))
                .foregroundColor(AppColors.textDark)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 4) {
                Image(systemName: "book")
                    .font(.system(size: 9))
                Text(topic)
                    .font(.inter(.medium, size: 11))
            }
            .foregroundColor(AppColors.primary)

            HStack {
                HStack(spacing: 3) {
                    ForEach(0..<dots.filled, id: \.self) { _ in
                        Circle().fill(AppColors.orangeBadge).frame(width: 4, height: 4)
                    }
                    ForEach(0..<dots.empty, id: \.self) { _ in
                        Circle().fill(Color.gray.opacity(0.3)).frame(width: 4, height: 4)
                    }
                    Text(difficulty)
                        .font(.inter(.regular, size: 10))
                        .foregroundColor(AppColors.textGray)
                }

                Spacer()

                HStack(spacing: 3) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Color.pink.opacity(0.7))
                    Text(likes)
                        .font(.inter(.medium, size: 10))
                        .foregroundColor(AppColors.textGray)
                }
            }
        }
        .padding(10)
        .frame(width: 190)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

struct TrendingRowView: View {
    let rank: Int
    let title: String
    let subtitle: String
    let likes: String
    let views: String
    let imageUrl: String

    var body: some View {
        HStack(spacing: 12) {
            // Rank Number
            Text("\(rank)")
                .font(.inter(.extraBold, size: 30))
                .foregroundColor(AppColors.primary.opacity(0.25))
                .frame(width: 25)

            // Thumbnail
            AsyncImage(url: URL(string: imageUrl)) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.15))
            }
            .frame(width: 62, height: 62)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Details
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.inter(.bold, size: 13))
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.inter(.regular, size: 11))
                    .foregroundColor(AppColors.textGray)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 8))
                            .foregroundColor(Color.pink.opacity(0.7))
                        Text(likes)
                    }

                    HStack(spacing: 3) {
                        Image(systemName: "eye")
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.textGray)
                        Text(views)
                    }
                }
                .font(.inter(.regular, size: 10))
                .foregroundColor(AppColors.textGray)
            }

            Spacer()

            // Circular Play Button
            Button(action: {}) {
                Image(systemName: "play.fill")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 32, height: 32)
                    .background(AppColors.primary.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }
}

struct RecentCardView: View {
    let badge: String
    let title: String
    let subtitle: String
    let imageUrl: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: imageUrl)) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.15))
            }
            .frame(width: 210, height: 130)
            .clipped()

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                HStack {
                    Text(badge)
                        .font(.inter(.bold, size: 9))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.orangeBadge)
                        .clipShape(Capsule())
                    Spacer()
                }
                Spacer()
            }
            .padding(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.inter(.bold, size: 13))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.inter(.regular, size: 10))
                    .foregroundColor(Color.white.opacity(0.8))
                    .lineLimit(1)
            }
            .padding(10)
        }
        .frame(width: 210, height: 130)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

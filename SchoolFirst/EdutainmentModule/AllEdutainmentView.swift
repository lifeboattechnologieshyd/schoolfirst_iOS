//
//  AllEdutainmentView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 13/11/26.
//

import SwiftUI

// MARK: - Safe Models for API Integration
enum EdutainmentMediaContent {
    case video(duration: String)
    case photos(count: Int)
}

struct EdutainmentActivityModel: Identifiable {
    let id = UUID()
    let mediaContent: EdutainmentMediaContent
    let category: String
    let categoryColor: Color
    let categoryBgColor: Color
    let title: String
    let topic: String
    let filledDots: Int
    let likes: String
    let imageUrl: String
}

// MARK: - Safe Font Loader (Inter Font with System Fallback)
private func appFont(_ weight: Font.Weight, size: CGFloat) -> Font {
    let fontName: String
    switch weight {
    case .regular: fontName = "Inter-Regular"
    case .medium:  fontName = "Inter-Medium"
    case .semibold: fontName = "Inter-SemiBold"
    case .bold:    fontName = "Inter-Bold"
    default:       fontName = "Inter-Regular"
    }
    
    // Uses Inter if added to Info.plist; otherwise cleanly falls back to system font
    if UIFont(name: fontName, size: size) != nil {
        return .custom(fontName, size: size)
    }
    return .system(size: size, weight: weight)
}

// MARK: - Color Palette
private struct Palette {
    static let primary = Color(red: 0.31, green: 0.28, blue: 0.92)         // #4E46E5
    static let background = Color(red: 0.97, green: 0.98, blue: 1.0)
    static let textDark = Color(red: 0.10, green: 0.10, blue: 0.18)
    static let textGray = Color(red: 0.52, green: 0.53, blue: 0.60)
    
    static let craftOrange = Color(red: 0.95, green: 0.51, blue: 0.15)
    static let craftOrangeBg = Color(red: 1.0, green: 0.95, blue: 0.88)
    
    static let sciencePurple = Color(red: 0.35, green: 0.32, blue: 0.92)
    static let sciencePurpleBg = Color(red: 0.93, green: 0.93, blue: 0.99)
    
    static let recyclingGreen = Color(red: 0.16, green: 0.70, blue: 0.52)
    static let recyclingGreenBg = Color(red: 0.89, green: 0.97, blue: 0.94)
    
    static let artPink = Color(red: 0.92, green: 0.32, blue: 0.53)
    static let artPinkBg = Color(red: 0.99, green: 0.91, blue: 0.94)
}

// MARK: - Main SwiftUI View
struct AllEdutainmentView: View {
    var onBack: (() -> Void)? = nil
    
    @State private var selectedCategory: String = "All"
    @State private var selectedSortOption: String = "Newest"
    
    let categories: [String] = ["All", "Crafts", "Science", "Art", "Recycling"]
    
    // Dummy / Static activities matching the Figma screen
    @State private var activities: [EdutainmentActivityModel] = [
        EdutainmentActivityModel(
            mediaContent: .video(duration: "08:10"),
            category: "Crafts",
            categoryColor: Palette.craftOrange,
            categoryBgColor: Palette.craftOrangeBg,
            title: "Egg Carton Flower\nGarden",
            topic: "Parts of a flower",
            filledDots: 1,
            likes: "812",
            imageUrl: "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?q=80&w=400&auto=format&fit=crop"
        ),
        EdutainmentActivityModel(
            mediaContent: .video(duration: "08:45"),
            category: "Science",
            categoryColor: Palette.sciencePurple,
            categoryBgColor: Palette.sciencePurpleBg,
            title: "Magic Colour-\nChanging Milk",
            topic: "Surface tension",
            filledDots: 2,
            likes: "640",
            imageUrl: "https://images.unsplash.com/photo-1530595467537-0b5996c41f2d?q=80&w=400&auto=format&fit=crop"
        ),
        EdutainmentActivityModel(
            mediaContent: .video(duration: "09:20"),
            category: "Recycling",
            categoryColor: Palette.recyclingGreen,
            categoryBgColor: Palette.recyclingGreenBg,
            title: "Bottle Pencil Holder\n",
            topic: "Reuse of plastic",
            filledDots: 1,
            likes: "455",
            imageUrl: "https://images.unsplash.com/photo-1588072432836-e10032774350?q=80&w=400&auto=format&fit=crop"
        ),
        EdutainmentActivityModel(
            mediaContent: .photos(count: 5),
            category: "Crafts",
            categoryColor: Palette.craftOrange,
            categoryBgColor: Palette.craftOrangeBg,
            title: "Paper Bag Tree\nCraft",
            topic: "Reuse and recycling",
            filledDots: 1,
            likes: "1200",
            imageUrl: "https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400&auto=format&fit=crop"
        ),
        EdutainmentActivityModel(
            mediaContent: .video(duration: "07:30"),
            category: "Science",
            categoryColor: Palette.sciencePurple,
            categoryBgColor: Palette.sciencePurpleBg,
            title: "Rainbow Fizz\nExperiment",
            topic: "Acids and bases",
            filledDots: 2,
            likes: "390",
            imageUrl: "https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?q=80&w=400&auto=format&fit=crop"
        ),
        EdutainmentActivityModel(
            mediaContent: .photos(count: 6),
            category: "Art",
            categoryColor: Palette.artPink,
            categoryBgColor: Palette.artPinkBg,
            title: "Pressed Flower\nBookmark",
            topic: "Patterns in nature",
            filledDots: 1,
            likes: "276",
            imageUrl: "https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=400&auto=format&fit=crop"
        )
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // Top Header Nav
                topNavBar
                
                // Title & Count
                titleSection
                
                // Categories
                categoryFilterSection
                
                // Info & Sort Bar
                sortHeaderSection
                
                // 2-Column Activities Grid
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(activities) { item in
                        ActivityGridCardView(item: item)
                    }
                }
                
                // Load More Button
                loadMoreButton
                
                Spacer(minLength: 32)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(Palette.background.ignoresSafeArea())
    }
    
    // MARK: - Top Navigation Bar
    private var topNavBar: some View {
        HStack {
            Button(action: {
                onBack?()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Palette.textDark)
                    .frame(width: 42, height: 42)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Palette.textDark)
                    .frame(width: 42, height: 42)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Explore DIY Activities")
                .font(appFont(.bold, size: 24))
                .foregroundColor(Palette.textDark)
            
            Text("48 activities")
                .font(appFont(.regular, size: 13))
                .foregroundColor(Palette.textGray)
        }
    }
    
    // MARK: - Category Filters
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    let isSelected = (selectedCategory == category)
                    
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(appFont(.semibold, size: 13))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .background(isSelected ? Palette.primary : Color.white)
                            .foregroundColor(isSelected ? .white : Palette.textDark)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    // MARK: - Sort Header Bar
    private var sortHeaderSection: some View {
        HStack {
            Text("Showing 6 of 48")
                .font(appFont(.medium, size: 12))
                .foregroundColor(Palette.textGray)
            
            Spacer()
            
            Menu {
                Button("Newest", action: { selectedSortOption = "Newest" })
                Button("Most Popular", action: { selectedSortOption = "Most Popular" })
                Button("Easiest", action: { selectedSortOption = "Easiest" })
            } label: {
                HStack(spacing: 4) {
                    Text(selectedSortOption)
                        .font(appFont(.semibold, size: 12))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(Palette.primary)
            }
        }
        .padding(.top, 2)
    }
    
    // MARK: - Load More Button
    private var loadMoreButton: some View {
        HStack {
            Spacer()
            Button(action: {
                // Pagination API logic goes here
            }) {
                Text("Load more")
                    .font(appFont(.semibold, size: 13))
                    .foregroundColor(Palette.primary)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            }
            Spacer()
        }
        .padding(.top, 8)
    }
}

// MARK: - Card Component
struct ActivityGridCardView: View {
    let item: EdutainmentActivityModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail Image & Media Tag
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: item.imageUrl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.12))
                }
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Media indicator pill (Video or Photos)
                HStack(spacing: 4) {
                    switch item.mediaContent {
                    case .video(let duration):
                        Image(systemName: "video.fill")
                            .font(.system(size: 8))
                        Text(duration)
                            .font(appFont(.semibold, size: 9))
                    case .photos(let count):
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 8))
                        Text("\(count) photos")
                            .font(appFont(.semibold, size: 9))
                    }
                }
                .foregroundColor(Palette.primary)
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.92))
                .clipShape(Capsule())
                .padding(7)
            }
            
            // Category Badge
            Text(item.category)
                .font(appFont(.semibold, size: 10))
                .foregroundColor(item.categoryColor)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(item.categoryBgColor)
                .clipShape(Capsule())
            
            // Title (strictly two lines high for grid alignment)
            Text(item.title)
                .font(appFont(.bold, size: 12))
                .foregroundColor(Palette.textDark)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 32, alignment: .topLeading)
            
            // Topic with Book Icon
            HStack(spacing: 4) {
                Image(systemName: "book")
                    .font(.system(size: 8))
                Text(item.topic)
                    .font(appFont(.medium, size: 10))
                    .lineLimit(1)
            }
            .foregroundColor(Palette.primary)
            
            // Bottom Row: Difficulty Dots & Likes
            HStack {
                HStack(spacing: 3) {
                    ForEach(0..<item.filledDots, id: \.self) { _ in
                        Circle()
                            .fill(Palette.craftOrange)
                            .frame(width: 4, height: 4)
                    }
                    ForEach(0..<(3 - item.filledDots), id: \.self) { _ in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Color.pink.opacity(0.75))
                    
                    Text(item.likes)
                        .font(appFont(.medium, size: 10))
                        .foregroundColor(Palette.textGray)
                }
            }
            .padding(.top, 2)
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

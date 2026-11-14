//
//  PictureStoryView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 14/11/26.
//

import SwiftUI
import UIKit

// MARK: - FONT
private func pictureStoryInter(_ weight: Font.Weight, _ size: CGFloat) -> Font {
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

private struct PictureStoryTheme {
    static let bg = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let primary = Color(red: 0.30, green: 0.27, blue: 0.90)
    static let primaryLight = Color(red: 0.93, green: 0.93, blue: 1.0)
    static let dark = Color(red: 0.11, green: 0.11, blue: 0.20)
    static let gray = Color(red: 0.55, green: 0.56, blue: 0.63)
    static let greenSolid = Color(red: 0.13, green: 0.77, blue: 0.55)
    static let greenLightBg = Color(red: 0.86, green: 0.96, blue: 0.90)
    static let greenDarkText = Color(red: 0.10, green: 0.55, blue: 0.40)
    static let blueLightBg = Color(red: 0.90, green: 0.91, blue: 1.0)
    static let pageCardBg = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let pinkHeart = Color(red: 1.0, green: 0.45, blue: 0.58)
    static let whatsappGreen = Color(red: 0.15, green: 0.75, blue: 0.45)
}

// MARK: - API READY MODELS
struct PictureStoryPage: Identifiable, Decodable {
    var id: String
    var pageNumber: Int
    var text: String
    enum CodingKeys: String, CodingKey { case id, pageNumber = "page_number", text }
}

struct PictureStoryDetail: Decodable {
    var id: String
    var title: String
    var category: String
    var storyNumber: String // #52
    var totalPages: Int
    var language: String
    var isFromSchool: Bool
    var isPictureStory: Bool
    var imageUrl: String
    var likes: String
    var sharesText: String
    var whatsappCount: String
    var commentsCount: String
    var pages: [PictureStoryPage]
    enum CodingKeys: String, CodingKey {
        case id, title, category
        case storyNumber = "story_number"
        case totalPages = "total_pages"
        case language
        case isFromSchool = "is_from_school"
        case isPictureStory = "is_picture_story"
        case imageUrl = "image_url"
        case likes, sharesText = "shares_text", whatsappCount = "whatsapp_count"
        case commentsCount = "comments_count", pages
    }
}

// MARK: - VIEWMODEL - REPLACE MOCK WITH API LATER
class PictureStoryViewModel: ObservableObject {
    @Published var story: PictureStoryDetail?
    @Published var currentPageIndex: Int = 2 // Page 3
    @Published var storyFontSize: CGFloat = 16
    @Published var selectedFeeling: String? = nil
    @Published var isLiked: Bool = false

    init() { loadMock() }

    func loadMock() {
        let pages = [
            PictureStoryPage(id: "1", pageNumber: 1, text: "A thirsty crow flew over the forest in search of water."),
            PictureStoryPage(id: "2", pageNumber: 2, text: "At last, he saw a jar below with very little water in it."),
            PictureStoryPage(id: "3", pageNumber: 3, text: "The crow dropped one small pebble after another into the jar, and slowly the water began to rise."),
            PictureStoryPage(id: "4", pageNumber: 4, text: "He drank the cool water happily and flew away strong."),
            PictureStoryPage(id: "5", pageNumber: 5, text: "The other animals watched and learned to never give up."),
            PictureStoryPage(id: "6", pageNumber: 6, text: "Slow and steady thinking always wins the day."),
            PictureStoryPage(id: "7", pageNumber: 7, text: "The crow told this clever trick to all his friends."),
            PictureStoryPage(id: "8", pageNumber: 8, text: "And they all lived wisely ever after.")
        ]
        story = PictureStoryDetail(
            id: "52", title: "The Clever Crow", category: "Fables",
            storyNumber: "#52", totalPages: 8, language: "English",
            isFromSchool: true, isPictureStory: true,
            imageUrl: "https://images.unsplash.com/photo-1555169062-013468b47731?q=80&w=800&auto=format&fit=crop",
            likes: "1.2k", sharesText: "Share", whatsappCount: "86",
            commentsCount: "24", pages: pages
        )
    }

    // TODO API:
    // func fetchDetail(id: String) async {
    //   let url = URL(string: "https://yourapi.com/picture-story/\(id)")!
    //   let (data,_) = try! await URLSession.shared.data(from: url)
    //   let decoded = try! JSONDecoder().decode(PictureStoryDetail.self, from: data)
    //   await MainActor.run { self.story = decoded }
    // }

    var totalPages: Int { story?.totalPages ?? 8 }
    var currentPage: PictureStoryPage? {
        guard let pages = story?.pages, currentPageIndex < pages.count else { return nil }
        return pages[currentPageIndex]
    }
    func next() { if currentPageIndex < totalPages - 1 { currentPageIndex += 1 } }
    func prev() { if currentPageIndex > 0 { currentPageIndex -= 1 } }
}

// MARK: - MAIN VIEW
struct PictureStoryView: View {
    var onBack: (() -> Void)? = nil
    var onShareTap: (() -> Void)? = nil
    var onCommentTap: (() -> Void)? = nil
    @StateObject private var vm = PictureStoryViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    heroView
                    contentCard
                        .offset(y: -24)
                        .padding(.bottom, -24)
                }
            }
            .background(PictureStoryTheme.bg)
            .ignoresSafeArea(edges: .top)

            topBar
        }
        .background(PictureStoryTheme.bg.ignoresSafeArea())
    }

    // MARK: Top bar over image
    private var topBar: some View {
        HStack {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 10) {
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
                Button(action: { onShareTap?() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 54)
    }

    // MARK: Hero image
    private var heroView: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: vm.story?.imageUrl ?? "")) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(red: 0.22, green: 0.28, blue: 0.25)
            }
            .frame(height: 380)
            .frame(maxWidth: .infinity)
            .clipped()

            LinearGradient(colors: [.clear, .black.opacity(0.45)], startPoint: .center, endPoint: .bottom)

            HStack {
                Spacer()
                // image dots
                HStack(spacing: 5) {
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(i == 0 ? Color.white : Color.white.opacity(0.55))
                            .frame(width: 6, height: 6)
                    }
                }
                Spacer()
                // Page count pill
                HStack(spacing: 4) {
                    Image(systemName: "book.fill").font(.system(size: 9))
                    Text("Page \(vm.currentPageIndex + 1) of \(vm.totalPages)")
                        .font(pictureStoryInter(.semibold, 10))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.black.opacity(0.55))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 36)
        }
        .frame(height: 380)
        .frame(maxWidth: .infinity)
    }

    // MARK: White sheet
    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Badges
            HStack(spacing: 6) {
                Text(vm.story?.category ?? "Fables")
                    .font(pictureStoryInter(.semibold, 10))
                    .foregroundColor(PictureStoryTheme.greenDarkText)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(PictureStoryTheme.greenLightBg)
                    .clipShape(Capsule())
                HStack(spacing: 4) {
                    Image(systemName: "book.fill").font(.system(size: 9))
                    Text("Picture story").font(pictureStoryInter(.semibold, 10))
                }
                .foregroundColor(PictureStoryTheme.primary)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(PictureStoryTheme.blueLightBg)
                .clipShape(Capsule())
                if vm.story?.isFromSchool == true {
                    Text("From school")
                        .font(pictureStoryInter(.bold, 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(PictureStoryTheme.greenSolid)
                        .clipShape(Capsule())
                }
            }

            // Title
            VStack(alignment: .leading, spacing: 3) {
                Text(vm.story?.title ?? "")
                    .font(pictureStoryInter(.bold, 22))
                    .foregroundColor(PictureStoryTheme.dark)
                Text("\(vm.story?.storyNumber ?? "#52") • \(vm.totalPages) pages • \(vm.story?.language ?? "English")")
                    .font(pictureStoryInter(.medium, 12))
                    .foregroundColor(PictureStoryTheme.gray)
            }

            // Reader card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Page \(vm.currentPageIndex + 1)")
                        .font(pictureStoryInter(.semibold, 12))
                        .foregroundColor(PictureStoryTheme.primary)
                    Spacer()
                    Button(action: {
                        if vm.storyFontSize > 13 { vm.storyFontSize -= 1 }
                    }) {
                        Text("A").font(pictureStoryInter(.semibold, 11)).foregroundColor(PictureStoryTheme.gray)
                    }
                    Button(action: {
                        if vm.storyFontSize < 20 { vm.storyFontSize += 1 }
                    }) {
                        Text("A").font(pictureStoryInter(.bold, 15)).foregroundColor(PictureStoryTheme.primary)
                    }
                }
                Text(vm.currentPage?.text ?? "")
                    .font(pictureStoryInter(.medium, vm.storyFontSize))
                    .foregroundColor(PictureStoryTheme.dark)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeInOut(duration: 0.2), value: vm.currentPageIndex)
                    .animation(.easeInOut(duration: 0.2), value: vm.storyFontSize)
            }
            .padding(14)
            .background(PictureStoryTheme.pageCardBg)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            // Prev / dots / Next
            HStack {
                Button(action: { withAnimation { vm.prev() } }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(PictureStoryTheme.primary)
                        .frame(width: 40, height: 40)
                        .background(PictureStoryTheme.primaryLight)
                        .clipShape(Circle())
                        .opacity(vm.currentPageIndex == 0 ? 0.5 : 1.0)
                }
                Spacer()
                HStack(spacing: 5) {
                    ForEach(0..<vm.totalPages, id: \.self) { i in
                        Capsule()
                            .fill(i == vm.currentPageIndex ? PictureStoryTheme.primary : Color.gray.opacity(0.22))
                            .frame(width: i == vm.currentPageIndex ? 16 : 6, height: 6)
                            .animation(.spring(response: 0.3), value: vm.currentPageIndex)
                    }
                }
                Spacer()
                Button(action: { withAnimation { vm.next() } }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(PictureStoryTheme.primary)
                        .clipShape(Circle())
                        .shadow(color: PictureStoryTheme.primary.opacity(0.35), radius: 8, x: 0, y: 4)
                        .opacity(vm.currentPageIndex == vm.totalPages - 1 ? 0.5 : 1.0)
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 2)

            // Like / Share / Whatsapp
            HStack(spacing: 8) {
                Button(action: { vm.isLiked.toggle() }) {
                    HStack(spacing: 5) {
                        Image(systemName: vm.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(PictureStoryTheme.pinkHeart)
                        Text(vm.story?.likes ?? "1.2k")
                            .font(pictureStoryInter(.semibold, 12))
                            .foregroundColor(PictureStoryTheme.dark)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.gray.opacity(0.14), lineWidth: 1))
                }
                Button(action: { onShareTap?() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 12))
                        Text("Share").font(pictureStoryInter(.semibold, 12))
                    }
                    .foregroundColor(PictureStoryTheme.dark)
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.gray.opacity(0.14), lineWidth: 1))
                }
                HStack(spacing: 5) {
                    Image(systemName: "message.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(PictureStoryTheme.whatsappGreen)
                    Text(vm.story?.whatsappCount ?? "86")
                        .font(pictureStoryInter(.semibold, 12))
                        .foregroundColor(PictureStoryTheme.dark)
                }
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.gray.opacity(0.14), lineWidth: 1))
                Spacer()
            }

            // Feelings
            VStack(alignment: .leading, spacing: 8) {
                Text("How did it feel?")
                    .font(pictureStoryInter(.bold, 14))
                    .foregroundColor(PictureStoryTheme.dark)
                HStack(spacing: 8) {
                    PictureFeelingPill(title: "Awesome", emoji: "🤩", isSelected: vm.selectedFeeling == "Awesome", action: { vm.selectedFeeling = "Awesome" })
                    PictureFeelingPill(title: "Made me think", emoji: "🤔", isSelected: vm.selectedFeeling == "Made me think", action: { vm.selectedFeeling = "Made me think" })
                }
                HStack(spacing: 8) {
                    PictureFeelingPill(title: "Loved it", emoji: "🥰", isSelected: vm.selectedFeeling == "Loved it", action: { vm.selectedFeeling = "Loved it" })
                }
            }
            .padding(.top, 2)

            // Comments
            Button(action: { onCommentTap?() }) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color(red: 0.99, green: 0.62, blue: 0.22)).frame(width: 28, height: 28)
                            .overlay(Text("SM").font(pictureStoryInter(.bold, 9)).foregroundColor(.white))
                            .offset(x: 10)
                        Circle().fill(PictureStoryTheme.primary).frame(width: 28, height: 28)
                            .overlay(Text("PK").font(pictureStoryInter(.bold, 9)).foregroundColor(.white))
                            .offset(x: -10)
                    }
                    .frame(width: 48)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("\(vm.story?.commentsCount ?? "24") comments")
                            .font(pictureStoryInter(.bold, 13))
                            .foregroundColor(PictureStoryTheme.dark)
                        Text("Join the conversation")
                            .font(pictureStoryInter(.regular, 11))
                            .foregroundColor(PictureStoryTheme.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(PictureStoryTheme.gray)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: -4)
    }
}

private struct PictureFeelingPill: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(emoji).font(.system(size: 13))
                Text(title).font(pictureStoryInter(.semibold, 12))
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(isSelected ? PictureStoryTheme.primary : Color.white)
            .foregroundColor(isSelected ? .white : PictureStoryTheme.dark)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.clear : Color.gray.opacity(0.16), lineWidth: 1))
        }
    }
}

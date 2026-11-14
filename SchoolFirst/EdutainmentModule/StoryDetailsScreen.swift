//
//  StoryDetailsScreen.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 14/11/26.
//

import SwiftUI

// MARK: - Design Tokens

extension Color {

    /// Renamed from `init(hex:)` -> `init(sfHex:)` because the project
    /// already defines `Color(hex:)` elsewhere (avoids "Invalid redeclaration").
    init(sfHex: String) {
        let hex = sfHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

    static let sfBackground    = Color(sfHex: "F1F1FA")
    static let sfPrimary       = Color(sfHex: "6B4EE8")
    static let sfPrimarySoft   = Color(sfHex: "ECE5FF")
    static let sfTitle         = Color(sfHex: "1E2352")
    static let sfBody          = Color(sfHex: "3D4260")
    static let sfMuted         = Color(sfHex: "9CA0B8")
    static let sfHighlight     = Color(sfHex: "DCE6FF")
    static let sfBorder        = Color(sfHex: "E3E4F0")
    static let sfTagYellowBG   = Color(sfHex: "FFD86B")
    static let sfTagYellowText = Color(sfHex: "6E5200")
    static let sfTagGreenBG    = Color(sfHex: "CDEBD6")
    static let sfTagGreenText  = Color(sfHex: "1E7A46")
}

// MARK: - Models (map these to your API response later)

enum StoryTagStyle { case moral, audio, duration }

struct StoryTag: Identifiable {
    let id = UUID()
    let title: String
    let style: StoryTagStyle
}

struct StorySegment: Identifiable {
    let id = UUID()
    let text: String
    let isHighlighted: Bool   // later you can sync this with audio narration timing
}

struct StoryParagraph: Identifiable {
    let id = UUID()
    let segments: [StorySegment]
}

struct FeelingOption: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    var isSelected: Bool = false
}

struct Reaction: Identifiable {
    let id = UUID()
    let emoji: String
    let countText: String
}

struct Commenter: Identifiable {
    let id = UUID()
    let initials: String
    let colorHex: String
}

struct StoryDetail {
    let id: Int
    let title: String
    let heroImageName: String        // TODO(API): change to heroImageURL: String
    let tags: [StoryTag]
    let storyNumber: Int
    let publishedDate: String
    let language: String
    let paragraphs: [StoryParagraph]
    let reactions: [Reaction]
    var feelings: [FeelingOption]    // ✅ CHANGED: `let` -> `var` so isSelected can toggle
    let commenters: [Commenter]
    let commentsCount: Int
}

// MARK: - Dummy Data (replace with API mapping later)

extension StoryDetail {

    static let dummy = StoryDetail(
        id: 54,
        title: "The Monkey Who Judged Too Soon",
        heroImageName: "hero_monkey",   // add this image to Assets.xcassets
        tags: [
            StoryTag(title: "Moral story", style: .moral),
            StoryTag(title: "Audio story", style: .audio),
            StoryTag(title: "12 min", style: .duration)
        ],
        storyNumber: 54,
        publishedDate: "28 Oct 2026",
        language: "English",
        paragraphs: [
            StoryParagraph(segments: [
                .init(text: "Deep in the green forest lived a young monkey named Momo. Every morning, ", isHighlighted: false),
                .init(text: "Momo watched the tortoise crawl slowly past his tree. “What a lazy creature,” a Momo laughed and swung away without a second thought.", isHighlighted: true)
            ]),
            StoryParagraph(segments: [
                .init(text: "One stormy night, the river rose and the forest creatures had to cross to safety. The tortoise, calm and steady, carried the little ones across, one by one.", isHighlighted: false)
            ]),
            StoryParagraph(segments: [
                .init(text: "Momo watched from the branches, and for the first time he felt small.", isHighlighted: false)
            ])
        ],
        reactions: [
            Reaction(emoji: "❤️", countText: "1.2k"),
            Reaction(emoji: "🤩", countText: "86")
        ],
        feelings: [
            FeelingOption(emoji: "😊", title: "Awesome"),
            FeelingOption(emoji: "🤔", title: "Made me think"),
            FeelingOption(emoji: "🥰", title: "Loved it")
        ],
        commenters: [
            Commenter(initials: "PK", colorHex: "F59E0B"),
            Commenter(initials: "RJ", colorHex: "EF4444"),
            Commenter(initials: "AS", colorHex: "8B5CF6")
        ],
        commentsCount: 24
    )
}

// MARK: - ViewModel

@MainActor
final class StoryDetailsVM: ObservableObject {

    // Data — will be replaced by API response
    @Published var story: StoryDetail = .dummy

    // Audio player (hook AVPlayer / player SDK here later)
    @Published var isPlaying = false
    @Published var currentTime: Double = 4 * 60 + 12      // 04:12
    @Published var totalTime: Double = 12 * 60 + 34       // 12:34
    @Published var speedIndex = 1
    let availableSpeeds: [Double] = [0.5, 1.0, 1.5, 2.0]

    // Read along
    @Published var fontScale: CGFloat = 1.0

    // User states
    @Published var isBookmarked = false
    @Published var isLiked = false

    var speedText: String { String(format: "%.1fx", availableSpeeds[speedIndex]) }
    var currentTimeText: String { timeString(currentTime) }
    var totalTimeText: String { timeString(totalTime) }

    // MARK: Actions (TODO: connect to real player + APIs)

    func togglePlayPause() { isPlaying.toggle() }

    func seek(by delta: Double) {
        currentTime = min(max(0, currentTime + delta), totalTime)
    }

    func cycleSpeed() { speedIndex = (speedIndex + 1) % availableSpeeds.count }

    func increaseFont() { fontScale = min(1.6, fontScale + 0.1) }
    func decreaseFont() { fontScale = max(0.85, fontScale - 0.1) }

    func toggleBookmark() { isBookmarked.toggle() }          // TODO(API)
    func toggleLike()     { isLiked.toggle() }               // TODO(API)

    func toggleFeeling(_ feeling: FeelingOption) {           // TODO(API)
        guard let idx = story.feelings.firstIndex(where: { $0.id == feeling.id }) else { return }
        story.feelings[idx].isSelected.toggle()
    }

    func loadStory() {
        // TODO(API): call your service here and assign result to `story`
    }

    private func timeString(_ seconds: Double) -> String {
        let s = Int(seconds)
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}

// MARK: - Screen

struct StoryDetailsScreen: View {
    @StateObject private var vm = StoryDetailsVM()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.sfBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    HeroSection(
                        imageName: vm.story.heroImageName,
                        isBookmarked: $vm.isBookmarked,
                        onBack: { dismiss() },
                        onShare: { /* TODO: share sheet */ }
                    )

                    VStack(spacing: 18) {
                        StoryHeaderSection(story: vm.story)
                        AudioPlayerCard(vm: vm)
                        ReadAlongSection(vm: vm)
                        ReactionsRow(vm: vm)
                        FeelingsSection(vm: vm)
                        CommentsCard(vm: vm)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Hero

private struct HeroSection: View {
    let imageName: String
    @Binding var isBookmarked: Bool
    let onBack: () -> Void
    let onShare: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // TODO(API): replace with AsyncImage(url: URL(string: heroImageURL))
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(BottomRoundedShape(radius: 24))

            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.2), .clear]),
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 120)

            HStack(spacing: 10) {
                CircleIconButton(systemName: "chevron.left", action: onBack)
                Spacer()
                CircleIconButton(systemName: isBookmarked ? "bookmark.fill" : "bookmark") {
                    isBookmarked.toggle()
                }
                CircleIconButton(systemName: "square.and.arrow.up", action: onShare)
            }
            .padding(.horizontal, 16)
            .padding(.top, 52)
        }
    }
}

private struct CircleIconButton: View {
    let systemName: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.sfTitle)
                .frame(width: 38, height: 38)
                .background(.white.opacity(0.92), in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct BottomRoundedShape: Shape {
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: rect.maxX, y: 0))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        p.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                 radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: true)
        p.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        p.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                 radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: true)
        p.addLine(to: CGPoint(x: 0, y: 0))
        p.closeSubpath()
        return p
    }
}

// MARK: - Header (tags + title + meta)

private struct StoryHeaderSection: View {
    let story: StoryDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ForEach(story.tags) { StoryTagPill(tag: $0) }
                Spacer(minLength: 0)
            }

            Text(story.title)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.sfTitle)
                .fixedSize(horizontal: false, vertical: true)

            Text("#\(story.storyNumber)  ·  \(story.publishedDate)  ·  \(story.language)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.sfMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StoryTagPill: View {
    let tag: StoryTag

    private var bg: Color {
        switch tag.style {
        case .moral: return .sfTagYellowBG
        case .audio: return .sfTagGreenBG
        case .duration: return .white
        }
    }
    private var fg: Color {
        switch tag.style {
        case .moral: return .sfTagYellowText
        case .audio: return .sfTagGreenText
        case .duration: return .sfTitle
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            if tag.style == .audio {
                Image(systemName: "waveform").font(.system(size: 10, weight: .semibold))
            }
            Text(tag.title).font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(bg)
        .foregroundColor(fg)
        .clipShape(Capsule())
    }
}

// MARK: - Audio Player Card

private struct AudioPlayerCard: View {
    @ObservedObject var vm: StoryDetailsVM

    var body: some View {
        VStack(spacing: 14) {

            // Now listening + speed
            HStack(spacing: 6) {
                NowListeningDot(isPlaying: vm.isPlaying)
                Text("Now listening")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.sfBody)
                Spacer()
                Button(action: vm.cycleSpeed) {
                    Text("\(vm.speedText) speed")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.sfPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.sfPrimarySoft, in: Capsule())
                }
                .buttonStyle(.plain)
            }

            // Progress + times
            VStack(spacing: 6) {
                CustomSlider(value: $vm.currentTime, range: 0...max(vm.totalTime, 1))
                HStack {
                    Text(vm.currentTimeText)
                    Spacer()
                    Text(vm.totalTimeText)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.sfMuted)
            }

            // Controls
            HStack(spacing: 26) {
                PlayerControlButton(systemName: "gobackward.10") { vm.seek(by: -10) }

                Button(action: vm.togglePlayPause) {
                    Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 62, height: 62)
                        .background(Circle().fill(Color.sfPrimary))
                        .shadow(color: Color.sfPrimary.opacity(0.4), radius: 10, y: 4)
                }
                .buttonStyle(.plain)

                PlayerControlButton(systemName: "goforward.10") { vm.seek(by: 10) }

                PlayerControlButton(systemName: vm.isBookmarked ? "bookmark.fill" : "bookmark") {
                    vm.toggleBookmark()
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

private struct PlayerControlButton: View {
    let systemName: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.sfTitle)
        }
        .buttonStyle(.plain)
    }
}

private struct NowListeningDot: View {
    let isPlaying: Bool
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(Color.sfPrimary)
            .frame(width: 8, height: 8)
            .scaleEffect(isPlaying && pulse ? 0.55 : 1.0)
            .opacity(isPlaying && pulse ? 0.5 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

private struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let span = max(range.upperBound - range.lowerBound, 0.001)
            let progress = CGFloat(min(max((value - range.lowerBound) / span, 0), 1))

            ZStack(alignment: .leading) {
                Capsule().fill(Color.sfPrimary.opacity(0.15)).frame(height: 6)
                Capsule().fill(Color.sfPrimary).frame(width: max(0, width * progress), height: 6)
                Circle()
                    .fill(Color.white)
                    .frame(width: 18, height: 18)
                    .shadow(color: .black.opacity(0.18), radius: 3)
                    .offset(x: width * progress - 9)
            }
            .frame(height: 20)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { g in
                    let p = min(max(g.location.x / width, 0), 1)
                    value = range.lowerBound + Double(p) * span
                }
            )
        }
        .frame(height: 20)
    }
}

// MARK: - Read Along

private struct ReadAlongSection: View {
    @ObservedObject var vm: StoryDetailsVM

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Text("Read along")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.sfTitle)
                Spacer()
                HStack(spacing: 0) {
                    FontButton(label: "A−", action: vm.decreaseFont)
                    Divider().frame(height: 16).background(Color.sfBorder)
                    FontButton(label: "A+", action: vm.increaseFont)
                }
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.sfBorder, lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 18) {
                ForEach(vm.story.paragraphs) { paragraph in
                    Text(attributed(paragraph))
                        .lineSpacing(7)
                }
            }
        }
    }

    private func attributed(_ paragraph: StoryParagraph) -> AttributedString {
        var result = AttributedString()
        let size = 16 * vm.fontScale
        for segment in paragraph.segments {
            var part = AttributedString(segment.text)
            part.font = .system(size: size)
            part.foregroundColor = segment.isHighlighted ? .sfTitle : .sfBody
            if segment.isHighlighted { part.backgroundColor = .sfHighlight }
            result += part
        }
        return result
    }
}

private struct FontButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.sfTitle)
                .frame(width: 36, height: 30)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reactions

private struct ReactionsRow: View {
    @ObservedObject var vm: StoryDetailsVM

    var body: some View {
        HStack(spacing: 10) {
            if let first = vm.story.reactions.first {
                ReactionPill(reaction: first)
            }

            Button {
                /* TODO: share */
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Share").font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.sfBody)
                .modifier(ChipBackground())
            }
            .buttonStyle(.plain)

            ForEach(vm.story.reactions.dropFirst()) { ReactionPill(reaction: $0) }

            Spacer(minLength: 0)
        }
    }
}

private struct ReactionPill: View {
    let reaction: Reaction

    var body: some View {
        Button {
            /* TODO(API): react */
        } label: {
            HStack(spacing: 6) {
                Text(reaction.emoji).font(.system(size: 14))
                Text(reaction.countText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.sfBody)
            }
            .modifier(ChipBackground())
        }
        .buttonStyle(.plain)
    }
}

private struct ChipBackground: ViewModifier {
    var isSelected: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isSelected ? Color.sfPrimarySoft : Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.sfPrimary : Color.sfBorder, lineWidth: 1))
    }
}

// MARK: - How did it feel?

private struct FeelingsSection: View {
    @ObservedObject var vm: StoryDetailsVM

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How did it feel?")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.sfTitle)

            FlowLayout(spacing: 10) {
                ForEach(vm.story.feelings) { feeling in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.toggleFeeling(feeling)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(feeling.emoji).font(.system(size: 15))
                            Text(feeling.title)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(feeling.isSelected ? .sfPrimary : .sfBody)
                        .modifier(ChipBackground(isSelected: feeling.isSelected))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// Wrapping layout for feeling chips (iOS 16+)
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Comments Card

private struct CommentsCard: View {
    @ObservedObject var vm: StoryDetailsVM

    var body: some View {
        Button {
            /* TODO: push comments screen */
        } label: {
            HStack(spacing: 12) {
                HStack(spacing: -10) {
                    ForEach(vm.story.commenters) { commenter in
                        Text(commenter.initials)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Color(sfHex: commenter.colorHex)))
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(vm.story.commentsCount) comments")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.sfTitle)
                    Text("Join the conversation")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.sfMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.sfMuted)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct StoryDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetailsScreen()
    }
}

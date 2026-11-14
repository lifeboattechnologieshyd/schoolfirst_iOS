import SwiftUI
import UIKit

// MARK: - FONT
private func diyDetailInter(_ weight: Font.Weight, _ size: CGFloat) -> Font {
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

private struct DIYDetailTheme {
    static let bg = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let primary = Color(red: 0.30, green: 0.27, blue: 0.90)
    static let primaryLight = Color(red: 0.93, green: 0.93, blue: 1.0)
    static let dark = Color(red: 0.11, green: 0.11, blue: 0.20)
    static let gray = Color(red: 0.55, green: 0.56, blue: 0.63)
    static let cardGray = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let orange = Color(red: 1.0, green: 0.55, blue: 0.16)
    static let orangeLight = Color(red: 1.0, green: 0.92, blue: 0.84)
    static let green = Color(red: 0.15, green: 0.71, blue: 0.51)
    static let greenLight = Color(red: 0.86, green: 0.96, blue: 0.90)
    static let yellowLight = Color(red: 1.0, green: 0.97, blue: 0.88)
    static let yellowDark = Color(red: 0.65, green: 0.45, blue: 0.12)
    static let pink = Color(red: 1.0, green: 0.45, blue: 0.58)
}

// MARK: - MODELS - API READY
struct DIYDetailMaterial: Identifiable, Decodable {
    var id: String
    var name: String
    var icon: String
    var bgHex: String
    enum CodingKeys: String, CodingKey { case id, name, icon, bgHex = "bg_hex" }
}

struct DIYDetailStep: Identifiable, Decodable {
    var id: String
    var number: Int
    var title: String
    var desc: String?
    var tip: String?
    var imageUrl: String?
    enum CodingKeys: String, CodingKey { case id, number, title, desc, tip, imageUrl = "image_url" }
}

struct DIYDetailInfo: Decodable {
    var id: String
    var title: String
    var meta: String
    var category: String
    var level: String
    var duration: String
    var videoDuration: String
    var heroImage: String
    var likes: String
    var commentsCount: String
    var saves: String
    var subject: String
    var topic: String
    var learnNote: String
    var about: String
    enum CodingKeys: String, CodingKey {
        case id, title, meta, category, level, duration
        case videoDuration = "video_duration"
        case heroImage = "hero_image"
        case likes, commentsCount = "comments_count", saves, subject, topic
        case learnNote = "learn_note", about
    }
}

// MARK: - VIEWMODEL - REPLACE MOCK WITH API LATER
class DIYDetailViewModel: ObservableObject {
    @Published var info: DIYDetailInfo?
    @Published var materials: [DIYDetailMaterial] = []
    @Published var steps: [DIYDetailStep] = []
    @Published var checkedMaterials: Set<String> = ["m1","m2","m3","m4","m5","m6"]
    @Published var showAllSteps = false
    @Published var expandedStep: Int = 1
    @Published var selectedFeeling: String? = nil
    @Published var isLiked = false

    init() { loadMock() }

    func loadMock() {
        info = DIYDetailInfo(
            id: "diy12", title: "DIY Paper Bag Tree Craft",
            meta: "#DIY-12 • Oct 2026 • English • 3.4k views",
            category: "Crafts", level: "Easy", duration: "12 min",
            videoDuration: "12:38",
            heroImage: "https://images.unsplash.com/photo-1502082553048-f009c37129b9?q=80&w=800&auto=format&fit=crop",
            likes: "1.2k", commentsCount: "86", saves: "24",
            subject: "Crafts", topic: "Reuse and recycling",
            learnNote: "Your child will learn how everyday waste can be reused to make something nice.",
            about: "Turn an ordinary brown paper bag into a beautiful handmade tree. Children twist, fold and decorate recycled paper to make a miniature tree with colorful leaves."
        )
        materials = [
            DIYDetailMaterial(id: "m1", name: "Paper bag", icon: "bag.fill", bgHex: "#FFF0DD"),
            DIYDetailMaterial(id: "m2", name: "Scissors", icon: "scissors", bgHex: "#E9E9FF"),
            DIYDetailMaterial(id: "m3", name: "Glue", icon: "drop.fill", bgHex: "#DFF7EA"),
            DIYDetailMaterial(id: "m4", name: "Coloured paper", icon: "doc.fill", bgHex: "#FFE9F0"),
            DIYDetailMaterial(id: "m5", name: "Markers", icon: "pencil", bgHex: "#FFF6D6"),
            DIYDetailMaterial(id: "m6", name: "Ruler", icon: "ruler.fill", bgHex: "#E6F6FF")
        ]
        steps = [
            DIYDetailStep(id: "s1", number: 1, title: "Take a clean paper bag", desc: "Pick a clean, empty brown paper bag and flatten it on the table.", tip: "Tip: an adult can help with the cutting.", imageUrl: "https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=600&auto=format&fit=crop"),
            DIYDetailStep(id: "s2", number: 2, title: "Cut the top into strips", desc: nil, tip: nil, imageUrl: "https://images.unsplash.com/photo-1513364776144-60967b0f800f?q=80&w=200&auto=format&fit=crop"),
            DIYDetailStep(id: "s3", number: 3, title: "Twist the middle into a trunk", desc: nil, tip: nil, imageUrl: "https://images.unsplash.com/photo-1463320726281-696a485928c7?q=80&w=200&auto=format&fit=crop"),
            DIYDetailStep(id: "s4", number: 4, title: "Twist strips into branches", desc: nil, tip: nil, imageUrl: "https://images.unsplash.com/photo-1452860606245-08befc0ff44b?q=80&w=200&auto=format&fit=crop"),
            DIYDetailStep(id: "s5", number: 5, title: "Fold leaves from coloured paper", desc: nil, tip: nil, imageUrl: nil),
            DIYDetailStep(id: "s6", number: 6, title: "Stick leaves on branches", desc: nil, tip: nil, imageUrl: nil),
            DIYDetailStep(id: "s7", number: 7, title: "Decorate with markers", desc: nil, tip: nil, imageUrl: nil),
            DIYDetailStep(id: "s8", number: 8, title: "Display your tree", desc: nil, tip: nil, imageUrl: nil)
        ]
    }

    var visibleSteps: [DIYDetailStep] {
        showAllSteps ? steps : Array(steps.prefix(4))
    }
}

// MARK: - FIXED REMOTE IMAGE (Strictly constrained - stops width overflow)
private struct DIYDetailRemoteImage: View {
    let urlString: String
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            Group {
                if let url = URL(string: urlString), !urlString.isEmpty {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill().frame(width: w, height: h).clipped()
                        } else if phase.error != nil {
                            placeholder
                        } else {
                            ZStack { Color.gray.opacity(0.15); ProgressView() }
                        }
                    }
                } else { placeholder }
            }
            .frame(width: w, height: h)
            .clipped()
        }
    }
    private var placeholder: some View {
        ZStack { Color.gray.opacity(0.15); Image(systemName: "photo").foregroundColor(Color.gray.opacity(0.45)) }
    }
}

// MARK: - MAIN VIEW
struct DIYDetailView: View {
    var onBack: (() -> Void)? = nil
    var onShareTap: (() -> Void)? = nil
    var onCommentTap: (() -> Void)? = nil
    @StateObject private var vm = DIYDetailViewModel()

    var body: some View {
        // FIXED: Removed outer ZStack - topBar no longer floats over scrolled content
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroView
                contentCard
                    .offset(y: -22)
                    .padding(.bottom, -22)
            }
            .frame(maxWidth: .infinity) // FIXED: Forces width = screen width
        }
        .background(DIYDetailTheme.bg)
        .ignoresSafeArea(edges: .top)
        .background(DIYDetailTheme.bg.ignoresSafeArea())
    }

    private var topBar: some View {
        HStack {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.38))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            Spacer()
            HStack(spacing: 10) {
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.38))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                Button(action: { onShareTap?() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.38))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 54)
    }

    private var heroView: some View {
        ZStack {
            // FIXED: Was AsyncImage - now constrained image
            DIYDetailRemoteImage(urlString: vm.info?.heroImage ?? "")
                .frame(maxWidth: .infinity)
                .frame(height: 340)

            LinearGradient(colors: [.black.opacity(0.15), .clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                .frame(height: 340)

            VStack(spacing: 10) {
                Spacer()
                ZStack {
                    Circle().fill(Color.white).frame(width: 56, height: 56)
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DIYDetailTheme.primary)
                        .offset(x: 2)
                }
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)

                HStack(spacing: 5) {
                    Image(systemName: "play.fill").font(.system(size: 9, weight: .bold))
                    Text("Watch Video : \(vm.info?.videoDuration ?? "12:38")")
                        .font(diyDetailInter(.semibold, 11))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Color.black.opacity(0.55))
                .clipShape(Capsule())
                .padding(.bottom, 36)
            }
            .frame(height: 340)

            // FIXED: topBar inside hero - scrolls away, no overlap on Materials/Steps
            VStack(spacing: 0) {
                topBar
                Spacer()
            }
            .frame(height: 340)
        }
        .frame(height: 340)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text(vm.info?.category ?? "Crafts")
                    .font(diyDetailInter(.semibold, 11))
                    .foregroundColor(DIYDetailTheme.orange)
                    .padding(.horizontal, 11).padding(.vertical, 6)
                    .background(DIYDetailTheme.orangeLight)
                    .clipShape(Capsule())
                HStack(spacing: 4) {
                    Text(vm.info?.level ?? "Easy").font(diyDetailInter(.semibold, 11))
                    Image(systemName: "star.fill").font(.system(size: 9))
                }
                .foregroundColor(DIYDetailTheme.yellowDark)
                .padding(.horizontal, 11).padding(.vertical, 6)
                .background(DIYDetailTheme.yellowLight)
                .clipShape(Capsule())
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill").font(.system(size: 10))
                    Text(vm.info?.duration ?? "12 min").font(diyDetailInter(.semibold, 11))
                }
                .foregroundColor(DIYDetailTheme.green)
                .padding(.horizontal, 11).padding(.vertical, 6)
                .background(DIYDetailTheme.greenLight)
                .clipShape(Capsule())
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(vm.info?.title ?? "")
                    .font(diyDetailInter(.bold, 21))
                    .foregroundColor(DIYDetailTheme.dark)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(vm.info?.meta ?? "")
                    .font(diyDetailInter(.medium, 11.5))
                    .foregroundColor(DIYDetailTheme.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 8) {
                DIYStatPill(icon: vm.isLiked ? "heart.fill" : "heart", iconColor: DIYDetailTheme.pink, text: vm.info?.likes ?? "1.2k", action: { vm.isLiked.toggle() })
                DIYStatPill(icon: "message", iconColor: DIYDetailTheme.gray, text: vm.info?.commentsCount ?? "86", action: {})
                DIYStatPill(icon: "square.and.arrow.up", iconColor: DIYDetailTheme.dark, text: "Share", action: { onShareTap?() })
                DIYStatPill(icon: "bookmark", iconColor: DIYDetailTheme.dark, text: vm.info?.saves ?? "24", action: {})
                Spacer()
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Learning focus")
                    .font(diyDetailInter(.bold, 14))
                    .foregroundColor(DIYDetailTheme.dark)
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(DIYDetailTheme.orangeLight).frame(width: 38, height: 38)
                        Image(systemName: "book.fill").font(.system(size: 15)).foregroundColor(DIYDetailTheme.orange)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Subject").font(diyDetailInter(.regular, 11)).foregroundColor(DIYDetailTheme.gray)
                        Text(vm.info?.subject ?? "Crafts").font(diyDetailInter(.bold, 13)).foregroundColor(DIYDetailTheme.dark)
                    }
                    Spacer()
                }
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(DIYDetailTheme.greenLight).frame(width: 38, height: 38)
                        Image(systemName: "leaf.fill").font(.system(size: 15)).foregroundColor(DIYDetailTheme.green)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Topic").font(diyDetailInter(.regular, 11)).foregroundColor(DIYDetailTheme.gray)
                        Text(vm.info?.topic ?? "Reuse and recycling").font(diyDetailInter(.bold, 13)).foregroundColor(DIYDetailTheme.dark)
                    }
                    Spacer()
                }
                Text(vm.info?.learnNote ?? "")
                    .font(diyDetailInter(.regular, 12))
                    .foregroundColor(DIYDetailTheme.yellowDark)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DIYDetailTheme.yellowLight.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DIYDetailTheme.cardGray)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 6) {
                Text("About this craft")
                    .font(diyDetailInter(.bold, 15))
                    .foregroundColor(DIYDetailTheme.dark)
                Text(vm.info?.about ?? "")
                    .font(diyDetailInter(.regular, 13))
                    .foregroundColor(DIYDetailTheme.dark.opacity(0.85))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {}) {
                    Text("Read more").font(diyDetailInter(.semibold, 12.5)).foregroundColor(DIYDetailTheme.primary)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Materials").font(diyDetailInter(.bold, 15)).foregroundColor(DIYDetailTheme.dark)
                    Spacer()
                    Text("\(vm.checkedMaterials.count) of \(vm.materials.count)").font(diyDetailInter(.medium, 11)).foregroundColor(DIYDetailTheme.gray)
                }
                Text("Tap to tick off what you have")
                    .font(diyDetailInter(.regular, 11.5)).foregroundColor(DIYDetailTheme.gray)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(vm.materials) { m in
                        DIYMaterialCell(
                            item: m,
                            isChecked: vm.checkedMaterials.contains(m.id),
                            action: {
                                if vm.checkedMaterials.contains(m.id) { vm.checkedMaterials.remove(m.id) }
                                else { vm.checkedMaterials.insert(m.id) }
                            }
                        )
                    }
                }
                .padding(.top, 4)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Steps").font(diyDetailInter(.bold, 15)).foregroundColor(DIYDetailTheme.dark)
                    Spacer()
                    Button(action: { withAnimation { vm.showAllSteps.toggle(); vm.expandedStep = 1 } }) {
                        Text(vm.showAllSteps ? "Collapse all" : "Collapse all")
                            .font(diyDetailInter(.semibold, 12)).foregroundColor(DIYDetailTheme.primary)
                    }
                    .buttonStyle(.plain)
                }
                VStack(spacing: 10) {
                    ForEach(vm.visibleSteps) { s in
                        if s.number == 1 {
                            DIYStepExpandedCard(step: s)
                        } else {
                            DIYStepCollapsedRow(step: s, isExpanded: vm.expandedStep == s.number, action: {
                                withAnimation { vm.expandedStep = vm.expandedStep == s.number ? -1 : s.number }
                            })
                            if vm.expandedStep == s.number, let d = s.desc {
                                Text(d).font(diyDetailInter(.regular, 12)).foregroundColor(DIYDetailTheme.gray)
                                    .padding(.horizontal, 12).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                HStack { Spacer()
                    Button(action: { withAnimation { vm.showAllSteps.toggle() } }) {
                        Text(vm.showAllSteps ? "Show less" : "Show steps 5-8")
                            .font(diyDetailInter(.semibold, 12.5)).foregroundColor(DIYDetailTheme.primary)
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.gray.opacity(0.16), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.top, 2)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("How was it?").font(diyDetailInter(.bold, 15)).foregroundColor(DIYDetailTheme.dark)
                HStack(spacing: 8) {
                    DIYFeelingPill(title: "Awesome", emoji: "😍", isSelected: vm.selectedFeeling == "Awesome", action: { vm.selectedFeeling = "Awesome" })
                    DIYFeelingPill(title: "Very useful", emoji: "👍", isSelected: vm.selectedFeeling == "Very useful", action: { vm.selectedFeeling = "Very useful" })
                    Spacer()
                }
                HStack(spacing: 8) {
                    DIYFeelingPill(title: "Loved it", emoji: "🥰", isSelected: vm.selectedFeeling == "Loved it", action: { vm.selectedFeeling = "Loved it" })
                    DIYFeelingPill(title: "Want more", emoji: "🙌", isSelected: vm.selectedFeeling == "Want more", action: { vm.selectedFeeling = "Want more" })
                    Spacer()
                }
            }

            Button(action: { onCommentTap?() }) {
                HStack(spacing: 10) {
                    HStack(spacing: -10) {
                        Circle().fill(Color(red: 0.99, green: 0.62, blue: 0.22)).frame(width: 28, height: 28).overlay(Text("S").font(diyDetailInter(.bold, 10)).foregroundColor(.white))
                        Circle().fill(DIYDetailTheme.primary).frame(width: 28, height: 28).overlay(Text("P").font(diyDetailInter(.bold, 10)).foregroundColor(.white))
                        Circle().fill(DIYDetailTheme.green).frame(width: 28, height: 28).overlay(Text("A").font(diyDetailInter(.bold, 10)).foregroundColor(.white))
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("24 comments").font(diyDetailInter(.bold, 13)).foregroundColor(DIYDetailTheme.dark)
                        Text("Join the conversation").font(diyDetailInter(.regular, 11)).foregroundColor(DIYDetailTheme.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(DIYDetailTheme.gray)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(DIYDetailTheme.cardGray)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .leading) // FIXED
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: -4)
    }
}

// MARK: - SUBVIEWS
private struct DIYStatPill: View {
    let icon: String
    let iconColor: Color
    let text: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 12, weight: .semibold)).foregroundColor(iconColor)
                Text(text).font(diyDetailInter(.semibold, 12)).foregroundColor(DIYDetailTheme.dark)
            }
            .padding(.horizontal, 12).padding(.vertical, 9)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.gray.opacity(0.14), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct DIYMaterialCell: View {
    let item: DIYDetailMaterial
    let isChecked: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Circle().fill(Color(diyHex: item.bgHex)).frame(width: 52, height: 52)
                        Image(systemName: item.icon).font(.system(size: 18)).foregroundColor(DIYDetailTheme.dark)
                    }
                    ZStack {
                        Circle().fill(isChecked ? DIYDetailTheme.green : Color.white).frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        if isChecked {
                            Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                        }
                    }
                    .offset(x: 4, y: -4)
                }
                Text(item.name).font(diyDetailInter(.medium, 11)).foregroundColor(DIYDetailTheme.dark).multilineTextAlignment(.center).lineLimit(2).frame(height: 28)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private struct DIYStepExpandedCard: View {
    let step: DIYDetailStep
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(DIYDetailTheme.primary).frame(width: 22, height: 22)
                    Text("\(step.number)").font(diyDetailInter(.bold, 12)).foregroundColor(.white)
                }
                Spacer()
            }
            if let url = step.imageUrl {
                // FIXED: Was AsyncImage - now constrained
                DIYDetailRemoteImage(urlString: url)
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            Text(step.title).font(diyDetailInter(.bold, 14)).foregroundColor(DIYDetailTheme.dark)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let d = step.desc {
                Text(d).font(diyDetailInter(.regular, 12.5)).foregroundColor(DIYDetailTheme.gray).lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let tip = step.tip {
                Text(tip)
                    .font(diyDetailInter(.medium, 11.5)).foregroundColor(DIYDetailTheme.yellowDark)
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DIYDetailTheme.yellowLight.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.12), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

private struct DIYStepCollapsedRow: View {
    let step: DIYDetailStep
    let isExpanded: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(DIYDetailTheme.primaryLight).frame(width: 22, height: 22)
                    Text("\(step.number)").font(diyDetailInter(.bold, 12)).foregroundColor(DIYDetailTheme.primary)
                }
                if let url = step.imageUrl {
                    // FIXED: Was AsyncImage - now constrained
                    DIYDetailRemoteImage(urlString: url)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)).frame(width: 44, height: 44)
                }
                Text(step.title).font(diyDetailInter(.semibold, 13)).foregroundColor(DIYDetailTheme.dark).lineLimit(2).multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DIYDetailTheme.gray)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct DIYFeelingPill: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(emoji).font(.system(size: 13))
                Text(title).font(diyDetailInter(.semibold, 12))
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(isSelected ? DIYDetailTheme.primary : Color.white)
            .foregroundColor(isSelected ? .white : DIYDetailTheme.dark)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.clear : Color.gray.opacity(0.16), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private extension Color {
    init(diyHex: String) {
        let h = diyHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r, g, b: Double
        if h.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        } else { r = 1; g = 1; b = 1 }
        self.init(red: r, green: g, blue: b)
    }
}

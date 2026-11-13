//
//  DailyactivityVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/11/26.
//

import UIKit
import SwiftUI

// =====================================================
// MARK: - DailyactivityVC (UIKit Host)
// =====================================================
class DailyactivityVC: UIViewController {
    
    // ViewModel with Dummy data now, later replace with API
    private var viewModel = DailyActivityViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.hidesBottomBarWhenPushed = true
        
        let swiftUIView = DailyActivitySwiftUIView(
            viewModel: viewModel,
            onBack: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let nav = self.navigationController, nav.viewControllers.count > 1 {
                        nav.popViewController(animated: true)
                    } else if self.presentingViewController != nil {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            },
            onShareTap: { [weak self] in
                guard let self = self else { return }
                let text = "\(self.viewModel.data.promptTitle) \(self.viewModel.data.benefitText)"
                let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            },
            onPlayVideoTap: {
                // TODO: Play video action / navigate to video player
                print("Play video tapped")
            },
            onMarkDoneTap: {
                // TODO: Call Mark as done API here
                print("Mark as done tapped")
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// =====================================================
// MARK: - API READY MODELS
// Later map your API response to DailyActivityUIModel
// =====================================================
struct DailyActivityStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let description: String
}

struct DailyActivityUIModel {
    let topDateText: String
    let promptLabel: String
    let promptTitle: String
    let benefitLabel: String
    let benefitText: String
    let watchTitle: String
    let videoTitle: String
    let videoSubtitle: String
    let howToTitle: String
    let durationText: String
    let steps: [DailyActivityStep]
    let reflectLabel: String
    let reflectText: String
    let markDoneButtonTitle: String
}

// Dummy Data - Replace with API later
extension DailyActivityUIModel {
    static var dummy: DailyActivityUIModel {
        return DailyActivityUIModel(
            topDateText: "Friday, 23 October 2026",
            promptLabel: "PROMPT",
            promptTitle: "Roleplay, children as parents and parents as children.",
            benefitLabel: "BENEFIT",
            benefitText: "Promotes leadership and strengthens bonds.",
            watchTitle: "Watch first",
            videoTitle: "Family Role Reversal Day",
            videoSubtitle: "A short video explaining today’s prompt and benefits.",
            howToTitle: "How to do it",
            durationText: "About 15 min",
            steps: [
                DailyActivityStep(number: 1, title: "Assign your roles", description: "Children play the parents; parents play the children."),
                DailyActivityStep(number: 2, title: "Act out daily routines", description: "Breakfast, school bags and tidy-up. Keep it light and fun."),
                DailyActivityStep(number: 3, title: "Practise leadership", description: "Kids give polite instructions and solve small problems."),
                DailyActivityStep(number: 4, title: "Understand each other’s feelings", description: "Talk about what everyone experienced and learned."),
                DailyActivityStep(number: 5, title: "Celebrate", description: "Share your funniest moments and pick one chore kids can take on.")
            ],
            reflectLabel: "REFLECT TOGETHER",
            reflectText: "Thank each other for the work done at home and choose one household responsibility children can help with regularly.",
            markDoneButtonTitle: "Mark as done"
        )
    }
}

class DailyActivityViewModel: ObservableObject {
    @Published var data: DailyActivityUIModel
    
    init(data: DailyActivityUIModel = .dummy) {
        self.data = data
    }
    
    // TODO: API INTEGRATION
    // Call your API here and assign result to self.data
    // Example:
    // func fetchDailyActivity() async {
    //   let response = await APIService.getDailyActivity()
    //   await MainActor.run {
    //     self.data = DailyActivityUIModel(
    //       topDateText: response.date,
    //       promptTitle: response.prompt,
    //       ...
    //     )
    //   }
    // }
}

// =====================================================
// MARK: - Main SwiftUI View
// =====================================================
struct DailyActivitySwiftUIView: View {
    @ObservedObject var viewModel: DailyActivityViewModel
    
    var onBack: (() -> Void)?
    var onShareTap: (() -> Void)?
    var onPlayVideoTap: (() -> Void)?
    var onMarkDoneTap: (() -> Void)?
    
    init(viewModel: DailyActivityViewModel,
         onBack: (() -> Void)? = nil,
         onShareTap: (() -> Void)? = nil,
         onPlayVideoTap: (() -> Void)? = nil,
         onMarkDoneTap: (() -> Void)? = nil) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onBack = onBack
        self.onShareTap = onShareTap
        self.onPlayVideoTap = onPlayVideoTap
        self.onMarkDoneTap = onMarkDoneTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. PINNED HEADER: Stays fixed at the top
            DailyActivityHeaderView(
                dateText: viewModel.data.topDateText,
                onBack: onBack,
                onShare: onShareTap
            )
            .zIndex(1)
            
            // 2. SCROLLABLE CONTENT: Only the cards scroll
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Prompt Card
                    DailyPromptCardView(data: viewModel.data)
                    
                    // Watch First
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.data.watchTitle)
                            .font(.custom("Inter-Bold", size: 18))
                            .foregroundColor(Color(hexCode: "1C1E26"))
                        
                        DailyVideoCardView(
                            title: viewModel.data.videoTitle,
                            onPlay: onPlayVideoTap
                        )
                        
                        Text(viewModel.data.videoSubtitle)
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color(hexCode: "667085"))
                    }
                    
                    // How to do it
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(viewModel.data.howToTitle)
                                .font(.custom("Inter-Bold", size: 18))
                                .foregroundColor(Color(hexCode: "1C1E26"))
                            Spacer()
                            Text(viewModel.data.durationText)
                                .font(.custom("Inter-Medium", size: 12))
                                .foregroundColor(Color(hexCode: "667085"))
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.data.steps) { step in
                                DailyStepRowView(step: step)
                            }
                        }
                    }
                    
                    // Reflect Card
                    DailyReflectCardView(data: viewModel.data)
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 20)
            }
            
            // 3. PINNED BOTTOM BUTTONS: Fixed at the bottom
            HStack(spacing: 12) {
                Button(action: {
                    onShareTap?()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hexCode: "3451D1"))
                        .frame(width: 52, height: 52)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hexCode: "E5E7EB"), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    onMarkDoneTap?()
                }) {
                    Text(viewModel.data.markDoneButtonTitle)
                        .font(.custom("Inter-SemiBold", size: 15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hexCode: "3451D1"))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.top) // Ensures pinned header hits the absolute top of the screen
        .background(Color(hexCode: "F4F6FB").edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

// =====================================================
// MARK: - Subviews (fileprivate - no conflict)
// =====================================================
fileprivate struct DailyActivityHeaderView: View {
    var dateText: String
    var onBack: (() -> Void)?
    var onShare: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                Text("Daily Life Skill")
                    .font(.custom("Inter-Bold", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { onShare?() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding(.top, safeAreaTop())
            
            Text(dateText)
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.white.opacity(0.9))
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hexCode: "3451D1"), Color(hexCode: "6644D4")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(DailyHeaderRoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
    }
    
    func safeAreaTop() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return keyWindow?.safeAreaInsets.top ?? 44
    }
}

fileprivate struct DailyPromptCardView: View {
    var data: DailyActivityUIModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(data.promptLabel)
                .font(.custom("Inter-Bold", size: 10))
                .foregroundColor(Color(hexCode: "667085"))
                .tracking(0.5)
            
            Text(data.promptTitle)
                .font(.custom("Inter-Bold", size: 15))
                .foregroundColor(Color(hexCode: "1C1E26"))
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(data.benefitLabel)
                    .font(.custom("Inter-Bold", size: 10))
                    .foregroundColor(Color(hexCode: "92400E"))
                    .tracking(0.5)
                
                Text(data.benefitText)
                    .font(.custom("Inter-SemiBold", size: 13))
                    .foregroundColor(Color(hexCode: "1C1E26"))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hexCode: "FFF4CC"))
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

fileprivate struct DailyVideoCardView: View {
    var title: String
    var onPlay: (() -> Void)?
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hexCode: "F97316"), Color(hexCode: "EC4899"), Color(hexCode: "7C3AED")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Button(action: { onPlay?() }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "play.fill")
                            .foregroundColor(Color(hexCode: "3451D1"))
                            .font(.system(size: 20))
                            .offset(x: 2)
                    )
            }
            
            VStack {
                Spacer()
                HStack {
                    Text(title)
                        .font(.custom("Inter-Bold", size: 16))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(16)
            }
        }
        .frame(height: 180)
        .cornerRadius(20)
    }
}

fileprivate struct DailyStepRowView: View {
    var step: DailyActivityStep
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(step.number)")
                .font(.custom("Inter-Bold", size: 14))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color(hexCode: "3451D1"))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(Color(hexCode: "1C1E26"))
                
                Text(step.description)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(Color(hexCode: "667085"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

fileprivate struct DailyReflectCardView: View {
    var data: DailyActivityUIModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(data.reflectLabel)
                .font(.custom("Inter-Bold", size: 10))
                .foregroundColor(Color(hexCode: "3451D1"))
                .tracking(0.5)
            
            Text(data.reflectText)
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(Color(hexCode: "1C1E26"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hexCode: "EAF1FF"))
        .cornerRadius(16)
    }
}

// MARK: - Fileprivate Helpers
fileprivate struct DailyHeaderRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

fileprivate extension Color {
    init(hexCode: String) {
        let hex = hexCode.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

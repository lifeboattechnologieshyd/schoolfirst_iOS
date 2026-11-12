//
//  PastdatesactivitiesVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/11/26.
//

import UIKit
import SwiftUI

// =====================================================
// MARK: - PastdatesactivitiesVC (UIKit Host)
// =====================================================
class PastdatesactivitiesVC: UIViewController {
    
    private var viewModel = PastDatesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.hidesBottomBarWhenPushed = true
        
        let swiftUIView = PastDatesSwiftUIView(
            viewModel: viewModel,
            onBack: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let nav = self.navigationController, nav.viewControllers.count > 1 {
                        nav.popViewController(animated: true)
                    } else if self.presentingViewController != nil {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            },
            onShareTap: { [weak self] in
                guard let self = self else { return }
                let text = "Past dates - Catch up on activities you missed."
                let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            },
            onActivityTap: { [weak self] item in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    // Open DailyactivityVC on row tap
                    let dailyVC = DailyactivityVC()
                    dailyVC.hidesBottomBarWhenPushed = true
                    dailyVC.modalPresentationStyle = .fullScreen
                    if let nav = self.navigationController {
                        nav.pushViewController(dailyVC, animated: true)
                    } else {
                        self.present(dailyVC, animated: true, completion: nil)
                    }
                }
            },
            onOpenMissedTap: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let dailyVC = DailyactivityVC()
                    dailyVC.hidesBottomBarWhenPushed = true
                    dailyVC.modalPresentationStyle = .fullScreen
                    if let nav = self.navigationController {
                        nav.pushViewController(dailyVC, animated: true)
                    } else {
                        self.present(dailyVC, animated: true, completion: nil)
                    }
                }
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
// Later map API response to these models
// =====================================================
enum PastDatesFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case done = "Done"
    case missed = "Missed"
    var id: String { rawValue }
}

enum PastActivityStatus: String {
    case done = "Done"
    case missed = "Missed"
}

struct PastActivityItem: Identifiable {
    let id = UUID()
    let month: String
    let date: String
    let title: String
    let subtitle: String
    let status: PastActivityStatus
}

// Dummy Data - Replace with API later
extension Array where Element == PastActivityItem {
    static var dummy: [PastActivityItem] {
        return [
            PastActivityItem(month: "OCT", date: "22", title: "Gratitude circle", subtitle: "Builds appreciation", status: .done),
            PastActivityItem(month: "OCT", date: "21", title: "Story time swap", subtitle: "Boosts listening", status: .done),
            PastActivityItem(month: "OCT", date: "20", title: "Cook together", subtitle: "Teaches teamwork", status: .done),
            PastActivityItem(month: "OCT", date: "19", title: "Screen-free hour", subtitle: "Strengthens focus", status: .missed),
            PastActivityItem(month: "OCT", date: "18", title: "Kindness notes", subtitle: "Grows empathy", status: .done)
        ]
    }
}

class PastDatesViewModel: ObservableObject {
    @Published var selectedFilter: PastDatesFilter = .all
    @Published var activities: [PastActivityItem] = .dummy
    
    let headerTitle = "Past dates"
    let headerSubtitle = "Catch up on activities you missed."
    let sectionTitle = "October 2026"
    let missedTitle = "Missed a day?"
    let missedSubtitle = "You can still open it and mark it done."
    let missedButtonTitle = "Open Oct 19"
    
    var filteredActivities: [PastActivityItem] {
        switch selectedFilter {
        case .all:
            return activities
        case .done:
            return activities.filter { $0.status == .done }
        case .missed:
            return activities.filter { $0.status == .missed }
        }
    }
    
    // TODO: API INTEGRATION
    // func fetchPastDates() async {
    //   let response = await APIService.getPastDates()
    //   await MainActor.run {
    //     self.activities = response.map { ... }
    //   }
    // }
}

// =====================================================
// MARK: - Main SwiftUI View
// =====================================================
struct PastDatesSwiftUIView: View {
    @ObservedObject var viewModel: PastDatesViewModel
    
    var onBack: (() -> Void)?
    var onShareTap: (() -> Void)?
    var onActivityTap: ((PastActivityItem) -> Void)?
    var onOpenMissedTap: (() -> Void)?
    
    init(viewModel: PastDatesViewModel,
         onBack: (() -> Void)? = nil,
         onShareTap: (() -> Void)? = nil,
         onActivityTap: ((PastActivityItem) -> Void)? = nil,
         onOpenMissedTap: (() -> Void)? = nil) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onBack = onBack
        self.onShareTap = onShareTap
        self.onActivityTap = onActivityTap
        self.onOpenMissedTap = onOpenMissedTap
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                
                PastDatesHeaderView(
                    title: viewModel.headerTitle,
                    subtitle: viewModel.headerSubtitle,
                    onBack: onBack,
                    onShare: onShareTap
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    // 1. Filters
                    HStack(spacing: 8) {
                        ForEach(PastDatesFilter.allCases) { filter in
                            PastFilterChip(
                                title: filter.rawValue,
                                isSelected: viewModel.selectedFilter == filter,
                                action: {
                                    viewModel.selectedFilter = filter
                                }
                            )
                        }
                    }
                    
                    // 2. Section Title
                    Text(viewModel.sectionTitle)
                        .font(.custom("Inter-Bold", size: 16))
                        .foregroundColor(Color(hexCode: "1C1E26"))
                    
                    // 3. List
                    VStack(spacing: 12) {
                        ForEach(viewModel.filteredActivities) { item in
                            Button(action: {
                                onActivityTap?(item)
                            }) {
                                PastActivityRowView(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // 4. Missed Card
                    PastMissedCardView(
                        title: viewModel.missedTitle,
                        subtitle: viewModel.missedSubtitle,
                        buttonTitle: viewModel.missedButtonTitle,
                        onTap: onOpenMissedTap
                    )
                    .padding(.top, 4)
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .background(Color(hexCode: "F4F6FB").edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

// =====================================================
// MARK: - Subviews (fileprivate - no conflict)
// =====================================================
fileprivate struct PastDatesHeaderView: View {
    var title: String
    var subtitle: String
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
                Text(title)
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
            
            Text(subtitle)
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
        .clipShape(PastHeaderRoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
        .edgesIgnoringSafeArea(.top)
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

fileprivate struct PastFilterChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Inter-SemiBold", size: 13))
                .foregroundColor(isSelected ? Color(hexCode: "594300") : Color(hexCode: "3451D1"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hexCode: "FEEB9E") : Color(hexCode: "EAF1FF"))
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

fileprivate struct PastActivityRowView: View {
    var item: PastActivityItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Date Box
            VStack(spacing: 2) {
                Text(item.month)
                    .font(.custom("Inter-Bold", size: 10))
                    .foregroundColor(Color(hexCode: "667085"))
                Text(item.date)
                    .font(.custom("Inter-Bold", size: 18))
                    .foregroundColor(Color(hexCode: "1C1E26"))
            }
            .frame(width: 56, height: 56)
            .background(Color(hexCode: "EAF1FF"))
            .cornerRadius(12)
            
            // Title + Subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(Color(hexCode: "1C1E26"))
                Text(item.subtitle)
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundColor(Color(hexCode: "667085"))
            }
            
            Spacer()
            
            // Status Badge
            Text(item.status.rawValue)
                .font(.custom("Inter-Bold", size: 11))
                .foregroundColor(item.status == .done ? Color(hexCode: "207D3E") : Color(hexCode: "B42318"))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(item.status == .done ? Color(hexCode: "D2F4D6") : Color(hexCode: "FEE4E2"))
                .cornerRadius(8)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

fileprivate struct PastMissedCardView: View {
    var title: String
    var subtitle: String
    var buttonTitle: String
    var onTap: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.custom("Inter-Bold", size: 15))
                .foregroundColor(Color(hexCode: "1C1E26"))
            
            Text(subtitle)
                .font(.custom("Inter-Regular", size: 13))
                .foregroundColor(Color(hexCode: "667085"))
            
            Button(action: { onTap?() }) {
                Text(buttonTitle)
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(Color(hexCode: "3451D1"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hexCode: "D0D5DD"), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Fileprivate Helpers
fileprivate struct PastHeaderRoundedCorner: Shape {
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

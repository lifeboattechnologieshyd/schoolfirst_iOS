import UIKit
import SwiftUI

class CalendarmonthviewVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Hide the UIKit Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 2. Initialize the SwiftUI Month View with Back + Open Activity Action
        let swiftUIView = CalendarMonthSwiftUIView(
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
            onOpenActivityTap: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let dailyVC = DailyactivityVC()
                    dailyVC.hidesBottomBarWhenPushed = true
                    dailyVC.modalPresentationStyle = .fullScreen
                    
                    if let nav = self.navigationController {
                        nav.pushViewController(dailyVC, animated: true)
                    } else {
                        // TabBar case where navigationController is nil
                        self.present(dailyVC, animated: true, completion: nil)
                    }
                }
            }
        )
        
        // 3. Wrap it in a UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // 4. Add the hosting controller to the current view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // 5. Set up AutoLayout constraints to fill the screen
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 6. Notify the hosting controller
        hostingController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Dummy Data Models for Month View
fileprivate enum DayStatus {
    case empty
    case done
    case missed
    case today
    case future
}

fileprivate struct MonthDayItem: Identifiable {
    let id = UUID()
    let dayNumber: String
    let status: DayStatus
}

// MARK: - Main SwiftUI View
struct CalendarMonthSwiftUIView: View {
    var onBack: (() -> Void)?
    var onOpenActivityTap: (() -> Void)?
    
    let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
    
    fileprivate let monthDays: [MonthDayItem] = [
        MonthDayItem(dayNumber: "", status: .empty),
        MonthDayItem(dayNumber: "", status: .empty),
        MonthDayItem(dayNumber: "", status: .empty),
        MonthDayItem(dayNumber: "", status: .empty),
        MonthDayItem(dayNumber: "1", status: .done),
        MonthDayItem(dayNumber: "2", status: .done),
        MonthDayItem(dayNumber: "3", status: .done),
        MonthDayItem(dayNumber: "4", status: .done),
        MonthDayItem(dayNumber: "5", status: .done),
        MonthDayItem(dayNumber: "6", status: .done),
        MonthDayItem(dayNumber: "7", status: .done),
        MonthDayItem(dayNumber: "8", status: .done),
        MonthDayItem(dayNumber: "9", status: .missed),
        MonthDayItem(dayNumber: "10", status: .done),
        MonthDayItem(dayNumber: "11", status: .done),
        MonthDayItem(dayNumber: "12", status: .done),
        MonthDayItem(dayNumber: "13", status: .done),
        MonthDayItem(dayNumber: "14", status: .done),
        MonthDayItem(dayNumber: "15", status: .done),
        MonthDayItem(dayNumber: "16", status: .missed),
        MonthDayItem(dayNumber: "17", status: .done),
        MonthDayItem(dayNumber: "18", status: .done),
        MonthDayItem(dayNumber: "19", status: .done),
        MonthDayItem(dayNumber: "20", status: .done),
        MonthDayItem(dayNumber: "21", status: .done),
        MonthDayItem(dayNumber: "22", status: .done),
        MonthDayItem(dayNumber: "23", status: .today),
        MonthDayItem(dayNumber: "24", status: .future),
        MonthDayItem(dayNumber: "25", status: .future),
        MonthDayItem(dayNumber: "26", status: .future),
        MonthDayItem(dayNumber: "27", status: .future),
        MonthDayItem(dayNumber: "28", status: .future),
        MonthDayItem(dayNumber: "29", status: .future),
        MonthDayItem(dayNumber: "30", status: .future),
        MonthDayItem(dayNumber: "31", status: .future)
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                
                MonthScreenHeaderView(onBack: onBack)
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack {
                            Text("October 2026")
                                .font(.custom("Inter-Bold", size: 18))
                                .foregroundColor(Color(hexCode: "1C1E26"))
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                Button(action: {}) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(hexCode: "3451D1"))
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(hexCode: "3451D1"))
                                }
                            }
                        }
                        
                        HStack(spacing: 0) {
                            ForEach(0..<weekDays.count, id: \.self) { index in
                                Text(weekDays[index])
                                    .font(.custom("Inter-SemiBold", size: 12))
                                    .foregroundColor(Color(hexCode: "667085"))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(monthDays) { item in
                                DayCellView(item: item)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            LegendItem(color: Color(hexCode: "475467"), text: "Done", textColor: Color(hexCode: "667085"))
                            LegendItem(color: Color(hexCode: "B42318"), text: "Missed", textColor: Color(hexCode: "B42318"))
                            LegendItem(color: Color(hexCode: "3451D1"), text: "Today", textColor: Color(hexCode: "3451D1"))
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today’s activity")
                            .font(.custom("Inter-Bold", size: 18))
                            .foregroundColor(Color(hexCode: "1C1E26"))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PROMPT")
                                .font(.custom("Inter-Bold", size: 10))
                                .foregroundColor(Color(hexCode: "594300"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(hexCode: "FEEB9E"))
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Family Role Reversal Day")
                                    .font(.custom("Inter-Bold", size: 18))
                                    .foregroundColor(Color(hexCode: "1C1E26"))
                                
                                Text("Promotes leadership and strengthens bonds.")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(Color(hexCode: "667085"))
                            }
                            
                            Button(action: {
                                onOpenActivityTap?()
                            }) {
                                Text("Open activity")
                                    .font(.custom("Inter-SemiBold", size: 15))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(hexCode: "3451D1"))
                                    .cornerRadius(12)
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    }
                    .padding(.bottom, 100)
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .background(Color(hexCode: "F4F6FB").edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

fileprivate struct MonthScreenHeaderView: View {
    var onBack: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: {
                    onBack?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                Text("Life Skills Calendar")
                    .font(.custom("Inter-Bold", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding(.top, safeAreaTop())
            
            Text("Tap a date to open that day’s activity.")
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
        .clipShape(MonthHeaderRoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
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

fileprivate struct DayCellView: View {
    let item: MonthDayItem
    
    var body: some View {
        if item.status == .empty {
            Color.clear
                .frame(width: 40, height: 46)
        } else {
            Button(action: {}) {
                VStack(spacing: 4) {
                    Text(item.dayNumber)
                        .font(.custom(fontName(for: item.status), size: 15))
                        .foregroundColor(textColor(for: item.status))
                    
                    Circle()
                        .fill(dotColor(for: item.status))
                        .frame(width: 5, height: 5)
                }
                .frame(width: 40, height: 46)
                .background(item.status == .today ? Color(hexCode: "3451D1") : Color.clear)
                .cornerRadius(12)
            }
        }
    }
    
    private func fontName(for status: DayStatus) -> String {
        switch status {
        case .future:
            return "Inter-Medium"
        default:
            return "Inter-Bold"
        }
    }
    
    private func textColor(for status: DayStatus) -> Color {
        switch status {
        case .today:
            return .white
        case .future:
            return Color(hexCode: "667085")
        default:
            return Color(hexCode: "1C1E26")
        }
    }
    
    private func dotColor(for status: DayStatus) -> Color {
        switch status {
        case .done:
            return Color(hexCode: "30A454")
        case .missed:
            return Color(hexCode: "D92D20")
        case .today:
            return Color(hexCode: "FDB022")
        default:
            return .clear
        }
    }
}

fileprivate struct LegendItem: View {
    let color: Color
    let text: String
    let textColor: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(text)
                .font(.custom("Inter-Medium", size: 12))
                .foregroundColor(textColor)
        }
    }
}

fileprivate struct MonthHeaderRoundedCorner: Shape {
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

import SwiftUI

// MARK: - Dummy Data Models
struct CalendarDay: Identifiable {
    let id = UUID()
    let dayName: String
    let date: String
    var isSelected: Bool // Changed to var so it can be updated on tap
    let hasDot: Bool
}

struct PastDate: Identifiable {
    let id = UUID()
    let month: String
    let date: String
    let hasDot: Bool
}

// =====================================================
// MARK: - Main View
// =====================================================
struct LifeSkillsCalendarView: View {
    
    // Callback for back button navigation
    var onBack: (() -> Void)?
    
    // Callback for Month view button navigation
    var onMonthViewTap: (() -> Void)?
    
    // Callback for View all button navigation
    var onViewAllTap: (() -> Void)?
    
    // Changed to @State to update UI dynamically on tap
    @State private var weekDays: [CalendarDay] = [
        CalendarDay(dayName: "Mon", date: "19", isSelected: false, hasDot: true),
        CalendarDay(dayName: "Tue", date: "20", isSelected: false, hasDot: true),
        CalendarDay(dayName: "Wed", date: "21", isSelected: false, hasDot: true),
        CalendarDay(dayName: "Thu", date: "22", isSelected: false, hasDot: true),
        CalendarDay(dayName: "Fri", date: "23", isSelected: true, hasDot: false),
        CalendarDay(dayName: "Sat", date: "24", isSelected: false, hasDot: false),
        CalendarDay(dayName: "Sun", date: "25", isSelected: false, hasDot: false)
    ]
    
    let pastDates: [PastDate] = [
        PastDate(month: "OCT", date: "22", hasDot: true),
        PastDate(month: "OCT", date: "21", hasDot: true),
        PastDate(month: "OCT", date: "20", hasDot: true),
        PastDate(month: "OCT", date: "19", hasDot: true)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. PINNED CUSTOM HEADER (Will not scroll)
            HeaderView(onBack: onBack)
                .zIndex(1)
            
            // 2. SCROLLABLE CONTENT (Only bottom part scrolls)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Current Month & Week View
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("October 2026")
                                .font(.custom("Inter-Bold", size: 18))
                                .foregroundColor(Color.CustomDarkText)
                            
                            Spacer()
                            
                            Button(action: {
                                onMonthViewTap?()
                            }) {
                                Text("Month view")
                                    .font(.custom("Inter-SemiBold", size: 14))
                                    .foregroundColor(Color.CustomPrimaryBlue)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle())
                        }
                        
                        // HORIZONTAL SCROLL FOR DATES
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(weekDays) { day in
                                    WeekDayPill(day: day)
                                        .onTapGesture {
                                            // Handle Date Selection
                                            selectDate(tappedDay: day)
                                        }
                                }
                            }
                            .padding(.vertical, 4) // Prevents shadow from clipping
                        }
                        
                        // Streak Badge
                        Text("4-day streak")
                            .font(.custom("Inter-SemiBold", size: 12))
                            .foregroundColor(Color.CustomStreakDark)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.CustomStreakLight)
                            .cornerRadius(16)
                    }
                    
                    // 3. Today's Activity Card
                    ActivityCardView()
                    
                    // 4. Past Dates Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Past dates")
                                .font(.custom("Inter-Bold", size: 18))
                                .foregroundColor(Color.CustomDarkText)
                            
                            Spacer()
                            
                            Button(action: {
                                onViewAllTap?()
                            }) {
                                Text("View all")
                                    .font(.custom("Inter-SemiBold", size: 14))
                                    .foregroundColor(Color.CustomPrimaryBlue)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle())
                        }
                        
                        // HORIZONTAL SCROLL FOR PAST DATES (Already fixed in your code, keeping untouched)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(pastDates) { date in
                                    PastDatePill(pastDate: date)
                                }
                                
                                // Placeholder for fading edge effect
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .frame(width: 20, height: 70)
                                    .opacity(0.5)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // 5. New Here / Video Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("New here?")
                            .font(.custom("Inter-Bold", size: 18))
                            .foregroundColor(Color.CustomDarkText)
                        
                        NewHereVideoCard()
                        
                        Text("See how a daily prompt helps your family learn together.")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color.gray)
                            .padding(.bottom, 100) // Spacing so user can scroll fully down
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .edgesIgnoringSafeArea(.top) // Allows pinned header to reach absolute top seamlessly
        .background(Color.CustomAppBackground.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
    
    // Function to process tap and select only the clicked date
    private func selectDate(tappedDay: CalendarDay) {
        for index in weekDays.indices {
            weekDays[index].isSelected = (weekDays[index].id == tappedDay.id)
        }
    }
}

// =====================================================
// MARK: - Subviews
// =====================================================
struct HeaderView: View {
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
                
                Button(action: {
                    // TODO: Share action
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding(.top, safeAreaTop())
            
            Text("One small activity a day, together.")
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.white.opacity(0.9))
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.CustomHeaderStart, Color.CustomHeaderEnd]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .customCornerRadius(32, corners: [.bottomLeft, .bottomRight])
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

struct WeekDayPill: View {
    let day: CalendarDay
    
    var body: some View {
        VStack(spacing: 4) {
            Text(day.dayName)
                .font(.custom("Inter-Medium", size: 12))
                .foregroundColor(day.isSelected ? .white.opacity(0.8) : Color.gray)
            
            Text(day.date)
                .font(.custom("Inter-Bold", size: 16))
                .foregroundColor(day.isSelected ? .white : Color.CustomDarkText)
            
            Circle()
                .fill(day.hasDot ? Color.CustomDotGreen : Color.clear)
                .frame(width: 6, height: 6)
                .padding(.top, 2)
        }
        .frame(width: 46) // Changed to a fixed width so ScrollView horizontal behavior functions properly
        .padding(.vertical, 12)
        .background(day.isSelected ? Color.CustomPrimaryBlue : Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

struct PastDatePill: View {
    let pastDate: PastDate
    
    var body: some View {
        VStack(spacing: 4) {
            Text(pastDate.month)
                .font(.custom("Inter-Bold", size: 10))
                .foregroundColor(Color.gray)
            
            Text(pastDate.date)
                .font(.custom("Inter-Bold", size: 18))
                .foregroundColor(Color.CustomDarkText)
            
            Circle()
                .fill(pastDate.hasDot ? Color.CustomDotGreen : Color.clear)
                .frame(width: 6, height: 6)
                .padding(.top, 2)
        }
        .frame(width: 64, height: 76)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

struct ActivityCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TODAY • 23 OCT")
                .font(.custom("Inter-Bold", size: 10))
                .foregroundColor(Color.CustomDarkText)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Family Role Reversal Day")
                    .font(.custom("Inter-Bold", size: 22))
                    .foregroundColor(Color.CustomDarkText)
                
                Text("Roleplay: children as parents and parents as children.")
                    .font(.custom("Inter-Regular", size: 15))
                    .foregroundColor(Color.CustomDarkText.opacity(0.8))
                    .lineLimit(2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("BENEFIT")
                    .font(.custom("Inter-Bold", size: 11))
                    .foregroundColor(Color.black.opacity(0.5))
                
                Text("Promotes leadership and strengthens bonds.")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(Color.CustomDarkText)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    // TODO: Start Activity
                }) {
                    Text("Start activity")
                        .font(.custom("Inter-SemiBold", size: 15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.CustomPrimaryBlue)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    // TODO: Watch Video
                }) {
                    Text("Watch video")
                        .font(.custom("Inter-SemiBold", size: 15))
                        .foregroundColor(Color.CustomPrimaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.CustomYellowStart, Color.CustomYellowEnd]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
    }
}

struct NewHereVideoCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "play.fill")
                                .foregroundColor(Color.CustomPrimaryBlue)
                                .font(.system(size: 20))
                                .offset(x: 2)
                        )
                    Spacer()
                }
                Spacer()
            }
            
            Text("What is the Family Life Skills Calendar?")
                .font(.custom("Inter-Bold", size: 16))
                .foregroundColor(.white)
                .padding(20)
        }
        .frame(height: 180)
        .cornerRadius(20)
    }
}

// =====================================================
// MARK: - Helper Extensions
// =====================================================
extension View {
    func customCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCornerShape(radius: radius, corners: corners) )
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Hex Color Converter
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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

// Inline color definitions matching Figma design
extension Color {
    static let CustomAppBackground = Color(hex: "F4F6FB")
    static let CustomPrimaryBlue = Color(hex: "3451D1")
    static let CustomDarkText = Color(hex: "1C1E26")
    static let CustomHeaderStart = Color(hex: "3451D1")
    static let CustomHeaderEnd = Color(hex: "6644D4")
    static let CustomDotGreen = Color(hex: "30A454")
    static let CustomStreakLight = Color(hex: "D2F4D6")
    static let CustomStreakDark = Color(hex: "207D3E")
    static let CustomYellowStart = Color(hex: "FFFDF5")
    static let CustomYellowEnd = Color(hex: "FEEB9E")
}

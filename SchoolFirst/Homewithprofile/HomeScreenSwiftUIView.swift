//
//  HomeScreenSwiftUIView.swift
//  SchoolFirst
//
//  Created by vamshi krishna
//

import SwiftUI

// Helper for Identifiable modules
struct AppModule: Identifiable {
    let id = UUID()
    let title: String
    let image: String
}

// ✅ NEW: ViewModel to handle Active Child Dropdown
class HomeViewModel: ObservableObject {
    @Published var kids: [Student] = UserManager.shared.kids
    @Published var selectedIndex: Int = 0
    @Published var isDropdownOpen: Bool = false
    
    init() {
        // Find the index of the currently selected kid
        if let current = UserManager.shared.selectedKid,
           let idx = kids.firstIndex(where: { $0.qpass_id == current.qpass_id }) {
            selectedIndex = idx
        }
    }
    
    var currentName: String {
        return UserManager.shared.resolvedStudentName
    }
    
    var currentGrade: String {
        return UserManager.shared.resolvedGradeSection
    }
    
    var currentPhoto: String {
        return UserManager.shared.resolvedStudentPhotoURL
    }
    
    func switchKid(to index: Int) {
        selectedIndex = index
        UserManager.shared.switchKid(to: index)
        isDropdownOpen = false
    }
}

struct HomeScreenSwiftUIView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    // Modules
    var modules: [AppModule]
    
    // Action Callbacks
    var onModuleTapped: ((String) -> Void)
    var onFamilyZoneTapped: () -> Void
    
    // Grid Layout (3 flexible columns)
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // Custom Colors matching Figma
    let figmaBlueHeader = Color(red: 0/255, green: 90/255, blue: 215/255)
    let figmaBgGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    // **** ADDED: FIGMA COLORS for the segment control ****
    let figmaSegmentSelectedStart = Color(red: 30/255, green: 85/255, blue: 225/255)
    let figmaSegmentSelectedEnd = Color(red: 8/255, green: 48/255, blue: 180/255)
    let figmaSegmentUnselectedText = Color(red: 60/255, green: 70/255, blue: 90/255)
    let figmaSegmentIndicatorYellow = Color(red: 255/255, green: 204/255, blue: 51/255)
    
    // **** ADDED: FIGMA COLORS for the "Regular Classes" banner ****
    let figmaBannerStart = Color(red: 214/255, green: 230/255, blue: 250/255)
    let figmaBannerEnd = Color(red: 190/255, green: 215/255, blue: 247/255)
    let figmaBannerTitle = Color(red: 15/255, green: 28/255, blue: 63/255)
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background to prevent white flashing during scroll bounces
            figmaBgGray.ignoresSafeArea()
            
            // Fixed Blue Header Background extended to safe area
            figmaBlueHeader
                .frame(height: 300)
                .ignoresSafeArea(edges: .top)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerView
                    
                    // MARK: - MAIN WHITE / GRAY BOARD
                    VStack(spacing: 24) {
                        activeChildSelectorView
                        tabsView
                        schoolTodayBannerView
                        schoolServicesHeaderView
                        modulesGridView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    .background(figmaBgGray)
                    .homeScreenCornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(y: -30)
                    .padding(.bottom, -30)
                }
            }
        }
    }
    
    // MARK: - Extracted Views (Fixes Compiler Time-out)
    
    private var headerView: some View {
        ZStack(alignment: .trailing) {
            // School image on the right
            Image("schoolimage")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 125)
                .offset(y: -15)
                .opacity(0.95)
            
            HStack(spacing: 14) {
                // Profile Image
                AsyncImage(url: URL(string: viewModel.currentPhoto)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable().foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("Connect, explore, and\nstay updated.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 60)
        }
        .background(figmaBlueHeader)
    }
    
    private var activeChildSelectorView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Active child")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.gray)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                dropdownHeaderButton
                
                if viewModel.isDropdownOpen {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.kids.enumerated()), id: \.offset) { index, kid in
                            kidRow(index: index, kid: kid)
                            
                            if index < viewModel.kids.count - 1 {
                                Divider().padding(.leading, 70)
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }
    
    private var dropdownHeaderButton: some View {
        Button(action: {
            withAnimation {
                viewModel.isDropdownOpen.toggle()
            }
        }) {
            HStack(spacing: 12) {
                asyncProfileImage(url: viewModel.currentPhoto)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.currentName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                    Text(viewModel.currentGrade)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: viewModel.isDropdownOpen ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(14)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func kidRow(index: Int, kid: Student) -> some View {
        Button(action: {
            viewModel.switchKid(to: index)
        }) {
            HStack(spacing: 12) {
                // ✅ FIXED: Using DBManager helper instead of 'kid.profileImage'
                asyncProfileImage(url: DBManager.extractPhotoURL(from: kid) ?? "")
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(kid.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                    
                    // Format as "Grade 5 - Section B" if section exists, or just "Grade 5"
                    Text(kid.section?.isEmpty == false ? "Grade \(kid.grade) - Section \(kid.section!)" : "Grade \(kid.grade)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                Spacer()
                
                // Blue Dot for active selection
                if viewModel.selectedIndex == index {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                }
            }
            .padding(14)
            .background(viewModel.selectedIndex == index ? Color.blue.opacity(0.05) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper to avoid deep nesting inside AsyncImage
    @ViewBuilder
    private func asyncProfileImage(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 42, height: 42)
        .clipShape(Circle())
    }
    
    private var tabsView: some View {
        HStack(spacing: 0) {
            // ✅ Family Zone is now a tappable button
            Button(action: onFamilyZoneTapped) {
                HStack {
                    Image(systemName: "heart")
                    Text("Family Zone")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(figmaSegmentUnselectedText) // **** UPDATED: Figma unselected text color ****
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            
            // School Zone remains static (Active)
            HStack {
                Image(systemName: "building.columns.fill")
                Text("School Zone")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            // **** UPDATED: Figma blue gradient for selected segment ****
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [figmaSegmentSelectedStart, figmaSegmentSelectedEnd]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            // **** ADDED: Yellow line at the bottom of the selected segment ****
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(figmaSegmentIndicatorYellow)
                    .frame(width: 36, height: 3)
                    .padding(.bottom, 5)
            }
        }
        .padding(5)
        .background(Color.white) // **** UPDATED: Figma white segment container ****
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3) // **** ADDED: Soft shadow like Figma ****
    }
    
    private var schoolTodayBannerView: some View {
        ZStack(alignment: .trailing) {
            // **** UPDATED: Figma sky-blue gradient background ****
            LinearGradient(
                gradient: Gradient(colors: [figmaBannerStart, figmaBannerEnd]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .cornerRadius(20)
            
            Image("schoolimage")
                .resizable()
                .scaledToFit()
                .frame(width: 202, height: 110)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("SCHOOL TODAY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0/255, green: 110/255, blue: 255/255))
                    .cornerRadius(8)
                
                Text("Regular Classes")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(figmaBannerTitle) // **** UPDATED: Figma navy title color ****
                
                Text("Have a great day, \(viewModel.currentName.split(separator: " ").first ?? "Student")!")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 115)
    }
    
    private var schoolServicesHeaderView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("School services")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            Text("Everything for the school day")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }
    
    private var modulesGridView: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(modules) { module in
                Button(action: {
                    onModuleTapped(module.title)
                }) {
                    VStack(spacing: 6) {
                        // ===== OUTER WHITE CARD =====
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 225/255, green: 230/255, blue: 240/255), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                            
                            // Centered icon/tile
                            Image(module.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 52, height: 52)
                        }
                        .frame(height: 90)
                        .frame(maxWidth: .infinity)
                        
                        // ===== TITLE BELOW =====
                        Text(module.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 45/255, green: 45/255, blue: 55/255))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Subviews & Extensions

extension View {
    func homeScreenCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( HomeScreenRoundedCorner(radius: radius, corners: corners) )
    }
}

struct HomeScreenRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

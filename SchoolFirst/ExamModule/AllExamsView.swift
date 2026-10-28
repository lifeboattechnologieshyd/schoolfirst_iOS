//
//  AllExamsView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import SwiftUI

// MARK: - Models (Ready for API Integration)
// ✅ DUMMY MODELS PRESERVED EXACTLY AS REQUESTED
struct ExamModel: Identifiable {
    let id = UUID()
    let title: String
    let dateRange: String
    let subjectsInfo: String
    let termInfo: String
    let status: ExamStatus
    let type: ExamIconType
    
    // For Completed Exams
    var score: String? = nil
    var grade: String? = nil
    
    // For Search Results
    var searchMatchType: String? = nil
}

enum ExamStatus: String {
    case upcoming = "Upcoming"
    case completed = "Completed"
    
    var color: Color {
        switch self {
        case .upcoming: return Color.blue
        case .completed: return Color.green
        }
    }
}

enum ExamIconType {
    case calendar, document
    
    var iconName: String {
        switch self {
        case .calendar: return "calendar"
        case .document: return "doc.text.fill"
        }
    }
}

// MARK: - Main View
struct AllExamsHistoryView: View {
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var selectedTab: String = "All"
    
    // ✅ Replaced hardcoded arrays with injectable properties loaded from API
    var upcomingExams: [ExamModel] = []
    var completedExams: [ExamModel] = []
    var allExams: [ExamModel] = []
    
    // ✅ Search filtering computed from live API mapping
    var searchResults: [ExamModel] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return allExams
        }
        return allExams.filter { exam in
            let q = searchText.lowercased()
            return exam.title.lowercased().contains(q) ||
                   exam.termInfo.lowercased().contains(q) ||
                   exam.subjectsInfo.lowercased().contains(q)
        }.map { exam in
            var mappedExam = exam
            mappedExam.searchMatchType = exam.title.lowercased().contains(searchText.lowercased()) ? "Exact match" : "Related match"
            return mappedExam
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Blue Header
            CustomHeader(isSearching: $isSearching)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if isSearching {
                        // SCREEN 2: Search View
                        searchContentView
                    } else {
                        // SCREEN 1: Default View
                        defaultContentView
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.top) // ✅ Forces the 100-height header to start exactly from the top edge
        .navigationBarHidden(true)
    }
    
    // MARK: - Default View (Screen 1)
    private var defaultContentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Title Section
            VStack(alignment: .leading, spacing: 4) {
                Text("All exams")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Dynamic Student Subtitle mapped from User Manager - Cleaned up to avoid "Class Class 4"
                let rawGrade = UserManager.shared.resolvedStudentGrade
                let rawSection = UserManager.shared.resolvedStudentSection
                
                let grade = rawGrade.replacingOccurrences(of: "Class ", with: "", options: .caseInsensitive)
                let section = rawSection.replacingOccurrences(of: "Section ", with: "", options: .caseInsensitive)
                
                Text(rawGrade.isEmpty ? "Academic Year" : "Academic Year • Class \(grade)-\(section)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Search Bar Placeholder (Tapping this opens search)
            SearchBar(text: $searchText, isSearching: $isSearching)
                .onTapGesture {
                    withAnimation { isSearching = true }
                }
            
            // Custom Segmented Control
            HStack {
                ForEach(["All", "Upcoming", "Completed"], id: \.self) { tab in
                    Text(tab)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .bold : .regular)
                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == tab ? Color.white : Color.clear)
                        .cornerRadius(8)
                        .shadow(color: selectedTab == tab ? Color.black.opacity(0.05) : Color.clear, radius: 2, y: 1)
                        .onTapGesture { selectedTab = tab }
                }
            }
            .padding(4)
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(10)
            
            // Upcoming Section
            if selectedTab == "All" || selectedTab == "Upcoming" {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(upcomingExams.count) EXAM")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Text("Upcoming")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if upcomingExams.isEmpty {
                        Text("No upcoming exams.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(upcomingExams) { exam in
                            ExamCardView(exam: exam, isSearchView: false)
                        }
                    }
                }
                .padding(.top, 10)
            }
            
            // Completed Section
            if selectedTab == "All" || selectedTab == "Completed" {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(completedExams.count) COMPLETED EXAMS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Text("Exam history")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if completedExams.isEmpty {
                        Text("No exam history found.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(completedExams) { exam in
                            ExamCardView(exam: exam, isSearchView: false)
                        }
                    }
                }
                .padding(.top, 10)
            }
            
            // Footer Text
            Text("Exam history is retained by Oasis Public School for the current and previous academic year.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
        }
    }
    
    // MARK: - Search View (Screen 2)
    private var searchContentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Active Search Bar
            SearchBar(text: $searchText, isSearching: $isSearching)
            
            // Results Header
            VStack(alignment: .leading, spacing: 4) {
                Text("\(searchResults.count) exams found")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Matches for \"\(searchText)\"")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Results List
            VStack(spacing: 12) {
                ForEach(searchResults) { exam in
                    ExamCardView(exam: exam, isSearchView: true)
                }
            }
            
            // Info Banner
            HStack(alignment: .top) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                let name = UserManager.shared.resolvedStudentName.isEmpty ? "Student" : UserManager.shared.resolvedStudentName
                Text("Search \(name)'s Oasis Public School exams by subject, term or academic year.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Custom Header Component
struct CustomHeader: View {
    @Binding var isSearching: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            Button(action: {
                if isSearching {
                    withAnimation { isSearching = false } // Go back to default view
                } else {
                    presentationMode.wrappedValue.dismiss() // Pop View Controller
                }
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isSearching ? "Search Exams" : "All Exams")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text("School moments, all in one place")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Button(action: {
                // Action for right icon
            }) {
                Image(systemName: isSearching ? "magnifyingglass" : "bell")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(height: 100, alignment: .bottom) // ✅ Forced strictly to exactly 100 Height
        .background(Color(red: 11/255, green: 86/255, blue: 154/255)) // ✅ Updated to exactly #0B569A (Hex conversion)
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(isSearching ? .blue : .gray)
            
            TextField("Search by exam name or term", text: $text)
                .disabled(!isSearching) // Disable typing when in default view to trigger onTapGesture
            
            if isSearching && !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSearching ? Color.blue : Color(UIColor.systemGray5), lineWidth: 1.5)
        )
    }
}

// MARK: - Reusable Exam Card Component
struct ExamCardView: View {
    let exam: ExamModel
    let isSearchView: Bool // Changes the bottom layout slightly based on the screen
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Half
            HStack(alignment: .top, spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 45, height: 45)
                    Image(systemName: exam.type.iconName)
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
                
                // Title and Date
                VStack(alignment: .leading, spacing: 4) {
                    Text(exam.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("\(exam.dateRange) • \(exam.subjectsInfo)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status Badge
                Text(exam.status.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(exam.status.color.opacity(0.15))
                    .foregroundColor(exam.status.color)
                    .cornerRadius(12)
            }
            .padding()
            
            Divider()
            
            // Bottom Half
            HStack {
                Text(isSearchView ? "\(exam.termInfo) • \(exam.subjectsInfo)" : exam.termInfo)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Conditional UI for the bottom right corner
                if isSearchView {
                    Text(exam.searchMatchType ?? "Match")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                } else if let score = exam.score, let grade = exam.grade {
                    Text("\(score) • ")
                        .font(.caption)
                        .fontWeight(.bold) +
                    Text(grade)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Text("View details")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6).opacity(0.3)) // Slight tint for bottom area
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview
struct AllExamsHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        AllExamsHistoryView(upcomingExams: [], completedExams: [], allExams: [])
    }
}

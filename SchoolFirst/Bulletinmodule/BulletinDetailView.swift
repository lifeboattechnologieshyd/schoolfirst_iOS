//
//  BulletinDetailView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 26/10/26.
//

import SwiftUI

struct BulletinDetailView: View {
    var bulletin: BulletinEntry?
    var onBack: (() -> Void)? = nil
    var onShare: ((String) -> Void)? = nil
    
    @State private var isReadState: Bool = false
    
    // ── Banner overlap config (how far the banner hangs over the header edge) ──
    private var bannerOverlap: CGFloat { bulletin?.banner != nil ? 36 : 0 }
    
    // ── Date parsers ────────────────────────────────────────────────
    private static let apiDateParser: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private static let apiDateParserFallback = ISO8601DateFormatter()
    
    // Grade & Section from UserManager
    private var gradeSectionText: String {
        let rawGrade = UserManager.shared.resolvedStudentGrade
        let rawSection = UserManager.shared.resolvedStudentSection
        
        // ✅ Avoid duplicated wording from API (e.g. "Class 4" → "Grade Class 4")
        let grade: String
        if rawGrade.isEmpty {
            grade = ""
        } else if rawGrade.lowercased().contains("grade") || rawGrade.lowercased().contains("class") {
            grade = rawGrade
        } else {
            grade = "Grade \(rawGrade)"
        }
        
        // ✅ Avoid duplicated wording (e.g. "Section E" → "Section Section E")
        let section: String
        if rawSection.isEmpty {
            section = ""
        } else if rawSection.lowercased().contains("section") {
            section = rawSection
        } else {
            section = "Section \(rawSection)"
        }
        
        if !grade.isEmpty && !section.isEmpty {
            return "\(grade) · \(section)"
        } else if !grade.isEmpty {
            return grade
        } else if !section.isEmpty {
            return section
        }
        return ""
    }
    
    private var formattedDate: String {
        guard let createdAt = bulletin?.createdAt, !createdAt.isEmpty else {
            return ""
        }
        let date = Self.apiDateParser.date(from: createdAt)
            ?? Self.apiDateParserFallback.date(from: createdAt)
        guard let date = date else {
            return ""
        }
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy · h:mm a"
        return df.string(from: date)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.96, green: 0.96, blue: 0.98).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerWithBanner
                    
                    VStack(alignment: .leading, spacing: 18) {
                        // Tags row
                        tagsRow
                        
                        // Title
                        Text(bulletin?.title ?? "Announcement Details")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.12, green: 0.14, blue: 0.22))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Sender Info
                        senderRow
                        
                        // Message Body Card
                        messageBodyCard
                        
                        // Attachments Section
                        attachmentsSection
                    }
                    .padding(.horizontal, 20)
                    // ✅ Pull content up so it sits right below the overhanging banner
                    .padding(.top, bulletin?.banner != nil ? -(bannerOverlap - 16) : 20)
                    .padding(.bottom, 100) // space for bottom action button
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Bottom "Mark as read" button
            bottomActionBar
        }
        .onAppear {
            isReadState = bulletin?.isRead ?? false
        }
    }
    
    // MARK: - Header & Banner Section (Figma: banner overlaps header edge)
    private var headerWithBanner: some View {
        VStack(spacing: 0) {
            // 1. Purple header — rounded corners clipped HERE ONLY (nav bar section)
            VStack(spacing: 0) {
                Spacer().frame(height: 50) // Status bar spacing
                
                // Navigation Bar
                HStack {
                    Button(action: {
                        onBack?()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Spacer()
                    
                    Text("Announcement")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        let shareContent = "\(bulletin?.title ?? "School Announcement")\n\n\(bulletin?.messageBody ?? bulletin?.summary ?? "")"
                        onShare?(shareContent)
                    }) {
                        Image("shareicon 1")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 20)
                
                // Reserve room inside the purple header so the banner can overlap it
                Spacer().frame(height: bulletin?.banner != nil ? bannerOverlap + 16 : 20)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.22, green: 0.32, blue: 0.86),
                        Color(red: 0.38, green: 0.28, blue: 0.88)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(28, corners: [.bottomLeft, .bottomRight])
            
            // 2. Banner card — drawn AFTER the header, pulled up so it
            //    straddles the purple header's bottom edge (Figma overlap)
            if let banner = bulletin?.banner {
                bannerCard(banner: banner)
                    .padding(.horizontal, 20)
                    .offset(y: -bannerOverlap)
            }
        }
    }
    
    // MARK: - Banner Card
    private func bannerCard(banner: BulletinBanner) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.30, green: 0.38, blue: 0.90).opacity(0.85),
                            Color(red: 0.24, green: 0.32, blue: 0.85)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 140, height: 140)
                            .offset(x: 100, y: -20)
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 100, height: 100)
                            .offset(x: 130, y: 30)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                if let label = banner.label, !label.isEmpty {
                    Text(label.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.8))
                        .tracking(0.5)
                }
                
                if let headline = banner.headline, !headline.isEmpty {
                    Text(headline)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if !gradeSectionText.isEmpty {
                    Text(gradeSectionText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.85))
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .shadow(color: Color(red: 0.22, green: 0.28, blue: 0.80).opacity(0.25), radius: 10, x: 0, y: 6)
    }
    
    // MARK: - Tags Row
    private var tagsRow: some View {
        HStack(spacing: 8) {
            let catName = bulletin?.category?.name ?? "Notice"
            Text(catName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(red: 0.40, green: 0.30, blue: 0.85))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(red: 0.40, green: 0.30, blue: 0.85).opacity(0.12))
                .clipShape(Capsule())
            
            if bulletin?.isPinned == true {
                Text("Pinned")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 0.22, green: 0.32, blue: 0.86))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.22, green: 0.32, blue: 0.86).opacity(0.12))
                    .clipShape(Capsule())
            }
            
            if bulletin?.banner != nil || bulletin?.banner?.bannerColor?.uppercased() == "AMBER" {
                Text("Important")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.75, green: 0.45, blue: 0.0))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 1.0, green: 0.88, blue: 0.65).opacity(0.7))
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
    }
    
    // MARK: - Sender Row
    private var senderRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.23, green: 0.35, blue: 0.88))
                    .frame(width: 40, height: 40)
                
                Text(String((bulletin?.category?.name ?? "P").prefix(1)))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(bulletin?.category?.name ?? "Principal's Office")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.14, blue: 0.22))
                
                if !formattedDate.isEmpty {
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Message Body Card
    private var messageBodyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            let message = bulletin?.messageBody ?? bulletin?.summary ?? ""
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.20, green: 0.22, blue: 0.30))
                .lineSpacing(5)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Attachments Section
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let attachments = bulletin?.attachments ?? []
            
            if !attachments.isEmpty {
                Text("Attachments · \(attachments.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.14, blue: 0.22))
                
                ForEach(attachments) { file in
                    attachmentCard(
                        title: file.name ?? "Document.pdf",
                        subtitle: "PDF Document",
                        urlString: file.pdf
                    )
                }
            }
        }
    }
    
    private func attachmentCard(title: String, subtitle: String, urlString: String?) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.98, green: 0.92, blue: 0.92))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.88, green: 0.32, blue: 0.32))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.14, blue: 0.22))
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                if let urlString = urlString,
                   !urlString.isEmpty,
                   let url = URL(string: urlString),
                   url.scheme == "http" || url.scheme == "https" {
                    UIApplication.shared.open(url)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.23, green: 0.35, blue: 0.88))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack {
            Button(action: {
                isReadState.toggle()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                    Text(isReadState ? "Marked as read" : "Mark as read")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.22, green: 0.32, blue: 0.86),
                            Color(red: 0.38, green: 0.28, blue: 0.88)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: Color(red: 0.23, green: 0.35, blue: 0.88).opacity(0.35), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Preview
struct BulletinDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BulletinDetailView(
            bulletin: BulletinEntry(
                id: "1",
                category: BulletinCategoryInfo(id: "c1", name: "Notices"),
                title: "Mid-term exam timetable released",
                summary: "Exams begin on 3 Nov.",
                messageBody: "Dear parents, the Mid-Term Examinations for Grade 5 begin on 3 November 2026. Please note the following:\n\n• Reporting time: 8:15 AM on all exam days.\n• Bring: ID card, pencil box and a water bottle.\n• Revision week: 27–31 Oct, half-day classes.",
                banner: BulletinBanner(label: "MID-TERM EXAMS", headline: "3 – 14 Nov 2026", bannerColor: "INDIGO"),
                isPinned: true,
                isRead: false,
                attachments: [BulletinAttachment(id: "a1", name: "Mid-term timetable.pdf", pdf: "https://example.com/timetable.pdf")],
                createdAt: "2026-10-24T12:11:51.739295Z",
                status: "PUBLISHED"
            )
        )
    }
}

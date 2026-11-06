//
//  PaymentHistoryView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 06/11/26.
//

import SwiftUI

// MARK: - Data Models (Ready for API Integration)
enum PHStatus: String, CaseIterable {
    case paid = "Paid"
    case pending = "Pending"
    case failed = "Failed"
    
    var iconName: String {
        switch self {
        case .paid: return "checkmark"
        case .pending: return "clock"
        case .failed: return "xmark"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .paid: return .green
        case .pending: return .blue
        case .failed: return .orange
        }
    }
    
    var iconBgColor: Color {
        switch self {
        case .paid: return Color.green.opacity(0.1)
        case .pending: return Color.blue.opacity(0.1)
        case .failed: return Color.orange.opacity(0.1)
        }
    }
    
    var textColor: Color {
        switch self {
        case .paid, .pending: return Color(red: 0.05, green: 0.35, blue: 0.65)
        case .failed: return .orange
        }
    }
}

struct PHTransaction: Identifiable {
    let id = UUID()
    let amount: String
    let dateDetails: String
    let transactionID: String
    let status: PHStatus
    let actionText: String? // "RCP-2026-0893", "Check status", "Try again"
}

struct PaymentHistoryView: View {
    
    // Dummy Data (Replace with ViewModel / API Data later)
    let studentName = "Aarav Sharma"
    let studentInitials = "AS"
    let studentClass = "Class 10-A • SF-2026-001"
    let academicYear = "AY 2026-27"
    
    let paidAmount = "₹17,735"
    let successfulPayments = "2 successful payments"
    
    let otherAttempts = "2"
    let pendingFailedText = "1 pending • 1 failed"
    
    let transactions: [PHTransaction] = [
        PHTransaction(amount: "₹8,585", dateDetails: "17 Aug 2026 • 9:41 AM • Card", transactionID: "TXN-SF-260817-4902", status: .paid, actionText: "RCP-2026-0893"),
        PHTransaction(amount: "₹5,500", dateDetails: "16 Aug 2026 • 6:18 PM • UPI", transactionID: "TXN-SF-260816-4811", status: .pending, actionText: "Check status"),
        PHTransaction(amount: "₹5,500", dateDetails: "15 Aug 2026 • 8:06 PM • UPI", transactionID: "TXN-SF-260815-4762", status: .failed, actionText: "Try again"),
        PHTransaction(amount: "₹9,150", dateDetails: "12 Aug 2026 • 11:27 AM • Online", transactionID: "TXN-SF-260812-4520", status: .paid, actionText: "RCP-2026-0892")
    ]
    
    // Filter state
    @State private var selectedFilter: String = "All"
    let filters = ["All", "Paid", "Pending", "Failed"]
    
    var filteredTransactions: [PHTransaction] {
        if selectedFilter == "All" {
            return transactions
        }
        return transactions.filter { $0.status.rawValue == selectedFilter }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            PHHeaderView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // 2. Student Selector
                    PHStudentCard(
                        initials: studentInitials,
                        name: studentName,
                        details: studentClass,
                        academicYear: academicYear
                    )
                    
                    // 3. Summary Cards
                    HStack(spacing: 12) {
                        PHSummaryCard(
                            title: "Paid this year",
                            value: paidAmount,
                            subtitle: successfulPayments,
                            isHighlighted: true
                        )
                        
                        PHSummaryCard(
                            title: "Other attempts",
                            value: otherAttempts,
                            subtitle: pendingFailedText,
                            isHighlighted: false
                        )
                    }
                    
                    // 4. Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: {
                                    withAnimation {
                                        selectedFilter = filter
                                    }
                                }) {
                                    Text(filter)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedFilter == filter ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(selectedFilter == filter ? Color(red: 0.05, green: 0.35, blue: 0.65) : Color.white)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(selectedFilter == filter ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // 5. Recent Activity Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recent activity")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                        Text("Academic Year 2026–27")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    
                    // 6. Transaction List
                    if filteredTransactions.isEmpty {
                        Text("No \(selectedFilter.lowercased()) transactions found.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredTransactions) { transaction in
                                PHTransactionCard(transaction: transaction)
                            }
                        }
                    }
                    
                    // 7. Bottom Note
                    PHBottomNote()
                        .padding(.top, 8)
                    
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Subviews

struct PHHeaderView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 50) // Safe area padding
            HStack {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Payment history")
                        .font(.system(size: 20, weight: .bold))
                    Text("School moments, all in one place")
                        .font(.system(size: 12))
                        .opacity(0.8)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                Image(systemName: "bell")
                    .font(.system(size: 20, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Color(red: 0.05, green: 0.35, blue: 0.65)) // Theme Blue
    }
}

struct PHStudentCard: View {
    let initials: String
    let name: String
    let details: String
    let academicYear: String
    
    var body: some View {
        HStack {
            Text(initials)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                .frame(width: 40, height: 40)
                .background(Color(red: 0.05, green: 0.35, blue: 0.65).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text(details)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(academicYear)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 0.05, green: 0.35, blue: 0.65).opacity(0.1))
                .cornerRadius(6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct PHSummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let isHighlighted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(isHighlighted ? .green : Color(red: 0.1, green: 0.15, blue: 0.25))
            
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct PHTransactionCard: View {
    let transaction: PHTransaction
    
    var body: some View {
        VStack(spacing: 12) {
            // Top Row: Icon, Info, Amount/Status
            HStack(alignment: .top, spacing: 12) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(transaction.status.iconBgColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: transaction.status.iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(transaction.status.iconColor)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.amount)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    
                    Text(transaction.dateDetails)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(transaction.transactionID)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.top, 2)
                }
                
                Spacer()
                
                // Status Text
                Text(transaction.status.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(transaction.status.textColor)
            }
            
            // Bottom Row: Action Text (Receipt / Check status / Try again)
            if let actionText = transaction.actionText {
                HStack {
                    Spacer()
                    
                    if transaction.status == .paid {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 10))
                            Text(actionText)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                    } else {
                        Text(actionText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(transaction.status.textColor)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct PHBottomNote: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                .padding(.top, 2)
            
            Text("Pending entries do not reduce the fee balance until confirmed. Failed attempts are never charged.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    PaymentHistoryView()
}

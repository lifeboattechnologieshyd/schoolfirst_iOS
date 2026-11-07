//
//  PaymentHistoryView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 06/11/26.
//

import SwiftUI

// **** UPDATED: Completely removed dummy models (PHStatus & PHTransaction) and static variables. Using direct API Model Data. ****

struct PaymentHistoryView: View {
    // **** ADDED: API Response Model parameter ****
    var response: CompletedFeeResponse?
    var onBack: () -> Void
    
    // Filter state
    @State private var selectedFilter: String = "All"
    let filters = ["All", "Paid", "Pending", "Failed"]
    
    // **** ADDED: Dynamically derived student values ****
    var studentName: String {
        response?.student.name ?? UserManager.shared.resolvedStudentName
    }
    
    var studentInitials: String {
        let components = studentName.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(studentName.prefix(2)).uppercased()
    }
    
    var studentClass: String {
        let grade = UserManager.shared.resolvedGradeSection
        let admissionNo = response?.student.admissionNumber ?? ""
        return admissionNo.isEmpty ? grade : "\(grade) • \(admissionNo)"
    }
    
    var academicYear: String {
        let ayName = response?.student.academicYear.name ?? ""
        if ayName.isEmpty { return "AY" }
        return ayName.hasPrefix("AY") ? ayName : "AY \(ayName)"
    }
    
    // **** ADDED: Dynamically format summary values ****
    var paidAmount: String {
        formatAmount(response?.totalPaidAmount)
    }
    
    var successfulPaymentsCount: Int {
        response?.payments.count ?? 0
    }
    
    // Derived transactions for the list
    var filteredTransactions: [CompletedFeeTransaction] {
        guard let payments = response?.payments else { return [] }
        if selectedFilter == "All" {
            return payments
        }
        return payments.filter { transaction in
            // Mapping status dynamically based on items. Fallback to "Paid" if status is unavailable.
            let status = transaction.fees.first?.displayStatus ?? "Paid"
            return status.caseInsensitiveCompare(selectedFilter) == .orderedSame
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            PHHeaderView(onBack: onBack)
            
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
                            subtitle: "\(successfulPaymentsCount) successful payments",
                            isHighlighted: true
                        )
                        
                        PHSummaryCard(
                            title: "Other attempts",
                            value: "0", // Since this is a completed API response, pending/failed attempts are mostly 0.
                            subtitle: "0 pending • 0 failed",
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
                        Text(academicYear)
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
                            // **** UPDATED: Dynamically parsing API payments ****
                            ForEach(filteredTransactions, id: \.transactionId) { transaction in
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
    
    // **** ADDED: Helper Format amount locally ****
    private func formatAmount(_ amount: Double?) -> String {
        guard let amount = amount else { return "₹0" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return "₹\(formatter.string(from: NSNumber(value: amount)) ?? "0")"
    }
}

// MARK: - Subviews

struct PHHeaderView: View {
    var onBack: () -> Void
    
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
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
        .background(Color(red: 0.05, green: 0.35, blue: 0.65))
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

// **** UPDATED: Binds real CompletedFeeTransaction API Model directly ****
struct PHTransactionCard: View {
    let transaction: CompletedFeeTransaction
    
    // Status Logic Extractors
    private var displayStatus: String {
        transaction.fees.first?.displayStatus ?? "Paid"
    }
    
    private var isPaid: Bool {
        displayStatus.caseInsensitiveCompare("Paid") == .orderedSame || displayStatus.caseInsensitiveCompare("Success") == .orderedSame
    }
    
    private var isFailed: Bool {
        displayStatus.caseInsensitiveCompare("Failed") == .orderedSame
    }
    
    private var iconName: String {
        if isPaid { return "checkmark" }
        if isFailed { return "xmark" }
        return "clock"
    }
    
    private var iconColor: Color {
        if isPaid { return .green }
        if isFailed { return .orange }
        return .blue
    }
    
    private var iconBgColor: Color {
        if isPaid { return Color.green.opacity(0.1) }
        if isFailed { return Color.orange.opacity(0.1) }
        return Color.blue.opacity(0.1)
    }
    
    private var textColor: Color {
        if isPaid || !isFailed { return Color(red: 0.05, green: 0.35, blue: 0.65) }
        return .orange
    }
    
    private var actionText: String? {
        if isPaid {
            return transaction.referenceNumber.isEmpty ? "Receipt" : "RCP-\(transaction.referenceNumber)"
        } else if isFailed {
            return "Try again"
        } else {
            return "Check status"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Top Row: Icon, Info, Amount/Status
            HStack(alignment: .top, spacing: 12) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(iconBgColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(iconColor)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.formattedTotalAmount)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    
                    Text("\(transaction.formattedPaymentDate) • \(transaction.paymentGateway.isEmpty ? "Online" : transaction.paymentGateway)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(transaction.transactionId.isEmpty ? transaction.gatewayTransactionId : transaction.transactionId)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.top, 2)
                }
                
                Spacer()
                
                // Status Text
                Text(displayStatus)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(textColor)
            }
            
            // Bottom Row: Action Text (Receipt / Check status / Try again)
            if let actionText = actionText {
                HStack {
                    Spacer()
                    
                    if isPaid {
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
                            .foregroundColor(textColor)
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
    PaymentHistoryView(response: nil, onBack: {})
}

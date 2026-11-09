//
//  FeeDashboardView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import SwiftUI

class FeeDashboardViewModel: ObservableObject {
    @Published var feeResponse: PendingFeeResponse?
    @Published var completedFeeResponse: CompletedFeeResponse?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchFeeData() {
        self.isLoading = true
        self.errorMessage = nil
        
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID
        
        let params: [String: Any] = ["student_id": studentId]
        let headers: [String: String] = ["X-School-Id": schoolId]
        
        // Call Pending Fee API
        NetworkManager.shared.request(
            urlString: API.STUDENT_PENDING_FEE,
            method: .GET,
            requiresAuth: true,
            parameters: params,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<PendingFeeResponse>, NetworkError>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if response.success {
                        self?.feeResponse = response.data
                    } else {
                        self?.errorMessage = response.description
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchCompletedFeeData() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID
        
        let params: [String: Any] = ["student_id": studentId]
        let headers: [String: String] = ["X-School-Id": schoolId]
        
        NetworkManager.shared.request(
            urlString: API.FEE_COMPLETED_PAYMENT,
            method: .GET,
            requiresAuth: true,
            parameters: params,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<CompletedFeeResponse>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self?.completedFeeResponse = response.data
                    }
                case .failure(let error):
                    print("Error fetching completed fees: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func formatCurrency(_ value: Double?) -> String {
        guard let value = value else { return "₹0" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return "₹\(formatter.string(from: NSNumber(value: value)) ?? "0")"
    }
}

struct FeeDashboardView: View {
    var onBack: () -> Void
    var onPayFees: (PendingFeeResponse?) -> Void
    var onViewHistory: (CompletedFeeResponse?) -> Void
    
    @StateObject private var viewModel = FeeDashboardViewModel()
    
    // MARK: - Computed Helpers
    private var studentName: String {
        viewModel.feeResponse?.student.name ?? UserManager.shared.resolvedStudentName
    }
    
    private var hasPendingFees: Bool {
        (viewModel.feeResponse?.totalPayableAmount ?? 0) > 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            FeeDashboardHeaderView(onBack: onBack)
            
            ZStack {
                // MARK: - Normal Fee Dashboard (when pending fees exist)
                if hasPendingFees {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            StudentSelectorView(
                                name: viewModel.feeResponse?.student.name ?? UserManager.shared.resolvedStudentName,
                                admissionNo: viewModel.feeResponse?.student.admissionNumber ?? "",
                                className: UserManager.shared.resolvedGradeSection
                            )
                            
                            TotalDueCard(
                                totalDue: viewModel.formatCurrency(viewModel.feeResponse?.totalPayableAmount),
                                lateFee: viewModel.feeResponse?.feeSummary?.totalLateFee ?? 0.0,
                                onPayFees: { onPayFees(viewModel.feeResponse) }
                            )
                            
                            if let fees = viewModel.feeResponse?.fees, !fees.isEmpty {
                                HStack(spacing: 12) {
                                    if let currentFee = fees.first {
                                        InstallmentCard(
                                            iconName: "exclamationmark.circle",
                                            iconColor: .orange,
                                            badgeText: "Due soon",
                                            badgeColor: .orange,
                                            title: currentFee.installment.isEmpty ? currentFee.feeType : currentFee.installment,
                                            amount: currentFee.formattedPayableAmount,
                                            dueDate: currentFee.formattedDueDate.isEmpty ? "No Due Date" : "Due \(currentFee.formattedDueDate)"
                                        )
                                    }
                                    
                                    if fees.count > 1 {
                                        let upcomingFee = fees[1]
                                        InstallmentCard(
                                            iconName: "calendar.badge.clock",
                                            iconColor: .blue,
                                            badgeText: "Upcoming",
                                            badgeColor: .blue,
                                            title: upcomingFee.installment.isEmpty ? upcomingFee.feeType : upcomingFee.installment,
                                            amount: upcomingFee.formattedPayableAmount,
                                            dueDate: upcomingFee.formattedDueDate.isEmpty ? "No Due Date" : "Due \(upcomingFee.formattedDueDate)"
                                        )
                                    } else {
                                        Spacer().frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            
                            AnnualFeeStructureCard(
                                assignedAmount: viewModel.formatCurrency(viewModel.feeResponse?.feeSummary?.totalFee),
                                concession: viewModel.formatCurrency(viewModel.feeResponse?.feeSummary?.totalConcession),
                                paidToDate: viewModel.formatCurrency(viewModel.feeResponse?.feeSummary?.totalPaid),
                                outstanding: viewModel.formatCurrency(viewModel.feeResponse?.feeSummary?.outstandingAmount),
                                classInfo: UserManager.shared.resolvedGradeSection
                            )
                            
                            if let recentPayment = viewModel.completedFeeResponse?.payments.first {
                                RecentPaymentCard(
                                    amountText: "\(recentPayment.formattedTotalAmount) paid",
                                    detailsText: "\(recentPayment.formattedPaymentDate) • \(recentPayment.paymentGateway.isEmpty ? "Online" : recentPayment.paymentGateway) • \(recentPayment.referenceNumber)",
                                    statusText: "Paid",
                                    onViewHistory: { onViewHistory(viewModel.completedFeeResponse) }
                                )
                            }
                        }
                        .padding()
                    }
                }
                // MARK: - Empty State (All fees paid)
                else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Green checkmark icon
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 44, weight: .medium))
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 30)
                            
                            VStack(spacing: 8) {
                                Text("All fees are paid")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                
                                Text("\(studentName)'s fee balance for Academic Year 2026-27 is fully settled.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            
                            // ₹0 balance pill
                            Text("₹0 balance")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(20)
                            
                            // Year summary card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Year summary")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                
                                VStack(spacing: 10) {
                                    YearSummaryRow(
                                        title: "Paid total",
                                        amount: viewModel.formatCurrency(viewModel.feeResponse?.feeSummary?.totalPaid),
                                        valueColor: .green
                                    )
                                    YearSummaryRow(title: "Outstanding balance", amount: "₹0")
                                    YearSummaryRow(
                                        title: "Successful payments",
                                        amount: "\(viewModel.completedFeeResponse?.payments.count ?? 0)"
                                    )
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                            
                            // No upcoming installment card
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.green)
                                    .frame(width: 40, height: 40)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("No upcoming installment")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                    Text("All scheduled installments for AY 2026-27 are settled.")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("Complete")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                            
                            // Recent payment card
                            if let recentPayment = viewModel.completedFeeResponse?.payments.first {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "doc.text")
                                            .foregroundColor(.blue)
                                            .frame(width: 40, height: 40)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(recentPayment.formattedTotalAmount) paid")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                            Text("\(recentPayment.formattedPaymentDate) • \(recentPayment.referenceNumber)")
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button("Receipt") {
                                            // Placeholder – can wire to receipt screen later
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                            }
                            
                            // View payment history button (navigation)
                            Button(action: {
                                onViewHistory(viewModel.completedFeeResponse)
                            }) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                    Text("View payment history")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                                .cornerRadius(10)
                            }
                            .padding(.top, 8)
                            
                            Spacer().frame(height: 20)
                        }
                        .padding()
                    }
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
                    ProgressView("Fetching fees...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            viewModel.fetchFeeData()
            viewModel.fetchCompletedFeeData()
        }
    }
}

// MARK: - Subviews

struct FeeDashboardHeaderView: View {
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
                    Text("Fees")
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

struct StudentSelectorView: View {
    var name: String
    var admissionNo: String
    var className: String
    
    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    
    var body: some View {
        HStack {
            Text(initials)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Text("\(className) • \(admissionNo)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
    }
}

struct TotalDueCard: View {
    var totalDue: String
    var lateFee: Double
    var onPayFees: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TOTAL DUE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(totalDue == "₹0" ? "Cleared" : "Overdue")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(totalDue == "₹0" ? .green : .orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(totalDue == "₹0" ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .cornerRadius(8)
            }
            
            Text(totalDue)
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            if lateFee > 0 {
                Text("Includes ₹\(Int(lateFee)) late fee under Standard Overdue Policy.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            } else {
                Text("No late fees applied at this time.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Button(action: onPayFees) {
                HStack {
                    Image(systemName: "arrow.right")
                    Text("Pay fees")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                .cornerRadius(10)
            }
            .padding(.top, 4)
            .disabled(totalDue == "₹0")
            .opacity(totalDue == "₹0" ? 0.6 : 1.0)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
    }
}

struct InstallmentCard: View {
    var iconName: String
    var iconColor: Color
    var badgeText: String
    var badgeColor: Color
    var title: String
    var amount: String
    var dueDate: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .padding(8)
                    .background(iconColor.opacity(0.1))
                    .clipShape(Circle())
                
                Spacer()
                
                Text(badgeText)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(badgeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeColor.opacity(0.1))
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(amount)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    .minimumScaleFactor(0.8)
                
                Text(dueDate)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
    }
}

struct AnnualFeeStructureCard: View {
    var assignedAmount: String
    var concession: String
    var paidToDate: String
    var outstanding: String
    var classInfo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Annual Fee Structure")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                Text("View details")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
            }
            
            Text("\(classInfo) • Term-wise billing")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .padding(.top, -8)
            
            VStack(spacing: 12) {
                FeeRow(title: "Assigned amount", amount: assignedAmount)
                FeeRow(title: "Merit concession", amount: "- \(concession)", isDiscount: true)
                FeeRow(title: "Paid to date", amount: paidToDate, isDiscount: true)
                Divider()
                FeeRow(title: "Outstanding fees", amount: outstanding, isBold: true)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
    }
}

struct FeeRow: View {
    var title: String
    var amount: String
    var isDiscount: Bool = false
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: isBold ? .bold : .regular))
                .foregroundColor(isBold ? Color(red: 0.1, green: 0.15, blue: 0.25) : .secondary)
            
            Spacer()
            
            Text(amount)
                .font(.system(size: 14, weight: isBold ? .bold : .regular))
                .foregroundColor(isDiscount ? .green : Color(red: 0.1, green: 0.15, blue: 0.25))
        }
    }
}

// MARK: - Empty State Row
struct YearSummaryRow: View {
    var title: String
    var amount: String
    var valueColor: Color = Color(red: 0.1, green: 0.15, blue: 0.25)
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(amount)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(valueColor)
        }
    }
}

struct RecentPaymentCard: View {
    var amountText: String
    var detailsText: String
    var statusText: String
    var onViewHistory: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent payment")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                
                Button(action: onViewHistory) {
                    Text("View History")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            HStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .foregroundColor(.green)
                    .frame(width: 40, height: 40)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(amountText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text(detailsText)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(statusText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
    }
}

#Preview {
    FeeDashboardView(onBack: {}, onPayFees: { _ in }, onViewHistory: { _ in })
}

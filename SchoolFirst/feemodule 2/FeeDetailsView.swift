//
//  FeeDetailsView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import SwiftUI

struct FeeDetailsView: View {
    // **** ADDED: Property to hold data passed from UIKit ****
    var feeData: PendingFeeResponse?
    
    var onBack: () -> Void
    var onChoosePaymentAmount: () -> Void
    
    // **** ADDED: Helper formatter ****
    func formatCurrency(_ value: Double?) -> String {
        guard let value = value else { return "₹0" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return "₹\(formatter.string(from: NSNumber(value: value)) ?? "0")"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            FDHeaderView(onBack: onBack)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // 1. Annual Fee Structure
                    FDAnnualStructureCard(
                        assignedAmount: formatCurrency(feeData?.feeSummary?.totalFee),
                        concession: formatCurrency(feeData?.feeSummary?.totalConcession),
                        netPayable: formatCurrency((feeData?.feeSummary?.totalFee ?? 0) - (feeData?.feeSummary?.totalConcession ?? 0))
                    )
                    
                    // 2. Component Breakdown
                    FDComponentBreakdownCard(fees: feeData?.fees ?? [])
                    
                    // 3. Merit Concession Info Box
                    if let concession = feeData?.feeSummary?.totalConcession, concession > 0 {
                        FDMeritConcessionBox(concessionAmount: formatCurrency(concession))
                    }
                    
                    // 4. Installment Schedule
                    // Hides the card completely until the backend sends installment/term data
                    if let fees = feeData?.fees, fees.contains(where: { !$0.installment.isEmpty }) {
                        FDInstallmentScheduleCard(fees: fees)
                    }
                    
                    // 5. Late-fee Impact Box
                    if let lateFee = feeData?.feeSummary?.totalLateFee, lateFee > 0 {
                        FDLateFeeImpactBox(
                            lateFee: formatCurrency(lateFee),
                            currentDue: formatCurrency(feeData?.totalPayableAmount)
                        )
                    }
                    
                    // 6. Payment Summary
                    FDPaymentSummaryCard(
                        paid: formatCurrency(feeData?.feeSummary?.totalPaid),
                        outstanding: formatCurrency(feeData?.feeSummary?.outstandingAmount),
                        lateFee: formatCurrency(feeData?.feeSummary?.totalLateFee),
                        totalDue: formatCurrency(feeData?.totalPayableAmount),
                        hasLateFee: (feeData?.feeSummary?.totalLateFee ?? 0) > 0
                    )
                    
                    Spacer().frame(height: 20)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Bottom Sticky Payment Bar
            FDBottomPaymentBar(
                totalDue: formatCurrency(feeData?.totalPayableAmount),
                isDisabled: (feeData?.totalPayableAmount ?? 0) <= 0,
                onChoosePaymentAmount: onChoosePaymentAmount
            )
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Components

struct FDHeaderView: View {
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
                    Text("Fee details")
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

// **** UPDATED: Accepts API values ****
struct FDAnnualStructureCard: View {
    var assignedAmount: String
    var concession: String
    var netPayable: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Annual Fee Structure")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    // Class name rendered via global scope
                    Text("\(UserManager.shared.resolvedGradeSection) • Term-wise")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("Active")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
            }
            
            VStack(spacing: 12) {
                FDSimpleRow(title: "Assigned amount", amount: assignedAmount, isBoldTitle: true, isBoldAmount: true)
                if concession != "₹0" {
                    FDSimpleRow(title: "Approved merit concession", amount: "− \(concession)", amountColor: .green)
                }
                FDSimpleRow(title: "Net payable", amount: netPayable)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// **** UPDATED: Dynamically rendering the component rows based on API fees array ****
struct FDComponentBreakdownCard: View {
    var fees: [PendingFeeItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Component breakdown")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text("Configured by the school for \(UserManager.shared.resolvedStudentName)'s class.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 16) {
                if fees.isEmpty {
                    Text("No component breakdown available.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(fees, id: \.studentFeeId) { fee in
                        FDDetailRow(
                            title: fee.feeType.isEmpty ? "Fee" : fee.feeType,
                            subtitle: fee.installment.isEmpty ? "Academic" : fee.installment,
                            amount: fee.formattedAmount
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// **** UPDATED: Added prop to receive dynamic concession amount ****
struct FDMeritConcessionBox: View {
    var concessionAmount: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.blue)
                Text("Merit concession")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                Text("− \(concessionAmount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
            }
            Text("Approved for academic performance. Applied proportionally across unpaid installments.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
    }
}

// **** UPDATED: Dynamically rendering installments based on API data ****
struct FDInstallmentScheduleCard: View {
    var fees: [PendingFeeItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Installment schedule")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text("The school has enabled term-wise billing.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                if fees.isEmpty {
                    Text("No installments to show.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(fees, id: \.studentFeeId) { fee in
                        let isPaid = fee.status.uppercased() == "PAID"
                        let isOverdue = fee.status.uppercased() == "OVERDUE"
                        
                        let icon = isPaid ? "checkmark.circle" : (isOverdue ? "calendar.badge.exclamationmark" : "calendar")
                        let iconColor: Color = isPaid ? .green : (isOverdue ? .orange : .blue)
                        let title = fee.installment.isEmpty ? fee.feeType : fee.installment
                        
                        FDScheduleRow(
                            icon: icon,
                            iconColor: iconColor,
                            title: title,
                            date: fee.formattedDueDate,
                            amount: fee.formattedAmount,
                            status: fee.status.isEmpty ? "Upcoming" : fee.status.capitalized,
                            statusColor: iconColor
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// **** UPDATED: Passing API Data ****
struct FDLateFeeImpactBox: View {
    var lateFee: String
    var currentDue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Late-fee impact")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            Text("Standard Overdue Policy - read-only")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.top, -8)
            
            VStack(spacing: 8) {
                FDSimpleRow(title: "Late fee applied", amount: "+ \(lateFee)", amountColor: .red)
                Divider().padding(.vertical, 4)
                FDSimpleRow(title: "Current installment due", amount: currentDue, isBoldTitle: true, isBoldAmount: true)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.12))
        .cornerRadius(12)
    }
}

// **** UPDATED: Used passed API values for summary ****
struct FDPaymentSummaryCard: View {
    var paid: String
    var outstanding: String
    var lateFee: String
    var totalDue: String
    var hasLateFee: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment summary")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            VStack(spacing: 12) {
                FDSimpleRow(title: "Paid", amount: paid, amountColor: .green)
                FDSimpleRow(title: "Outstanding fees", amount: outstanding)
                if hasLateFee {
                    FDSimpleRow(title: "Late fee", amount: lateFee, amountColor: .red)
                }
                
                Divider()
                
                FDSimpleRow(title: "Total due today", amount: totalDue, isBoldTitle: true, isBoldAmount: true)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// **** UPDATED: Dynamically bind Total Due and disable if nothing to pay ****
struct FDBottomPaymentBar: View {
    var totalDue: String
    var isDisabled: Bool
    var onChoosePaymentAmount: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Total due")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                Text(totalDue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            }
            
            Button(action: onChoosePaymentAmount) {
                Text("Choose payment amount")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                    .cornerRadius(10)
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 30)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
    }
}

// MARK: - Reusable Helper Rows

struct FDSimpleRow: View {
    var title: String
    var amount: String
    var titleColor: Color = .secondary
    var amountColor: Color = Color(red: 0.1, green: 0.15, blue: 0.25)
    var isBoldTitle: Bool = false
    var isBoldAmount: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: isBoldTitle ? .bold : .regular))
                .foregroundColor(isBoldTitle ? Color(red: 0.1, green: 0.15, blue: 0.25) : titleColor)
            Spacer()
            Text(amount)
                .font(.system(size: 14, weight: isBoldAmount ? .bold : .medium))
                .foregroundColor(amountColor)
        }
    }
}

struct FDDetailRow: View {
    var title: String
    var subtitle: String
    var amount: String
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(amount)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
        }
    }
}

struct FDScheduleRow: View {
    var icon: String
    var iconColor: Color
    var title: String
    var date: String
    var amount: String
    var status: String
    var statusColor: Color
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                
                Text(status)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(6)
            }
        }
    }
}

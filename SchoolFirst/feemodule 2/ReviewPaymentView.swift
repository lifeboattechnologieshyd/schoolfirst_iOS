//
//  ReviewPaymentView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import SwiftUI

// **** UPDATED: Removed dummy models RPReviewData and RPFeeItem. Replaced with direct API Model bindings. ****

struct ReviewPaymentView: View {
    // **** ADDED: API Response object passed from ViewController ****
    var feeData: PendingFeeResponse?
    var isLoading: Bool = false
    
    var onBack: () -> Void
    var onPay: () -> Void
    
    // **** ADDED: Dynamic computed properties mapping API data ****
    private var academicYear: String {
        feeData?.student.academicYear?.name ?? "AY 2026-27"
    }
    
    private var totalPayable: Double {
        feeData?.totalPayableAmount ?? 0.0
    }
    
    private var totalLateFee: Double {
        feeData?.feeSummary?.totalLateFee ?? 0.0
    }
    
    private var totalConcession: Double {
        feeData?.feeSummary?.totalConcession ?? 0.0
    }
    
    private var baseFeeAmount: Double {
        // Base amount excluding the late fee
        max(0, totalPayable - totalLateFee)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            RPHeaderView(onBack: onBack)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // 2. Payment Details
                    RPPaymentDetailsCard(
                        academicYear: academicYear,
                        feeStructure: "Annual Fee" // Defaulted to Annual Fee, as specific term structure isn't in header
                    )
                    
                    // 3. Outstanding Fee Items
                    RPOutstandingItemsCard(
                        fees: feeData?.fees ?? [],
                        totalOutstanding: totalPayable
                    )
                    
                    // 4. Merit Concession
                    if totalConcession > 0 {
                        RPMeritConcessionCard(amount: formatCurrency(totalConcession))
                    }
                    
                    // 5. Charges and Total
                    RPChargesTotalCard(
                        baseFee: baseFeeAmount,
                        lateFee: totalLateFee,
                        totalPayable: totalPayable
                    )
                    
                    // 6. Info Note
                    RPInfoNoteView()
                    
                    Spacer().frame(height: 16)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // 7. Bottom Sticky Bar
            RPBottomBar(
                amount: formatCurrency(totalPayable),
                isDisabled: totalPayable <= 0,
                isLoading: isLoading,
                onBack: onBack,
                onPay: onPay
            )
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // **** ADDED: Currency Formatting Helper ****
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        return "₹\(formatter.string(from: NSNumber(value: value)) ?? "0")"
    }
}

// MARK: - Subviews

struct RPHeaderView: View {
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
                    Text("Review payment")
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

// **** UPDATED: Takes specific strings rather than dummy struct ****
struct RPPaymentDetailsCard: View {
    let academicYear: String
    let feeStructure: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment details")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Academic year")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(academicYear)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fee structure")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(feeStructure)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
            
            HStack(spacing: 12) {
                Image(systemName: "creditcard")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                    .frame(width: 36, height: 36)
                    .background(Color(red: 0.05, green: 0.35, blue: 0.65).opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Debit / credit card")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text("Secure online payment")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Change") {
                    // Action to change payment method
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// **** UPDATED: Dynamically loop through PendingFeeItem array ****
struct RPOutstandingItemsCard: View {
    let fees: [PendingFeeItem]
    let totalOutstanding: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Outstanding fee items")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text("Amounts currently remaining for this academic year.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 12) {
                if fees.isEmpty {
                    Text("No outstanding items.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(fees, id: \.studentFeeId) { item in
                        // Only render unpaid fee items
                        if item.payableAmount > 0 {
                            HStack {
                                Text(item.feeType.isEmpty ? "Fee" : item.feeType)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatCurrency(item.payableAmount))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                            }
                        }
                    }
                }
                
                Divider().padding(.vertical, 4)
                
                HStack {
                    Text("Outstanding fees")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Spacer()
                    Text(formatCurrency(totalOutstanding))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        return "₹\(formatter.string(from: NSNumber(value: value)) ?? "0")"
    }
}

// **** UPDATED: Takes isolated String amount ****
struct RPMeritConcessionCard: View {
    let amount: String
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Merit concession")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text("Approved waiver on assigned annual fee")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("- \(amount)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

// **** UPDATED: Calculations match API models, removed fake Convenience Fee that affects balance ****
struct RPChargesTotalCard: View {
    let baseFee: Double
    let lateFee: Double
    let totalPayable: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Charges and total")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            VStack(spacing: 12) {
                RPChargeRow(title: "Fee amount", amount: formatCurrency(baseFee))
                
                if lateFee > 0 {
                    RPChargeRow(title: "Late fee", amount: formatCurrency(lateFee), color: .red)
                }
                
                Divider().padding(.vertical, 4)
                
                HStack {
                    Text("Total payable")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Spacer()
                    Text(formatCurrency(totalPayable))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        return "₹\(formatter.string(from: NSNumber(value: value)) ?? "0")"
    }
}

struct RPChargeRow: View {
    let title: String
    let amount: String
    var color: Color = Color(red: 0.1, green: 0.15, blue: 0.25)
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(amount)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
        }
    }
}

struct RPInfoNoteView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                .padding(.top, 2)
            
            Text("By continuing, you confirm the child, fee items, and payment amount shown above.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Text("Verified")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.05, green: 0.35, blue: 0.65).opacity(0.1))
                .cornerRadius(6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// **** UPDATED: Dynamically disables button if there is nothing to pay or loading ****
struct RPBottomBar: View {
    let amount: String
    let isDisabled: Bool
    var isLoading: Bool = false
    let onBack: () -> Void
    let onPay: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Total payable")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                Text(amount)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            }
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Text("Back")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(10)
                }
                .frame(width: 100)
                .disabled(isLoading)
                
                Button(action: onPay) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                            .cornerRadius(10)
                    } else {
                        Text(amount == "₹0" ? "Cleared" : "Pay \(amount)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                            .cornerRadius(10)
                    }
                }
                .disabled(isDisabled || isLoading)
                .opacity((isDisabled || isLoading) ? 0.6 : 1.0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 30)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: -4)
    }
}

#Preview {
    ReviewPaymentView(feeData: nil, onBack: {}, onPay: {})
}

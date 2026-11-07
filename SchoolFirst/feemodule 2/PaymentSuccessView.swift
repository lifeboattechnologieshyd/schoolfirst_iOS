//
//  PaymentSuccessView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import SwiftUI

// MARK: - Data Model (Ready for API Integration)
struct PSPaymentData {
    let amountPaid: String
    let paymentMethod: String
    let dateTime: String
    let outstandingBalance: String
    let receiptNumber: String
    let appliedItems: [String]
}

struct PaymentSuccessView: View {
    // API Models passed from ViewController
    var feeData: PendingFeeResponse?
    var creationData: FeePaymentCreationResponse?
    var verifyData: FeeVerifyPaymentData?
    
    // Callbacks
    var onBack: () -> Void
    var onViewReceipt: () -> Void
    var onBackToFees: (() -> Void)? = nil
    
    // Dynamic payment data binding from APIs with fallback
    private var data: PSPaymentData {
        let amountVal: String
        if let vAmount = verifyData?.amount, !vAmount.isEmpty {
            amountVal = formatCurrencyString(vAmount)
        } else if let cAmount = creationData?.amount, cAmount > 0 {
            amountVal = formatCurrency(cAmount)
        } else if let total = feeData?.totalPayableAmount, total > 0 {
            amountVal = formatCurrency(total)
        } else {
            amountVal = "₹0"
        }
        
        let receiptNum: String
        if let vTxn = verifyData?.transactionNumber, !vTxn.isEmpty {
            receiptNum = vTxn
        } else if let cTxn = creationData?.transactionNumber, !cTxn.isEmpty {
            receiptNum = cTxn
        } else if let orderId = creationData?.orderId, !orderId.isEmpty {
            receiptNum = orderId
        } else {
            receiptNum = "TXN-B7447EB9AE57"
        }
        
        let dateStr: String
        if let paidAt = verifyData?.paidAt, !paidAt.isEmpty {
            dateStr = formatDate(paidAt)
        } else {
            let df = DateFormatter()
            df.dateFormat = "d MMM yyyy • h:mm a"
            df.locale = Locale(identifier: "en_IN")
            dateStr = df.string(from: Date())
        }
        
        var items: [String] = []
        if let fees = feeData?.fees, !fees.isEmpty {
            for fee in fees {
                items.append("\(formatCurrency(fee.payableAmount)) applied to \(fee.feeType)")
            }
            if let lateFee = feeData?.feeSummary?.totalLateFee, lateFee > 0 {
                items.append("\(formatCurrency(lateFee)) late fee settled")
            }
            items.append("Receipt generated and saved to payment history")
        } else {
            items = [
                "\(amountVal) applied to outstanding fee items",
                "Receipt generated and saved to payment history"
            ]
        }
        
        return PSPaymentData(
            amountPaid: amountVal,
            paymentMethod: "PhonePe / Online",
            dateTime: dateStr,
            outstandingBalance: "₹0",
            receiptNumber: receiptNum,
            appliedItems: items
        )
    }
    
    private var studentName: String {
        feeData?.student.name ?? "Student"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Header
            PSHeaderView(onBack: onBack)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 2. Success Icon & Text
                    VStack(spacing: 16) {
                        PSSuccessIcon()
                            .padding(.top, 20)
                        
                        VStack(spacing: 8) {
                            Text("Payment successful")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                            
                            Text("\(studentName)'s fee payment has been received and the outstanding balance is now cleared.")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Button(action: onViewReceipt) {
                                Text("Receipt \(data.receiptNumber)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                                    .padding(.top, 4)
                            }
                        }
                    }
                    
                    // 3. Payment Summary Card
                    PSPaymentSummaryCard(data: data)
                    
                    // 4. Applied Items Card
                    PSAppliedItemsCard(items: data.appliedItems)
                    
                    // 5. Action Buttons
                    PSActionButtonsView(
                        onViewReceipt: onViewReceipt,
                        onBackToFees: onBackToFees ?? onBack,
                        onShare: {
                            let shareText = """
                            🎉 Fee Payment Successful
                            Receipt: \(data.receiptNumber)
                            Student: \(studentName)
                            Amount Paid: \(data.amountPaid)
                            Date: \(data.dateTime)
                            Status: Verified
                            """
                            ReceiptSharePresenter.present(items: [shareText])
                        }
                    )
                    
                    // 6. Footer Help Text
                    PSHelpFooter()
                    
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // MARK: - Formatters
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        return "₹\(formatter.string(from: NSNumber(value: value)) ?? "0")"
    }
    
    private func formatCurrencyString(_ value: String) -> String {
        if let dbl = Double(value) {
            return formatCurrency(dbl)
        }
        return value.hasPrefix("₹") ? value : "₹\(value)"
    }
    
    private func formatDate(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = isoFormatter.date(from: isoString)
        if date == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            date = isoFormatter.date(from: isoString)
        }
        if let date = date {
            let df = DateFormatter()
            df.dateFormat = "d MMM yyyy • h:mm a"
            df.locale = Locale(identifier: "en_IN")
            return df.string(from: date)
        }
        return isoString
    }
}

// MARK: - Subviews

struct PSHeaderView: View {
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
                    Text("Payment complete")
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

struct PSSuccessIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 100, height: 100)
            
            Circle()
                .fill(Color.green)
                .frame(width: 70, height: 70)
            
            Image(systemName: "checkmark")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
                .offset(x: 45, y: -25)
            
            Circle()
                .fill(Color.purple)
                .frame(width: 6, height: 6)
                .offset(x: -45, y: 35)
        }
        .frame(height: 120)
    }
}

struct PSPaymentSummaryCard: View {
    let data: PSPaymentData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment summary")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            VStack(spacing: 12) {
                PSSummaryRow(
                    title: "Amount paid",
                    value: data.amountPaid,
                    valueColor: .green,
                    isBold: true
                )
                PSSummaryRow(title: "Payment method", value: data.paymentMethod)
                PSSummaryRow(title: "Date and time", value: data.dateTime)
                PSSummaryRow(
                    title: "Outstanding balance",
                    value: data.outstandingBalance,
                    valueColor: .green
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct PSSummaryRow: View {
    let title: String
    let value: String
    var valueColor: Color = Color(red: 0.1, green: 0.15, blue: 0.25)
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: isBold ? 16 : 14, weight: isBold ? .bold : .medium))
                .foregroundColor(valueColor)
        }
    }
}

struct PSAppliedItemsCard: View {
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.top, 2)
                    
                    Text(item)
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct PSActionButtonsView: View {
    var onViewReceipt: () -> Void
    var onBackToFees: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onViewReceipt) {
                HStack {
                    Image(systemName: "doc.text")
                    Text("View detailed receipt")
                        .fontWeight(.bold)
                }
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                .cornerRadius(10)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    onShare?()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share receipt")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Button(action: {
                    onBackToFees?()
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Back to fees")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }
}

struct PSHelpFooter: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 13))
            Text("Need help? Contact the school finance office.")
                .font(.system(size: 13))
        }
        .foregroundColor(.secondary)
        .padding(.top, 10)
    }
}

#Preview {
    PaymentSuccessView(onBack: {}, onViewReceipt: {})
}

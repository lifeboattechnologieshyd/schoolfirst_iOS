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
    // Dummy Data (Replace with ViewModel / API response later)
    let data = PSPaymentData(
        amountPaid: "₹8,585",
        paymentMethod: "Card",
        dateTime: "17 Aug 2026 • 9:41 AM",
        outstandingBalance: "₹0",
        receiptNumber: "RCP-2026-0893",
        appliedItems: [
            "₹8,150 applied to outstanding fee items",
            "₹350 late fee settled",
            "Receipt generated and saved to payment history"
        ]
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Header
            PSHeaderView()
            
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
                            
                            Text("Aarav's fee payment has been received and the outstanding balance is now cleared.")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Button(action: {
                                // TODO: Handle view receipt tap
                            }) {
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
                    PSActionButtonsView()
                    
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
}

// MARK: - Subviews

struct PSHeaderView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            HStack {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                
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
        .background(Color(red: 0.05, green: 0.35, blue: 0.65)) // Theme Blue
    }
}

struct PSSuccessIcon: View {
    var body: some View {
        ZStack {
            // Outer faint green circle
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 100, height: 100)
            
            // Inner solid green circle
            Circle()
                .fill(Color.green)
                .frame(width: 70, height: 70)
            
            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            // Decorative small dots (Confetti)
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
    var body: some View {
        VStack(spacing: 12) {
            // Primary Button
            Button(action: {
                // TODO: Handle detailed receipt view
            }) {
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
            
            // Secondary Buttons Row
            HStack(spacing: 12) {
                Button(action: {
                    // TODO: Handle Share
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
                    // TODO: Handle Back to fees
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
    PaymentSuccessView()
}

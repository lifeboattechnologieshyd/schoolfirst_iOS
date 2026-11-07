//
//  ChoosePaymentMethodView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import SwiftUI

// Enum to manage the payment selections
enum PaymentMethodType: String, CaseIterable {
    case card = "Debit / credit card"
    case upi = "UPI"
    case netBanking = "Net banking"
    case cash = "Cash at school" // Disabled
    case cheque = "Cheque / DD" // Disabled
}

struct ChoosePaymentMethodView: View {
    var onBack: () -> Void
    var onContinue: () -> Void
    
    @State private var selectedMethod: PaymentMethodType = .card
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Header
            CPMHeaderView(onBack: onBack)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 2. Title Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Choose a payment method")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                        
                        Text("Only methods enabled by SchoolFirst are available.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    // 3. Active Payment Options
                    VStack(spacing: 12) {
                        CPMPaymentRow(
                            isSelected: selectedMethod == .card,
                            isDisabled: false,
                            iconName: "creditcard",
                            title: "Debit / credit card",
                            tagText: "Selected",
                            subtitle: "Visa, Mastercard, RuPay • 1% convenience fee"
                        ) {
                            selectedMethod = .card
                        }
                        
                        CPMPaymentRow(
                            isSelected: selectedMethod == .upi,
                            isDisabled: false,
                            iconName: "qrcode",
                            title: "UPI",
                            tagText: "Recommended",
                            subtitle: "Pay with any UPI app • No convenience fee"
                        ) {
                            selectedMethod = .upi
                        }
                        
                        CPMPaymentRow(
                            isSelected: selectedMethod == .netBanking,
                            isDisabled: false,
                            iconName: "building.columns",
                            title: "Net banking",
                            tagText: nil,
                            subtitle: "All major Indian banks supported"
                        ) {
                            selectedMethod = .netBanking
                        }
                    }
                    
                    // 4. Divider with Text
                    CPMDividerWithText(text: "Unavailable in the parent app")
                    
                    // 5. Disabled Payment Options
                    VStack(spacing: 12) {
                        CPMPaymentRow(
                            isSelected: false,
                            isDisabled: true,
                            iconName: "banknote",
                            title: "Cash at school",
                            tagText: "Unavailable",
                            subtitle: "Disabled by school • Collection counter only"
                        ) {
                            // Action disabled
                        }
                        
                        CPMPaymentRow(
                            isSelected: false,
                            isDisabled: true,
                            iconName: "doc.text",
                            title: "Cheque / DD",
                            tagText: "Unavailable",
                            subtitle: "Disabled by school for this fee structure"
                        ) {
                            // Action disabled
                        }
                    }
                    
                    // 6. Security Note
                    CPMSecurityNote()
                    
                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // 7. Bottom Sticky Bar
            CPMBottomBar(amount: "₹8,500") {
                onContinue()
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Subviews

struct CPMHeaderView: View {
    var onBack: () -> Void
    
    var body: some View {
        VStack {
            Spacer().frame(height: 50) // Safe area padding
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Payment method")
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

struct CPMPaymentRow: View {
    let isSelected: Bool
    let isDisabled: Bool
    let iconName: String
    let title: String
    let tagText: String?
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !isDisabled { action() }
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isDisabled ? .gray.opacity(0.5) : Color(red: 0.05, green: 0.35, blue: 0.65))
                    .frame(width: 40, height: 40)
                    .background(isDisabled ? Color.gray.opacity(0.05) : Color(red: 0.05, green: 0.35, blue: 0.65).opacity(0.1))
                    .cornerRadius(10)
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(isDisabled ? .gray.opacity(0.7) : Color(red: 0.1, green: 0.15, blue: 0.25))
                        
                        if let tagText = tagText {
                            Text(tagText)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(isDisabled ? .gray : Color(red: 0.05, green: 0.35, blue: 0.65))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(isDisabled ? Color.gray.opacity(0.1) : Color(red: 0.05, green: 0.35, blue: 0.65).opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(isDisabled ? .gray.opacity(0.6) : .secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.05, green: 0.35, blue: 0.65) : (isDisabled ? Color.gray.opacity(0.3) : Color.gray.opacity(0.4)), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.05, green: 0.35, blue: 0.65))
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(red: 0.05, green: 0.35, blue: 0.65) : Color.clear, lineWidth: 1.5)
            )
            // Opacity for disabled rows
            .opacity(isDisabled ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
}

struct CPMDividerWithText: View {
    let text: String
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
}

struct CPMSecurityNote: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Text("Payments are encrypted and processed by SchoolFirst's secure payment partner.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct CPMBottomBar: View {
    let amount: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Paying")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                Text(amount)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            }
            
            Button(action: onContinue) {
                Text("Review payment")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.1, green: 0.2, blue: 0.4)) // Dark Blue
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 30) // Safe area bottom padding
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: -4)
    }
}

#Preview {
    ChoosePaymentMethodView(onBack: {}, onContinue: {})
}

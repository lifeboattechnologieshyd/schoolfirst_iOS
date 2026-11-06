//
//  ChoosePaymentAmountView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import SwiftUI

struct ChoosePaymentAmountView: View {
    
    // MARK: - Selection State (easy to bind to API / ViewModel later)
    enum PaymentOption {
        case fullOutstanding
        case currentInstallment
        case custom
    }
    
    @State private var selectedOption: PaymentOption = .fullOutstanding
    @State private var customAmountText: String = ""
    
    // Dummy values (replace with API data later)
    private let fullOutstandingAmount = 8500
    private let currentInstallmentAmount = 5500
    private let minCustomAmount = 1000
    private let maxCustomAmount = 8500
    
    private var selectedAmount: Int {
        switch selectedOption {
        case .fullOutstanding: return fullOutstandingAmount
        case .currentInstallment: return currentInstallmentAmount
        case .custom:
            return Int(customAmountText) ?? 0
        }
    }
    
    private var selectedAmountDisplay: String {
        if selectedOption == .custom && (customAmountText.isEmpty || Int(customAmountText) == nil) {
            return "₹0"
        }
        return "₹\(selectedAmount.formattedWithComma)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            CPAHeaderView()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("How much would you like to pay?")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                        
                        Text("Choose an amount allowed by the school's partial-payment policy.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 8)
                    
                    // Partial payments allowed banner
                    CPAPartialPaymentsBanner()
                    
                    // Payment options
                    VStack(spacing: 12) {
                        // 1. Full outstanding
                        CPAPaymentOptionRow(
                            isSelected: selectedOption == .fullOutstanding,
                            title: "Full outstanding",
                            subtitle: "Clears all fee dues and the current late fee",
                            amount: "₹\(fullOutstandingAmount.formattedWithComma)",
                            showAmount: true
                        ) {
                            selectedOption = .fullOutstanding
                        }
                        
                        // 2. Current installment
                        CPAPaymentOptionRow(
                            isSelected: selectedOption == .currentInstallment,
                            title: "Current installment",
                            subtitle: "Term 2 outstanding ₹5,150 + late fee ₹350",
                            amount: "₹\(currentInstallmentAmount.formattedWithComma)",
                            showAmount: true
                        ) {
                            selectedOption = .currentInstallment
                        }
                        
                        // 3. Custom amount
                        CPACustomAmountOption(
                            isSelected: selectedOption == .custom,
                            customAmountText: $customAmountText,
                            minAmount: minCustomAmount,
                            maxAmount: maxCustomAmount
                        ) {
                            selectedOption = .custom
                        }
                    }
                    
                    // How payment is applied
                    CPAPaymentAppliedInfo()
                    
                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Bottom sticky bar
            CPABottomBar(selectedAmountText: selectedAmountDisplay) {
                // TODO: Navigate to payment method screen
                print("Continue with amount: \(selectedAmount)")
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Header
struct CPAHeaderView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            HStack {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Payment amount")
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

// MARK: - Partial payments banner
struct CPAPartialPaymentsBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Partial payments allowed")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                
                Text("Minimum ₹1,000 • No more than outstanding amount")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Text("School policy")
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.05, green: 0.35, blue: 0.65).opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Standard payment option row
struct CPAPaymentOptionRow: View {
    let isSelected: Bool
    let title: String
    let subtitle: String
    let amount: String
    let showAmount: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Radio
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.05, green: 0.35, blue: 0.65) : Color.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.05, green: 0.35, blue: 0.65))
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if showAmount {
                    Text(amount)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(red: 0.05, green: 0.35, blue: 0.65) : Color.gray.opacity(0.2), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom amount option
struct CPACustomAmountOption: View {
    let isSelected: Bool
    @Binding var customAmountText: String
    let minAmount: Int
    let maxAmount: Int
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: action) {
                HStack(alignment: .top, spacing: 12) {
                    // Radio
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color(red: 0.05, green: 0.35, blue: 0.65) : Color.gray.opacity(0.4), lineWidth: 2)
                            .frame(width: 22, height: 22)
                        
                        if isSelected {
                            Circle()
                                .fill(Color(red: 0.05, green: 0.35, blue: 0.65))
                                .frame(width: 12, height: 12)
                        }
                    }
                    .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom amount")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                        
                        Text("Pay a partial amount within the configured limit")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            // Text field (only visible / enabled feeling when selected)
            if isSelected {
                HStack {
                    Text("₹")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("Enter ₹\(minAmount.formattedWithComma)–₹\(maxAmount.formattedWithComma)", text: $customAmountText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 14)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(red: 0.05, green: 0.35, blue: 0.65) : Color.gray.opacity(0.2), lineWidth: isSelected ? 1.5 : 1)
        )
    }
}

// MARK: - How payment is applied
struct CPAPaymentAppliedInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How your payment is applied")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            Text("Payments settle late fees first, then the oldest unpaid installment. Future installments remain unchanged.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Bottom bar
struct CPABottomBar: View {
    let selectedAmountText: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Selected amount")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                Text(selectedAmountText)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            }
            
            Button(action: onContinue) {
                Text("Continue to payment method")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 30)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: -4)
    }
}

// MARK: - Number formatting helper
extension Int {
    var formattedWithComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN") // Indian numbering (optional)
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

#Preview {
    ChoosePaymentAmountView()
}

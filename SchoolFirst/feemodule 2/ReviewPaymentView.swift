//
//  ReviewPaymentView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import SwiftUI

// MARK: - Data Models (Ready for API Integration)
struct RPFeeItem: Identifiable {
    let id = UUID()
    let title: String
    let amount: String
}

struct RPReviewData {
    let academicYear: String
    let feeStructure: String
    let paymentMethodTitle: String
    let paymentMethodSubtitle: String
    let outstandingItems: [RPFeeItem]
    let outstandingTotal: String
    let meritConcession: String
    let feeAmount: String
    let lateFee: String
    let convenienceFee: String
    let totalPayable: String
}

struct ReviewPaymentView: View {
    var onBack: () -> Void
    var onPay: () -> Void // ADDED: onPay closure property
    
    // Dummy Data (Replace this with API data / ViewModel later)
    let data = RPReviewData(
        academicYear: "2026-27",
        feeStructure: "Annual Fee",
        paymentMethodTitle: "Debit / credit card",
        paymentMethodSubtitle: "Secure online payment",
        outstandingItems: [
            RPFeeItem(title: "Tuition fee", amount: "₹4,900"),
            RPFeeItem(title: "Transport fee · Route 4", amount: "₹1,500"),
            RPFeeItem(title: "Library access", amount: "₹250"),
            RPFeeItem(title: "Lab & practical", amount: "₹1,000"),
            RPFeeItem(title: "Sports & gym", amount: "₹500")
        ],
        outstandingTotal: "₹8,150",
        meritConcession: "- ₹1,000",
        feeAmount: "₹8,150",
        lateFee: "₹350",
        convenienceFee: "₹85",
        totalPayable: "₹8,585"
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            RPHeaderView(onBack: onBack)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // 2. Payment Details
                    RPPaymentDetailsCard(data: data)
                    
                    // 3. Outstanding Fee Items
                    RPOutstandingItemsCard(data: data)
                    
                    // 4. Merit Concession
                    RPMeritConcessionCard(amount: data.meritConcession)
                    
                    // 5. Charges and Total
                    RPChargesTotalCard(data: data)
                    
                    // 6. Info Note
                    RPInfoNoteView()
                    
                    Spacer().frame(height: 16)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // 7. Bottom Sticky Bar
            // Replaced TODO placeholder with the onPay closure
            RPBottomBar(amount: data.totalPayable, onBack: onBack, onPay: onPay)
        }
        .edgesIgnoringSafeArea(.top)
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
        .background(Color(red: 0.05, green: 0.35, blue: 0.65)) // Theme Blue
    }
}

struct RPPaymentDetailsCard: View {
    let data: RPReviewData
    
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
                    Text(data.academicYear)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fee structure")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(data.feeStructure)
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
                    Text(data.paymentMethodTitle)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text(data.paymentMethodSubtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Change") {
                    // TODO: Action to change payment method
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

struct RPOutstandingItemsCard: View {
    let data: RPReviewData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Outstanding fee items")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text("Amounts remaining after the payment made on 12 Aug 2026.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 12) {
                ForEach(data.outstandingItems) { item in
                    HStack {
                        Text(item.title)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(item.amount)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    }
                }
                
                Divider().padding(.vertical, 4)
                
                HStack {
                    Text("Outstanding fees")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Spacer()
                    Text(data.outstandingTotal)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

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
            
            Text(amount)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

struct RPChargesTotalCard: View {
    let data: RPReviewData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Charges and total")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            VStack(spacing: 12) {
                RPChargeRow(title: "Fee amount", amount: data.feeAmount)
                RPChargeRow(title: "Late fee · 7 days overdue", amount: data.lateFee, color: .red)
                RPChargeRow(title: "Card convenience fee · 1%", amount: data.convenienceFee)
                
                Divider().padding(.vertical, 4)
                
                HStack {
                    Text("Total payable")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Spacer()
                    Text(data.totalPayable)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
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

struct RPBottomBar: View {
    let amount: String
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
                .frame(width: 100) // Fixed width for back button as per design
                
                Button(action: onPay) {
                    Text("Pay \(amount)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.1, green: 0.2, blue: 0.4)) // Dark Blue
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 30)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: -4)
    }
}

//Added onPay argument to preview
#Preview {
    ReviewPaymentView(onBack: {}, onPay: {})
}

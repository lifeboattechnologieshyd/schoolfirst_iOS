//
//  FeeDetailsView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import SwiftUI

struct FeeDetailsView: View {
    var onBack: () -> Void
    var onChoosePaymentAmount: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            FDHeaderView(onBack: onBack)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // 1. Annual Fee Structure
                    FDAnnualStructureCard()
                    
                    // 2. Component Breakdown
                    FDComponentBreakdownCard()
                    
                    // 3. Merit Concession Info Box
                    FDMeritConcessionBox()
                    
                    // 4. Installment Schedule
                    FDInstallmentScheduleCard()
                    
                    // 5. Late-fee Impact Box
                    FDLateFeeImpactBox()
                    
                    // 6. Payment Summary
                    FDPaymentSummaryCard()
                    
                    Spacer().frame(height: 20)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Bottom Sticky Payment Bar
            FDBottomPaymentBar(onChoosePaymentAmount: onChoosePaymentAmount)
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

struct FDAnnualStructureCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Annual Fee Structure")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text("Class 9-10 • AY 2026-27 • Term-wise")
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
                FDSimpleRow(title: "Assigned amount", amount: "₹18,300", isBoldTitle: true, isBoldAmount: true)
                FDSimpleRow(title: "Approved merit concession", amount: "− ₹1,000", amountColor: .green)
                FDSimpleRow(title: "Net payable", amount: "₹17,300")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct FDComponentBreakdownCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Component breakdown")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text("Configured by the school for Aarav's class and assignments.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 16) {
                FDDetailRow(title: "Tuition fee", subtitle: "Academic • Required", amount: "₹12,000")
                FDDetailRow(title: "Transport fee", subtitle: "Route 4 - Assigned", amount: "₹3,500")
                FDDetailRow(title: "Library access", subtitle: "Annual - Optional", amount: "₹500")
                FDDetailRow(title: "Lab & practical", subtitle: "Class 10", amount: "₹1,500")
                FDDetailRow(title: "Sports & gym", subtitle: "Annual - Required", amount: "₹800")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct FDMeritConcessionBox: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.blue)
                Text("Merit concession")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                Text("− ₹1,000")
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

struct FDInstallmentScheduleCard: View {
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
                FDScheduleRow(icon: "checkmark.circle", iconColor: .green, title: "Term 1", date: "10 Apr 2026", amount: "₹9,150", status: "Paid", statusColor: .green)
                FDScheduleRow(icon: "calendar.badge.exclamationmark", iconColor: .orange, title: "Term 2", date: "10 Aug 2026", amount: "₹5,150", status: "Overdue", statusColor: .orange)
                FDScheduleRow(icon: "calendar", iconColor: .blue, title: "Term 3", date: "10 Oct 2026", amount: "₹3,000", status: "Upcoming", statusColor: .blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct FDLateFeeImpactBox: View {
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
                FDSimpleRow(title: "Term 2 outstanding", amount: "₹5,150")
                FDSimpleRow(title: "7 days overdue - ₹50/day", amount: "+ ₹350", amountColor: .red)
                
                Divider().padding(.vertical, 4)
                
                FDSimpleRow(title: "Current installment due", amount: "₹5,500", isBoldTitle: true, isBoldAmount: true)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.12))
        .cornerRadius(12)
    }
}

struct FDPaymentSummaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment summary")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            VStack(spacing: 12) {
                FDSimpleRow(title: "Paid", amount: "₹9,150", amountColor: .green)
                FDSimpleRow(title: "Outstanding fees", amount: "₹8,150")
                FDSimpleRow(title: "Late fee", amount: "₹350", amountColor: .red)
                
                Divider()
                
                FDSimpleRow(title: "Total due today", amount: "₹8,500", isBoldTitle: true, isBoldAmount: true)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct FDBottomPaymentBar: View {
    var onChoosePaymentAmount: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Total due")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                Text("₹8,500")
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

#Preview {
    FeeDetailsView(onBack: {}, onChoosePaymentAmount: {})
}

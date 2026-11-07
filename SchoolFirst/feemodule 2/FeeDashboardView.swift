//
//  FeeDashboardView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/11/26.
//

import SwiftUI

struct FeeDashboardView: View {
    var onBack: () -> Void
    var onPayFees: () -> Void
    var onViewHistory: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Navigation Bar
            FeeDashboardHeaderView(onBack: onBack)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // 2. Student Selector
                    StudentSelectorView()
                    
                    // 3. Total Due Card
                    TotalDueCard(onPayFees: onPayFees)
                    
                    // 4. Split Cards (Current & Upcoming)
                    HStack(spacing: 12) {
                        InstallmentCard(
                            iconName: "exclamationmark.circle",
                            iconColor: .orange,
                            badgeText: "7 days",
                            badgeColor: .orange,
                            title: "Current installment",
                            amount: "₹5,500",
                            dueDate: "Due 10 Aug 2026"
                        )
                        
                        InstallmentCard(
                            iconName: "calendar.badge.clock",
                            iconColor: .blue,
                            badgeText: "Term 3",
                            badgeColor: .blue,
                            title: "Upcoming",
                            amount: "₹3,000",
                            dueDate: "Due 10 Oct 2026"
                        )
                    }
                    
                    // 5. Annual Fee Structure Card
                    AnnualFeeStructureCard()
                    
                    // 6. Recent Payment Card
                   
                    RecentPaymentCard(onViewHistory: onViewHistory)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.top)
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
    var body: some View {
        HStack {
            Text("AS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Aarav Sharma")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Text("Class 10-A • SF-2026-001")
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
    var onPayFees: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TOTAL DUE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Overdue")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(8)
            }
            
            Text("₹8,500")
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            Text("Includes ₹350 late fee under Standard Overdue Policy.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
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
                
                Text(amount)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                
                Text(dueDate)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
    }
}

struct AnnualFeeStructureCard: View {
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
            
            Text("Class 9-10 • Term-wise billing")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .padding(.top, -8)
            
            VStack(spacing: 12) {
                FeeRow(title: "Assigned amount", amount: "₹18,300")
                FeeRow(title: "Merit concession", amount: "− ₹1,000", isDiscount: true)
                FeeRow(title: "Paid to date", amount: "₹9,150", isDiscount: true)
                
                Divider()
                
                FeeRow(title: "Outstanding fees", amount: "₹8,150", isBold: true)
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


struct RecentPaymentCard: View {
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
                    Text("₹9,150 paid")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text("12 Aug 2026 • Online • RCP-2026-0892")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Paid")
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
    
    FeeDashboardView(onBack: {}, onPayFees: {}, onViewHistory: {})
}

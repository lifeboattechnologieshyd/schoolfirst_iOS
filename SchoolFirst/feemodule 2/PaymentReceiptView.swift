//
//  PaymentReceiptView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 06/11/26.
//

import SwiftUI

// MARK: - Data Model (Ready for API Integration)
struct PRReceiptData {
    let schoolName: String
    let academicYear: String
    let status: String
    let receiptNumber: String
    let paymentDate: String
    let studentName: String
    let studentInitials: String
    let studentDetails: String
    let outstandingFee: String
    let lateFee: String
    let convenienceFee: String
    let totalPaid: String
    let meritConcession: String
    let paymentMethod: String
    let transactionId: String
    let gatewayStatus: String
    let remainingBalance: String
    let schoolAddress: String
    let schoolContact: String
}

struct PaymentReceiptView: View {
    // Dummy Data (Replace with ViewModel / API Response later)
    let data = PRReceiptData(
        schoolName: "Oasis Public School",
        academicYear: "AY 2026-27",
        status: "PAID",
        receiptNumber: "RCP-2026-0893",
        paymentDate: "17 Aug 2026 • 9:41 AM",
        studentName: "Aarav Sharma",
        studentInitials: "AS",
        studentDetails: "SF-2026-001 • Class 10-A • AY 2026-27",
        outstandingFee: "₹8,150",
        lateFee: "₹350",
        convenienceFee: "₹85",
        totalPaid: "₹8,585",
        meritConcession: "− ₹1,000",
        paymentMethod: "Debit / credit card",
        transactionId: "TXN-SF-260817-4902",
        gatewayStatus: "Captured",
        remainingBalance: "₹0",
        schoolAddress: "Oasis Public School • Main Campus",
        schoolContact: "finance@schoolfirst.edu • +91 80 4000 2400"
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Header
            PRHeaderView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // 2. Main Receipt Card
                    VStack(spacing: 0) {
                        // Top Navy Banner
                        PRReceiptBanner(
                            schoolName: data.schoolName,
                            academicYear: data.academicYear,
                            status: data.status
                        )
                        
                        VStack(spacing: 24) {
                            // Meta Info
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("RECEIPT NUMBER")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.secondary)
                                    Text(data.receiptNumber)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("PAYMENT DATE")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.secondary)
                                    Text(data.paymentDate)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                }
                            }
                            
                            Divider()
                            
                            // Student Info
                            PRStudentInfoRow(
                                initials: data.studentInitials,
                                name: data.studentName,
                                details: data.studentDetails
                            )
                            
                            Divider()
                            
                            // Payment Breakdown
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Payment breakdown")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                
                                PRDetailRow(title: "Outstanding fee items", amount: data.outstandingFee)
                                PRDetailRow(title: "Late fee", amount: data.lateFee, amountColor: .red)
                                PRDetailRow(title: "Card convenience fee", amount: data.convenienceFee)
                                
                                Divider().padding(.vertical, 4)
                                
                                HStack {
                                    Text("Total paid")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                    Spacer()
                                    Text(data.totalPaid)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65)) // Theme Blue
                                }
                            }
                            
                            // Concession Box
                            PRConcessionBox(amount: data.meritConcession)
                            
                            // Transaction Details
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Transaction details")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                
                                PRDetailRow(title: "Payment method", amount: data.paymentMethod)
                                PRDetailRow(title: "Transaction ID", amount: data.transactionId)
                                PRDetailRow(title: "Gateway status", amount: data.gatewayStatus)
                                PRDetailRow(title: "Remaining balance", amount: data.remainingBalance, amountColor: .green)
                            }
                            
                            // Verified Receipt Box
                            PRVerifiedBox()
                                .padding(.top, 4)
                            
                            // Footer Address
                            VStack(spacing: 4) {
                                Text(data.schoolAddress)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                Text(data.schoolContact)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                        }
                        .padding(20)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                    
                    Spacer().frame(height: 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // 3. Bottom Sticky Action Bar
            PRBottomActionBar()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Subviews

struct PRHeaderView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            HStack {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Receipt")
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

struct PRReceiptBanner: View {
    let schoolName: String
    let academicYear: String
    let status: String
    
    var body: some View {
        VStack(spacing: 12) {
            // School Logo Placeholder
            Text("OPS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
            
            VStack(spacing: 4) {
                Text(schoolName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Fee Payment Receipt • \(academicYear)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Paid Badge
            Text(status)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65)) // Dark text for contrast
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(red: 0.6, green: 0.9, blue: 0.7)) // Light green
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(red: 0.1, green: 0.2, blue: 0.4)) // Dark Navy Blue
        .clipShape(
            .rect(
                topLeadingRadius: 16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 16
            )
        )
    }
}

struct PRStudentInfoRow: View {
    let initials: String
    let name: String
    let details: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(initials)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                .frame(width: 36, height: 36)
                .background(Color(red: 0.05, green: 0.35, blue: 0.65).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text(details)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

struct PRDetailRow: View {
    let title: String
    let amount: String
    var amountColor: Color = Color(red: 0.1, green: 0.15, blue: 0.25)
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
            Text(amount)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(amountColor)
        }
    }
}

struct PRConcessionBox: View {
    let amount: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Merit concession on assigned fee")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Spacer()
                Text(amount)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
            }
            Text("Approved waiver was applied before calculation of the outstanding fee balance.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(red: 0.05, green: 0.35, blue: 0.65).opacity(0.05))
        .cornerRadius(10)
    }
}

struct PRVerifiedBox: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "qrcode")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Digitally verified receipt")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text("Scan to verify this payment in SchoolFirst. No signature required.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
    }
}

struct PRBottomActionBar: View {
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                // TODO: Handle share action
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 15))
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            Button(action: {
                // TODO: Handle download PDF action
            }) {
                HStack {
                    Image(systemName: "arrow.down.doc")
                    Text("Download PDF")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 15))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
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

#Preview {
    PaymentReceiptView()
}

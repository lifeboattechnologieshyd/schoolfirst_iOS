//
//  PaymentReceiptView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 06/11/26.
//

import SwiftUI

// MARK: - Data Model (Configured with API Integration)
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
    // API data passed from ViewController
    var feeData: PendingFeeResponse?
    var creationData: FeePaymentCreationResponse?
    var verifyData: FeeVerifyPaymentData?
    
    // onBack closure property to trigger pop navigation from UIKit
    var onBack: () -> Void
    var onShare: (() -> Void)? = nil
    var onDownload: (() -> Void)? = nil
    
    // Dynamic Receipt Data computed from API models with robust fallbacks
    private var data: PRReceiptData {
        let school = UserManager.shared.selectedSchool
        let schoolName = school?.schoolName.isEmpty == false ? school!.schoolName : "SchoolFirst Academy"
        let academicYear = feeData?.student.academicYear?.name ?? feeData?.fees.first?.academicYear?.name ?? "AY 2026-27"
        
        let receiptNum: String
        if let vTxn = verifyData?.transactionNumber, !vTxn.isEmpty {
            receiptNum = vTxn
        } else if let cTxn = creationData?.transactionNumber, !cTxn.isEmpty {
            receiptNum = cTxn
        } else if let orderId = creationData?.orderId, !orderId.isEmpty {
            receiptNum = orderId
        } else {
            receiptNum = "RCP-2026-0893"
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
        
        let sName = (feeData?.student.name.isEmpty == false) ? feeData!.student.name : UserManager.shared.resolvedStudentName
        let sInitials = getInitials(from: sName)
        
        let admissionNo: String
        if let adm = feeData?.student.admissionNumber, !adm.isEmpty {
            admissionNo = adm
        } else {
            let studentId = UserManager.shared.resolvedStudentID
            admissionNo = !studentId.isEmpty ? studentId : "SF-2026-001"
        }
        
        let gradeStr = UserManager.shared.selectedKid?.grade ?? "Class 10-A"
        let sectionStr = UserManager.shared.selectedKid?.section
        let gradeName = (sectionStr != nil && !sectionStr!.isEmpty) ? "\(gradeStr)-\(sectionStr!)" : gradeStr
        let studentDetails = "\(admissionNo) • \(gradeName) • \(academicYear)"
        
        let totalPaidVal: Double
        if let vAmt = verifyData?.amount, let dbl = Double(vAmt), dbl > 0 {
            totalPaidVal = dbl
        } else if let cAmt = creationData?.amount, cAmt > 0 {
            totalPaidVal = cAmt
        } else if let total = feeData?.totalPayableAmount, total > 0 {
            totalPaidVal = total
        } else {
            totalPaidVal = 0.0
        }
        
        let lateFeeVal = feeData?.feeSummary?.totalLateFee ?? 0.0
        let concessionVal = feeData?.feeSummary?.totalConcession ?? 0.0
        let baseFeeVal = max(0.0, totalPaidVal - lateFeeVal)
        
        let statusText = verifyData?.status.uppercased().isEmpty == false ? verifyData!.status.uppercased() : "PAID"
        let gwStatus = verifyData?.status.capitalized.isEmpty == false ? verifyData!.status.capitalized : "Captured"
        
        let txnId: String
        if let gwTxn = verifyData?.gatewayTransactionId, !gwTxn.isEmpty {
            txnId = gwTxn
        } else if let vTxnId = verifyData?.transactionId, !vTxnId.isEmpty {
            txnId = vTxnId
        } else if let cTxnId = creationData?.transactionId, !cTxnId.isEmpty {
            txnId = cTxnId
        } else {
            txnId = "TXN-SF-\(receiptNum)"
        }
        
        let schoolAddr = (school?.address?.isEmpty == false) ? school!.address! : "\(schoolName) • Main Campus"
        let schoolContact = school?.email ?? "finance@schoolfirst.edu • +91 80 4000 2400"
        
        return PRReceiptData(
            schoolName: schoolName,
            academicYear: academicYear,
            status: statusText,
            receiptNumber: receiptNum,
            paymentDate: dateStr,
            studentName: sName,
            studentInitials: sInitials,
            studentDetails: studentDetails,
            outstandingFee: formatCurrency(baseFeeVal > 0 ? baseFeeVal : totalPaidVal),
            lateFee: lateFeeVal > 0 ? formatCurrency(lateFeeVal) : "₹0",
            convenienceFee: "₹0",
            totalPaid: formatCurrency(totalPaidVal),
            meritConcession: concessionVal > 0 ? "− \(formatCurrency(concessionVal))" : "₹0",
            paymentMethod: "PhonePe / Online",
            transactionId: txnId,
            gatewayStatus: gwStatus,
            remainingBalance: "₹0",
            schoolAddress: schoolAddr,
            schoolContact: schoolContact
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Header
            PRHeaderView(onBack: onBack)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // 2. Main Receipt Card
                    PRMainReceiptCard(data: data)
                    
                    Spacer().frame(height: 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // 3. Bottom Sticky Action Bar (Share & Download)
            PRBottomActionBar(
                onShare: {
                    if let customShare = onShare {
                        customShare()
                    } else {
                        handleShare()
                    }
                },
                onDownload: {
                    if let customDownload = onDownload {
                        customDownload()
                    } else {
                        handleDownload()
                    }
                }
            )
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // MARK: - Actions
    
    private func handleShare() {
        let pdfURL = generateReceiptPDF()
        let shareText = """
        🧾 Fee Payment Receipt
        School: \(data.schoolName)
        Receipt No: \(data.receiptNumber)
        Student: \(data.studentName)
        Amount Paid: \(data.totalPaid)
        Date: \(data.paymentDate)
        Status: \(data.status)
        """
        if let url = pdfURL {
            ReceiptSharePresenter.present(items: [shareText, url])
        } else {
            ReceiptSharePresenter.present(items: [shareText])
        }
    }
    
    private func handleDownload() {
        if let pdfURL = generateReceiptPDF() {
            ReceiptSharePresenter.present(items: [pdfURL])
        }
    }
    
    private func generateReceiptPDF() -> URL? {
        let sanitizedReceiptNo = data.receiptNumber.replacingOccurrences(of: "/", with: "-")
        let fileName = "PaymentReceipt-\(sanitizedReceiptNo).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        let cardContent = PRMainReceiptCard(data: data)
            .frame(width: 375)
            .padding(16)
            .background(Color.white)
        
        let success = PaymentReceiptPDFRenderer.render(cardContent, width: 407, to: url)
        return success ? url : nil
    }
    
    // MARK: - Helpers
    
    private func getInitials(from name: String) -> String {
        let parts = name.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
        if parts.count >= 2, let first = parts.first?.prefix(1), let last = parts.last?.prefix(1) {
            return "\(first)\(last)".uppercased()
        } else if let first = parts.first?.prefix(2) {
            return String(first).uppercased()
        }
        return "SF"
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        return "₹\(formatter.string(from: NSNumber(value: value)) ?? "0")"
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

// MARK: - Main Receipt Card

struct PRMainReceiptCard: View {
    let data: PRReceiptData
    
    var body: some View {
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
                    if data.lateFee != "₹0" && !data.lateFee.isEmpty {
                        PRDetailRow(title: "Late fee", amount: data.lateFee, amountColor: .red)
                    }
                    if data.convenienceFee != "₹0" && !data.convenienceFee.isEmpty {
                        PRDetailRow(title: "Card convenience fee", amount: data.convenienceFee)
                    }
                    
                    Divider().padding(.vertical, 4)
                    
                    HStack {
                        Text("Total paid")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                        Spacer()
                        Text(data.totalPaid)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                    }
                }
                
                // Concession Box
                if data.meritConcession != "₹0" && !data.meritConcession.isEmpty {
                    PRConcessionBox(amount: data.meritConcession)
                }
                
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
    }
}

// MARK: - Subviews

struct PRHeaderView: View {
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
            
            Text(status)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.35, blue: 0.65))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(red: 0.6, green: 0.9, blue: 0.7))
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(red: 0.1, green: 0.2, blue: 0.4))
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
    var onShare: () -> Void
    var onDownload: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onShare) {
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
            
            Button(action: onDownload) {
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

// MARK: - Share & PDF Presenters

enum ReceiptSharePresenter {
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    static func topViewController() -> UIViewController? {
        var top = keyWindow?.rootViewController
        while true {
            if let presented = top?.presentedViewController, !presented.isBeingDismissed {
                top = presented
            } else if let nav = top as? UINavigationController, let visible = nav.visibleViewController, visible !== nav {
                top = visible
            } else if let tab = top as? UITabBarController, let selected = tab.selectedViewController {
                top = selected
            } else {
                break
            }
        }
        return top
    }
    
    static func present(items: [Any]) {
        guard let top = topViewController() else { return }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = top.view
            popover.sourceRect = CGRect(x: top.view.bounds.midX, y: top.view.bounds.maxY - 80, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        top.present(activityVC, animated: true)
    }
}

@MainActor
enum PaymentReceiptPDFRenderer {
    static func render<Content: View>(_ content: Content, width: CGFloat, to url: URL) -> Bool {
        try? FileManager.default.removeItem(at: url)
        
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: content)
            renderer.proposedSize = ProposedViewSize(width: width, height: nil)
            
            var success = false
            renderer.render { size, draw in
                guard size.width > 0, size.height > 0 else { return }
                var box = CGRect(origin: .zero, size: size)
                guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
                pdfContext.beginPDFPage(nil)
                draw(pdfContext)
                pdfContext.endPDFPage()
                pdfContext.closePDF()
                success = true
            }
            return success
        } else {
            let host = UIHostingController(rootView: content)
            host.view.backgroundColor = .white
            
            let fitted = host.sizeThatFits(in: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            let height = max(fitted.height, 1)
            
            host.view.frame = CGRect(x: -width * 3, y: 0, width: width, height: height)
            ReceiptSharePresenter.keyWindow?.addSubview(host.view)
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            defer { host.view.removeFromSuperview() }
            
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)
            let pdfRenderer = UIGraphicsPDFRenderer(bounds: bounds)
            do {
                try pdfRenderer.writePDF(to: url) { ctx in
                    ctx.beginPage()
                    host.view.layer.render(in: ctx.cgContext)
                }
                return true
            } catch {
                print("❌ Payment Receipt PDF failed: \(error.localizedDescription)")
                return false
            }
        }
    }
}

#Preview {
    PaymentReceiptView(onBack: {})
}

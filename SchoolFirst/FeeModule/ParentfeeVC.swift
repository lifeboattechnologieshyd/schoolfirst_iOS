//
//  ParentfeeVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/06/26.
//

import UIKit

class ParentfeeVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var tableview: UITableView!

    // MARK: - Data

    private var pendingFeeData: PendingFeeResponse?
    private var isLoading: Bool = true

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
        fetchPendingFees()
    }

    // MARK: - Resolve School ID

    private func resolvedSchoolID() -> String {
        if let scid = UserManager.shared.selectedKid?.school?.schoolID,
           !scid.isEmpty { return scid }
        if let scid = UserManager.shared.selectedSchool?.schoolID,
           !scid.isEmpty { return scid }
        if let scid = UserDefaults.standard.string(forKey: "SCHOOL_ID"),
           !scid.isEmpty { return scid }
        if let scid = UserDefaults.standard.string(forKey: "SchoolID"),
           !scid.isEmpty { return scid }
        if let scid = UserDefaults.standard.string(forKey: "school_id"),
           !scid.isEmpty { return scid }
        if let data = UserDefaults.standard.data(forKey: "USER_INFO"),
           let user = try? JSONDecoder().decode(User.self, from: data),
           let scid = user.students?.first?.school?.schoolID,
           !scid.isEmpty { return scid }
        return ""
    }

    // MARK: - Resolve Student ID

    private func resolvedStudentID() -> String {
        if let sid = UserManager.shared.selectedKid?.studentID,
           !sid.isEmpty { return sid }
        if let sid = UserDefaults.standard.string(forKey: "STUDENT_ID"),
           !sid.isEmpty { return sid }
        if let data = UserDefaults.standard.data(forKey: "USER_INFO"),
           let user = try? JSONDecoder().decode(User.self, from: data),
           let sid = user.students?.first?.studentID,
           !sid.isEmpty { return sid }
        return ""
    }

    // MARK: - 1️⃣ Fetch Pending Fees API

    private func fetchPendingFees() {
        isLoading = true
        tableview.reloadData()

        let schoolId = resolvedSchoolID()
        let studentId = resolvedStudentID()

        guard !schoolId.isEmpty, !studentId.isEmpty else {
            print("⚠️ Missing school_id or student_id")
            isLoading = false
            tableview.reloadData()
            return
        }

        NetworkManager.shared.request(
            urlString: API.STUDENT_PENDING_FEE,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<PendingFeeResponse>, NetworkError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.pendingFeeData = data
                        print("✅ Pending fees loaded | fees count: \(data.fees.count)")
                    } else {
                        self.pendingFeeData = nil
                    }

                case .failure(let error):
                    print("❌ Pending fee api failed: \(error)")
                    self.pendingFeeData = nil
                }

                self.tableview.reloadData()
            }
        }
    }

    // MARK: - 2️⃣ Initiate Payment (Called when Pay button tapped)

    private func initiatePayment(for feeItem: PendingFeeItem) {
        let schoolId = resolvedSchoolID()
        let studentId = resolvedStudentID()

        guard !schoolId.isEmpty, !studentId.isEmpty else {
            print("⚠️ Missing IDs for payment")
            AlertManager.shared.showAlert(
                title: "Error",
                message: "Unable to process payment. Missing student information."
            )
            return
        }

        createPaymentOrder(
            studentId: studentId,
            schoolId: schoolId,
            feeItem: feeItem
        )
    }

    // MARK: - 3️⃣ Create Payment Order API

    // MARK: - 3️⃣ Create Payment Order API

    private func createPaymentOrder(
        studentId: String,
        schoolId: String,
        feeItem: PendingFeeItem
    ) {
        // ✅ Include student_fee_id so backend knows WHICH fee
        let parameters: [String: Any] = [
            "student_id": studentId,
            "student_fee_ids": [feeItem.studentFeeId],
            "amount": feeItem.payableAmount
        ]

        print("📡 Creating payment order")
        print("📌 studentId: \(studentId)")
        print("📌 student_fee_id: \(feeItem.studentFeeId)")
        print("📌 amount: \(feeItem.payableAmount)")

        NetworkManager.shared.request(
            urlString: API.FEE_CREATE_PAYMENT_PHONEPE,
            method: .POST,
            requiresAuth: true,
            parameters: parameters,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<FeePaymentCreationResponse>, NetworkError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let paymentData = response.data {
                        print("✅ Payment order created | orderId: \(paymentData.orderId)")

                        self.startPhonePeCheckout(
                            with: paymentData,
                            feeItem: feeItem
                        )
                    } else {
                        print("⚠️ API returned success=false: \(response.description)")
                        AlertManager.shared.showAlert(
                            title: "Error",
                            message: response.description
                        )
                    }

                case .failure(let error):
                    print("❌ Failed to create payment: \(error)")
                    AlertManager.shared.showAlert(
                        title: "Error",
                        message: "Failed to initiate payment. Please try again."
                    )
                }
            }
        }
    }

    // MARK: - 4️⃣ Start PhonePe Checkout

    private func startPhonePeCheckout(
        with paymentData: FeePaymentCreationResponse,
        feeItem: PendingFeeItem
    ) {
        print("💳 Starting PhonePe checkout | orderId: \(paymentData.orderId)")

        PhonePePaymentManager.shared.initiatePhonePePayment(
            with: paymentData,
            from: self
        ) { [weak self] paymentResult in
            guard let self = self else { return }

            // ✅ Go to Step 5
            self.handlePaymentResult(
                paymentResult,
                feeItem: feeItem
            )
        }
    }

    // MARK: - 5️⃣ Handle Payment Result

    private func handlePaymentResult(
        _ result: PaymentResultStatus,
        feeItem: PendingFeeItem
    ) {
        switch result {

        case .success(let paymentInfo):
            print("✅ Payment Success | transactionId: \(paymentInfo.transactionId)")
            AlertManager.shared.showAlert(
                title: "Payment Successful",
                message: "Your payment has been processed!\n\nTransaction ID: \(paymentInfo.transactionId)\nFee Type: \(feeItem.feeType)"
            )
            fetchPendingFees()

        case .pending(let paymentInfo):
            print("⏳ Payment Pending | transactionId: \(paymentInfo.transactionId)")
            AlertManager.shared.showAlert(
                title: "Payment Pending",
                message: "Your payment is being processed.\n\nTransaction ID: \(paymentInfo.transactionId)"
            )
            fetchPendingFees()

        case .failure(let error):
            print("❌ Payment Failed | error: \(error.localizedDescription)")
            AlertManager.shared.showAlert(
                title: "Payment Failed",
                message: error.localizedDescription
            )
        }
    }

    // MARK: - Setup TableView

    private func setupTableView() {
        tableview.delegate   = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "ParentfeeVCTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ParentfeeVCTableViewCell"
        )
        tableview.register(
            UINib(nibName: "ParentVCfeetypeTableViewCell2", bundle: nil),
            forCellReuseIdentifier: "ParentVCfeetypeTableViewCell2"
        )
        tableview.register(
            UINib(nibName: "ParentVCPaymentcompletedTableViewCell3", bundle: nil),
            forCellReuseIdentifier: "ParentVCPaymentcompletedTableViewCell3"
        )
        tableview.register(
            UINib(nibName: "ParentVCTransactionTableViewCell4", bundle: nil),
            forCellReuseIdentifier: "ParentVCTransactionTableViewCell4"
        )

        tableview.separatorStyle              = .none
        tableview.showsVerticalScrollIndicator = false
    }

    // MARK: - Top Shadow

    private func setupTopViewShadow() {
        TopView.layer.shadowColor    = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity  = 0.4
        TopView.layer.shadowOffset   = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius   = 2
        TopView.layer.masksToBounds  = false
    }

    // MARK: - Navigate to FeealltransactionVC

    private func navigateToAllTransactions() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let vc = storyboard.instantiateViewController(
            withIdentifier: "FeealltransactionVC"
        ) as? FeealltransactionVC {
            navigationController?.pushViewController(
                vc,
                animated: true
            )
        }
    }

    // MARK: - Back Button

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ParentfeeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if isLoading { return 4 }
        let feesCount = pendingFeeData?.fees.count ?? 0
        return 1 + feesCount + 2
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let fees      = pendingFeeData?.fees ?? []
        let feesCount = fees.count

        // MARK: Row 0 - Summary Cell

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ParentfeeVCTableViewCell",
                for: indexPath
            ) as! ParentfeeVCTableViewCell

            cell.selectionStyle = .none
            cell.configure(
                totalPayableAmount: pendingFeeData?.totalPayableAmount
            )
            return cell
        }

        // MARK: Rows 1 to N - Dynamic Fee Cells

        if indexPath.row >= 1 && indexPath.row <= feesCount {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ParentVCfeetypeTableViewCell2",
                for: indexPath
            ) as! ParentVCfeetypeTableViewCell2

            cell.selectionStyle = .none

            let feeIndex = indexPath.row - 1
            let feeItem  = fees[feeIndex]

            print("📌 Fee row \(indexPath.row) → \(feeItem.feeType) | ₹\(feeItem.payableAmount)")

            cell.configure(with: feeItem)

            // ✅ PAY BUTTON → triggers Step 2️⃣
            cell.onPayTapped = { [weak self] item in
                guard let self = self else { return }
                print("💳 Initiating payment for: \(item.feeType)")
                self.initiatePayment(for: item)
            }

            return cell
        }

        // MARK: Row N+1 - Payment Completed Cell

        if indexPath.row == feesCount + 1 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ParentVCPaymentcompletedTableViewCell3",
                for: indexPath
            ) as! ParentVCPaymentcompletedTableViewCell3

            cell.selectionStyle = .none
            return cell
        }

        // MARK: Row N+2 - Transaction Cell

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ParentVCTransactionTableViewCell4",
            for: indexPath
        ) as! ParentVCTransactionTableViewCell4

        cell.selectionStyle = .none

        cell.onViewAllTransactionsTapped = { [weak self] in
            guard let self = self else { return }
            self.navigateToAllTransactions()
        }

        cell.onViewFullScheduleTapped = { [weak self] in
            guard let self = self else { return }
            print("📅 View Full Schedule tapped")
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let feesCount = pendingFeeData?.fees.count ?? 0

        if indexPath.row == 0 {
            return 136
        } else if indexPath.row >= 1 && indexPath.row <= feesCount {
            return 306
        } else if indexPath.row == feesCount + 1 {
            return 156
        } else {
            return 290
        }
    }
}

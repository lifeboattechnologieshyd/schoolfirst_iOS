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
    private var completedFeeData: CompletedFeeResponse?
    private var isLoading: Bool = true
    private var isLoadingCompleted: Bool = true
    private var loadedStudentId: String = ""

    // MARK: - Helper Computed Properties
    private var feesCount: Int {
        return pendingFeeData?.fees.count ?? 0
    }

    private var hasCompletedPayments: Bool {
        return (completedFeeData?.payments.count ?? 0) > 0
    }

    private var completedPaymentsRow: Int? {
        guard hasCompletedPayments else { return nil }
        return feesCount + 1
    }

    private var transactionRow: Int {
        return feesCount + 1 + (hasCompletedPayments ? 1 : 0)
    }

    // MARK: - New Row 5 (always at the end after transactionRow)
    private var transaction5Row: Int {
        return transactionRow + 1
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        setupTableView()
        UserManager.shared.debugPrint()
        fetchPendingFees()
        fetchCompletedFees()
    }

    // MARK: - Fetch Completed Fees API
    private func fetchCompletedFees() {
        isLoadingCompleted = true
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty, !schoolId.isEmpty else {
            isLoadingCompleted = false
            return
        }

        NetworkManager.shared.request(
            urlString: API.FEE_COMPLETED_PAYMENT,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<CompletedFeeResponse>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingCompleted = false
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.completedFeeData = data
                        print("✅ Completed fees loaded | payments: \(data.payments.count)")
                    } else {
                        self.completedFeeData = nil
                    }
                case .failure(let error):
                    print("❌ Completed fee API failed: \(error)")
                    self.completedFeeData = nil
                }
                self.tableview.reloadData()
            }
        }
    }

    // MARK: - Reload on Student Switch
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentStudentId = UserManager.shared.resolvedStudentID
        if currentStudentId != loadedStudentId && !currentStudentId.isEmpty {
            print("🔄 Student changed to: \(currentStudentId)")
            fetchPendingFees()
            fetchCompletedFees()
        }
    }

    // MARK: - 1️⃣ Fetch Pending Fees API
    private func fetchPendingFees() {
        isLoading = true
        tableview.reloadData()
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty, !schoolId.isEmpty else {
            isLoading = false
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
                        self.loadedStudentId = studentId
                    } else {
                        self.pendingFeeData = nil
                    }
                case .failure(let error):
                    print("❌ Pending fee API failed: \(error)")
                    self.pendingFeeData = nil
                }
                self.tableview.reloadData()
            }
        }
    }

    // MARK: - 2️⃣ Initiate Payment
    private func initiatePayment(for feeItem: PendingFeeItem) {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID
        guard !studentId.isEmpty, !schoolId.isEmpty else { return }
        createPaymentOrder(studentId: studentId, schoolId: schoolId, feeItem: feeItem)
    }

    // MARK: - 3️⃣ Create Payment Order API
    private func createPaymentOrder(studentId: String, schoolId: String, feeItem: PendingFeeItem) {
        let parameters: [String: Any] = [
            "student_id": studentId,
            "student_fee_ids": [feeItem.studentFeeId],
            "amount": feeItem.payableAmount
        ]

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
                        self.startPhonePeCheckout(with: paymentData, feeItem: feeItem)
                    }
                case .failure(let error):
                    print("❌ Failed to create payment: \(error)")
                    AlertManager.shared.showAlert(title: "Error", message: "Failed to initiate payment.")
                }
            }
        }
    }

    // MARK: - 4️⃣ Start PhonePe Checkout
    private func startPhonePeCheckout(with paymentData: FeePaymentCreationResponse, feeItem: PendingFeeItem) {
        PhonePePaymentManager.shared.initiatePhonePePayment(
            with: paymentData,
            from: self
        ) { [weak self] paymentResult in
            guard let self = self else { return }
            self.handlePaymentResult(paymentResult, feeItem: feeItem)
        }
    }

    // MARK: - 5️⃣ Handle Payment Result
    private func handlePaymentResult(_ result: PaymentResultStatus, feeItem: PendingFeeItem) {
        switch result {
        case .success(let paymentInfo):
            AlertManager.shared.showAlert(
                title: "Payment Successful",
                message: "Transaction ID: \(paymentInfo.transactionId)\nFee Type: \(feeItem.feeType)"
            )
            loadedStudentId = ""
            fetchPendingFees()
            fetchCompletedFees()
        case .pending(let paymentInfo):
            AlertManager.shared.showAlert(
                title: "Payment Pending",
                message: "Transaction ID: \(paymentInfo.transactionId)"
            )
            loadedStudentId = ""
            fetchPendingFees()
            fetchCompletedFees()
        case .failure(let error):
            AlertManager.shared.showAlert(title: "Payment Failed", message: error.localizedDescription)
        }
    }

    // MARK: - Setup TableView
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "ParentfeeVCTableViewCell", bundle: nil), forCellReuseIdentifier: "ParentfeeVCTableViewCell")
        tableview.register(UINib(nibName: "ParentVCfeetypeTableViewCell2", bundle: nil), forCellReuseIdentifier: "ParentVCfeetypeTableViewCell2")
        tableview.register(UINib(nibName: "ParentVCPaymentcompletedTableViewCell3", bundle: nil), forCellReuseIdentifier: "ParentVCPaymentcompletedTableViewCell3")
        tableview.register(UINib(nibName: "ParentVCTransactionTableViewCell4", bundle: nil), forCellReuseIdentifier: "ParentVCTransactionTableViewCell4")
        tableview.register(UINib(nibName: "ParentVCTransactionTableViewCell5", bundle: nil), forCellReuseIdentifier: "ParentVCTransactionTableViewCell5")
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }

    // MARK: - Top Shadow
    private func setupTopViewShadow() {
        TopView.layer.shadowColor = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius = 2
        TopView.layer.masksToBounds = false
    }

    // MARK: - Navigate to FeealltransactionVC
    private func navigateToAllTransactions() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "FeealltransactionVC") as? FeealltransactionVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Navigate to CalenderVC
    private func navigateToCalender() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CalenderVC") as? CalenderVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Back Button - FIXED VERSION
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 4 }
        // Summary (1) + Pending fees (feesCount) + Completed (1 if exists) + Transaction (1) + Transaction5 (1)
        return transaction5Row + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row

        // Row 0: Summary Cell
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParentfeeVCTableViewCell", for: indexPath) as! ParentfeeVCTableViewCell
            cell.selectionStyle = .none
            cell.configure(totalPayableAmount: pendingFeeData?.totalPayableAmount)
            return cell
        }

        // Rows 1..feesCount: Pending Fee Cells
        if row >= 1 && row <= feesCount {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParentVCfeetypeTableViewCell2", for: indexPath) as! ParentVCfeetypeTableViewCell2
            cell.selectionStyle = .none
            let feeItem = pendingFeeData!.fees[row - 1]
            cell.configure(with: feeItem)

            // ✅ FIXED: Correct closure syntax
            cell.onPayTapped = { [weak self] _ in
                self?.initiatePayment(for: feeItem)
            }
            return cell
        }

        // Row feesCount+1: Completed Payments Cell (ONLY IF EXISTS)
        if let completedRow = completedPaymentsRow, row == completedRow {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParentVCPaymentcompletedTableViewCell3", for: indexPath) as! ParentVCPaymentcompletedTableViewCell3
            cell.selectionStyle = .none

            if isLoadingCompleted {
                cell.configureLoading()
            } else if let firstTransaction = completedFeeData?.payments.first,
                      let firstFee = firstTransaction.fees.first {
                cell.configure(with: firstFee)
            } else {
                cell.configureEmpty()
            }
            return cell
        }

        // Row transactionRow: Transaction Cell
        if row == transactionRow {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParentVCTransactionTableViewCell4", for: indexPath) as! ParentVCTransactionTableViewCell4
            cell.selectionStyle = .none
            return cell
        }

        // Row transaction5Row: Transaction Cell 5
        if row == transaction5Row {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParentVCTransactionTableViewCell5", for: indexPath) as! ParentVCTransactionTableViewCell5
            cell.selectionStyle = .none

            // ✅ Navigate to FeealltransactionVC
            cell.onViewAllTransactionsTapped = { [weak self] in
                self?.navigateToAllTransactions()
            }

            // ✅ Navigate to CalenderVC
            cell.onViewFullScheduleTapped = { [weak self] in
                self?.navigateToCalender()
            }

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0 { return 136 }
        if row >= 1 && row <= feesCount { return 306 }
        if let completedRow = completedPaymentsRow, row == completedRow { return 156 }
        if row == transactionRow { return 140 }
        if row == transaction5Row { return 140 }
        return UITableView.automaticDimension
    }
}

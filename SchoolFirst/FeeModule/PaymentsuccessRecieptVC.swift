//
//  PaymentsuccessRecieptVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/06/26.
//

import UIKit

class PaymentsuccessRecieptVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableview: UITableView!

    /// Optional — connect only if these exist in your storyboard
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var DoneButton: UIButton!

    // MARK: - 📥 Injected Values (set by ParentfeeVC before pushing)
    /// Transaction ID returned by PhonePe — used to match the exact transaction
    var paidTransactionId: String = ""
    /// Amount paid — used as fallback if API hasn't synced yet
    var paidAmount: Double = 0.0
    /// Fee type paid (optional display)
    var paidFeeType: String = ""

    // MARK: - Data
    private var completedFeeData: CompletedFeeResponse?
    private var matchedTransaction: CompletedFeeTransaction?
    private var isLoading: Bool = true

    /// Retry logic — server may take a moment to record the payment
    private var retryCount: Int = 0
    private let maxRetries: Int = 3
    private let retryDelay: TimeInterval = 2.0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        print("""
        🎉 PAYMENT SUCCESS SCREEN OPENED
           Injected Txn ID : \(paidTransactionId)
           Injected Amount : \(paidAmount)
           Injected FeeType: \(paidFeeType)
        """)

        setupTableView()
        fetchCompletedPayment()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Actions
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        goBackToFeeScreen()
    }

    @IBAction func DoneButtonTapped(_ sender: UIButton) {
        goBackToFeeScreen()
    }

    private func goBackToFeeScreen() {
        if let nav = navigationController {
            // Pop back to ParentfeeVC if it's in the stack
            if let feeVC = nav.viewControllers.first(where: { $0 is ParentfeeVC }) {
                nav.popToViewController(feeVC, animated: true)
            } else {
                nav.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - TableView Setup
    private func setupTableView() {

        tableview.delegate   = self
        tableview.dataSource = self

        tableview.separatorStyle               = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.backgroundColor              = .clear

        tableview.register(
            UINib(
                nibName: "PaymentsuccessRecieptVCTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "PaymentsuccessRecieptVCTableViewCell"
        )
    }

    // MARK: - 🌐 Fetch Completed Payment API
    private func fetchCompletedPayment() {

        isLoading = true
        tableview.reloadData()

        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty, !schoolId.isEmpty else {
            print("❌ Missing studentId (\(studentId)) or schoolId (\(schoolId))")
            isLoading = false
            tableview.reloadData()
            return
        }

        print("""
        📡 FETCHING COMPLETED PAYMENT
           URL       : \(API.FEE_COMPLETED_PAYMENT)
           student_id: \(studentId)
           X-School-Id: \(schoolId)
           Attempt   : \(retryCount + 1)/\(maxRetries + 1)
        """)

        NetworkManager.shared.request(
            urlString: API.FEE_COMPLETED_PAYMENT,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<CompletedFeeResponse>, NetworkError>) in

            guard let self = self else { return }

            DispatchQueue.main.async {

                switch result {

                case .success(let response):

                    if response.success, let data = response.data {

                        self.completedFeeData = data
                        self.matchTransaction(from: data)

                        print("✅ Completed payments loaded | total: \(data.payments.count)")

                        // 🔁 Retry if our exact transaction isn't recorded yet
                        if self.matchedTransaction == nil,
                           self.retryCount < self.maxRetries {

                            self.retryCount += 1
                            print("🔄 Transaction not found — retrying \(self.retryCount)/\(self.maxRetries) in \(self.retryDelay)s")

                            DispatchQueue.main.asyncAfter(deadline: .now() + self.retryDelay) {
                                self.fetchCompletedPayment()
                            }
                            return
                        }

                    } else {
                        print("⚠️ API returned success=false")
                        self.completedFeeData   = nil
                        self.matchedTransaction = nil
                    }

                case .failure(let error):
                    print("❌ Completed payment API failed: \(error)")

                    // Retry on network failure too
                    if self.retryCount < self.maxRetries {
                        self.retryCount += 1
                        print("🔄 Network retry \(self.retryCount)/\(self.maxRetries)")

                        DispatchQueue.main.asyncAfter(deadline: .now() + self.retryDelay) {
                            self.fetchCompletedPayment()
                        }
                        return
                    }

                    self.completedFeeData   = nil
                    self.matchedTransaction = nil
                }

                self.isLoading = false
                self.tableview.reloadData()
            }
        }
    }

    // MARK: - 🎯 Match the Exact Transaction
    private func matchTransaction(from data: CompletedFeeResponse) {

        guard !data.payments.isEmpty else {
            matchedTransaction = nil
            print("⚠️ No payments in response")
            return
        }

        // 1️⃣ Match by any of the PhonePe identifiers
        if !paidTransactionId.isEmpty {

            if let exact = data.payments.first(where: { txn in
                txn.transactionId.caseInsensitiveCompare(paidTransactionId)        == .orderedSame ||
                txn.gatewayTransactionId.caseInsensitiveCompare(paidTransactionId) == .orderedSame ||
                txn.gatewayOrderId.caseInsensitiveCompare(paidTransactionId)       == .orderedSame ||
                txn.referenceNumber.caseInsensitiveCompare(paidTransactionId)      == .orderedSame
            }) {
                matchedTransaction = exact
                print("🎯 MATCHED transaction by ID → \(exact.displayTransactionId)")
                return
            }

            print("⚠️ No exact ID match for: \(paidTransactionId)")
        }

        // 2️⃣ Fallback → most recent transaction by date
        let sorted = data.payments.sorted { lhs, rhs in
            let l = lhs.paymentDateObject ?? Date.distantPast
            let r = rhs.paymentDateObject ?? Date.distantPast
            return l > r
        }

        matchedTransaction = sorted.first

        if let matched = matchedTransaction {
            print("📌 Using LATEST transaction → \(matched.displayTransactionId)")
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension PaymentsuccessRecieptVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PaymentsuccessRecieptVCTableViewCell",
            for: indexPath
        ) as! PaymentsuccessRecieptVCTableViewCell

        cell.selectionStyle = .none

        if isLoading {
            // ⏳ Still fetching
            cell.configureLoading()

        } else if let transaction = matchedTransaction {
            // ✅ API data available
            cell.configure(
                student:     completedFeeData?.student,
                transaction: transaction
            )

        } /*else {
            // 🛟 API failed / not synced → show local PhonePe data
            let name = completedFeeData?.student.name
                        ?? UserManager.shared.resolvedStudentName

            cell.configureFallback(
                amount:        paidAmount,
                studentName:   name,
                transactionId: paidTransactionId
            )
        }*/

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 1000
    }
}

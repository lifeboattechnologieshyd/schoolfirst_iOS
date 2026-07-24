//
//  FeealltransactionVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/06/26.
//

import UIKit

class FeealltransactionVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var AcademicYearLbl: UILabel!
    @IBOutlet weak var BackButton:      UIButton!
    @IBOutlet weak var tableview:       UITableView!
    @IBOutlet weak var TopView:         UIView!

    // MARK: - Data
    private var completedFeeData: CompletedFeeResponse?
    private var isLoading:        Bool   = true
    private var loadedStudentId:  String = ""

    // MARK: - Flat rows: one row per fee item
    // Each row = one CompletedFeeItem + its parent CompletedFeeTransaction
    private var flatRows: [(transaction: CompletedFeeTransaction,
                            feeItem: CompletedFeeItem)] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        setupTableView()
        // ✅ Only fetch here — viewWillAppear handles student-switch reload
        fetchCompletedFees()
    }

    // ✅ FIXED: Only reload if student ACTUALLY changed
    // viewWillAppear fires on first appear too, but
    // loadedStudentId is "" on first load so viewDidLoad's
    // fetchCompletedFees() sets it before viewWillAppear's
    // check runs (both on same runloop tick after viewDidLoad)
    // Solution: use a separate flag to skip first appearance
    private var isFirstAppearance = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // ✅ Skip first appearance — viewDidLoad already fetched
        if isFirstAppearance {
            isFirstAppearance = false
            return
        }

        // ✅ Only reload if student changed since last load
        let currentStudentId = UserManager.shared.resolvedStudentID

        guard !currentStudentId.isEmpty else {
            print("⚠️ FeealltransactionVC viewWillAppear: empty studentId, skipping")
            return
        }

        if currentStudentId != loadedStudentId {
            print("🔄 FeealltransactionVC: Student changed!")
            print("   Old : \(loadedStudentId)")
            print("   New : \(currentStudentId)")
            print("   Name: \(UserManager.shared.selectedKid?.name ?? "unknown")")
            fetchCompletedFees()
        } else {
            print("✅ FeealltransactionVC: Same student (\(currentStudentId)), no reload needed")
        }
    }

    // MARK: - Fetch Completed Fees API
    private func fetchCompletedFees() {
        isLoading = true
        flatRows  = []
        tableview.reloadData()

        // ✅ Single source of truth — UserManager
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId  = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty, !schoolId.isEmpty else {
            print("⚠️ FeealltransactionVC: Missing studentId or schoolId")
            print("   studentId: '\(studentId)'")
            print("   schoolId : '\(schoolId)'")
            isLoading = false
            tableview.reloadData()
            return
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 FeealltransactionVC: Fetching completed fees")
        print("   studentId  : \(studentId)")
        print("   studentName: \(UserManager.shared.selectedKid?.name ?? "unknown")")
        print("   schoolId   : \(schoolId)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        NetworkManager.shared.request(
            urlString: API.FEE_COMPLETED_PAYMENT,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<CompletedFeeResponse>, NetworkError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.completedFeeData = data

                        // ✅ Mark which student's data is loaded
                        self.loadedStudentId  = studentId

                        // ✅ Flatten: transaction → fee items
                        // One transaction can have multiple fee items
                        // Each fee item = one table row
                        self.flatRows = data.payments.flatMap { transaction in
                            transaction.fees.map { feeItem in
                                (transaction: transaction, feeItem: feeItem)
                            }
                        }

                        // ✅ Safe label update
                        self.AcademicYearLbl?.text = data.student.academicYear.name

                        print("✅ Completed fees loaded")
                        print("   student     : \(data.student.name)")
                        print("   admissionNo : \(data.student.admissionNumber)")
                        print("   academicYear: \(data.student.academicYear.name)")
                        print("   transactions: \(data.payments.count)")
                        print("   total rows  : \(self.flatRows.count)")
                        print("   total paid  : ₹\(data.totalPaidAmount)")

                        // ✅ Log each row for debugging
                        for (i, row) in self.flatRows.enumerated() {
                            print("   [\(i)] \(row.feeItem.feeType) | \(row.feeItem.formattedPaidAmount) | \(row.feeItem.displayStatus)")
                        }

                    } else {
                        // API returned success = false
                        self.completedFeeData      = nil
                        self.flatRows              = []
                        self.loadedStudentId       = studentId
                        self.AcademicYearLbl?.text = ""
                        print("⚠️ API success=false: \(response.description)")
                    }

                case .failure(let error):
                    // Network / server error
                    self.completedFeeData      = nil
                    self.flatRows              = []
                    self.loadedStudentId       = studentId
                    self.AcademicYearLbl?.text = ""
                    print("❌ Completed fee API failed: \(error)")
                }

                self.tableview.reloadData()
            }
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

    // MARK: - TableView Setup
    private func setupTableView() {
        tableview.delegate             = self
        tableview.dataSource           = self
        tableview.separatorStyle       = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.register(
            UINib(nibName: "FeetransactionTableViewCell", bundle: nil),
            forCellReuseIdentifier: "FeetransactionTableViewCell"
        )
    }

    // MARK: - TopView Shadow
    private func setupTopViewShadow() {
        TopView.layer.shadowColor   = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset  = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius  = 2
        TopView.layer.masksToBounds = false
    }
}

// MARK: - UITableView Delegate & DataSource
extension FeealltransactionVC: UITableViewDelegate, UITableViewDataSource {

    // MARK: - numberOfRowsInSection
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        // ✅ Show skeleton rows while API is in progress
        if isLoading {
            return 5
        }

        // ✅ If there are no completed payments,
        // do not show any cell and keep the table blank
        if flatRows.isEmpty {
            return 0
        }

        return flatRows.count
    }

    // MARK: - cellForRowAt
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeetransactionTableViewCell",
            for: indexPath
        ) as! FeetransactionTableViewCell

        cell.selectionStyle = .none

        // ─────────────────────────────────────
        // Loading State — show placeholders
        // ─────────────────────────────────────
        if isLoading {
            cell.FeetypeLbl?.text         = "Loading..."
            cell.InstallmentLbl?.text     = "──"
            cell.TransactionIDLbl?.text   = "──"
            cell.PaymentDatetimeLbl?.text = "──"
            cell.StatusLbl?.text          = "──"
            return cell
        }

        // ─────────────────────────────────────
        // Safety check
        // ─────────────────────────────────────
        guard indexPath.row < flatRows.count else {
            print("⚠️ Row \(indexPath.row) out of flatRows bounds (\(flatRows.count))")
            return cell
        }

        // ─────────────────────────────────────
        // Data Row — configure only when data exists
        // ─────────────────────────────────────
        let row = flatRows[indexPath.row]

        print("📌 Configuring row \(indexPath.row)")
        print("   feeType    : \(row.feeItem.feeType)")
        print("   paidAmount : \(row.feeItem.formattedPaidAmount)")
        print("   txnRef     : \(row.transaction.referenceNumber)")
        print("   date       : \(row.transaction.formattedPaymentDate)")
        print("   status     : \(row.feeItem.displayStatus)")

        cell.configure(
            feeItem:     row.feeItem,
            transaction: row.transaction
        )

        return cell
    }

    // MARK: - heightForRowAt
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 140
    }
}

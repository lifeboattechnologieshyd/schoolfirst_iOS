//
//  TRSPRTfeepaymentVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

// MARK: - Fee Item Model (sample data — replace with API later)
struct CurrentMonthFeeItem {
    let feeType: String
    let subscriptionType: String
    let amount: String
    let iconName: String
    let iconBgColor: UIColor
    let iconTintColor: UIColor
}

// MARK: - Payment History Item Model (sample data — replace with API later)
struct PaymentHistoryItem {
    let paymentMonth: String      // e.g. "October Payment"
    let date: String              // e.g. "Oct 12, 2024"
    let transactionID: String     // e.g. "99281"
    let amount: String            // e.g. "₹420.00"
    let status: String            // e.g. "SUCCESS"
}

class TRSPRTfeepaymentVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!

    // MARK: - Sample Data (replace with API response later)
    private var currentMonthFees: [CurrentMonthFeeItem] = [
        CurrentMonthFeeItem(
            feeType: "School Bus Service",
            subscriptionType: "Monthly subscription fee",
            amount: "₹280",
            iconName: "bus.fill",
            iconBgColor: UIColor.systemBlue.withAlphaComponent(0.12),
            iconTintColor: .systemBlue
        ),
        CurrentMonthFeeItem(
            feeType: "Platform Service",
            subscriptionType: "Real-time tracking access",
            amount: "₹140",
            iconName: "play.rectangle.fill",
            iconBgColor: UIColor.systemPurple.withAlphaComponent(0.12),
            iconTintColor: .systemPurple
        )
    ]

    // MARK: - Payment History Sample Data (replace with API response later)
    private var paymentHistory: [PaymentHistoryItem] = [
        PaymentHistoryItem(
            paymentMonth: "October Payment",
            date: "Oct 12, 2024",
            transactionID: "99281",
            amount: "₹420.00",
            status: "SUCCESS"
        ),
        PaymentHistoryItem(
            paymentMonth: "September Payment",
            date: "Sep 14, 2024",
            transactionID: "98112",
            amount: "₹420.00",
            status: "SUCCESS"
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    // MARK: - Setup TableView
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "TRSPTfeepaymetsUITableViewCell1", bundle: nil),
            forCellReuseIdentifier: "TRSPTfeepaymetsUITableViewCell1"
        )

        tableview.register(
            UINib(nibName: "TRSPTcurrentmonthfeeUITableViewCell1", bundle: nil),
            forCellReuseIdentifier: "TRSPTcurrentmonthfeeUITableViewCell1"
        )

        tableview.register(
            UINib(nibName: "TRSPTpaymenthistoryUITableViewCell", bundle: nil),
            forCellReuseIdentifier: "TRSPTpaymenthistoryUITableViewCell"
        )

        // ── NEW: Payment Button Cell (last section) ──
        tableview.register(
            UINib(nibName: "TRSPTpaymentbuttonUITableViewCell4", bundle: nil),
            forCellReuseIdentifier: "TRSPTpaymentbuttonUITableViewCell4"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }

    // MARK: - View All Button Action
    @objc private func viewAllPaymentHistoryTapped() {
        print("🔘 View All payment history tapped")
        // TODO: Navigate to full payment history screen
        // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // if let vc = storyboard.instantiateViewController(withIdentifier: "PaymentHistoryVC") as? PaymentHistoryVC {
        //     navigationController?.pushViewController(vc, animated: true)
        // }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension TRSPRTfeepaymentVC: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1   // Summary card cell
        }
        if section == 1 {
            return currentMonthFees.count   // Current month fee items
        }
        if section == 2 {
            return paymentHistory.count   // Payment history items
        }
        return 1   // Payment button cell (last section)
    }

    // MARK: - Section Headers
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {

        // ── Section 1: Current Month Fees ──────────────────────────────
        if section == 1 {
            let headerView = UIView()
            headerView.backgroundColor = .clear

            // ── "Current Month Fees" title (width 200, height 28, semibold, 20, black) ──
            let titleLabel = UILabel()
            titleLabel.text = "Current Month Fees"
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            titleLabel.textColor = .black
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            // ── Current month-year on right (e.g. "October 2024") ──
            let monthLabel = UILabel()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            monthLabel.text = formatter.string(from: Date())
            monthLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            monthLabel.textColor = UIColor.systemBlue
            monthLabel.translatesAutoresizingMaskIntoConstraints = false

            headerView.addSubview(titleLabel)
            headerView.addSubview(monthLabel)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                titleLabel.widthAnchor.constraint(equalToConstant: 200),
                titleLabel.heightAnchor.constraint(equalToConstant: 28),

                monthLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                monthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])

            return headerView
        }

        // ── Section 2: Payment History ─────────────────────────────────
        if section == 2 {
            let headerView = UIView()
            headerView.backgroundColor = .clear

            // ── "Payment History" title (width 150, height 28, bold, 20, black) ──
            let titleLabel = UILabel()
            titleLabel.text = "Payment History"
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            titleLabel.textColor = .black
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            // ── "View All >" button on right ──
            let viewAllButton = UIButton(type: .system)
            viewAllButton.setTitle("View All >", for: .normal)
            viewAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            viewAllButton.setTitleColor(UIColor.systemBlue, for: .normal)
            viewAllButton.translatesAutoresizingMaskIntoConstraints = false
            viewAllButton.addTarget(
                self,
                action: #selector(viewAllPaymentHistoryTapped),
                for: .touchUpInside
            )

            headerView.addSubview(titleLabel)
            headerView.addSubview(viewAllButton)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                titleLabel.widthAnchor.constraint(equalToConstant: 180),
                titleLabel.heightAnchor.constraint(equalToConstant: 28),

                viewAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                viewAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                viewAllButton.heightAnchor.constraint(equalToConstant: 28)
            ])

            return headerView
        }

        return nil
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        if section == 1 { return 44 }
        if section == 2 { return 44 }
        return 0
    }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        return nil
    }

    // MARK: - Cells
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        // ── Section 0: Summary Card Cell ───────────────────────────────
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TRSPTfeepaymetsUITableViewCell1",
                for: indexPath
            ) as! TRSPTfeepaymetsUITableViewCell1

            cell.selectionStyle = .none
            return cell
        }

        // ── Section 1: Current Month Fee Item Cells ────────────────────
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TRSPTcurrentmonthfeeUITableViewCell1",
                for: indexPath
            ) as! TRSPTcurrentmonthfeeUITableViewCell1

            cell.selectionStyle = .none

            let item = currentMonthFees[indexPath.row]
            cell.configure(with: item)

            return cell
        }

        // ── Section 2: Payment History Cells ───────────────────────────
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TRSPTpaymenthistoryUITableViewCell",
                for: indexPath
            ) as! TRSPTpaymenthistoryUITableViewCell

            cell.selectionStyle = .none

            let item = paymentHistory[indexPath.row]
            cell.configure(with: item)

            return cell
        }

        // ── Section 3: Payment Button Cell (last) ──────────────────────
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TRSPTpaymentbuttonUITableViewCell4",
            for: indexPath
        ) as! TRSPTpaymentbuttonUITableViewCell4

        cell.selectionStyle = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        if indexPath.section == 0 {
            return 320
        }

        if indexPath.section == 1 {
            return 100   // Current month fee item card
        }

        if indexPath.section == 2 {
            return 100   // Payment history item card
        }

        return 300   // Payment button cell (last section)
    }
}

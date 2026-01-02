//
//  FeeTransactionsVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit

class FeeTransactionsVC: UIViewController {
    
    var feeDetails: StudentFeeDetails!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var transactions: [FeeTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        getTransactions()
    }
    
    private func setupUI() {
        topVw.addBottomShadow()
        
//        // Setup no data label (if you have one)
//        noDataLbl?.isHidden = true
//        noDataLbl?.text = "No transactions found"
    }
    
    private func setupTableView() {
        tblVw.register(
            UINib(nibName: "TransactionsCell", bundle: nil),
            forCellReuseIdentifier: "TransactionsCell"
        )
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.showsVerticalScrollIndicator = false
    }

    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getTransactions() {
        guard let studentId = feeDetails?.studentUUID else {
            print("❌ No student ID found")
            showNoData()
            return
        }
        
        let parameters: [String: Any] = [
            "student_id": studentId
        ]
        
        NetworkManager.shared.request(
            urlString: API.FEE_TRANSACTIONS,
            method: .GET,
            parameters: parameters
        ) { [weak self] (result: Result<APIResponse<[FeeTransaction]>, NetworkError>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.transactions = data
                        
                        if data.isEmpty {
                            self.showNoData()
                        } else {
                            self.tblVw.isHidden = false
                            self.tblVw.reloadData()
                        }
                        
                        print("✅ Loaded \(data.count) transactions")
                    } else {
                        self.showNoData()
                    }
                    
                case .failure(let error):
                    print("❌ Transaction API Error: \(error)")
                    self.showNoData()
                }
            }
        }
    }
    
    private func showNoData() {
        tblVw.isHidden = true
    }
    
    private func getTransactionStatusColor(type: String) -> UIColor {
        switch type.uppercased() {
        case "CREDIT":
            return UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0) // Green
        case "DEBIT":
            return UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0) // Red
        default:
            return UIColor.darkGray
        }
    }
    
    private func formatDate(timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, hh:mm a"
        return formatter.string(from: date)
    }
    
    private func formatAmount(amount: Double, type: String) -> String {
        let prefix = type.uppercased() == "CREDIT" ? "+ " : "- "
        return "\(prefix)₹\(Int(amount))"
    }
}

extension FeeTransactionsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TransactionsCell",
            for: indexPath
        ) as! TransactionsCell

        let transaction = transactions[indexPath.row]
        
        // Configure cell with transaction data
        cell.configure(with: transaction)

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

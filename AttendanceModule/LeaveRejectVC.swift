//
//  LeaveRejectVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class LeaveRejectVC: UIViewController {
    
    @IBOutlet weak var RejectdateLabel: UILabel!
    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!
    
    // MARK: - Data Source
    var leaveItem: LeaveListItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBackButton()
        configureHeader()
    }
    
    // MARK: - Setup Navigation
    private func setupBackButton() {
        Backbutton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }

    @objc private func didTapBackButton() {
        // ✅ Pop Navigation for Back Button
        navigationController?.popViewController(animated: true)
    }
    
    private func configureHeader() {
        guard let item = leaveItem else {
            RejectdateLabel.text = ""
            return
        }
        
        let rawDate = item.reviewedAt ?? item.createdAt
        RejectdateLabel.text = Self.displayDate(from: rawDate)
    }
    
    // MARK: - Setup TableView
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
        
        let nib = UINib(nibName: "LeaverejectTBLVCLL", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "LeaverejectTBLVCLL")
        
        Tableview.tableFooterView = UIView()
    }
    
    // MARK: - Date Formatting Helpers
    private static let apiFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let apiDateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd MMM yyyy"
        return f
    }()

    static func displayDate(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "—" }

        if let d = apiFormatter.date(from: String(trimmed.prefix(10))) {
            return displayFormatter.string(from: d)
        }
        if let d = apiDateTimeFormatter.date(from: trimmed) {
            return displayFormatter.string(from: d)
        }
        if trimmed.count >= 10 {
            return String(trimmed.prefix(10))
        }
        return trimmed
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension LeaveRejectVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "LeaverejectTBLVCLL",
            for: indexPath
        ) as? LeaverejectTBLVCLL else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        
        if let item = leaveItem {
            cell.configure(with: item)
        }
        
        // ✅ Handle navigation to LeaveapplyVC
        cell.onNavigateToApplyLeave = { [weak self] in
            guard let self = self, let nav = self.navigationController else { return }
            
            // If LeaveapplyVC is already in the stack, pop to it
            if let applyVC = nav.viewControllers.first(where: { $0 is LeaveapplyVC }) {
                nav.popToViewController(applyVC, animated: true)
            } else {
                // Otherwise, instantiate and push it
                let storyboard = UIStoryboard(name: "Main", bundle: nil) // Update Storyboard name if needed
                let applyVC = storyboard.instantiateViewController(withIdentifier: "LeaveapplyVC") as! LeaveapplyVC
                nav.pushViewController(applyVC, animated: true)
            }
        }
        
        return cell
    }
    
    // MARK: - Cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}

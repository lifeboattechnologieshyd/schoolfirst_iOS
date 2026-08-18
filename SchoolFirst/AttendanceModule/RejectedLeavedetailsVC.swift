//
//  LeavedetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 14/08/26.
//

import UIKit

class RejectedLeavedetailsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var Topview: UIView!
    @IBOutlet weak var Tableview: UITableView!  // Add this connection in XIB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopViewShadow()
        setupTableView()
    }
    
    // MARK: - Top View Shadow Setup
    private func setupTopViewShadow() {
        
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
        
        // Optional corner radius
        // Topview.layer.cornerRadius = 12
    }
    
    // MARK: - TableView Setup
    private func setupTableView() {
        
        // Set Delegate & DataSource
        Tableview.delegate = self
        Tableview.dataSource = self
        
        // Register Cell
        Tableview.register(
            UINib(nibName: "ATDNCLeavedetailsVCTBLCLL1", bundle: nil),
            forCellReuseIdentifier: "ATDNCLeavedetailsVCTBLCLL1"
        )
        
        // UI Configuration
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = true
        Tableview.bounces = true
        Tableview.backgroundColor = .white
        
        // Estimated row size for performance (optional)
        Tableview.estimatedRowHeight = 900
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension RejectedLeavedetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1  // Single cell as per requirement
    }
    
    // MARK: - Cell For Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ATDNCLeavedetailsVCTBLCLL1",
            for: indexPath
        ) as! ATDNCLeavedetailsVCTBLCLL1
        
        cell.selectionStyle = .none
        
        // Configure your cell data here if needed
        // cell.setupData(leaveDetail: leaveDetailObject)
        
        return cell
    }
    
    // MARK: - Height For Row (Fixed at 900)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 900
    }
    
    // MARK: - Selection Handler (Optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

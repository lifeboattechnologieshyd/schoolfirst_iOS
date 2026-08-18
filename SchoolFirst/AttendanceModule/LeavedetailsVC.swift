//
//  LeavedetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 17/08/26.
//

import UIKit

class LeavedetailsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Topview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopViewShadow()
        setupTableView()
    }
    
    private func setupTopViewShadow() {
        
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
        
        // Optional: Corner radius
        // Topview.layer.cornerRadius = 12
    }
    
    // MARK: - TableView Configuration
    private func setupTableView() {
        
        // Set Delegate & DataSource
        Tableview.delegate = self
        Tableview.dataSource = self
        
        // Register Cell 1 - Main Details Card (Index 0, Height 1000)
        Tableview.register(
            UINib(nibName: "ATDNCleavedetailsVCTBLCLL", bundle: nil),
            forCellReuseIdentifier: "ATDNCleavedetailsVCTBLCLL"
        )
        
        // Register Cell 2 - Secondary Card (Index 1, Height 260) [NEW]
        Tableview.register(
            UINib(nibName: "ATDNCleavedetailsVCTBLCLL2", bundle: nil),
            forCellReuseIdentifier: "ATDNCleavedetailsVCTBLCLL2"
        )
        
        // UI Settings
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = true
        Tableview.bounces = true
        Tableview.backgroundColor = .white
        
        // Optimization for large cell
        Tableview.estimatedRowHeight = 600
    }
}

// MARK: - TableView Delegate & DataSource
extension LeavedetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Number of Rows Changed to 2
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2  // Updated from 1 to 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // INDEX 0: Main Details Cell (Height 1000)
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ATDNCleavedetailsVCTBLCLL",
                for: indexPath
            ) as! ATDNCleavedetailsVCTBLCLL
            
            cell.selectionStyle = .none
            
            // Configure main details here if needed
            // cell.setupData(leaveDetails: detailsData)
            
            return cell
        }
        
        // INDEX 1: Secondary Cell (Height 260) [NEW]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ATDNCleavedetailsVCTBLCLL2",
            for: indexPath
        ) as! ATDNCleavedetailsVCTBLCLL2
        
        cell.selectionStyle = .none
        
        // Configure second cell data here if needed
        // cell.configureActions(actionsList: actions)
        
        return cell
    }
    
    // MARK: - Height For Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 800 // Cell 1 - Main Details
            
        case 1:
            return 220  // Cell 2 - New Cell
            
        default:
            return UITableView.automaticDimension
        }
    }
    
    // MARK: - Selection Handler (Optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("Selected Row: \(indexPath.row)")
    }
}

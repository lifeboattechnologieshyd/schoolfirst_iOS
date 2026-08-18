//
//  CorrectionHistoryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 14/08/26.
//

import UIKit

class CorrectionHistoryVC: UIViewController {
    
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Topview: UIView!
    
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
        
        // Optional: Add corner radius to top view if needed
        // Topview.layer.cornerRadius = 12
    }
    
    // MARK: - TableView Setup
    private func setupTableView() {
        
        // Set Delegate & DataSource
        Tableview.delegate = self
        Tableview.dataSource = self
        
        // Register Cell 1 (For Index 0)
        Tableview.register(
            UINib(nibName: "ATDNCcorrectionhistoryTBLCLL1", bundle: nil),
            forCellReuseIdentifier: "ATDNCcorrectionhistoryTBLCLL1"
        )
        
        // Register Cell 2 (For Index 1, 2, 3)
        Tableview.register(
            UINib(nibName: "ATDNCcorrectionhistoryTBLCLL2", bundle: nil),
            forCellReuseIdentifier: "ATDNCcorrectionhistoryTBLCLL2"
        )
        
        // UI Configuration
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
        Tableview.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        // Estimated row size for performance
        Tableview.estimatedRowHeight = 340
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CorrectionHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Number of Rows (4 Rows Total: 0, 1, 2, 3)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    // MARK: - Cell For Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Index 0 => Cell 1 (Header/Summary Card - Height 380)
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ATDNCcorrectionhistoryTBLCLL1",
                for: indexPath
            ) as! ATDNCcorrectionhistoryTBLCLL1
            
            cell.selectionStyle = .none
            
            // Configure cell data here if needed
            // cell.setupData(data: yourDataModel)
            
            return cell
        }
        
        // Index 1, 2, 3 => Cell 2 (List Item Cards - Height 300 each)
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ATDNCcorrectionhistoryTBLCLL2",
            for: indexPath
        ) as! ATDNCcorrectionhistoryTBLCLL2
        
        cell.selectionStyle = .none
        
        // Optional: Pass index if you need different data per row
        // cell.configure(for: indexPath.row)
        
        return cell
    }
    
    // MARK: - Height For Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            // First Cell - Large Header Card
            return 240
            
        case 1, 2, 3:
            // Subsequent Cells - List Items
            return 260
        default:
            return UITableView.automaticDimension
        }
    }
    
    // MARK: - Spacing Between Cells (Optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle cell selection if needed
        print("Selected row: \(indexPath.row)")
    }
}

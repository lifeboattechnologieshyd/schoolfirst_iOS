//
//  AttendancecorrectionVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 17/08/26.
//

import UIKit

class AttendancecorrectionVC: UIViewController {
    
    @IBOutlet weak var Topview: UIView!
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopViewShadow()
        setupTableView()
    }
    
    // MARK: - Top View Shadow
    private func setupTopViewShadow() {
        
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }
    
    // MARK: - TableView Setup
    private func setupTableView() {
        
        tableview.delegate = self
        tableview.dataSource = self
        
        // Register Cell 1
        tableview.register(
            UINib(
                nibName: "ATNDScorrectionTBLVCll",
                bundle: nil
            ),
            forCellReuseIdentifier: "ATNDScorrectionTBLVCll"
        )
        
        // Register Cell 2
        tableview.register(
            UINib(
                nibName: "ATNDSrecentcorrectionTBLVCll2",
                bundle: nil
            ),
            forCellReuseIdentifier: "ATNDSrecentcorrectionTBLVCll2"
        )
        
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension AttendancecorrectionVC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Number of Rows
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 2
    }
    
    // MARK: - Cell For Row
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        // MARK: Cell 1
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ATNDScorrectionTBLVCll",
                for: indexPath
            ) as! ATNDScorrectionTBLVCll
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        // MARK: Cell 2
        else {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ATNDSrecentcorrectionTBLVCll2",
                for: indexPath
            ) as! ATNDSrecentcorrectionTBLVCll2
            
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    // MARK: - Cell Height
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        // Cell 1
        if indexPath.row == 0 {
            return 420
        }
        
        // Cell 2
        return 100
    }
}

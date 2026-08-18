//
//  ApplyforleaveVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 14/08/26.
//

import UIKit

class ApplyforleaveVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var Topview: UIView!
    @IBOutlet weak var Tableview: UITableView!  // Connect this in Storyboard/XIB
    
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
        
        // Register Cell with given identifier
        Tableview.register(
            UINib(nibName: "ATDNCApplyforleaveVCBLCLL1", bundle: nil),
            forCellReuseIdentifier: "ATDNCApplyforleaveVCBLCLL1"
        )
        
        // UI Configuration
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = true
        Tableview.bounces = true
        Tableview.backgroundColor = .white
        
        // Estimated row size for performance optimization
        Tableview.estimatedRowHeight = 1000
    }
}

// MARK: - UITableViewDelegate & DataSource
extension ApplyforleaveVC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1  // Single large form cell
    }
    
    // MARK: - Cell For Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ATDNCApplyforleaveVCBLCLL1",
            for: indexPath
        ) as! ATDNCApplyforleaveVCBLCLL1
        
        cell.selectionStyle = .none
        
        // Optional: Setup your form data here
        // cell.configure(with: formData)
        
        return cell
    }
    
    // MARK: - Height For Row (Fixed at 1000)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1000
    }
    
    // MARK: - Selection Handler (Optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

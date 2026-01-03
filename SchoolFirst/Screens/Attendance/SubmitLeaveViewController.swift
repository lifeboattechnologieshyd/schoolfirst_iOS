//
//  SubmitLeaveViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

import UIKit

class SubmitLeaveViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var bottomVw: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
    }
    
    func setupUI() {
        topVw.addBottomShadow(shadowOpacity: 0.15, shadowRadius: 3, shadowHeight: 4)
        bottomVw.addTopShadow()
    }
    
    func setupTableView() {
        // Register cell
        tblVw.register(
            UINib(nibName: "SubmitLeaveTableCell", bundle: nil),
            forCellReuseIdentifier: "SubmitLeaveTableCell"
        )
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        // ⭐ IMPORTANT: Enable automatic dimension for dynamic height
        tblVw.estimatedRowHeight = 300
        tblVw.rowHeight = UITableView.automaticDimension
        
        // Remove extra separators
        tblVw.tableFooterView = UIView()
        
        // Disable cell selection highlight
        tblVw.allowsSelection = false
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SubmitLeaveViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SubmitLeaveTableCell",
            for: indexPath
        ) as! SubmitLeaveTableCell
        
        cell.selectionStyle = .none
        
        return cell
    }

    // ⭐ IMPORTANT: Use automatic dimension instead of fixed height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}

extension UIView {
    
    func addTopShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: -3)
        layer.shadowRadius = 3
        layer.masksToBounds = false
    }
    
    func addBottomShadow(shadowOpacity: Float = 0.2, shadowRadius: CGFloat = 3, shadowHeight: CGFloat = 4) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
    }
}

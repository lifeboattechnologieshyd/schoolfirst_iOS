//
//  TRSPTchatVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/07/26.
//

import UIKit

class TRSPTchatVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var DrivernameLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    
    // MARK: - Properties Passed from Contact Driver Screen
    var driverName: String?
    var driverStatus: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        configureHeaderData()
    }
    
    // MARK: - Back Button Action
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Configure Data to Outlets
    private func configureHeaderData() {
        // Configure Driver Name
        if let name = driverName, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DrivernameLabel.text = name
        } else {
            DrivernameLabel.text = "Driver"
        }

        // Configure Status
        if let status = driverStatus, !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            StatusLabel.text = status.capitalized
        } else {
            StatusLabel.text = "Active"
        }
    }
    
    // MARK: - UI Setup
    private func setupTopViewShadow() {
        TopView.layer.shadowColor = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius = 2
        TopView.layer.masksToBounds = false
    }
}

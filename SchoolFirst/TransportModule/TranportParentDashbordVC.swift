//
//  TranportParentDashbordVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/07/26.
//

import UIKit

class TranportParentDashbordVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!

    // MARK: - Outlets
    @IBOutlet weak var Tableview: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        // If Homescreen was pushed from EdutainmentVC
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup
    private func setupTableView() {
        Tableview.delegate   = self
        Tableview.dataSource = self

        Tableview.register(
            UINib(nibName: "TRNSPTdashbordUITableViewCell1", bundle: nil),
            forCellReuseIdentifier: "TRNSPTdashbordUITableViewCell1"
        )

        Tableview.separatorStyle               = .none
        Tableview.showsVerticalScrollIndicator = false
    }

    // MARK: - Navigation Helpers
    private func navigateToLiveTracking() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "BuslivetrackingVC"
        ) as? BuslivetrackingVC else {
            print("❌ BuslivetrackingVC not found in storyboard. Check Storyboard ID.")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    private func navigateToPickupandDrop() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "TRSPRTpickupanddropVC"
        ) as? TRSPRTpickupanddropVC else {
            print("❌ TRSPRTpickupanddropVC not found in storyboard. Check Storyboard ID.")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func navigateToFeeModule() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "TRSPRTfeepaymentVC"
        ) as? TRSPRTfeepaymentVC else {
            print("❌ TRSPRTfeepaymentVC not found in storyboard. Check Storyboard ID.")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToDriverContact() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "TRSPRTcantactdriverVC"
        ) as? TRSPRTcantactdriverVC else {
            print("❌ TRSPRTcantactdriverVC not found in storyboard. Check Storyboard ID.")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TranportParentDashbordVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TRNSPTdashbordUITableViewCell1",
            for: indexPath
        ) as! TRNSPTdashbordUITableViewCell1

        cell.selectionStyle = .none

        // ── Assign delegate so cell can trigger navigation ─────────────────
        cell.delegate = self

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 1000
    }
}

// MARK: - TRNSPTdashbordCell1Delegate
extension TranportParentDashbordVC: TRNSPTdashbordCell1Delegate {

    func didTapLiveTracking() {
        navigateToLiveTracking()
    }

    func didTapDriverContact() {
        navigateToDriverContact()
    }
    func didTapFeeModule() {
        navigateToFeeModule()
    }
    func didTapPickupandDrop() {
        navigateToPickupandDrop()
    }
}

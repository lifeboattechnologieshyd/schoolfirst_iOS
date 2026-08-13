//
//  TRSPRTpickupanddropVC.swift
//  SchoolFirst
//

import UIKit

class TRSPRTpickupanddropVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    // Track the selected segment index (0 = Pickup, 1 = Drop)
    private var selectedSegmentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    @IBAction func BackButtonTapped(_ sender: UIButton) {

        // If Homescreen was pushed from EdutainmentVC
        navigationController?.popViewController(animated: true)

    }
    

    // MARK: - Setup TableView
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self

        // Register all 3 cell types
        tableview.register(
            UINib(nibName: "TRSPRTpickupanddropUITableviewcell", bundle: nil),
            forCellReuseIdentifier: "TRSPRTpickupanddropUITableviewcell"
        )
        tableview.register(
            UINib(nibName: "TRSPRpickupUITableviewcell2", bundle: nil),
            forCellReuseIdentifier: "TRSPRpickupUITableviewcell2"
        )
        tableview.register(
            UINib(nibName: "TRSPRdropUITableviewcell3", bundle: nil),
            forCellReuseIdentifier: "TRSPRdropUITableviewcell3"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension TRSPRTpickupanddropVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // Row 0: Segment Control | Row 1: Dynamic Content
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Segment Control Cell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TRSPRTpickupanddropUITableviewcell",
                for: indexPath
            ) as! TRSPRTpickupanddropUITableviewcell
            cell.selectionStyle = .none

            // Set initial segment index
            cell.segmentcontroller.selectedSegmentIndex = selectedSegmentIndex

            // Handle segment changes
            cell.onSegmentChange = { [weak self] index in
                self?.selectedSegmentIndex = index
                // Reload only the content cell (row 1)
                self?.tableview.reloadRows(
                    at: [IndexPath(row: 1, section: 0)],
                    with: .automatic
                )
            }
            return cell
        } else {
            // Dynamic Content Cell (Pickup or Drop)
            if selectedSegmentIndex == 0 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TRSPRpickupUITableviewcell2",
                    for: indexPath
                ) as! TRSPRpickupUITableviewcell2
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TRSPRdropUITableviewcell3",
                    for: indexPath
                ) as! TRSPRdropUITableviewcell3
                cell.selectionStyle = .none
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 280 // Height for segment control cell
        } else {
            return 540// Height for Pickup/Drop cells
        }
    }
}

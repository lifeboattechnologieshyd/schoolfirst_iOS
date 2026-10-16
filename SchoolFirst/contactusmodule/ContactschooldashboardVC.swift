//
//  ContactschooldashboardVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/09/26.
//

import UIKit

class ContactschooldashboardVC: UIViewController {

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register XIB cell
        let nib = UINib(nibName: "ContactdashboardTBLVCLL", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "ContactdashboardTBLVCLL")

        // TableView setup
        Tableview.delegate = self
        Tableview.dataSource = self

        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false

        // Add back button navigation
        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }

    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ContactschooldashboardVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContactdashboardTBLVCLL",
            for: indexPath
        ) as! ContactdashboardTBLVCLL

        cell.selectionStyle = .none

        // Handle card tap navigation to ContactslistVC
        cell.onCardTapped = { [weak self] index in
            guard let self = self else { return }
            let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ContactslistVC") as? ContactslistVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 800
    }
}

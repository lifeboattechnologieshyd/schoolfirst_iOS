//
//  ExameventVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/05/26.
//

import UIKit

class ExameventVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!

    let titles = [
        "EXAMINATION DATE",
        "TIME SLOT",
        "VENUE",
        "INVIGILATOR"
    ]

    let values = [
        "May 24, 2024",
        "09:00 - 11:30 AM",
        "Hall B, Level 2",
        "Mr. Smith"
    ]

    let images = [
        "dateicon",
        "clockicon",
        "locationicon",
        "personicon"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.allowsSelection = false
        
        tableview.separatorStyle = .none

        setupTableView()
    }

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "ExameventTableViewCell1", bundle: nil),
            forCellReuseIdentifier: "ExameventTableViewCell1"
        )

        tableview.register(
            UINib(nibName: "ExameventTableViewCell2", bundle: nil),
            forCellReuseIdentifier: "ExameventTableViewCell2"
        )

        // NEW CELL
        tableview.register(
            UINib(nibName: "ExameventTableViewCell3", bundle: nil),
            forCellReuseIdentifier: "ExameventTableViewCell3"
        )

        tableview.separatorStyle = .none
    }
}

extension ExameventVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return 6
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ExameventTableViewCell1",
                for: indexPath
            ) as! ExameventTableViewCell1

            return cell

        } else if indexPath.row == 5 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ExameventTableViewCell3",
                for: indexPath
            ) as! ExameventTableViewCell3

            return cell

        } else {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ExameventTableViewCell2",
                for: indexPath
            ) as! ExameventTableViewCell2

            let dataIndex = indexPath.row - 1

            cell.TitleLabel.text = titles[dataIndex]
            cell.MainLabel.text = values[dataIndex]
            cell.ImageView.image = UIImage(named: images[dataIndex])

            return cell
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0 {
            return 180
        }

        if indexPath.row == 5 {
            return 500
        }

        return 100
    }
}

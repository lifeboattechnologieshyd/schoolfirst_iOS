//
//  HalfDayViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

import UIKit

class HalfDayViewController: UIViewController {

    @IBOutlet weak var bottomVw: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        bottomVw.addTopShadow()

        tblVw.register(UINib(nibName: "SelectDateTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "SelectDateTableViewCell")
        tblVw.register(UINib(nibName: "SelectSessionTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "SelectSessionTableViewCell")

        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
    }
}

extension HalfDayViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectDateTableViewCell", for: indexPath) as? SelectDateTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSessionTableViewCell", for: indexPath) as? SelectSessionTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 350 : 358
    }
}

extension HalfDayViewController: SelectDateCellDelegate {
    func didTaphalfday() {
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "HalfDayViewController") as? HalfDayViewController {
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

 extension UIView {
    func addBottomShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }

    func addTopShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
}


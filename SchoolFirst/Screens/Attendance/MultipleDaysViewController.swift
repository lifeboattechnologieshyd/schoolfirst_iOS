//
//  MultipleDaysViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 31/10/25.
//

import UIKit

class MultipleDaysViewController: UIViewController {
    
    @IBOutlet weak var bottomVw: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         topVw.addBottomShadow()
        bottomVw.addTopShadow()
        
         tblVw.register(UINib(nibName: "MultipleCellOne", bundle: nil),
                       forCellReuseIdentifier: "MultipleCellOne")
        tblVw.register(UINib(nibName: "MultipleCellTwo", bundle: nil),
                       forCellReuseIdentifier: "MultipleCellTwo")
        
         tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension MultipleDaysViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleCellOne", for: indexPath) as? MultipleCellOne else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleCellTwo", for: indexPath) as? MultipleCellTwo else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 444 : 468
    }
}

 


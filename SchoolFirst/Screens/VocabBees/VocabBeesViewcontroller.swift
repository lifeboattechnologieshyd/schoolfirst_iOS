//
//  VocabBeesViewcontroller.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit



class VocabBeesViewController:UIViewController, PracticeTableViewCellDelegate, ChallengesTableViewCellDelegate {
    
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var BackButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(UINib(nibName: "ChallengesTableViewCell", bundle: nil), forCellReuseIdentifier: "ChallengesTableViewCell")
        tblVw.register(UINib(nibName: "PracticeTableViewCell", bundle: nil), forCellReuseIdentifier: "PracticeTableViewCell")
        tblVw.register(UINib(nibName: "CompeteTableViewCell", bundle: nil), forCellReuseIdentifier: "CompeteTableViewCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
    }
}

extension VocabBeesViewController: UITableViewDataSource, UITableViewDelegate, NextButtonDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengesTableViewCell", for: indexPath) as! ChallengesTableViewCell
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeTableViewCell", for: indexPath) as! PracticeTableViewCell
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompeteTableViewCell", for: indexPath) as! CompeteTableViewCell
            cell.delegate = self
             return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
     func didTapNextButton() {
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        if let gradeVC = storyboard.instantiateViewController(withIdentifier: "gradeViewController") as? gradeViewController {
            self.navigationController?.pushViewController(gradeVC, animated: true)
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


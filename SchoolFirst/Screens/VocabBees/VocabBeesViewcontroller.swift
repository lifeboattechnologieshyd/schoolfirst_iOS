//
//  VocabBeesViewcontroller.swift
//  SchoolFirst
//
//  Created by Lifeboat Technologies on 20/10/25.
//

import UIKit



class VocabBeesViewController:UIViewController {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var BackButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.addBottomShadow()
        tblVw.register(UINib(nibName: "ChallengesTableViewCell", bundle: nil), forCellReuseIdentifier: "ChallengesTableViewCell")
        tblVw.register(UINib(nibName: "PracticeTableViewCell", bundle: nil), forCellReuseIdentifier: "PracticeTableViewCell")
        tblVw.register(UINib(nibName: "CompeteTableViewCell", bundle: nil), forCellReuseIdentifier: "CompeteTableViewCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
    }
}

extension VocabBeesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengesTableViewCell", for: indexPath) as! ChallengesTableViewCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeTableViewCell", for: indexPath) as! PracticeTableViewCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompeteTableViewCell", for: indexPath) as! CompeteTableViewCell
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        if let gradeVC = storyboard.instantiateViewController(withIdentifier: "gradeViewController") as? gradeViewController {
            self.navigationController?.pushViewController(gradeVC, animated: true)
        }
    }
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


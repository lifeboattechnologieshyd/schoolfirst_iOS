//
//  AssessmentsViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 10/10/25.
//

import UIKit

class AssessmentsViewController: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(UINib(nibName: "KidsCell", bundle: nil), forCellReuseIdentifier: "KidsCell")
        tblVw.register(UINib(nibName: "AddKidsCell", bundle: nil), forCellReuseIdentifier: "AddKidsCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        for controller in navigationController?.viewControllers ?? [] {
            if controller is HomeController {
                navigationController?.popToViewController(controller, animated: true)
                return
            }
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
}



extension AssessmentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserManager.shared.kids.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == UserManager.shared.kids.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddKidsCell", for: indexPath) as! AddKidsCell
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "KidsCell", for: indexPath) as! KidsCell
        cell.backgroundView?.backgroundColor = .primary
        cell.contentView.backgroundColor = .primary
        cell.setupCell(student: UserManager.shared.kids[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == UserManager.shared.kids.count {
            return 48
        }
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == UserManager.shared.kids.count {
            let vc = storyboard?.instantiateViewController(identifier: "AddKidVC") as! AddKidVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }else{
            let vc = storyboard?.instantiateViewController(identifier: "AssessmentsGradeSelectionVC") as! AssessmentsGradeSelectionVC
            UserManager.shared.assessmentSelectedStudent = UserManager.shared.kids[indexPath.row]
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


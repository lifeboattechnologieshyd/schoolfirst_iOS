//
//  AssessmentsViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 10/10/25.
//

import UIKit

class AssessmentsViewController: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblVw.register(UINib(nibName: "KidsCell", bundle: nil), forCellReuseIdentifier: "KidsCell")
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
}

extension AssessmentsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserManager.shared.kids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KidsCell") as! KidsCell
        cell.backgroundView?.backgroundColor = .primary
        cell.contentView.backgroundColor = .primary
        cell.setupCell(student:  UserManager.shared.kids[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "AssessmentsGradeSelectionVC") as? AssessmentsGradeSelectionVC
        UserManager.shared.assessmentSelectedStudent = UserManager.shared.kids[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

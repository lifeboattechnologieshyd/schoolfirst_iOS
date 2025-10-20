//
//  VocabBeesViewcontroller.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit

class VocabBeesViewController:UIViewController {
     
    
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tblVw.register(UINib(nibName: "ChallengesTableViewCell", bundle: nil), forCellReuseIdentifier: "ChallengesTableViewCell")
        tblVw.register(UINib(nibName: "PracticeTableViewCell", bundle: nil), forCellReuseIdentifier: "PracticeTableViewCell")
        tblVw.register(UINib(nibName: "CompeteTableViewCell", bundle: nil), forCellReuseIdentifier: "CompeteTableViewCell")
       

        tblVw.dataSource = self
        tblVw.delegate = self
    }
}
extension VocabBeesViewController:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
        
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
    
}

//
//  TimeTableViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 12/11/25.
//

import UIKit

class TimeTableViewController: UIViewController {
    @IBOutlet weak var tblVw: UITableView!
    
    @IBOutlet weak var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.addBottomShadow()
        tblVw.register(UINib(nibName: "TimeTableSessionCell", bundle: nil), forCellReuseIdentifier: "TimeTableSessionCell")
        tblVw.register(UINib(nibName: "TimeTablePeroidCell", bundle: nil), forCellReuseIdentifier: "TimeTablePeroidCell")
        tblVw.delegate = self
        tblVw.dataSource = self
        

    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TimeTableViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTablePeroidCell") as! TimeTablePeroidCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTableSessionCell") as! TimeTableSessionCell
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 48 : 88
    }
}

//
//  AttendanceViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 28/10/25.
//

import UIKit

class AttendanceViewController:UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tblVw.register(UINib(nibName: "AttendanceCell", bundle: nil), forCellReuseIdentifier: "AttendanceCell")
        tblVw.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        tblVw.register(UINib(nibName: "CalenderCell", bundle: nil), forCellReuseIdentifier: "CalenderCell")

        
    }
}

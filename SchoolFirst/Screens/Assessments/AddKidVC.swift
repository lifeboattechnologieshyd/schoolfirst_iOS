//
//  AddKidVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 07/11/25.
//

import UIKit

class AddKidVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var addkidButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()

        
        tblVw.delegate = self
        tblVw.dataSource = self
        
         tblVw.register(UINib(nibName: "AddKidOneCell", bundle: nil), forCellReuseIdentifier: "AddKidOneCell")
        
         tblVw.rowHeight = 740
    }
}

extension AddKidVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddKidOneCell", for: indexPath)
        return cell
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    
    }
}


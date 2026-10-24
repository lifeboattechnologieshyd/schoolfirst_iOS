//
//  RemarksdetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 15/10/26.
//

import UIKit

class RemarksdetailsVC: UIViewController {
    
    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!
    
    // MARK: - Data received from previous screen
    var remark: RemarkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Tableview.rowHeight = UITableView.automaticDimension
        Tableview.estimatedRowHeight = 200

        Tableview.separatorStyle = .none
        
        Tableview.delegate = self
        Tableview.dataSource = self
        
        Tableview.register(
            UINib(nibName: "RemarksdetailsTBLVCll1", bundle: nil),
            forCellReuseIdentifier: "RemarksdetailsTBLVCll1"
        )
        
        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension RemarksdetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "RemarksdetailsTBLVCll1",
            for: indexPath
        ) as! RemarksdetailsTBLVCll1
        
        if let remark = remark {
            cell.configure(with: remark)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

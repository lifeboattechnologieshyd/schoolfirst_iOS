//
//  ChatVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 15/09/26.
//

import UIKit

class ChatVC: UIViewController {
    
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Backbutton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add back button navigation
        Backbutton?.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }

    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

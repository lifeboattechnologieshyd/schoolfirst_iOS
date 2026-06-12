//
//  HomeworkDetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkDetailsVC: UIViewController {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var TopView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopViewShadow()
        setupTableView()
    }
    
    private func setupTopViewShadow() {
        TopView.layer.shadowColor = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius = 2
        TopView.layer.masksToBounds = false
    }
    
    private func setupTableView() {
        TableView.delegate = self
        TableView.dataSource = self
        
        TableView.register(
            UINib(nibName: "HomeworkDetailsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "HomeworkDetailsTableViewCell"
        )
        
        TableView.separatorStyle = .none
    }
}

// MARK: - UITableView Delegate & DataSource

extension HomeworkDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HomeworkDetailsTableViewCell",
            for: indexPath
        ) as! HomeworkDetailsTableViewCell
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1200
    }
}

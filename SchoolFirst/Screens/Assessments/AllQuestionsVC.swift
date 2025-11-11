//
//  AllQuestionsVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 11/11/25.
//

import UIKit

class AllQuestionsVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        registerCells()
    }
    
    private func registerCells() {
        tblVw.register(UINib(nibName: "QuestionOneCell", bundle: nil), forCellReuseIdentifier: "QuestionOneCell")
        tblVw.register(UINib(nibName: "QuestionTwoCell", bundle: nil), forCellReuseIdentifier: "QuestionTwoCell")
      }
}

extension AllQuestionsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "QuestionOneCell", for: indexPath)
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "QuestionTwoCell", for: indexPath)
         default:
            return UITableViewCell()
        }
    }
    
     func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0: return 650
        case 1: return 650
         default: return 650
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}




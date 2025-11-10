//
//  QuestionVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class QuestionVC: UIViewController {

    @IBOutlet weak var tblVw: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tblVw.delegate = self
        tblVw.dataSource = self

         tblVw.register(UINib(nibName: "QuestionCell", bundle: nil),
                       forCellReuseIdentifier: "QuestionCell")
    }
}

extension QuestionVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1066
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell",
                                                 for: indexPath) as! QuestionCell

        return cell
    }
}


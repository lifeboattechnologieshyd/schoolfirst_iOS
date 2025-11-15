//
//  DetailsScreenVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 15/11/25.
//
import UIKit

class DetailsScreenVC: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    
    var selectedEvent: Event?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()


        tblVw.register(
            UINib(nibName: "DetailsCell", bundle: nil),
            forCellReuseIdentifier: "DetailsCell"
        )

        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
  
}

extension DetailsScreenVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DetailsCell",
            for: indexPath
        ) as! DetailsCell

     
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
        
    }
}

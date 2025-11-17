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
        
         tblVw.rowHeight = UITableView.automaticDimension
        tblVw.estimatedRowHeight = 200
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
        
        cell.imgVw.loadImage(url: selectedEvent?.image ?? "")
        cell.lblDate.text = selectedEvent?.date.fromyyyyMMddtoDDMMMYYYY()
        cell.lblDateDesign.text = selectedEvent?.date.fromyyyyMMddtoDDMMM()
        cell.lblTime.text = selectedEvent?.time.to12HourTime()
        cell.titleLbl.text = selectedEvent?.name
        cell.desTv.text = selectedEvent?.description
        
        return cell
    }
}

//
//  FeeViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/09/25.
//

import UIKit

class FeeViewController: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var fee_details = [StudentFeeDetails]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(
            UINib(nibName: "FeeTableViewCell", bundle: nil),
            forCellReuseIdentifier: "FeeTableViewCell"
        )
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        getFeeDetails()
        
        topVw.clipsToBounds = false
        topVw.layer.masksToBounds = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topVw.addBottomShadow()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getFeeDetails() {
        NetworkManager.shared.request(urlString: API.FEE_GET_DETAILS, method: .GET) { (result: Result<APIResponse<[StudentFeeDetails]>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.fee_details = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                } else {
                    self.showAlert(msg: info.description)
                }
                
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    func goToPartPayment() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "FeePartPaymentVC"
        ) as! FeePartPaymentVC
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
    

extension FeeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return fee_details.count * 2
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeeTableViewCell",
            for: indexPath
        ) as! FeeTableViewCell
        
        let actualIndex = indexPath.row % fee_details.count
        
        cell.bgView.applyCardShadow()
        cell.setup(details: fee_details[actualIndex])
        
        cell.onClickPartPayment = {
            self.goToPartPayment()
        }
        
        cell.onClickDueDate = {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(
                withIdentifier: "SchoolFeesVC"
            ) as! SchoolFeesVC
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 407
    }
}

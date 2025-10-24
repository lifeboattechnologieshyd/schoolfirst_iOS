//
//  CheckOutViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class CheckOutViewController: UIViewController {
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topbarVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var amountLbl: UILabel!
    
    @IBOutlet weak var buynowButton: UIButton!
    @IBOutlet weak var gstLbl: UILabel!
    @IBOutlet weak var bottomVw: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(UINib(nibName: "CheckOutImageTableViewCell", bundle: nil), forCellReuseIdentifier: "CheckOutImageTableViewCell")
        tblVw.register(UINib(nibName: "DescriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "DescriptionTableViewCell")
        
        tblVw.dataSource = self
        tblVw.delegate = self
        
        setupTopbarShadow()
            }
            
            private func setupTopbarShadow() {
                topbarVw.layer.shadowColor = UIColor.black.cgColor
                topbarVw.layer.shadowOpacity = 0.15
                topbarVw.layer.shadowOffset = CGSize(width: 0, height: 3)
                topbarVw.layer.shadowRadius = 5
                topbarVw.layer.masksToBounds = false
        
                
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)  
            }
        }

         @IBAction func buyNowButtonTapped(_ sender: UIButton) {
            let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
            if let nextVC = storyboard.instantiateViewController(withIdentifier: "MakePaymentViewController") as? MakePaymentViewController {
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }

extension CheckOutViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckOutImageTableViewCell", for: indexPath) as! CheckOutImageTableViewCell
            cell.selectionStyle = .none
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTableViewCell", for: indexPath) as! DescriptionTableViewCell
             cell.selectionStyle = .none
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 212
        case 1:
            return 528  
        default:
            return UITableView.automaticDimension
        }
    }
}

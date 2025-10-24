//
//  EdStoreViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import  UIKit

class EdStoreViewController:UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var inspiroLbl: UILabel!
    @IBOutlet weak var topbarVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
            super.viewDidLoad()

            tblVw.register(UINib(nibName: "EdStoreTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "EdStoreTableViewCell")

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
            navigationController?.popViewController(animated: true)
        }
    }

     extension EdStoreViewController: UITableViewDataSource, UITableViewDelegate, EdStoreCellDelegate {

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 4
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EdStoreTableViewCell", for: indexPath) as! EdStoreTableViewCell
            cell.delegate = self   
            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 246
        }

         func didTapImage(in cell: EdStoreTableViewCell) {
            let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
            if let nextVC = storyboard.instantiateViewController(withIdentifier: "CheckOutViewController") as? CheckOutViewController {
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }


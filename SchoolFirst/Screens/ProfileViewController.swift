//
//  ProfileViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/08/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // header view outlets
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgVw: UIImageView!
    
    @IBOutlet weak var tblVw: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgVw.loadImage(url: UserManager.shared.user?.schools.first?.fullLogo ?? "", placeHolderImage: "")
        
        
        self.tblVw.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        self.tblVw.register(UINib(nibName: "KidsCell", bundle: nil), forCellReuseIdentifier: "KidsCell")
        self.tblVw.register(UINib(nibName: "ProfileOthersCell", bundle: nil), forCellReuseIdentifier: "ProfileOthersCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
    }
    
    func confirmation() {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure want to delete your account?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .destructive) { action in
            self.showAlert(msg: "We’ve received your request. Your account will be permanently deleted in 15 days. If you change your mind, you can log in again before that time to cancel the request.")
        }
        let action2 = UIAlertAction(title: "No", style: .default) { action in
            print("No")
        }
        alert.addAction(action)
        alert.addAction(action2)
        self.present(alert, animated: true)
    }
}

extension ProfileViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? UserManager.shared.kids.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
            cell.onShareClick = {
                self.shareApp(from: self)
            }
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "KidsCell") as! KidsCell
            cell.setupCell(student:  UserManager.shared.kids[indexPath.row])
            return cell
        } else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileOthersCell") as! ProfileOthersCell
            cell.onClickDelete = {
                self.confirmation()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 145
        }else if indexPath.section == 1 {
            return 74
        } else {
            return 374
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else if section == 1 {
            return "My Kids"
        } else {
            return "Others"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 20
        }
    }
}

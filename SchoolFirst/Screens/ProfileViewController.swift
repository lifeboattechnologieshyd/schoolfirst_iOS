//
//  ProfileViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/08/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safe loading of school logo
//        if let logoURL = UserManager.shared.user?.schools.first?.fullLogo, !logoURL.isEmpty {
//            self.imgVw.loadImage(url: logoURL, placeHolderImage: "placeholder_school")
//        } else {
//            self.imgVw.image = UIImage(named: "placeholder_school")
//        }
        
        self.tblVw.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        self.tblVw.register(UINib(nibName: "KidsCell", bundle: nil), forCellReuseIdentifier: "KidsCell")
        self.tblVw.register(UINib(nibName: "ProfileOthersCell", bundle: nil), forCellReuseIdentifier: "ProfileOthersCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblVw.reloadData() // Reload to reflect any kid changes
    }
    
    func navigateToLogin() {
        UserManager.shared.deleteUser()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first {
                let nav = UINavigationController(rootViewController: loginVC)
                nav.navigationBar.isHidden = true
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }
    }
}

extension ProfileViewController {
    
    func logoutConfirmation() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.navigateToLogin()
        }
        let noAction = UIAlertAction(title: "No", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { 3 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1:
            let kidsCount = UserManager.shared.kids.count
            return kidsCount > 0 ? kidsCount : 1  // Show at least 1 row for "No kids" message
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
            cell.onShareClick = { [weak self] in
                guard let self = self else { return }
                self.shareApp(from: self)
            }
            return cell
            
        case 1:
            let kids = UserManager.shared.kids
            if kids.isEmpty {
                // Return a cell showing "No kids added"
                let cell = UITableViewCell(style: .default, reuseIdentifier: "NoKidsCell")
                cell.textLabel?.text = "No kids added yet"
                cell.textLabel?.textColor = .gray
                cell.textLabel?.textAlignment = .center
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "KidsCell") as! KidsCell
                cell.setupCell(student: kids[indexPath.row])
                return cell
            }
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileOthersCell") as! ProfileOthersCell
            
            cell.onClickDelete = { [weak self] in
                // self?.confirmation()
            }
            
            cell.onTermsTapped = { [weak self] in
                let vc = self?.storyboard?.instantiateViewController(identifier: "WebViewController") as? WebViewController
                vc?.type = "TC"
                self?.navigationController?.pushViewController(vc!, animated: true)
            }
            
            cell.onPrivacyTapped = { [weak self] in
                DispatchQueue.main.async {
                    let vc = self?.storyboard?.instantiateViewController(identifier: "WebViewController") as? WebViewController
                    vc?.type = "PP"
                    self?.navigationController?.pushViewController(vc!, animated: true)
                }
            }
            
            cell.onLogoutTapped = { [weak self] in
                self?.logoutConfirmation()
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 145
        case 1:
            if UserManager.shared.kids.isEmpty {
                return 50  // Height for "No kids" cell
            }
            return 74
        default: return 434
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "My Kids"
        case 2: return "Others"
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 20
    }
}

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
        
        self.imgVw.loadImage(url: UserManager.shared.user?.schools.first?.fullLogo ?? "", placeHolderImage: "")
        
        self.tblVw.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        self.tblVw.register(UINib(nibName: "KidsCell", bundle: nil), forCellReuseIdentifier: "KidsCell")
        self.tblVw.register(UINib(nibName: "ProfileOthersCell", bundle: nil), forCellReuseIdentifier: "ProfileOthersCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
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
        return section == 1 ? UserManager.shared.kids.count : 1
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "KidsCell") as! KidsCell
            cell.setupCell(student: UserManager.shared.kids[indexPath.row])
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileOthersCell") as! ProfileOthersCell
            
            cell.onClickDelete = { [weak self] in
                self?.confirmation()
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
        case 1: return 74
        default: return 495
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

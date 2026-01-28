//
//  ProfileViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/08/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var tblVw: UITableView!
    
    var hasKids: Bool {
        return UserManager.shared.kids.count > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImg.addFourSideShadow(
            color: .black,
            opacity: 0.3,
            radius: 8
        )
        self.tblVw.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        self.tblVw.register(UINib(nibName: "KidsCell", bundle: nil), forCellReuseIdentifier: "KidsCell")
        self.tblVw.register(UINib(nibName: "ProfileOthersCell", bundle: nil), forCellReuseIdentifier: "ProfileOthersCell")
        self.tblVw.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        self.tblVw.register(UINib(nibName: "AddKidsCell", bundle: nil), forCellReuseIdentifier: "AddKidsCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblVw.reloadData()
        imgProfile.loadImage(url: UserManager.shared.user?.profileImage ?? "", placeHolderImage: "dummy_kid_profile_pic")

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
            if hasKids {
                return UserManager.shared.kids.count + 1
            } else {
                return 2
            }
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
            if !hasKids {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    cell.titleLbl.textColor = .black
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddKidsCell", for: indexPath) as! AddKidsCell
                    cell.configure(showCardShadow: true)
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    return cell
                }
            }
            if indexPath.row == UserManager.shared.kids.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddKidsCell", for: indexPath) as! AddKidsCell
                cell.configure(showCardShadow: true)
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "KidsCell", for: indexPath) as! KidsCell
            cell.setupCell(student: UserManager.shared.kids[indexPath.row])
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileOthersCell") as! ProfileOthersCell
            
            cell.onClickDelete = { [weak self] in
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
            if !hasKids {
                if indexPath.row == 0 {
                    return 218
                } else {
                    return 48
                }
            }
            
            if indexPath.row == UserManager.shared.kids.count {
                return 48
            }
            
            return 74
            
        case 2: return 434
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 1 else { return }
        
        if !hasKids {
            if indexPath.row == 1 {
                let vc = storyboard?.instantiateViewController(identifier: "AddKidVC") as! AddKidVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        
        if indexPath.row == UserManager.shared.kids.count {
            let vc = storyboard?.instantiateViewController(identifier: "AddKidVC") as! AddKidVC
            self.navigationController?.pushViewController(vc, animated: true)
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

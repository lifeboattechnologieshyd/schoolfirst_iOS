//
//  StudentprofileVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/05/26.
//

//
//  StudentprofileVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/05/26.
//

//
//  StudentprofileVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/05/26.
//

import UIKit

class StudentprofileVC: UIViewController {

    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TableView: UITableView!

    let cellIdentifier = "StudentdetailsTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.allowsSelection = false

        TableView.delegate = self
        TableView.dataSource = self

        // Register XIB
        TableView.register(UINib(nibName: "StudentdetailsTableViewCell", bundle: nil),
                           forCellReuseIdentifier: cellIdentifier)
        
        // Setup Notification Button
        setupNotificationButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup Notification Button
    
    private func setupNotificationButton() {
        NotificationButton.addTarget(self,
                                     action: #selector(notificationButtonTapped),
                                     for: .touchUpInside)
    }
    
    // MARK: - Notification Button Action
    
    @objc private func notificationButtonTapped() {
        navigateToNotification()
    }
    
    // MARK: - Navigate to NotificationVC
    
    private func navigateToNotification() {
        let notificationVC = NotificationVC()
        notificationVC.hidesBottomBarWhenPushed = true
        
        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: false)
            nav.pushViewController(notificationVC, animated: true)
        } else {
            notificationVC.modalPresentationStyle = .fullScreen
            present(notificationVC, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension StudentprofileVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1160
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentdetailsTableViewCell", for: indexPath) as! StudentdetailsTableViewCell
        cell.delegate = self
        return cell
    }
}

// MARK: - StudentdetailsTableViewCellDelegate

extension StudentprofileVC: StudentdetailsTableViewCellDelegate {
    
    func didTapEditButton() {
        navigateToEditProfile()
    }
    
    private func navigateToEditProfile() {
        let editVC = EditProfileVC()
        editVC.hidesBottomBarWhenPushed = true
        
        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: false)
            nav.pushViewController(editVC, animated: true)
        } else {
            editVC.modalPresentationStyle = .fullScreen
            present(editVC, animated: true)
        }
    }
}

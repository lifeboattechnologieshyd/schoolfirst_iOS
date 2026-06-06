//
//  EdutainmentVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 03/01/26.
//

import UIKit
import QPassLib

class EdutainmentVC: UIViewController {
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var videonoTf: UITextField!
    
    var kids: [Student] {
        return UserManager.shared.kids
    }
    
    private var emptyStateView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblVw.reloadData()
        setupEmptyState()
    }
    
    func setupUI() {
        // Nuclear cleanup: Hide all subviews first
        for subview in view.subviews {
            subview.isHidden = true
            // Also remove from superview if it's a segmented control or background image
            if subview is UISegmentedControl {
                subview.removeFromSuperview()
            }
        }
        
        // Only show the table view
        tblVw?.isHidden = false
        tblVw?.backgroundColor = .white
        view.backgroundColor = .white
        
        // Find and show the logo banner if it exists, but skip any 'bg' images
        for subview in view.subviews {
            if let imageView = subview as? UIImageView, imageView.image == UIImage(named: "bg") {
                imageView.removeFromSuperview()
            }
            
            // If it's the header container view (nxn-at-BAE in XML), we need to be careful
            if subview.frame.height > 100 && subview.frame.origin.y == 0 {
                // This is the header view. Let's hide its background image but keep its logos
                subview.isHidden = false
                subview.backgroundColor = .clear
                for innerView in subview.subviews {
                    if let imgV = innerView as? UIImageView {
                        if imgV.image == UIImage(named: "bg") {
                            imgV.isHidden = true
                            imgV.removeFromSuperview()
                        } else {
                            innerView.isHidden = false
                        }
                    } else {
                        innerView.isHidden = true
                    }
                }
            }
        }
        
        // Clear existing constraints to prevent conflicts with storyboard
        for constraint in view.constraints {
            if constraint.firstItem === tblVw || constraint.secondItem === tblVw {
                view.removeConstraint(constraint)
            }
        }
        
        // Position table view with some space from the top
        tblVw.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tblVw.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            tblVw.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tblVw.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tblVw.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        setupEmptyState()
    }
    
    private func setupEmptyState() {
        if kids.isEmpty {
            tblVw.isHidden = true
            
            if emptyStateView == nil {
                let emptyView = UIView()
                emptyView.backgroundColor = .white
                view.addSubview(emptyView)
                emptyView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    emptyView.topAnchor.constraint(equalTo: view.topAnchor),
                    emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
                
                // Content Stack
                let stack = UIStackView()
                stack.axis = .vertical
                stack.alignment = .center
                stack.spacing = 20
                emptyView.addSubview(stack)
                stack.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stack.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                    stack.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20),
                    stack.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
                    stack.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20)
                ])
                
                // Illustration
                let illustration = UIImageView(image: UIImage(named: "bannerImg"))
                illustration.contentMode = .scaleAspectFit
                illustration.translatesAutoresizingMaskIntoConstraints = false
                illustration.heightAnchor.constraint(equalToConstant: 200).isActive = true
                stack.addArrangedSubview(illustration)
                
                // Footer text
                let footerLbl = UILabel()
                footerLbl.text = "Create your Kids Profiles & Access their Grade Curriculums & much more..."
                footerLbl.font = UIFont.lexend(.regular, size: 14)
                footerLbl.textColor = .gray
                footerLbl.textAlignment = .center
                footerLbl.numberOfLines = 0
                stack.addArrangedSubview(footerLbl)
                
                emptyStateView = emptyView
            }
            emptyStateView?.isHidden = false
        } else {
            tblVw.isHidden = false
            emptyStateView?.isHidden = true
        }
    }
    
    private func removeSegmentedControls(from view: UIView) {
        for subview in view.subviews {
            if subview is UISegmentedControl {
                subview.removeFromSuperview()
            } else {
                removeSegmentedControls(from: subview)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeSegmentedControls(from: self.view)
    }
    
    func setupTableView() {
        tblVw.register(UINib(nibName: "KidsCell", bundle: nil), forCellReuseIdentifier: "KidsCell")
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.allowsSelection = true
        tblVw.separatorStyle = .none
        tblVw.backgroundColor = .white
    }
}

extension EdutainmentVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KidsCell", for: indexPath) as! KidsCell
        cell.setupCell(student: kids[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Adjusted for card height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 40))
        label.text = "My School"
        label.font = UIFont.lexend(.semiBold, size: 24)
        label.textColor = .gray
        
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Cell Tapped")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(
            withIdentifier: "Homescreen"
        )
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

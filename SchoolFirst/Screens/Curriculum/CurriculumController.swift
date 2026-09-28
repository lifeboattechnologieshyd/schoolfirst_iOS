//  CurriculumController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class CurriculumController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var lblNoKids: UILabel!
    
    var selected_student = 0
    var types = [Curriculum]()
    var hasShownAddKid = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.addBottomShadow()
        
        tblVw.register(UINib(nibName: "CurriculumTypeCell", bundle: nil),
                       forCellReuseIdentifier: "CurriculumTypeCell")
        
        removeKidSelection()
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.backgroundColor = .white
        tblVw.separatorStyle = .none
        
        getCurriculumType()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    // MARK: - Remove Kid Selection UI (collapse storyboard collection view)
    
    private func removeKidSelection() {
        guard let colVw = colVw else { return }
        
        colVw.isHidden = true
        colVw.dataSource = nil
        colVw.delegate = nil
        
        var foundHeight = false
        for c in colVw.constraints where c.firstAttribute == .height && c.firstItem === colVw {
            c.constant = 0
            foundHeight = true
        }
        if !foundHeight {
            let h = colVw.heightAnchor.constraint(equalToConstant: 0)
            h.priority = .required
            h.isActive = true
        }
        
        for c in view.constraints {
            let involvesCol = (c.firstItem === colVw || c.secondItem === colVw)
            let involvesTbl = (c.firstItem === tblVw || c.secondItem === tblVw)
            if involvesCol && involvesTbl,
               c.firstAttribute == .top || c.firstAttribute == .bottom {
                c.constant = 0
            }
        }
        
        view.layoutIfNeeded()
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        let kids = UserManager.shared.kids
        
        // Case 1: No kids added yet → show AddKid screen
        if kids.isEmpty && !hasShownAddKid {
            hasShownAddKid = true
            
            tblVw.isHidden = true
            lblNoKids?.isHidden = true
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addKidVC = storyboard.instantiateViewController(identifier: "AddKidVC") as? AddKidVC {
                addKidVC.modalPresentationStyle = .fullScreen
                addKidVC.onDismissWithoutAdding = { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
                present(addKidVC, animated: true, completion: nil)
            }
            return
        }
        
        // Case 2: Kids exist → show curriculum table
        if !kids.isEmpty {
            tblVw.isHidden = false
            lblNoKids?.isHidden = true
            
            if let selected = UserManager.shared.curriculamSelectedStudent,
               let idx = kids.firstIndex(where: { $0.id == selected.id }) {
                selected_student = idx
            } else {
                selected_student = 0
                UserManager.shared.curriculamSelectedStudent = kids[0]
            }
            
            tblVw.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    func navigateToCategories(selectedCurriculum: Curriculum) {
        let stbd = UIStoryboard(name: "curriculum", bundle: nil)
        guard let vc = stbd.instantiateViewController(identifier: "CurriculumCategoryController")
                as? CurriculumCategoryController else { return }
        
        vc.selectedCurriculum = selectedCurriculum
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumTypeCell")
                as? CurriculumTypeCell else {
            return UITableViewCell()
        }
        
        let item = types[indexPath.row]
        cell.lblDesc.text = item.description
        cell.lblName.text = item.curriculumName
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedType = types[indexPath.row]
        navigateToCategories(selectedCurriculum: selectedType)
    }
    
    // MARK: - APIs
    
    func getCurriculumType() {
        showLoader()
        NetworkManager.shared.request(urlString: API.CURRICULUM_TYPES,
                                      method: .GET) { [weak self] (result: Result<APIResponse<[Curriculum]>, NetworkError>) in
            guard let self = self else { return }
            self.hideLoader()
            
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.types = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                } else {
                    self.showAlert(msg: info.description ?? "Failed to load curriculum")
                }
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
}

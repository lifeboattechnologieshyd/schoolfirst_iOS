//
//  CurriculumController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class CurriculumController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var lblNoKids: UILabel! 
    
    var selected_student = 0
    var types = [Curriculum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.addBottomShadow()
        
        self.colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        self.tblVw.register(UINib(nibName: "CurriculumTypeCell", bundle: nil), forCellReuseIdentifier: "CurriculumTypeCell")
        
        self.getCurriculumType()
        colVw.delegate = self
        colVw.dataSource = self
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        colVw.reloadData()
    }
    
    var hasShownAddKid = false

    func setupUI() {
        let kids = UserManager.shared.kids

        if kids.isEmpty && !hasShownAddKid {
            hasShownAddKid = true
            
            // Hide curriculum UI
            colVw.isHidden = true
            tblVw.isHidden = true
            lblNoKids?.isHidden = true
            
            // Present AddKidVC modally
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addKidVC = storyboard.instantiateViewController(identifier: "AddKidVC") as? AddKidVC {
                addKidVC.modalPresentationStyle = .fullScreen
                
                // 👇 ADD THIS CLOSURE - When back pressed without adding kid
                addKidVC.onDismissWithoutAdding = { [weak self] in
                    // Pop CurriculumController also
                    self?.navigationController?.popViewController(animated: true)
                }
                
                self.present(addKidVC, animated: true, completion: nil)
            }
            return
        }

        if !kids.isEmpty {
            // Show curriculum
            colVw.isHidden = false
            tblVw.isHidden = false
            lblNoKids?.isHidden = true

            selected_student = 0
            UserManager.shared.curriculamSelectedStudent = kids[0]

            colVw.reloadData()
            tblVw.reloadData()
        }
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:  Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserManager.shared.kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
        let kids = UserManager.shared.kids
        cell.setup(student: kids[indexPath.row], isSelected: selected_student == indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousIndex = selected_student
        selected_student = indexPath.row
        UserManager.shared.curriculamSelectedStudent = UserManager.shared.kids[indexPath.row]
        
        var indexPathsToReload = [indexPath]
        if previousIndex != indexPath.row {
            indexPathsToReload.append(IndexPath(row: previousIndex, section: 0))
        }
        colVw.reloadItems(at: indexPathsToReload)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 20) / 2
        return CGSize(width: width, height: 80)
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumTypeCell") as? CurriculumTypeCell
        cell?.lblDesc.text = types[indexPath.row].description
        cell?.lblName.text = types[indexPath.row].curriculumName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stbd = UIStoryboard(name: "curriculum", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "CurriculumCategoryController") as! CurriculumCategoryController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getCurriculumType() {
        NetworkManager.shared.request(urlString: API.CURRICULUM_TYPES, method: .GET) { (result: Result<APIResponse<[Curriculum]>, NetworkError>) in
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

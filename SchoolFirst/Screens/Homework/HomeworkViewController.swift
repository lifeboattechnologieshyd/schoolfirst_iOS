//
//  HomeworkViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 22/09/25.
//

import UIKit

class HomeworkViewController: UIViewController {
    @IBOutlet weak var lblTItle: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var colVw: UICollectionView!
    
    var homework = [Homework]()
    var past_homework = [Homework]()
    var selected_student = 0
    
    private var currentRequestID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        
        colVw.delegate = self
        colVw.dataSource = self
        
        self.tblVw.delegate = self
        self.tblVw.dataSource = self
        
        self.lblTItle.text = "HomeWork"
        self.segmentControl.applyCustomStyle()
        segmentControl.selectedSegmentIndex = 1
        topView.addBottomShadow()
        
        tblVw.register(UINib(nibName: "HWHeaderCell", bundle: nil), forCellReuseIdentifier: "HWHeaderCell")
        tblVw.register(UINib(nibName: "HWSubjectWiseCell", bundle: nil), forCellReuseIdentifier: "HWSubjectWiseCell")
        tblVw.register(UINib(nibName: "HWFooterCell", bundle: nil), forCellReuseIdentifier: "HWFooterCell")
        
        getHomework()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickChangeSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.getPastHomework()
        } else if sender.selectedSegmentIndex == 1 {
            self.getHomework()
        }
    }
    
    private var currentHomeworkList: [Homework] {
        if segmentControl.selectedSegmentIndex == 0 {
            return past_homework
        } else {
            return homework
        }
    }
    
    private func safeHomework(at section: Int) -> Homework? {
        let list = currentHomeworkList
        guard section >= 0, section < list.count else { return nil }
        return list[section]
    }
    
    private var selectedGradeID: String? {
        guard !UserManager.shared.kids.isEmpty,
              selected_student >= 0,
              selected_student < UserManager.shared.kids.count else {
            return nil
        }
        return UserManager.shared.kids[selected_student].gradeID
    }
    
    func getHomework() {
        homework.removeAll()
        tblVw.reloadData()
        
        guard let gradeID = selectedGradeID else {
            return
        }
        
        let requestID = UUID()
        currentRequestID = requestID
        
        let url = API.HOMEWORK + "?grade_id=\(gradeID)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Homework]>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard self.currentRequestID == requestID else {
                    return
                }
                
                guard self.segmentControl.selectedSegmentIndex == 1 else {
                    return
                }
                
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.homework = data
                    } else {
                        self.homework = []
                    }
                    self.tblVw.reloadData()
                    
                case .failure(let error):
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getPastHomework() {
        past_homework.removeAll()
        tblVw.reloadData()
        
        guard let gradeID = selectedGradeID else {
            return
        }
        
        let requestID = UUID()
        currentRequestID = requestID
        
        let url = API.HOMEWORK_PAST + "grade_id=\(gradeID)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Homework]>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard self.currentRequestID == requestID else {
                    return
                }
                
                guard self.segmentControl.selectedSegmentIndex == 0 else {
                    return
                }
                
                switch result {
                case .success(let info):
                    if info.success, let data = info.data {
                        self.past_homework = data
                    } else {
                        self.past_homework = []
                    }
                    self.tblVw.reloadData()
                    
                case .failure(let error):
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
}

extension HomeworkViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentHomeworkList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let hw = safeHomework(at: section) else { return 0 }
        return 2 + hw.homeworkDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentHW = safeHomework(at: indexPath.section) else {
            return UITableViewCell()
        }
        
        let detailsCount = currentHW.homeworkDetails.count
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HWHeaderCell") as? HWHeaderCell else {
                return UITableViewCell()
            }
            cell.lbldate.text = "Homework Given on \(currentHW.homeworkDate.toddMMMyyyy())"
            cell.lbldeadline.text = "Submit Before: \(currentHW.deadline.toddMMMyyyy())"
            return cell
        }
        
        if indexPath.row == detailsCount + 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HWFooterCell") as? HWFooterCell else {
                return UITableViewCell()
            }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HWSubjectWiseCell") as? HWSubjectWiseCell else {
            return UITableViewCell()
        }
        
        let detailIndex = indexPath.row - 1
        guard detailIndex >= 0, detailIndex < detailsCount else {
            return UITableViewCell()
        }
        
        let details = currentHW.homeworkDetails[detailIndex]
        cell.lblSubject.text = details.subject
        cell.lblDescription.text = details.description
        cell.lblDescription.font = .lexend(.regular, size: 14)
        cell.lblSubject.font = .lexend(.semiBold, size: 14)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let currentHW = safeHomework(at: indexPath.section) else { return 0 }
        
        if indexPath.row == 0 {
            return 66
        } else if indexPath.row == currentHW.homeworkDetails.count + 1 {
            return 80
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension HomeworkViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserManager.shared.kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
        
        guard indexPath.row < UserManager.shared.kids.count else {
            return cell
        }
        
        cell.setup(student: UserManager.shared.kids[indexPath.row], isSelected: selected_student == indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < UserManager.shared.kids.count else { return }
        
        selected_student = indexPath.row
        colVw.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        if segmentControl.selectedSegmentIndex == 0 {
            getPastHomework()
        } else {
            getHomework()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 14) / 2
        return CGSize(width: width, height: 74)
    }
}

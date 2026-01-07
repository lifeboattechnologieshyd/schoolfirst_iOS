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

    private var currentHomeworkList: [Homework] {
        segmentControl.selectedSegmentIndex == 0 ? past_homework : homework
    }
    
    private var selectedGradeID: String? {
        let kids = UserManager.shared.kids
        guard !kids.isEmpty, selected_student >= 0, selected_student < kids.count else { return nil }
        return kids[selected_student].gradeID
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        guard !UserManager.shared.kids.isEmpty else {
            showAlert(msg: "No students found")
            return
        }
        getHomework()
    }

    func setupUI() {
        colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        colVw.delegate = self
        colVw.dataSource = self
        
        tblVw.delegate = self
        tblVw.dataSource = self
        ["HWHeaderCell", "HWSubjectWiseCell", "HWFooterCell"].forEach {
            tblVw.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
        
        lblTItle.text = "HomeWork"
        segmentControl.applyCustomStyle()
        segmentControl.selectedSegmentIndex = 1
        topView.addBottomShadow()
    }

    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickChangeSegment(_ sender: UISegmentedControl) {
        sender.selectedSegmentIndex == 0 ? getPastHomework() : getHomework()
    }

    private func safeHomework(at section: Int) -> Homework? {
        guard section >= 0, section < currentHomeworkList.count else { return nil }
        return currentHomeworkList[section]
    }

    func findTrackerDetail(for subject: String, in homework: Homework) -> HomeworkTrackerDetail? {
        homework.homeworkTrackerDetails.first { $0.subject.lowercased() == subject.lowercased() }
    }

    func calculateUserDoneCount(for homework: Homework) -> Int {
        homework.homeworkTrackerDetails.filter {
            ["completed", "done"].contains($0.status.lowercased())
        }.count
    }

    func getHomework() {
        homework.removeAll()
        tblVw.reloadData()
        
        guard let gradeID = selectedGradeID else { return }
        
        let requestID = UUID()
        currentRequestID = requestID
        
        NetworkManager.shared.request(urlString: API.HOMEWORK + "?grade_id=\(gradeID)", method: .GET) { [weak self] (result: Result<APIResponse<[Homework]>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self, self.currentRequestID == requestID, self.segmentControl.selectedSegmentIndex == 1 else { return }
                self.handleHomeworkResult(result, isPast: false)
            }
        }
    }

    func getPastHomework() {
        past_homework.removeAll()
        tblVw.reloadData()
        
        guard let gradeID = selectedGradeID else { return }
        
        let requestID = UUID()
        currentRequestID = requestID
        
        NetworkManager.shared.request(urlString: API.HOMEWORK_PAST + "grade_id=\(gradeID)", method: .GET) { [weak self] (result: Result<APIResponse<[Homework]>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self, self.currentRequestID == requestID, self.segmentControl.selectedSegmentIndex == 0 else { return }
                self.handleHomeworkResult(result, isPast: true)
            }
        }
    }
    
    private func handleHomeworkResult(_ result: Result<APIResponse<[Homework]>, NetworkError>, isPast: Bool) {
        switch result {
        case .success(let info):
            if isPast {
                past_homework = info.success ? (info.data ?? []) : []
            } else {
                homework = info.success ? (info.data ?? []) : []
            }
            tblVw.reloadData()
        case .failure(let error):
            if case .noaccess = error { handleLogout() } else { showAlert(msg: error.localizedDescription) }
        }
    }

    func markHomeworkAsDone(trackerId: String, cell: HWSubjectWiseCell, section: Int) {
        cell.doneBtn.isUserInteractionEnabled = false
        
        NetworkManager.shared.request(urlString: API.DONE_HOMEWORK, method: .POST, parameters: ["homework_tracker_id": trackerId]) { [weak self] (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if response.success {
                        cell.markAsDone()
                        self.updateTrackerStatus(trackerId: trackerId, section: section)
                        self.reloadFooter(for: section)
                    } else {
                        cell.doneBtn.isUserInteractionEnabled = true
                        self.showAlert(msg: response.description)
                    }
                case .failure(let error):
                    cell.doneBtn.isUserInteractionEnabled = true
                    if case .noaccess = error { self.handleLogout() } else { self.showAlert(msg: error.localizedDescription) }
                }
            }
        }
    }

    func updateTrackerStatus(trackerId: String, section: Int) {
        let isPast = segmentControl.selectedSegmentIndex == 0
        var list = isPast ? past_homework : homework
        guard section < list.count,
              let index = list[section].homeworkTrackerDetails.firstIndex(where: { $0.id == trackerId }) else { return }
        
        let old = list[section].homeworkTrackerDetails[index]
        list[section].homeworkTrackerDetails[index] = HomeworkTrackerDetail(
            id: old.id, userId: old.userId, subject: old.subject, description: old.description, status: "Completed"
        )
        
        if isPast { past_homework = list } else { homework = list }
    }

    func reloadFooter(for section: Int) {
        guard let hw = safeHomework(at: section) else { return }
        let footerRow = hw.homeworkDetails.count + 1
        guard section < tblVw.numberOfSections, footerRow < tblVw.numberOfRows(inSection: section) else { return }
        tblVw.reloadRows(at: [IndexPath(row: footerRow, section: section)], with: .none)
    }
}

extension HomeworkViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        currentHomeworkList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let hw = safeHomework(at: section) else { return 0 }
        return hw.homeworkDetails.count + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentHW = safeHomework(at: indexPath.section) else { return UITableViewCell() }
        let detailsCount = currentHW.homeworkDetails.count
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWHeaderCell") as! HWHeaderCell
            cell.lbldate.text = "Homework Given on \(currentHW.homeworkDate.toddMMMyyyy())"
            cell.lbldeadline.text = "Submit Before: \(currentHW.deadline.toddMMMyyyy())"
            return cell
        }
        
        if indexPath.row == detailsCount + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HWFooterCell") as! HWFooterCell
            cell.configure(studentsCompleted: currentHW.doneCount,
                          userDoneCount: calculateUserDoneCount(for: currentHW),
                          totalCount: detailsCount)
            return cell
        }
        
        let detailIndex = indexPath.row - 1
        guard detailIndex >= 0, detailIndex < detailsCount else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HWSubjectWiseCell") as! HWSubjectWiseCell
        let detail = currentHW.homeworkDetails[detailIndex]
        cell.configure(detail: detail, trackerDetail: findTrackerDetail(for: detail.subject, in: currentHW))
        
        cell.onDoneTapped = { [weak self] in
            guard let self = self, let trackerId = cell.trackerId, let subject = cell.subject else {
                self?.showAlert(msg: "Unable to mark as done. Please try again.")
                return
            }
            
            let alert = UIAlertController(title: "Mark as Done", message: "Are you sure you want to mark \(subject) homework as done?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
                self.markHomeworkAsDone(trackerId: trackerId, cell: cell, section: indexPath.section)
            })
            self.present(alert, animated: true)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == 0 ? 66 : UITableView.automaticDimension
    }
}

extension HomeworkViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        UserManager.shared.kids.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
        let kids = UserManager.shared.kids
        guard indexPath.row < kids.count else { return cell }
        cell.setup(student: kids[indexPath.row], isSelected: selected_student == indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < UserManager.shared.kids.count else { return }
        selected_student = indexPath.row
        colVw.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        segmentControl.selectedSegmentIndex == 0 ? getPastHomework() : getHomework()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.frame.width - 14) / 2, height: 74)
    }
}

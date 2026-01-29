//
//  LeaveHistoryViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 01/11/25.
//
import UIKit

class LeaveHistoryViewController: UIViewController {
    
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var monthsCollectionView: UICollectionView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    
    let months = ["ALL", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                  "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    
    var selectedMonthIndex = 0
    var selected_student = 0
    
    // Data arrays
    var allLeaveHistory: [LeaveHistoryData] = []
    var filteredLeaveHistory: [LeaveHistoryData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow(shadowOpacity: 0.15, shadowRadius: 3, shadowHeight: 4)
        
        setupCollectionView()
        setupKidsCollectionView()
        setupTableView()
        
        // Fetch leave history for first student
        if !UserManager.shared.kids.isEmpty {
            fetchLeaveHistory()
        }
    }
    
    private func setupCollectionView() {
        monthsCollectionView.delegate = self
        monthsCollectionView.dataSource = self
        
        let nib = UINib(nibName: "MonthCell", bundle: nil)
        monthsCollectionView.register(nib, forCellWithReuseIdentifier: "MonthCell")
        
        if let layout = monthsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
        
        monthsCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupKidsCollectionView() {
        colVw.delegate = self
        colVw.dataSource = self
        
        colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        
        if let layout = colVw.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
        
        colVw.showsHorizontalScrollIndicator = false
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.allowsSelection = false
        
        tblVw.register(UINib(nibName: "LeaveHistoryCell", bundle: nil), forCellReuseIdentifier: "LeaveHistoryCell")
    }
    
    private func showToast(message: String) {
        DispatchQueue.main.async {
            let toastLabel = UILabel()
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            toastLabel.textColor = .white
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont.systemFont(ofSize: 14)
            toastLabel.text = message
            toastLabel.numberOfLines = 0
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 8
            toastLabel.clipsToBounds = true
            
            let maxWidth = self.view.frame.width - 40
            let size = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
            toastLabel.frame = CGRect(x: 20, y: self.view.frame.height - 120,
                                      width: maxWidth, height: size.height + 20)
            
            self.view.addSubview(toastLabel)
            
            UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    func fetchLeaveHistory() {
        guard !UserManager.shared.kids.isEmpty else { return }
        
        let student = UserManager.shared.kids[selected_student]
        let studentId = student.studentID
        
        let urlString = "\(API.LEAVE_HISTORY)?student_id=\(studentId)"
        
        showLoader() // ✅ Added
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET,
            parameters: nil,
            headers: nil
        ) { [weak self] (result: Result<APIResponse<[LeaveHistoryData]>, NetworkError>) in
            
            DispatchQueue.main.async {
                
                self?.hideLoader() // ✅ Added
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self?.allLeaveHistory = data
                        self?.filterLeaveHistory()
                        print("✅ Leave history fetched: \(data.count) records")
                    } else {
                        self?.allLeaveHistory = []
                        self?.filteredLeaveHistory = []
                        self?.tblVw.reloadData()
                        self?.showEmptyState()
                        self?.showToast(message: response.description)
                    }
                    
                case .failure(let error):
                    self?.allLeaveHistory = []
                    self?.filteredLeaveHistory = []
                    self?.tblVw.reloadData()
                    self?.showEmptyState()
                    
                    switch error {
                    case .noaccess:
                        self?.showToast(message: "Session expired. Please login again.")
                    case .serverError(let msg):
                        self?.showToast(message: msg)
                    default:
                        self?.showToast(message: "Failed to fetch leave history")
                    }
                    print("❌ Error fetching leave history: \(error)")
                }
            }
        }
    }
    
    func filterLeaveHistory() {
        if selectedMonthIndex == 0 {
            // "ALL" selected - show all records
            filteredLeaveHistory = allLeaveHistory
        } else {
            // Filter by selected month (selectedMonthIndex matches month number: 1=JAN, 2=FEB, etc.)
            filteredLeaveHistory = allLeaveHistory.filter { leave in
                return leave.leaveMonth == selectedMonthIndex
            }
        }
        
        tblVw.reloadData()
        showEmptyState()
    }
    
    func showEmptyState() {
        if filteredLeaveHistory.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No leave history found"
            emptyLabel.textColor = .gray
            emptyLabel.textAlignment = .center
            emptyLabel.font = UIFont.systemFont(ofSize: 16)
            tblVw.backgroundView = emptyLabel
        } else {
            tblVw.backgroundView = nil
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension LeaveHistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == monthsCollectionView {
            return months.count
        } else if collectionView == colVw {
            return UserManager.shared.kids.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == monthsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath) as! MonthCell
            let isSelected = indexPath.item == selectedMonthIndex
            cell.configure(with: months[indexPath.item], isSelected: isSelected)
            return cell
            
        } else if collectionView == colVw {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
            cell.setup(student: UserManager.shared.kids[indexPath.row], isSelected: selected_student == indexPath.row)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == monthsCollectionView {
            selectedMonthIndex = indexPath.item
            collectionView.reloadData()
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            filterLeaveHistory()
            
        } else if collectionView == colVw {
            selected_student = indexPath.row
            collectionView.reloadData()
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            selectedMonthIndex = 0
            monthsCollectionView.reloadData()
            fetchLeaveHistory()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == monthsCollectionView {
            return CGSize(width: 60, height: 32)
        } else if collectionView == colVw {
            let width = (collectionView.frame.size.width - 20) / 3
            return CGSize(width: width, height: 74)
        }
        
        return CGSize(width: 80, height: 50)
    }
}

extension LeaveHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLeaveHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveHistoryCell", for: indexPath) as! LeaveHistoryCell
        let leave = filteredLeaveHistory[indexPath.row]
        cell.configure(with: leave)
        cell.resubmitBtn.tag = indexPath.row
        cell.resubmitBtn.addTarget(self, action: #selector(resubmitTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func resubmitTapped(_ sender: UIButton) {
        let leave = filteredLeaveHistory[sender.tag]
        print("Resubmit tapped for leave ID: \(leave.id)")
        
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let resubmitVC = storyboard.instantiateViewController(withIdentifier: "ReSubmitViewController") as? ReSubmitViewController {
            resubmitVC.leaveData = leave
            navigationController?.pushViewController(resubmitVC, animated: true)
        }
    }
}

//
//  AttendanceViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 28/10/25.
//

import UIKit
import FSCalendar

class AttendanceViewController: UIViewController {
    
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    var selected_student = 0
    var selected_date = Date()
    var leaves = [Leave]()
    var attendanceDetails: Attendance?
    var monthlyAttendance = [String: DayAttendanceStats]()
    
    private var kids: [Student] {
        UserManager.shared.kids
    }
    
    private var selectedStudentID: String? {
        guard !kids.isEmpty, selected_student >= 0, selected_student < kids.count else { return nil }
        return kids[selected_student].studentID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow(shadowOpacity: 0.15, shadowRadius: 3, shadowHeight: 4)
        setupTableView()
        
        guard !kids.isEmpty else {
            showAlert(msg: "No student found")
            return
        }
        
        getAttandanceReport()
        getLeaveDetails(date: Date())
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.allowsSelection = false
        
        colVw.delegate = self
        colVw.dataSource = self
        
        colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        tblVw.register(UINib(nibName: "AttendanceCell", bundle: nil), forCellReuseIdentifier: "AttendanceCell")
        tblVw.register(UINib(nibName: "CalendarTableViewCell", bundle: nil), forCellReuseIdentifier: "CalendarTableViewCell")
    }
    
    func getAttandanceReport() {
        showLoader()

        guard let studentID = selectedStudentID else { return }
        
        let url = API.ATTENDANCE_STATS + "student_id=\(studentID)"
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<Attendance>, NetworkError>) in
            guard let self = self else { return }
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success, let data = info.data {
                    self.attendanceDetails = data
                    DispatchQueue.main.async { self.tblVw.reloadData() }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if case .noaccess = error {
                        self.handleLogout()
                    } else {
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getLeaveDetails(date: Date) {
        guard let studentID = selectedStudentID else { return }
        showLoader()
        
        let (sd, ed) = getMonthStartEnd(from: date)
        let url = API.ATTENDANCE_LEAVE_HISTORY + "student_id=\(studentID)&start_date=\(sd)&end_date=\(ed)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[Leave]>, NetworkError>) in
            guard let self = self else { return }
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success, let data = info.data {
                    self.leaves = data
                    let key = self.toYearMonth(date)
                    let stats = self.generateDayAttendanceStats(leaves: data, month: date)
                    self.monthlyAttendance[key] = stats
                    DispatchQueue.main.async { self.tblVw.reloadData() }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if case .noaccess = error {
                        self.handleLogout()
                    } else {
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getMonthStartEnd(from date: Date) -> (String, String) {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let endComps = DateComponents(year: calendar.component(.year, from: date), month: calendar.component(.month, from: date), day: calendar.range(of: .day, in: .month, for: date)!.count)
        let end = calendar.date(from: endComps)!
        return (formatter.string(from: start), formatter.string(from: end))
    }
    
    func toYearMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
    
    func generateDayAttendanceStats(leaves: [Leave], month: Date) -> DayAttendanceStats {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)!.count
        let today = Date()
        let isCurrentMonth = calendar.isDate(today, equalTo: month, toGranularity: .month)
        let endDayLimit = isCurrentMonth ? calendar.component(.day, from: today) : daysInMonth
        
        var absentDays = Set<Int>()
        var halfDays = Set<Int>()
        
        for leave in leaves {
            guard let from = formatter.date(from: leave.fromDate),
                  let to = formatter.date(from: leave.toDate) else { continue }
            
            let clampedStart = max(from, startOfMonth)
            let clampedEnd = min(to, calendar.date(byAdding: .day, value: endDayLimit - 1, to: startOfMonth)!)
            
            guard clampedStart <= clampedEnd else { continue }
            
            let startDay = calendar.component(.day, from: clampedStart)
            let endDay = calendar.component(.day, from: clampedEnd)
            
            if leave.totalDays == 0.5 {
                halfDays.insert(startDay)
            } else {
                for d in startDay...endDay { absentDays.insert(d) }
            }
        }
        
        var presentDays: [Int] = []
        for d in 1...endDayLimit {
            var comps = calendar.dateComponents([.year, .month], from: month)
            comps.day = d
            if let date = calendar.date(from: comps),
               calendar.component(.weekday, from: date) != 1,
               !absentDays.contains(d),
               !halfDays.contains(d) {
                presentDays.append(d)
            }
        }
        
        return DayAttendanceStats(present: presentDays.sorted(), absent: Array(absentDays).sorted(), half: Array(halfDays).sorted())
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension AttendanceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        attendanceDetails != nil ? 2 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath) as! AttendanceCell
            if let attendance = attendanceDetails {
                cell.setupcell(attendance: attendance)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell", for: indexPath) as! CalendarTableViewCell
            cell.monthlyAttendance = monthlyAttendance
            cell.calendar.reloadData()
            cell.onSelectMonth = { [weak self] date in
                self?.selected_date = date
                self?.getLeaveDetails(date: date)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == 0 ? 290 : 472
    }
}

extension AttendanceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
        guard indexPath.row < kids.count else { return cell }
        cell.setup(student: kids[indexPath.row], isSelected: selected_student == indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < kids.count else { return }
        selected_student = indexPath.row
        colVw.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        getAttandanceReport()
        getLeaveDetails(date: selected_date)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 150, height: 74)
    }
}

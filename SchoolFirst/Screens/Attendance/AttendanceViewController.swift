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
    var attendanceDetails : Attendance!
    var monthlyAttendance = [String: DayAttendanceStats]()
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow(shadowOpacity: 0.15, shadowRadius: 3, shadowHeight: 4)
        self.getAttandanceReport()
        self.getLeaveDetails(date: Date())
    }
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.allowsSelection = false
        
        self.colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")

        colVw.delegate = self
        colVw.dataSource = self
        
        tblVw.register(UINib(nibName: "AttendanceCell", bundle: nil), forCellReuseIdentifier: "AttendanceCell")
        tblVw.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        tblVw.register(UINib(nibName: "CalendarTableViewCell", bundle: nil), forCellReuseIdentifier: "CalendarTableViewCell")
    }
    
    func getMonthStartEnd(from date: Date) -> (String, String) {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: date)!
        var comps = calendar.dateComponents([.year, .month], from: date)
        comps.day = range.count
        let endDate = calendar.date(from: comps)!
        return (formatter.string(from: startDate), formatter.string(from: endDate))
    }
    
    
    func getAttandanceReport() {
        let url = API.ATTENDANCE_STATS + "student_id=\(UserManager.shared.kids[selected_student].studentID)"
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<Attendance>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.attendanceDetails = data
                        DispatchQueue.main.async {
                            self.setupTableView()
                            self.tblVw.reloadData()
                        }
                    }
                }else{
                    print(info.description)
                }
            case .failure(let error):
                DispatchQueue.main.async {
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
    
    func generateDayAttendanceStats(leaves: [Leave], month: Date) -> DayAttendanceStats {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Start of the selected month
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)!.count
        
        // If selected month is current month, endDayLimit = today.day, else end of month
        let today = Date()
        let selectedComponents = calendar.dateComponents([.year, .month], from: month)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        let isCurrentMonth = (selectedComponents.year == todayComponents.year) && (selectedComponents.month == todayComponents.month)
        let endDayLimit = isCurrentMonth ? (todayComponents.day ?? daysInMonth) : daysInMonth
        
        var absentDays = Set<Int>()
        var halfDays = Set<Int>()
        
        for leave in leaves {
            // Parse leave dates (expects "yyyy-MM-dd")
            guard let from = formatter.date(from: leave.fromDate),
                  let to = formatter.date(from: leave.toDate) else {
                continue
            }
            
            // If leave period doesn't overlap selected month at all, skip
            if to < startOfMonth {
                continue
            }
            // End of selected month (clamped to endDayLimit)
            var comps = calendar.dateComponents([.year, .month], from: month)
            comps.day = endDayLimit
            guard let endOfVisibleMonth = calendar.date(from: comps) else { continue }
            
            if from > endOfVisibleMonth {
                continue
            }
            
            // Clamp start & end to within selected month's visible range
            let clampedStart = max(from, startOfMonth)
            let clampedEnd = min(to, endOfVisibleMonth)
            
            // Convert to day numbers (1-based)
            let startDay = calendar.component(.day, from: clampedStart)
            let endDay = calendar.component(.day, from: clampedEnd)
            
            if leave.totalDays == 0.5 {
                // For half-day, mark only the start day (clamped)
                if startDay >= 1 && startDay <= endDayLimit {
                    halfDays.insert(startDay)
                }
            } else {
                // Full-day absent: mark every day in the clamped range
                for d in startDay...endDay {
                    absentDays.insert(d)
                }
            }
        }
        
        // Present days = all visible days (1...endDayLimit) not in absent or half
        var presentDays: [Int] = []
        for d in 1...endDayLimit {
            
            // this is to remove sundays from present days. we have to remove this logic if holiday list is provided from the api.
            var c = calendar.dateComponents([.year, .month], from: month)
                   c.day = d
            if let date = calendar.date(from: c) {
                let weekday = calendar.component(.weekday, from: date)
                if weekday == 1 { continue }  // Skip Sunday
            }
            // skip sunday logic completed.
            
            if !absentDays.contains(d) && !halfDays.contains(d) {
                presentDays.append(d)
            }
        }
        
        return DayAttendanceStats(
            present: presentDays.sorted(),
            absent: Array(absentDays).sorted(),
            half: Array(halfDays).sorted()
        )
    }

    
    func getLeaveDetails(date: Date){
        let (sd,ed) = getMonthStartEnd(from: date)
        let url = API.ATTENDANCE_LEAVE_HISTORY + "student_id=\(UserManager.shared.kids[selected_student].studentID)"+"&start_date=\(sd)&end_date=\(ed)"
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[Leave]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.leaves = data
                        let key = self.toYearMonth(date)
                        let values = self.generateDayAttendanceStats(leaves: data, month: date)
                        self.monthlyAttendance = [key: values]
                        DispatchQueue.main.async {
                            self.setupTableView()
                            self.tblVw.reloadData()
                        }
                    }
                }else{
                    print(info.description)
                }
            case .failure(let error):
                DispatchQueue.main.async {
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

extension AttendanceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath) as! AttendanceCell
            cell.setupcell(attendance: attendanceDetails)
            return cell
            //        case 2:
            //            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceTableViewCell", for: indexPath) as! AttendanceTableViewCell
            //            cell.colVw.reloadData()
            //            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell", for: indexPath) as! CalendarTableViewCell
            cell.monthlyAttendance = self.monthlyAttendance
            cell.calendar.reloadData()
            cell.onSelectMonth = { date in
                self.selected_date = date
                self.getLeaveDetails(date: date)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func toYearMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 295
        case 1: return 480
        default: return 0
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}


extension AttendanceViewController  : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserManager.shared.kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
        cell.setup(student: UserManager.shared.kids[indexPath.row], isSelected: selected_student ==  indexPath.row)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected_student = indexPath.row
        colVw.reloadData()
        collectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: true
            )
        getAttandanceReport()
        self.getLeaveDetails(date: self.selected_date)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        colVw.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width-10)/2
        return CGSize(width: width, height: 74)
    }
}


//
//  WeaklyattendanceVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class WeaklyattendanceVC: UIViewController {
    
    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!
    
    // MARK: - Data State
    private var allAttendanceRecords: [FetchStudentAttendanceRecord] = []
    
    // Manage currently selected week (always points to the Monday of that week)
    private var currentWeekStart: Date = Date()
    // Manage currently selected specific day
    private var selectedDate: Date = Date()
    
    // Date Formatters
    private let apiDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize dates to current week's Monday and today
        setupDates()
        setupTableView()
        
        Backbutton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )
        
        fetchWeeklyAttendance()
    }
    
    // MARK: - Date Initialization
    private func setupDates() {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Monday
        
        let today = Date()
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        currentWeekStart = cal.date(from: comps) ?? today
        
        // Default select today. If today is weekend, fallback to Friday
        let weekday = cal.component(.weekday, from: today)
        if weekday == 1 || weekday == 7 { // 1 = Sun, 7 = Sat
            selectedDate = cal.date(byAdding: .day, value: 4, to: currentWeekStart) ?? currentWeekStart // Friday
        } else {
            selectedDate = today
        }
    }
    
    // MARK: - Back Button
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup TableView
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
        
        // Register cell 1 (Top Header / Week Selector)
        let nib = UINib(nibName: "WeaklyattendanceVCTBLVCLL", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "WeaklyattendanceVCTBLVCLL")
        
        // Register cell 2 (List of rest of the week records)
        let nib2 = UINib(nibName: "absentpresentlateTBLVCLL", bundle: nil)
        Tableview.register(nib2, forCellReuseIdentifier: "absentpresentlateTBLVCLL")
        
        Tableview.tableFooterView = UIView()
    }
    
    // MARK: - API Integration
    private func fetchWeeklyAttendance() {
        let studentID = UserManager.shared.resolvedStudentID
        let schoolID = UserManager.shared.resolvedSchoolID
        
        guard !studentID.isEmpty, !schoolID.isEmpty else {
            print("⚠️ Missing Student ID or School ID")
            return
        }
        
        let parameters: [String: Any] = ["student_id": studentID]
        let headers: [String: String] = ["x-school-id": schoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_STUDENT_ATTENDANCE,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<FetchStudentAttendanceData>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.allAttendanceRecords = response.data?.attendance ?? []
                    self?.Tableview.reloadData()
                    
                case .failure(let error):
                    print("❌ Failed to fetch weekly attendance: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Computed Data Helpers
    
    /// Returns the dates from Mon to Fri of the currently selected week
    private func currentWeekDays() -> [String] {
        var days: [String] = []
        let cal = Calendar(identifier: .gregorian)
        for i in 0..<5 {
            if let d = cal.date(byAdding: .day, value: i, to: currentWeekStart) {
                days.append(apiDateFormatter.string(from: d))
            }
        }
        return days
    }
    
    /// Returns records only for the currently selected week (Mon-Fri)
    private func recordsForCurrentWeek() -> [FetchStudentAttendanceRecord] {
        let weekDays = currentWeekDays()
        return allAttendanceRecords.filter { record in
            guard let dateStr = record.attendanceDate else { return false }
            return weekDays.contains(dateStr)
        }
    }
    
    /// Returns records for the "Rest of the week" section (Excluding the selected day)
    private func restOfWeekRecords() -> [FetchStudentAttendanceRecord] {
        let selectedDateStr = apiDateFormatter.string(from: selectedDate)
        
        // Get records for the week, exclude the selected date, and sort descending by date
        return recordsForCurrentWeek()
            .filter { $0.attendanceDate != selectedDateStr }
            .sorted { ($0.attendanceDate ?? "") > ($1.attendanceDate ?? "") }
    }
    
    /// Returns the specific record for the selected date
    private func recordForSelectedDate() -> FetchStudentAttendanceRecord {
        let selectedDateStr = apiDateFormatter.string(from: selectedDate)
        if let match = allAttendanceRecords.first(where: { $0.attendanceDate == selectedDateStr }) {
            return match
        } else {
            // Return dummy "No record" if API hasn't generated one for this day
            return FetchStudentAttendanceRecord(
                id: nil, attendanceDate: selectedDateStr, status: "",
                student: nil, grade: nil, section: nil, branch: nil,
                remarks: "No attendance recorded", createdAt: nil, markedBy: nil
            )
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension WeaklyattendanceVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1 header cell + dynamic records for the "Rest of the week"
        return 1 + restOfWeekRecords().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            // HEADER CELL
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "WeaklyattendanceVCTBLVCLL",
                for: indexPath
            ) as? WeaklyattendanceVCTBLVCLL else {
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            cell.delegate = self
            
            // Calculate stats for the current week
            let currentWeekData = recordsForCurrentWeek()
            let leaves = currentWeekData.filter { $0.status?.uppercased() == "LEAVE" }.count
            let lates = currentWeekData.filter { $0.status?.uppercased() == "LATE" }.count
            
            // Configure the header cell with the computed state
            cell.configure(
                weekStart: currentWeekStart,
                selectedDate: selectedDate,
                selectedRecord: recordForSelectedDate(),
                leaveCount: leaves,
                lateCount: lates
            )
            
            return cell
            
        } else {
            // REST OF THE WEEK CELLS
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "absentpresentlateTBLVCLL",
                for: indexPath
            ) as? absentpresentlateTBLVCLL else {
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            
            let records = restOfWeekRecords()
            let record = records[indexPath.row - 1]
            cell.configure(with: record)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 360 : 76
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 360 : 76
    }
}

// MARK: - WeaklyattendanceVCTBLVCLLDelegate
extension WeaklyattendanceVC: WeaklyattendanceVCTBLVCLLDelegate {
    
    func didChangeWeek(to newWeekStart: Date) {
        self.currentWeekStart = newWeekStart
        // Automatically select Monday of the new week
        self.selectedDate = newWeekStart
        self.Tableview.reloadData()
    }
    
    func didSelectDay(date: Date) {
        self.selectedDate = date
        self.Tableview.reloadData()
    }
}

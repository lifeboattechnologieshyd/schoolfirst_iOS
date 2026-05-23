//
//  CalendarViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 31/08/25.
//

import UIKit

class CalendarViewController: UIViewController {
    
    // header view outlets
    
    @IBOutlet weak var imgProfile: UIImageView!
//    @IBOutlet weak var imgVw: UIImageView!

    @IBOutlet weak var dateSelectionView: MonthHeaderView!
    
    @IBOutlet weak var tblVw: UITableView!
    var selectedIndex: IndexPath?
    var events = [Event]()
    var calender = [LifeSkillPrompt]()
    var start_date = ""
    @IBOutlet weak var colVw: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imgProfile.loadImage(url: UserManager.shared.user?.profileImage ?? "", placeHolderImage: "dummy_kid_profile_pic")

        self.colVw.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "DateCell")
        self.tblVw.register(UINib(nibName: "EventTableCell", bundle: nil), forCellReuseIdentifier: "EventTableCell")
        self.tblVw.register(UINib(nibName: "CalendarTableCell", bundle: nil), forCellReuseIdentifier: "CalendarTableCell")
        selectedIndex = IndexPath(row: 3, section: 0)

        self.colVw.delegate = self
        self.colVw.dataSource = self
        self.tblVw.delegate = self
        self.tblVw.dataSource = self

        // Set today as the initial start_date and fetch data
        let todayFormatter = DateFormatter()
        todayFormatter.dateFormat = "dd-MM-yyyy"
        start_date = todayFormatter.string(from: Date())

        // Seed UI instantly from cache while API loads
        if let cal = DBManager.shared.calender {
            self.calender.append(cal)
            self.tblVw.reloadData()
        }

        // Fetch fresh data from server
        getCalender()
        getMyEvents()

        dateSelectionView.onDateChanged = { [weak self] date in
            guard let self = self else { return }
            let fmt = DateFormatter()
            fmt.dateFormat = "dd-MM-yyyy"
            self.start_date = fmt.string(from: date)
            self.getCalender()
            self.getMyEvents()
        }
    }
    
    func getCalender() {
        showLoader()
        let targetDate = self.start_date
        
        // Try the specific date endpoint first (broadcast/calendar/dd-MM-yyyy)
        let specificDateUrl = API.BROADCAST_CALENDER + "/" + targetDate
        
        NetworkManager.shared.request(urlString: specificDateUrl, method: .GET) { (result: Result<APIResponse<[LifeSkillPrompt]>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success, let content = info.data?.first {
                    self.hideLoader()
                    self.calender = [content]
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                } else {
                    // If specific date fails or returns no data, fall back to bulk fetch
                    self.fetchBulkCalendar(targetDate: targetDate)
                }
                
            case .failure:
                // Fallback to bulk fetch to see if we can find it there, otherwise show message
                self.fetchBulkCalendar(targetDate: targetDate)
            }
        }
    }
    
    private func showFallbackMessage(for dateString: String) {
        self.hideLoader()
        // Create a dummy LifeSkillPrompt to show the custom message in the existing UI
        let fallbackPrompt = LifeSkillPrompt(
            id: "fallback",
            date: dateString,
            prompt: "Stay tuned! Exciting things are on the horizon at SchoolFirst. Everyday in 2026 brings something extraordinary. See you soon!",
            benefit: "Coming Soon",
            youtubeVideoURL: "",
            description: "We are preparing exciting new activities for you. Check back soon!",
            image: ""
        )
        self.calender = [fallbackPrompt]
        DispatchQueue.main.async {
            self.tblVw.reloadData()
        }
    }
    
    private func fetchBulkCalendar(targetDate: String) {
        NetworkManager.shared.request(urlString: API.BROADCAST_CALENDER, method: .GET, parameters: ["limit": 400, "page": 1]) { (result: Result<APIResponse<[LifeSkillPrompt]>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                if let data = info.data, let match = data.first(where: { $0.date == targetDate }) {
                    self.calender = [match]
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                } else {
                    // No match found in bulk data either, show the fallback message
                    self.showFallbackMessage(for: targetDate)
                }
            case .failure:
                self.showFallbackMessage(for: targetDate)
            }
        }
    }
    
    
    
    func getMyEvents(){
        showLoader()
        
        let userId = UserManager.shared.user?.id ?? ""
        
        // Convert dd-MM-yyyy to yyyy-MM-dd for events API
        var apiDate = start_date
        let fmt = DateFormatter()
        fmt.dateFormat = "dd-MM-yyyy"
        if let dateObj = fmt.date(from: start_date) {
            let apiFmt = DateFormatter()
            apiFmt.dateFormat = "yyyy-MM-dd"
            apiDate = apiFmt.string(from: dateObj)
        }
        
        let params: [String:Any] = [
            "event_users": userId,
            "start_date": apiDate,
            "end_date": apiDate,
        ]
        
        NetworkManager.shared.request(urlString: API.EVENTS_GETEVENTS, method: .GET, parameters: params) { (result: Result<APIResponse<[Event]>, NetworkError>)  in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.events = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                }else{
                    print(info.description)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        // Set the selected date before fetching
        let selectedDate = getDate(for: indexPath.item)
        let fmt = DateFormatter()
        fmt.dateFormat = "dd-MM-yyyy"
        start_date = fmt.string(from: selectedDate)
        // Reload collection to update highlight, then fetch data
        collectionView.reloadData()
        getCalender()
        getMyEvents()
    }
}

extension CalendarViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        let date = getDate(for: indexPath.item)

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"   // e.g. Aug
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"    // e.g. Sun
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"     // e.g. 31

        cell.lblMonth.text = monthFormatter.string(from: date)
        cell.lblDay.text = dayFormatter.string(from: date)
        cell.lblDate.text = dateFormatter.string(from: date)

        // Only update highlight — API calls moved to didSelectItemAt
        if indexPath == selectedIndex {
            cell.bgView.backgroundColor = UIColor(named: "secondaryColor")
        } else {
            cell.bgView.backgroundColor = UIColor(red: 237/255, green: 246/255, blue: 255/255, alpha: 1)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/7, height: 64)
    }
    
    func getDate(for index: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let offset = index - 3
        let date = calendar.date(byAdding: .day, value: offset, to: today)!
        return date
    }
}

extension CalendarViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return events.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !events.isEmpty {
            return section == 0 ? "Today’s Events" : "Today’s Activity"
        }
        return "Today’s Activity"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !events.isEmpty {
            if section == 0 {
                return events.count
            } else {
                return calender.count
            }
        } else {
            return calender.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !events.isEmpty {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableCell", for: indexPath) as! EventTableCell
                cell.config(event: events[indexPath.row])
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableCell", for: indexPath) as! CalendarTableCell
                cell.configure(calender: calender[indexPath.row])
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableCell", for: indexPath) as! CalendarTableCell
            cell.configure(calender: calender[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

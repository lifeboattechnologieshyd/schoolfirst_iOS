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
    @IBOutlet weak var imgVw: UIImageView!
    
    
    @IBOutlet weak var dateSelectionView: MonthHeaderView!
    
    @IBOutlet weak var tblVw: UITableView!
    var selectedIndex: IndexPath?
    var events = [Event]()
    var calender = [LifeSkillPrompt]()
    var start_date = ""
    @IBOutlet weak var colVw: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgVw.loadImage(url: UserManager.shared.user?.schools.first?.fullLogo ?? "", placeHolderImage: "")

        if let cal = DBManager.shared.calender {
            self.calender.append(cal)
        }
        
        
        dateSelectionView.onDateChanged = { date in
            print("New date: \(date)")
            // reload your calendar/news/homework
        }
        
        self.colVw.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "DateCell")
        self.tblVw.register(UINib(nibName: "EventTableCell", bundle: nil), forCellReuseIdentifier: "EventTableCell")
        self.tblVw.register(UINib(nibName: "CalendarTableCell", bundle: nil), forCellReuseIdentifier: "CalendarTableCell")
        selectedIndex =  IndexPath(row: 3, section: 0)
        
        self.colVw.delegate = self
        self.colVw.dataSource = self

        self.tblVw.delegate = self
        self.tblVw.dataSource = self
    }
    
    func getCalender() {
        self.calender = []
        NetworkManager.shared.request(urlString: API.BROADCAST_CALENDER+start_date, method: .GET) { (result: Result<APIResponse<[LifeSkillPrompt]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.calender = data
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
    
    
    
    func getMyEvents(){
        let params: [String:Any] = [
            "start_date": start_date,
            "end_date": start_date,
        ]
        NetworkManager.shared.request(urlString: API.EVENTS_GETEVENTS, method: .GET, parameters: params) { (result: Result<APIResponse<[Event]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.events = []
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
        collectionView.reloadData()
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
        if indexPath == selectedIndex {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY"
            start_date = dateFormatter.string(from: date)
            cell.bgView.backgroundColor = UIColor(named: "secondaryColor")
            getCalender()
            getMyEvents()
        }else{
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

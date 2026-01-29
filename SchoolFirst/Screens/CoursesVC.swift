//
//  CoursesVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 09/01/26.
//

import UIKit
import AVKit
import Kingfisher

class CoursesVC: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    
    var selectedTab = 0
    var onlineCourses = [OnlineCourse]()
    var offlineCourses = [OfflineCourse]()
    var webinars = [Webinar]()

    let tabs = [
        ["name": "All", "image": "all"],
        ["name": "Online", "image": "online"],
        ["name": "Webinars", "image": "live"],
        ["name": "Offline", "image": "offlinee"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        topVw.addBottomShadow()
        loadTab(0)
    }
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    func setupViews() {
        colVw.register(UINib(nibName: "TabCell", bundle: nil), forCellWithReuseIdentifier: "TabCell")
        tblVw.register(UINib(nibName: "CourseCell", bundle: nil), forCellReuseIdentifier: "CourseCell")
        tblVw.register(UINib(nibName: "OfflineCell", bundle: nil), forCellReuseIdentifier: "OfflineCell")
        tblVw.register(UINib(nibName: "WebinarsCell", bundle: nil), forCellReuseIdentifier: "WebinarsCell")

        colVw.tag = 1

        tblVw.delegate = self
        tblVw.dataSource = self
        colVw.delegate = self
        colVw.dataSource = self
        
    }

    func loadTab(_ index: Int) {
        selectedTab = index
        colVw.reloadData()
        tblVw.reloadData()

        if onlineCourses.isEmpty { fetchOnline() }
        if webinars.isEmpty { fetchWebinars() }
        if offlineCourses.isEmpty { fetchOffline() }
    }

    func fetchOnline() {
        showLoader()
        NetworkManager.shared.request(urlString: API.ONLINE_COURSES, method: .GET) { [weak self] (result: Result<APIResponse<[OnlineCourse]>, NetworkError>) in
            self?.hideLoader()
            if case .success(let res) = result, let data = res.data {
                self?.onlineCourses = data
                DispatchQueue.main.async { self?.tblVw.reloadData() }
            }
        }
    }

    func fetchWebinars() {
        showLoader()
        NetworkManager.shared.request(urlString: API.WEBINARS, method: .GET) { [weak self] (result: Result<APIResponse<[Webinar]>, NetworkError>) in
            self?.hideLoader()
            if case .success(let res) = result, let data = res.data {
                self?.webinars = data
                DispatchQueue.main.async { self?.tblVw.reloadData() }
            }
        }
    }

    func fetchOffline() {
        showLoader()
        NetworkManager.shared.request(urlString: API.OFFLINE_COURSES, method: .GET) { [weak self] (result: Result<APIResponse<[OfflineCourse]>, NetworkError>) in
            self?.hideLoader()
            if case .success(let res) = result, let data = res.data {
                self?.offlineCourses = data
                DispatchQueue.main.async { self?.tblVw.reloadData() }
            }
        }
    }

    private func playDemo(_ url: String?) {
        guard let str = url, let url = URL(string: str) else {
            showAlert("Demo not available")
            return
        }
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        present(vc, animated: true) { player.play() }
    }

    private func openLink(_ url: String) {
        if let url = URL(string: url) { UIApplication.shared.open(url) }
    }

    private func showAlert(_ msg: String) {
        let a = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

extension CoursesVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection s: Int) -> Int {
        cv.tag == 1 ? tabs.count : 3
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        if cv.tag == 1 {
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "TabCell", for: ip) as! TabCell
            cell.loadCell(option: tabs[ip.row])
            cell.selectedView.backgroundColor = ip.row == selectedTab ? UIColor(named: "primaryColor") : .clear
            return cell
        }
        return cv.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: ip) as! BannerCell
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt ip: IndexPath) {
        if cv.tag == 1 { loadTab(ip.row) }
    }
    
    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt ip: IndexPath) -> CGSize {
        if cv.tag == 1 {
            return CGSize(width: 80, height: 80)
        }
        return CGSize(width: cv.frame.width - 40, height: 150)
    }
}

extension CoursesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int {
        switch selectedTab {
        case 1: return onlineCourses.count
        case 2: return webinars.count
        case 3: return offlineCourses.count
        default: return onlineCourses.count + webinars.count + offlineCourses.count
        }
    }
    
    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        
        if selectedTab == 0 {
            let onlineCount = onlineCourses.count
            let webinarCount = webinars.count
            
            if ip.row < onlineCount {
                let cell = tv.dequeueReusableCell(withIdentifier: "CourseCell", for: ip) as! CourseCell
                let c = onlineCourses[ip.row]
                cell.lblCourseName.text = c.name
                cell.imgCourse.kf.setImage(with: URL(string: c.thumbnailImage), placeholder: UIImage(named: "placeholder"))
                cell.lblDuration.text = "\(c.duration) mins"
                cell.lblAudience.text = c.audience
                cell.btnCost.setTitle("₹\(c.finalCourseFee)", for: .normal)
                cell.onWatchDemoTapped = { [weak self] in self?.playDemo(c.demoVideo?.first) }
                cell.onBuyTapped = { print("Buy Online:", c.name) }
                return cell
            }
            else if ip.row < onlineCount + webinarCount {
                let cell = tv.dequeueReusableCell(withIdentifier: "WebinarsCell", for: ip) as! WebinarsCell
                let w = webinars[ip.row - onlineCount]
                cell.lblCourseName.text = w.name
                cell.imgCourse.kf.setImage(with: URL(string: w.thumbnailImage), placeholder: UIImage(named: "placeholder"))
                cell.lblDuration.text = "\(w.duration / 60)m"
                cell.lblAudience.text = w.audience
                let remaining = w.totalSlots - w.totalEnrolled
                cell.noofslotsLbl.text = "Hurry up! Only \(remaining) Slots are left"
                
                // Dynamic Entry Fee Button
                let webinarFee = formatEntryFee(w.entryFee)
                cell.enrollBtn.setTitle("Enroll at \(webinarFee)", for: .normal)
                
              
                return cell
            }
            else {
                let cell = tv.dequeueReusableCell(withIdentifier: "OfflineCell", for: ip) as! OfflineCell
                let o = offlineCourses[ip.row - onlineCount - webinarCount]
                cell.lblCourseName.text = o.name
                cell.imgCourse.kf.setImage(with: URL(string: o.thumbnailImage), placeholder: UIImage(named: "placeholder"))
                cell.lblAudience.text = o.audience
                cell.locationLbl.text = o.venue
                let remaining = o.totalSlots - o.totalEnrolled
                cell.noofslotsLbl.text = "Hurry up! Only \(remaining) Slots are left"
                
                // Dynamic Entry Fee Button
                let offlineFee = formatEntryFee(o.entryFee)
                cell.enrollBtn.setTitle("Enroll at \(offlineFee)", for: .normal)
            
                return cell
            }
        }
        
        switch selectedTab {
        case 1:
            let cell = tv.dequeueReusableCell(withIdentifier: "CourseCell", for: ip) as! CourseCell
            let c = onlineCourses[ip.row]
            cell.lblCourseName.text = c.name
            cell.imgCourse.kf.setImage(with: URL(string: c.thumbnailImage), placeholder: UIImage(named: "placeholder"))
            cell.lblDuration.text = "\(c.duration) mins"
            cell.lblAudience.text = c.audience
            cell.btnCost.setTitle("₹\(c.finalCourseFee)", for: .normal)
            cell.onWatchDemoTapped = { [weak self] in self?.playDemo(c.demoVideo?.first) }
            cell.onBuyTapped = { print("Buy:", c.name) }
            return cell
            
        case 2:
            let cell = tv.dequeueReusableCell(withIdentifier: "WebinarsCell", for: ip) as! WebinarsCell
            let w = webinars[ip.row]
            cell.lblCourseName.text = w.name
            cell.imgCourse.kf.setImage(with: URL(string: w.thumbnailImage), placeholder: UIImage(named: "placeholder"))
            cell.lblDuration.text = "\(w.duration / 60)m"
            cell.lblAudience.text = w.audience
            let remaining = w.totalSlots - w.totalEnrolled
            cell.noofslotsLbl.text = "Hurry up! Only \(remaining) Slots are left"
            
            // Dynamic Entry Fee Button
            let webinarFee = formatEntryFee(w.entryFee)
            cell.enrollBtn.setTitle("Enroll at \(webinarFee)", for: .normal)
            return cell
            
        case 3:
            let cell = tv.dequeueReusableCell(withIdentifier: "OfflineCell", for: ip) as! OfflineCell
            let o = offlineCourses[ip.row]
            cell.lblCourseName.text = o.name
            cell.imgCourse.kf.setImage(with: URL(string: o.thumbnailImage), placeholder: UIImage(named: "placeholder"))
            cell.lblAudience.text = o.audience
            cell.locationLbl.text = o.venue
            let remaining = o.totalSlots - o.totalEnrolled
            cell.noofslotsLbl.text = "Hurry up! Only \(remaining) Slots are left"
            
            // Dynamic Entry Fee Button
            let offlineFee = formatEntryFee(o.entryFee)
            cell.enrollBtn.setTitle("Enroll at \(offlineFee)", for: .normal)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tv: UITableView, heightForRowAt ip: IndexPath) -> CGFloat {
        if selectedTab == 0 {
            let onlineCount = onlineCourses.count
            let webinarCount = webinars.count
            
            if ip.row < onlineCount { return 420 }
            else if ip.row < onlineCount + webinarCount { return 400 }
            else { return 420 }
        }
        
        switch selectedTab {
        case 1: return 420
        case 2: return 400
        case 3: return 420
        default: return 394
        }
    }
    
}

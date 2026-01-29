//
//  MySchoolViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 12/09/25.
//

import UIKit

class MySchoolViewController: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    var gallery = [EventGallery]()
    var school_info = [SchoolInfo]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tblVw.contentInsetAdjustmentBehavior = .never
        getGalleryData()
        getSchoolInfo()
        
        self.tblVw.register(UINib(nibName: "SchoolBannerCell", bundle: nil), forCellReuseIdentifier: "SchoolBannerCell")
        self.tblVw.register(UINib(nibName: "SchoolInfoCell", bundle: nil), forCellReuseIdentifier: "SchoolInfoCell")
        self.tblVw.register(UINib(nibName: "SchoolGalleryCell", bundle: nil), forCellReuseIdentifier: "SchoolGalleryCell")
        self.tblVw.register(UINib(nibName: "SchoolKYSCell", bundle: nil), forCellReuseIdentifier: "SchoolKYSCell")
        self.tblVw.delegate = self
        self.tblVw.dataSource = self
        
        bgView.addBottomShadow()
        
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func getGalleryData(){
        showLoader()
        NetworkManager.shared.request(urlString: API.EVENT_GALLERY,method: .GET) { (result: Result<APIResponse<[EventGallery]>, NetworkError>)  in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.gallery = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
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
    
    func getSchoolInfo() {
        showLoader()
        NetworkManager.shared.request(urlString: API.SCHOOL_INFO,method: .GET) { (result: Result<APIResponse<[SchoolInfo]>, NetworkError>)  in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                         self.school_info = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
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

extension MySchoolViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + school_info.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolBannerCell") as? SchoolBannerCell
            cell?.onBackClick = {
                self.navigationController?.popViewController(animated: true)
            }
            return cell!
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolInfoCell") as? SchoolInfoCell
            return cell!
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolGalleryCell") as! SchoolGalleryCell
            cell.gallery = self.gallery
            cell.colVw.reloadData()
            
            cell.onViewAllTapped = { [weak self] in
                guard let self = self else { return }
                let stbd = UIStoryboard(name: "Gallery", bundle: nil)
                let vc = stbd.instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
                vc.gallery = self.gallery
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        
        }else if indexPath.row == 3 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell?.textLabel?.text = "Know Your School"
            cell?.textLabel?.font = UIFont.lexend(.semiBold, size: 18)
            return cell!
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolKYSCell") as? SchoolKYSCell
            cell?.config(info: self.school_info[indexPath.row - 4])
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 222
        case 1:
            return UITableView.automaticDimension
        case 2:
            return 270
        case 3:
            return 55
        case 4:
            return 121
        default:
            return 121
        }
    }
}

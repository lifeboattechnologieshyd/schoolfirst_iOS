//
//  BulletinController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 13/09/25.
//

import UIKit

class BulletinController: UIViewController {
    var newsList: [Bulletin] = []

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getNews()
        self.tblVw.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        tblVw.dataSource = self
        tblVw.delegate = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.addBottomShadow(shadowOpacity: 0.25, shadowRadius: 8, shadowHeight: 4)
    }
    
    func getNews(){
        var url = API.NEWS
        if let gradeId = UserManager.shared.user?.schools.first?.students.first?.gradeID {
            url += "?grade_id=\(gradeId)&page=1&page_size=10"
        }
        NetworkManager.shared.request(urlString: url,method: .GET) { (result: Result<APIResponse<[Bulletin]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.newsList = data
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
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension BulletinController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        let newsItem = newsList[indexPath.row]
        cell.config(news: newsItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 148
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BulletinInfoViewController") as! BulletinInfoViewController
            vc.bulletin = self.newsList[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


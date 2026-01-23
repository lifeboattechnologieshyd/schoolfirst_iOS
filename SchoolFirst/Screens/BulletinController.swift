//
//  BulletinController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 13/09/25.
//

import UIKit

class BulletinController: UIViewController {
    var newsList: [Bulletin] = []
    
    var isLoading = false
    var isLastPage = false
    var page = 1
    var page_size = 10
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblVw.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        self.getNews()
        
        tblVw.dataSource = self
        tblVw.delegate = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.addBottomShadow()
    }
    
    func getNews(){
        guard !isLoading else { return }
        isLoading = true
        
        var url = API.NEWS
        if let gradeId = UserManager.shared.selectedKid?.gradeID {
            url += "?grade_id=\(gradeId)&page=\(page)&page_size=\(page_size)"
        }
        NetworkManager.shared.request(urlString: url,method: .GET) { (result: Result<APIResponse<[Bulletin]>, NetworkError>)  in
            self.isLoading = false
            
            switch result {
            case .success(let info):
                if info.success {
                    
                    if let data = info.data {
                        if data.isEmpty {
                            self.isLastPage = true
                            return
                        }
                        self.newsList.append(contentsOf: data)
                        for i in 0..<self.newsList.count {
                            self.newsList[i].prepareHTMLForRendering()
                        }
                    }
                    else{
                        self.isLastPage = true
                        return
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height - 200 {
            loadNextPage()
        }
    }
    
    func loadNextPage() {
        guard !isLoading, !isLastPage else { return }
        self.page += 1
        getNews()
    }
}


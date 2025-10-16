//
//  PTipsViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import  UIKit

class PTipsViewController: UIViewController {
    
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var Back: UIButton!
    var feed = [Feed]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tblView.register(UINib(nibName: "EdutainCell", bundle: nil), forCellReuseIdentifier: "EdutainCell")
        
        self.getEdutainment()
        
        tblView.dataSource = self
        tblView.delegate = self
        
    }
    
    func getEdutainment(){
        var url = API.EDUTAIN_FEED + "?f_category=Ptips"
        NetworkManager.shared.request(urlString: API.EDUTAIN_FEED,method: .GET) { (result: Result<APIResponse<[Feed]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.feed = data
                    }
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                }else{
                    self.showAlert(msg: info.description)
                }
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
}

extension PTipsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feed.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EdutainCell") as? EdutainCell
        cell?.setup(feed: self.feed[indexPath.row])
        cell?.likeClicked = { tag in
            if self.feed[indexPath.row].isLiked {
                print("unlike")
            }else{
                print("like")
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

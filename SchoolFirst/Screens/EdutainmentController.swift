//
//  EdutainmentController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 01/07/25.
//

import UIKit

class EdutainmentController: UIViewController {
    // header view outlets
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgVw: UIImageView!
    
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tblVw: UITableView!
    var feed = [Feed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgVw.loadImage(url: UserManager.shared.user?.schools.first?.fullLogo ?? "", placeHolderImage: "")

        self.tblVw.register(UINib(nibName: "EdutainCell", bundle: nil), forCellReuseIdentifier: "EdutainCell")

        self.getEdutainment()
        self.tblVw.delegate = self
        self.tblVw.dataSource = self
        

        
    }
    
    
   @IBAction func onChangeSegment(_ sender: UISegmentedControl) {
if sender.selectedSegmentIndex == 1 {
          let vc = storyboard?.instantiateViewController(identifier: "HomeController") as? HomeController
           navigationController?.pushViewController(vc!, animated: true)
      }else{
            
        }
    }
    
    
    func getEdutainment(){
        NetworkManager.shared.request(urlString: API.EDUTAIN_FEED,method: .GET) { (result: Result<APIResponse<[Feed]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.feed = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                }else{
                    self.showAlert(msg: info.description)
                }
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    func likeFeed(){
        NetworkManager.shared.request(urlString: API.EDUTAIN_FEED,method: .GET) { (result: Result<APIResponse<[Feed]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.feed = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
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

extension EdutainmentController : UITableViewDelegate, UITableViewDataSource {
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
}

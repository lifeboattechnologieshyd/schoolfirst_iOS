//
//  FeelViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 26/08/25.
//

import UIKit

class FeelViewController: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    var feels = [ReadingShort]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblVw.register(UINib(nibName: "FeelsCell", bundle: nil), forCellReuseIdentifier: "FeelsCell")
        self.tblVw.delegate = self
        self.tblVw.dataSource = self
        
        getFeels()
    }
    
    
    func getFeels() {
        NetworkManager.shared.request(urlString: API.EDUTAIN_FEEL, method: .GET) { (result: Result<APIResponse<[ReadingShort]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.feels = data
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
    
}

extension FeelViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feels.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeelsCell") as! FeelsCell
        cell.config(feel: self.feels[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height
    }
}

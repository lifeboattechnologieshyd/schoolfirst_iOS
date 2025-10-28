//
//  FeeViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/09/25.
//

import UIKit

class FeeViewController: UIViewController {

    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
     
    override func viewDidLoad() {
           super.viewDidLoad()
           
           tblVw.register(UINib(nibName: "FeeTableViewCell", bundle: nil),
                          forCellReuseIdentifier: "FeeTableViewCell")
           tblVw.delegate = self
           tblVw.dataSource = self
           
           getFeeDetails()
           
           // Allow shadow to be visible outside the view bounds
           topVw.clipsToBounds = false
           topVw.layer.masksToBounds = false
       }

       // 👉 Add the shadow here — this method runs after Auto Layout sets the correct frame
       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           topVw.addBottomShadow()
       }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    
    }
}

extension FeeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeeTableViewCell") as! FeeTableViewCell
        cell.bgView.applyCardShadow()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 407
    }
}

extension FeeViewController {
    func getFeeDetails(){
        NetworkManager.shared.request(urlString: API.FEE, method: .GET) { (result: Result<APIResponse<[LifeSkillPrompt]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        
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

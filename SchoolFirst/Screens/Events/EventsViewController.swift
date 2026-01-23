//
//  EventsViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 17/09/25.
//

import UIKit

class EventsViewController: UIViewController {
    var events = [Event]()

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMyEvents()
        
        self.tblVw.register(UINib(nibName: "EventTableCell", bundle: nil),
                            forCellReuseIdentifier: "EventTableCell")
        
        tblVw.dataSource = self
        tblVw.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.addBottomShadow()
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getMyEvents() {
        let params: [String:Any] = [:]
        
        NetworkManager.shared.request(urlString: API.EVENTS_GETEVENTS,
                                      method: .GET,
                                      parameters: params) { (result: Result<APIResponse<[Event]>, NetworkError>)  in
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
                } else {
                    print(info.description)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension EventsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableCell",
                                                 for: indexPath) as! EventTableCell
        cell.config(event: self.events[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(
            withIdentifier: "DetailsScreenVC"
        ) as! DetailsScreenVC
        
        vc.selectedEvent = events[indexPath.row]        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

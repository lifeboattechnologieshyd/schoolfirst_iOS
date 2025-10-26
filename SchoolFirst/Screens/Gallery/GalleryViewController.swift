//
//  GalleryViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 25/10/25.
//

import UIKit

 
class GalleryViewController: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var galleryLbl: UILabel!
    
    var gallery = [EventGallery]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.addBottomShadow()
        
        tblVw.register(UINib(nibName: "GalleryCell", bundle: nil), forCellReuseIdentifier: "GalleryCell")
        tblVw.delegate = self
        tblVw.dataSource = self
        getGalleryData()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GalleryViewController {
    func getGalleryData() {
        NetworkManager.shared.request(urlString: API.EVENT_GALLERY,method: .GET) { (result: Result<APIResponse<[EventGallery]>, NetworkError>)  in
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
}

extension GalleryViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gallery.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.dateLbl.text = self.gallery[indexPath.row].eventDate.convertTo()
        cell.imgVw.loadImage(url: self.gallery[indexPath.row].images.first ?? "")
        cell.paintingLbl.text = self.gallery[indexPath.row].eventName
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 248
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stbd = UIStoryboard(name: "Gallery", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "AnnualDayViewController") as! AnnualDayViewController
        vc.gallery = self.gallery[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}


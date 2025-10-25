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
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowOpacity = 0.3
        topView.layer.shadowOffset = CGSize(width: 0, height: 3)
        topView.layer.shadowRadius = 4
        topView.layer.masksToBounds = false
        
         tblVw.register(UINib(nibName: "GalleryCell", bundle: nil), forCellReuseIdentifier: "GalleryCell")
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    
     @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
     }
}

extension GalleryViewController: GalleryCellDelegate {

    func galleryCellDidTap(_ cell: GalleryCell) {
        guard let indexPath = tblVw.indexPath(for: cell) else { return }

        let storyboard = UIStoryboard(name: "Gallery", bundle: nil)
        if let annualVC = storyboard.instantiateViewController(withIdentifier: "AnnualDayViewController") as? AnnualDayViewController {
             self.navigationController?.pushViewController(annualVC, animated: true)
        }
    }
}

extension GalleryViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.delegate = self
        cell.paintingLbl.text = "Painting \(indexPath.row + 1)"
        cell.dateLbl.text = "Date: 2025"
        cell.imgVw.image = UIImage(named: "defaultImage")
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 248
    }
}


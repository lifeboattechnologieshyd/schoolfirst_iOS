//
//  GalleryViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 25/10/25.
//

import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(UINib(nibName: "GalleryTableViewCell", bundle: nil), forCellReuseIdentifier: "GalleryTableViewCell")
        
        
        tblVw.delegate = self
        tblVw.dataSource = self
    }
}
extension GalleryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
}

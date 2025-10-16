//
//  CoursesViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/07/25.
//

import UIKit

class CoursesViewController: UIViewController {
    
    // header view outlets
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgVw: UIImageView!
    
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var bannerColVw: UICollectionView!
    var selectedIndexPath: IndexPath?
    var courses = [Course]()
    
    var categories : [[String:Any]] = [
        [
            "name":"All",
            "image": "all_courses",
        ],
        [
            "name":"Online",
            "image": "online",
        ],
        [
            "name":"Webinars",
            "image": "webinars",
        ],
        [
            "name":"Offline",
            "image": "offline",
        ],
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgVw.loadImage(url: UserManager.shared.user?.schools.first?.fullLogo ?? "", placeHolderImage: "")

        
        self.getCourses()
        selectedIndexPath = IndexPath(item: 0, section: 0)
        self.colVw.register(UINib(nibName: "TabCell", bundle: nil), forCellWithReuseIdentifier: "TabCell")
        self.bannerColVw.register(UINib(nibName: "BannerCell", bundle: nil), forCellWithReuseIdentifier: "BannerCell")
        self.colVw.tag = 1
        self.bannerColVw.tag = 2
        
        self.tblVw.register(UINib(nibName: "CourseCell", bundle: nil), forCellReuseIdentifier: "CourseCell")
        
        self.tblVw.delegate = self
        self.tblVw.dataSource = self


        self.colVw.delegate = self
        self.colVw.dataSource = self
        
        self.bannerColVw.delegate = self
        self.bannerColVw.dataSource = self
    }
    
    func getCourses(){
        NetworkManager.shared.request(urlString: API.ONLINE_COURSES,method: .GET) { (result: Result<APIResponse<[Course]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    print("courses fetched")
                    if let data = info.data {
                        self.courses = data
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

extension CoursesViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return categories.count
        }
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! TabCell
            cell.selectedView.backgroundColor = indexPath.row == 0 ? UIColor(named: "primaryColor") : UIColor.clear
            cell.loadCell(option: categories[indexPath.row])
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! BannerCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1 {
            return CGSize(width: collectionView.frame.width/4, height: 80)
        }else{
            return CGSize(width: collectionView.frame.width-5, height: 58)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1{
            if let previousIndex = selectedIndexPath, previousIndex != indexPath {
                collectionView.deselectItem(at: previousIndex, animated: false)
                if let previousCell = collectionView.cellForItem(at: previousIndex) as? TabCell {
                    previousCell.selectedView.backgroundColor = .clear
                }
            }
            selectedIndexPath = indexPath
            collectionView.reloadItems(at: [indexPath])
            
            if let newCell = collectionView.cellForItem(at: indexPath) as? TabCell {
                newCell.selectedView.backgroundColor = UIColor(named: "primaryColor")
            }
        }else{
            print("")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1{
            collectionView.reloadItems(at: [indexPath])
        }else {
            print("")
        }
    }
}

extension CoursesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell") as! CourseCell
        cell.setupCell(course: self.courses[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 394
    }
}

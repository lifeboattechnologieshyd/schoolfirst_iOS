//
//  gradeViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//
import UIKit

class gradeViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var studentColVw: UICollectionView!
    
    @IBOutlet weak var topbarView: UIView!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    var grades = [GradeModel]()
   
    var selected_student = 0
    
    func getGrades() {
        NetworkManager.shared.request(urlString: API.GRADES,method: .GET) { (result: Result<APIResponse<[GradeModel]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        let sortedGrades = data.sorted { $0.numericGrade < $1.numericGrade }
                        self.grades = sortedGrades
                        DispatchQueue.main.async {
                            self.colVw.reloadData()
                        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topbarView.addBottomShadow()
        getGrades()
        
        
        
        colVw.register(UINib(nibName: "gradeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "gradeCollectionViewCell")
        
        self.studentColVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")

        
        colVw.delegate = self
        colVw.dataSource = self
        
        studentColVw.delegate = self
        studentColVw.dataSource = self
        
        colVw.tag = 1
        studentColVw.tag = 2
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.tag == 1 ? grades.count : UserManager.shared.kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gradeCollectionViewCell", for: indexPath) as! gradeCollectionViewCell
            cell.clsLabel.text = grades[indexPath.row].name
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
            cell.setup(student: UserManager.shared.kids[indexPath.row], isSelected: selected_student ==  indexPath.row)
            return cell
        }
    }
    
    // MARK: - FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1 {
            
            return CGSize(width: (colVw.frame.size.width)/2, height: 54)
        }else {
            let width = (collectionView.frame.size.width-10)/2
            return CGSize(width: width, height: 74)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.tag == 2 {
            colVw.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 2 {
            selected_student = indexPath.row
            UserManager.shared.vocabBee_selected_student = UserManager.shared.kids[indexPath.row]
            collectionView.reloadData()
            collectionView.scrollToItem(
                    at: indexPath,
                    at: .centeredHorizontally,
                    animated: true
                )

        }else {
            UserManager.shared.vocabBee_selected_grade = grades[indexPath.row]
            let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
            if UserManager.shared.vocabBee_selected_mode == "DAILY" {
                if let nextVC = storyboard.instantiateViewController(withIdentifier: "DateViewController") as? DateViewController {
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }else {
                let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
                if let nextVC = storyboard.instantiateViewController(withIdentifier: "PracticeGameController") as? PracticeGameController {
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        }
        
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

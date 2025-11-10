//
//  AssessmentsGradeSelectionVC.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit

class AssessmentsGradeSelectionVC: UIViewController {
    
    @IBOutlet weak var completedAssessments: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    var grades = [GradeModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getGrades()
        self.colVw.register(UINib(nibName: "GradeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GradeCollectionCell")
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    
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
}

extension AssessmentsGradeSelectionVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.grades.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GradeCollectionCell", for: indexPath) as! GradeCollectionCell
        cell.lblGrade.text = self.grades[indexPath.row].name
        if self.grades[indexPath.row].name != UserManager.shared.assessmentSelectedStudent.grade {
            cell.lblGrade.backgroundColor = .white.withAlphaComponent(0.5)
        }else{
            cell.lblGrade.backgroundColor = .white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (colVw.frame.size.width-32)/3, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "AssessmentSubjectSelectionVC") as? AssessmentSubjectSelectionVC
        vc?.grade_id = self.grades[indexPath.row].id
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func onClickCompleted(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "PastAssessmentsVC") as! PastAssessmentsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
}

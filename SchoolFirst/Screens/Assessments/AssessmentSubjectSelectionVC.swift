//
//  AssessmentSubjectSelectionVC.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit

class AssessmentSubjectSelectionVC: UIViewController {

    @IBOutlet weak var colVw: UICollectionView!
    var grade_id = ""
    var subjects = [GradeSubject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSubjects()
        self.colVw.register(UINib(nibName: "SubjectCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SubjectCollectionCell")
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    
    func getSubjects() {
        var subject_url = API.SUBJECTS + "\(grade_id)"
        NetworkManager.shared.request(urlString: subject_url,method: .GET) { (result: Result<APIResponse<[GradeSubject]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.subjects = data
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


extension AssessmentSubjectSelectionVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectCollectionCell", for: indexPath) as! SubjectCollectionCell
        cell.imgVw.loadImage(url: self.subjects[indexPath.row].subjectImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (colVw.frame.size.width-10)/2, height: (colVw.frame.size.width-10)/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "AssessmentLessonVC") as? AssessmentLessonVC
        vc?.grade_id = grade_id
        vc?.subject_id = self.subjects[indexPath.row].id
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

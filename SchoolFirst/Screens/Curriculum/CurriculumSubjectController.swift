//
//  CurriculumSubjectController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/10/25.
//

import UIKit

class CurriculumSubjectController: UIViewController {
    var subjects = [GradeSubject]()
    var selected_category : CurriculumCategory!
    @IBOutlet weak var colzvw: UICollectionView!
    
    @IBOutlet weak var topVw: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colzvw.register(UINib(nibName: "SubjectCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SubjectCollectionCell")

        getSubjects()
        topVw.addBottomShadow()
        self.colzvw.delegate = self
        self.colzvw.dataSource = self
        
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)

    }
    
    func getSubjects() {
        let subject_url = API.SUBJECTS + "\(UserManager.shared.curriculamSelectedStudent.gradeID)&category=\(selected_category.id)"
        NetworkManager.shared.request(urlString: subject_url,method: .GET) { (result: Result<APIResponse<[GradeSubject]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.subjects = data
                            self.colzvw.reloadData()
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
extension CurriculumSubjectController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectCollectionCell", for: indexPath) as! SubjectCollectionCell
        cell.backgroundColor = .gray
        cell.imgVw.loadImage(url: self.subjects[indexPath.row].subjectImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (colzvw.frame.size.width-10)/2, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stbd = UIStoryboard(name: "curriculum", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "CurriculumLessonController") as? CurriculumLessonController
        vc?.subj = self.subjects[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

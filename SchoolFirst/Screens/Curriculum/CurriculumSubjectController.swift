//
//  CurriculumSubjectController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/10/25.
//

import UIKit

class CurriculumSubjectController: UIViewController {

    var subjects = [GradeSubject]()

    var selected_category: CurriculumCategory!

    // Grade ID received from CurriculumCategoryController
    var selectedGradeID: String = ""

    // Actual Grade ID used in Subject API
    private var gradeIDUsedForSubjects: String = ""

    @IBOutlet weak var colzvw: UICollectionView!
    @IBOutlet weak var topVw: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.colzvw.register(
            UINib(
                nibName: "SubjectCollectionCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "SubjectCollectionCell"
        )

        print("====================================")
        print("📥 CurriculumSubjectController")
        print("🎓 Received Grade ID: \(selectedGradeID)")
        print("📚 Selected Category ID: \(selected_category.id)")
        print("====================================")

        getSubjects()

        topVw.addBottomShadow()

        self.colzvw.delegate = self
        self.colzvw.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        colzvw.collectionViewLayout.invalidateLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        colzvw.collectionViewLayout.invalidateLayout()
    }

    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Subjects API

    func getSubjects() {

        showLoader()

        let gradeIDToUse: String

        // First use Grade ID passed from previous screen
        if !selectedGradeID
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty {

            gradeIDToUse = selectedGradeID

        } else {

            // Fallback to selected student's Grade ID
            gradeIDToUse =
                UserManager.shared.curriculamSelectedStudent?.gradeID ?? ""
        }

        let cleanedGradeID = gradeIDToUse
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Check Grade ID
        if cleanedGradeID.isEmpty {

            self.hideLoader()

            print("❌ Subject API: Grade ID is EMPTY")

            self.showAlert(
                msg: "Grade information not available."
            )

            return
        }

        let categoryID = selected_category.id

        // IMPORTANT:
        // Store the exact Grade ID used for Subject API
        self.gradeIDUsedForSubjects = cleanedGradeID

        let subject_url =
            API.SUBJECTS +
            "\(cleanedGradeID)&category=\(categoryID)"

        print("====================================")
        print("📚 SUBJECT API REQUEST")
        print("🎓 Grade ID Used: \(cleanedGradeID)")
        print("📚 Category ID Used: \(categoryID)")
        print("🔗 Subjects URL: \(subject_url)")
        print("====================================")

        NetworkManager.shared.request(
            urlString: subject_url,
            method: .GET
        ) { (result: Result<APIResponse<[GradeSubject]>, NetworkError>) in

            self.hideLoader()

            switch result {

            case .success(let info):

                if info.success {

                    if let data = info.data {

                        DispatchQueue.main.async {

                            self.subjects = data

                            print("====================================")
                            print("✅ Subjects API Success")
                            print("📊 Subject Count: \(data.count)")
                            print("🎓 Grade ID: \(self.gradeIDUsedForSubjects)")
                            print("====================================")

                            self.colzvw.reloadData()
                        }

                    } else {

                        print("⚠️ Subjects API returned no data")
                    }

                } else {

                    print(
                        "❌ Subjects API Error: \(info.description ?? "Unknown error")"
                    )
                }

            case .failure(let error):

                DispatchQueue.main.async {

                    switch error {

                    case .noaccess:
                        self.handleLogout()

                    default:
                        self.showAlert(
                            msg: error.localizedDescription
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Collection View

extension CurriculumSubjectController:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        return self.subjects.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SubjectCollectionCell",
            for: indexPath
        ) as! SubjectCollectionCell

        cell.backgroundColor = .gray

        cell.imgVw.loadImage(
            url: self.subjects[indexPath.row].subjectImage
        )

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        return CGSize(
            width: (colzvw.bounds.width - 10) / 2,
            height: 140
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

        let selectedSubject = self.subjects[indexPath.row]

        let stbd = UIStoryboard(
            name: "curriculum",
            bundle: nil
        )

        let vc = stbd.instantiateViewController(
            identifier: "CurriculumLessonController"
        ) as? CurriculumLessonController

        // Pass selected subject
        vc?.subj = selectedSubject

        // IMPORTANT:
        // Pass the EXACT Grade ID that was used
        // in the Subject API request.
        vc?.selectedGradeID = gradeIDUsedForSubjects

        print("====================================")
        print("➡️ NAVIGATING TO LESSONS")
        print("🎓 Grade ID Passed: \(gradeIDUsedForSubjects)")
        print("📚 Subject ID Passed: \(selectedSubject.id)")
        print("====================================")

        if let vc = vc {
            self.navigationController?.pushViewController(
                vc,
                animated: true
            )
        }
    }
}

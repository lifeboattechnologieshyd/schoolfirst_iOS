//
//  CurriculumLessonController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 22/10/25.
//

import UIKit

class CurriculumLessonController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tblVw: UITableView!

    var subj: GradeSubject!
    
    // Grade ID passed from CurriculumSubjectController
    var selectedGradeID: String = ""

    var lessons = [Lesson]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblVw.register(
            UINib(
                nibName: "CurriculumLessonCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "CurriculumLessonCell"
        )

        print("📥 CurriculumLessonController received Grade ID: \(selectedGradeID)")
        print("📚 Subject ID: \(subj.id)")

        getLessons()

        topView.addBottomShadow()

        tblVw.delegate = self
        tblVw.dataSource = self
    }

    // MARK: - Get Lessons

    func getLessons() {

        showLoader()

        // Use passed Grade ID first
        let gradeIDToUse: String

        if !selectedGradeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            gradeIDToUse = selectedGradeID

        } else {

            // Fallback to selected student's Grade ID
            gradeIDToUse =
                UserManager.shared.curriculamSelectedStudent?.gradeID ?? ""
        }

        // Validate Grade ID
        if gradeIDToUse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            self.hideLoader()

            print("❌ Lesson API: Grade ID is EMPTY")

            self.showAlert(
                msg: "Grade information not available."
            )

            return
        }

        let subjectID = subj.id

        let subject_url =
            API.LESSON +
            "?grade=\(gradeIDToUse)&subject=\(subjectID)"

        print("🎓 Grade ID Used for Lessons: \(gradeIDToUse)")
        print("📚 Subject ID Used for Lessons: \(subjectID)")
        print("🔗 Lessons URL: \(subject_url)")

        NetworkManager.shared.request(
            urlString: subject_url,
            method: .GET
        ) { (result: Result<APIResponse<[Lesson]>, NetworkError>) in

            self.hideLoader()

            switch result {

            case .success(let info):

                print("✅ Lesson API Success: \(info.success)")
                print("📊 Lesson Count: \(info.data?.count ?? 0)")

                if info.success {

                    if let data = info.data {

                        DispatchQueue.main.async {

                            self.lessons = data
                            self.tblVw.reloadData()
                        }
                    }

                } else {

                    print("❌ Lesson API Error: \(info.description)")
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

    // MARK: - Back

    @IBAction func onClickBack(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table View

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return self.lessons.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tblVw.dequeueReusableCell(
            withIdentifier: "CurriculumLessonCell"
        ) as! CurriculumLessonCell

        cell.lblName.text =
            "\(indexPath.row + 1). \(self.lessons[indexPath.row].lessonName)"

        cell.lblNumber.text =
            "\(self.lessons[indexPath.row].numberOfConcepts) Concepts"

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 74
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        let stbd = UIStoryboard(
            name: "curriculum",
            bundle: nil
        )

        let vc = stbd.instantiateViewController(
            identifier: "CurriculumConceptsController"
        ) as? CurriculumConceptsController

        vc?.selected_lesson = self.lessons[indexPath.row]

        // Pass Grade ID to next screen too
        vc?.selectedGradeID = selectedGradeID

        print("➡️ Passing Grade ID to CurriculumConceptsController: \(selectedGradeID)")

        self.navigationController?.pushViewController(
            vc!,
            animated: true
        )
    }
}

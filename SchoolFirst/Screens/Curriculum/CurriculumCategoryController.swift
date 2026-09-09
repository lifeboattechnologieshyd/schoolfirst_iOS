//
//  CurriculumCategoryController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class CurriculumCategoryController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topView: UIView!

    var cats = [CurriculumCategory]()

    // Grade ID received from CurriculumController
    var selectedGradeID: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblVw.register(
            UINib(
                nibName: "CurriculamCategoryCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "CurriculamCategoryCell"
        )

        topView.addBottomShadow()

        print("📥 CurriculumCategoryController received Grade ID: \(selectedGradeID)")

        getCurriculumCats()

        tblVw.delegate = self
        tblVw.dataSource = self
    }

    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table View

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return cats.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CurriculamCategoryCell"
        ) as! CurriculamCategoryCell

        cell.lblTitle.text = cats[indexPath.row].categoryName

        cell.imgVw.loadImage(
            url: cats[indexPath.row].categoryImage
        )

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 185
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
            identifier: "CurriculumSubjectController"
        ) as! CurriculumSubjectController

        // Pass selected category
        vc.selected_category = cats[indexPath.row]

        // Pass same selected student's grade ID
        vc.selectedGradeID = selectedGradeID

        print("➡️ Passing Grade ID to CurriculumSubjectController: \(selectedGradeID)")

        navigationController?.pushViewController(
            vc,
            animated: true
        )
    }

    // MARK: - Curriculum Categories API

    func getCurriculumCats() {

        showLoader()

        // First use passed Grade ID
        let gradeIDToUse: String

        if !selectedGradeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            gradeIDToUse = selectedGradeID

        } else {

            // Fallback to selected student's Grade ID
            gradeIDToUse =
                UserManager.shared.curriculamSelectedStudent?.gradeID ?? ""
        }

        // Check Grade ID
        if gradeIDToUse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            self.hideLoader()

            print("❌ Grade ID is EMPTY")
            self.showAlert(
                msg: "Grade information not available."
            )

            return
        }

        let url = API.CURRICULUM_CATEGORIES + gradeIDToUse

        print("🎓 Grade ID Used: \(gradeIDToUse)")
        print("🔗 Curriculum Categories URL: \(url)")

        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { (result: Result<APIResponse<[CurriculumCategory]>, NetworkError>) in

            self.hideLoader()

            switch result {

            case .success(let info):

                if info.success {

                    if let data = info.data {
                        self.cats = data
                    }

                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }

                } else {

                    self.showAlert(
                        msg: info.description
                    )
                }

            case .failure(let error):

                self.showAlert(
                    msg: error.localizedDescription
                )
            }
        }
    }
}

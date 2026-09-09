//
//  CurriculumConceptsController.swift
//  SchoolFirst
//

import UIKit

class CurriculumConceptsController: UIViewController,
                                     UITableViewDelegate,
                                     UITableViewDataSource {

    // MARK: - Outlets

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topView: UIView!

    // MARK: - Properties

    var selected_lesson: Lesson!
    var concepts = [LessonConcept]()
    
    // Selected student's Grade ID
    var selectedGradeID: String = ""

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register table cell
        self.tblVw.register(
            UINib(
                nibName: "CurriculumConceptCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "CurriculumConceptCell"
        )

        // UI
        topView.addBottomShadow()

        // Table View
        tblVw.delegate = self
        tblVw.dataSource = self

        // Debug logs
        print("========================================")
        print("📥 CurriculumConceptsController Loaded")
        print("🎓 Received Grade ID: \(selectedGradeID)")
        print("📚 Selected Lesson ID: \(selected_lesson?.id ?? "")")
        print("========================================")

        // Get concepts
        getConcepts()
    }

    // MARK: - Get Concepts API

    func getConcepts() {

        showLoader()

        // Validate selected lesson
        guard let lesson = selected_lesson else {
            self.hideLoader()
            print("❌ Concepts API: Selected lesson is nil")
            self.showAlert(msg: "Lesson information not available.")
            return
        }

        // Get lesson ID
        let lessonID = lesson.id.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // Validate lesson ID
        guard !lessonID.isEmpty else {
            self.hideLoader()
            print("❌ Concepts API: Lesson ID is EMPTY")
            self.showAlert(msg: "Lesson information not available.")
            return
        }

        // Concepts API uses lesson_id
        let conceptsURL = API.CONCEPTS + "\(lessonID)"

        print("========================================")
        print("📚 Concepts API Request")
        print("🎓 Grade ID: \(selectedGradeID)")
        print("📖 Lesson ID: \(lessonID)")
        print("🔗 Concepts URL: \(conceptsURL)")
        print("========================================")

        NetworkManager.shared.request(
            urlString: conceptsURL,
            method: .GET
        ) { (result: Result<APIResponse<[LessonConcept]>, NetworkError>) in

            self.hideLoader()

            switch result {

            // MARK: Success

            case .success(let info):

                print("========================================")
                print("✅ Concepts API Response")
                print("✅ Success: \(info.success)")
                print("📊 Total: \(info.total ?? 0)")
                print("📦 Data Count: \(info.data?.count ?? 0)")
                print("📝 Description: \(info.description)")
                print("========================================")

                if info.success {

                    let data = info.data ?? []

                    DispatchQueue.main.async {

                        self.concepts = data.sorted {
                            $0.priority < $1.priority
                        }

                        self.tblVw.reloadData()

                        if self.concepts.isEmpty {
                            print("⚠️ Concepts API returned 0 concepts")
                        } else {
                            print(
                                "✅ Loaded \(self.concepts.count) concepts"
                            )
                        }
                    }

                } else {

                    DispatchQueue.main.async {
                        print(
                            "❌ Concepts API Error: \(info.description)"
                        )

                        self.showAlert(
                            msg: info.description
                        )
                    }
                }

            // MARK: Failure

            case .failure(let error):

                print("========================================")
                print("❌ Concepts API Request Failed")
                print("❌ Error: \(error)")
                print("========================================")

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

    // MARK: - Back Button

    @IBAction func onClickBack(_ sender: Any) {

        self.navigationController?.popViewController(
            animated: true
        )
    }

    // MARK: - UITableView DataSource

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return self.concepts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tblVw.dequeueReusableCell(
            withIdentifier: "CurriculumConceptCell",
            for: indexPath
        ) as! CurriculumConceptCell

        let concept = self.concepts[indexPath.row]

        // Title
        cell.lblTitle.text = concept.title

        // Description
        cell.lblDescription.text = concept.description

        // MARK: - Concept Image

        if !concept.images.isEmpty {

            // images[0] is URL
            // loadImage(url:) expects String
            cell.imgVw.loadImage(
                url: concept.images[0].absoluteString
            )

        } else {

            // No image available
            cell.imgVw.image = nil
        }

        return cell
    }

    // MARK: - UITableView Delegate

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 110
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        let storyboard = UIStoryboard(
            name: "curriculum",
            bundle: nil
        )

        let vc = storyboard.instantiateViewController(
            identifier: "ConceptDetailController"
        ) as? ConceptDetailController

        guard let vc = vc else {
            print("❌ Could not instantiate ConceptDetailController")
            return
        }

        // Pass selected concept
        vc.concept = self.concepts[indexPath.row]

        self.navigationController?.pushViewController(
            vc,
            animated: true
        )
    }
}

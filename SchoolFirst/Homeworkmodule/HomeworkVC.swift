//
//  HomeworkVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var Topview: UIView!

    // MARK: - API Data

    private var studentHomeworkData: StudentHomeworkData?
    private var homeworkList: [StudentHomework] = []

    private var isLoading = false
    private var loadedStudentId = ""

    // Prevents EmptyhomeworkVC from being opened multiple times.
    private var hasNavigatedToEmptyHomework = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()

        UserManager.shared.debugPrint()
        fetchStudentHomework()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let currentStudentId =
            UserManager.shared.resolvedStudentID

        guard !currentStudentId.isEmpty else {
            return
        }

        // Fetch again when selected student changes.
        if currentStudentId != loadedStudentId,
           !isLoading {

            // Allow the empty screen to open for the new student.
            hasNavigatedToEmptyHomework = false
            fetchStudentHomework()
        }
    }

    // MARK: - Actions

    @IBAction func BackButtonTapped(_ sender: UIButton) {

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @IBAction func NotificationButtonTapped(_ sender: UIButton) {
        navigateToNotificationVC()
    }

    // MARK: - Fetch Student Homework

    private func fetchStudentHomework() {

        let studentId =
            UserManager.shared.resolvedStudentID

        let schoolId =
            UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty,
              !schoolId.isEmpty else {

            isLoading = false
            loadedStudentId = ""

            studentHomeworkData = nil
            homeworkList.removeAll()

            TableView.refreshControl?.endRefreshing()
            TableView.reloadData()

            showTableMessage(
                "Student or school information is unavailable."
            )

            print("❌ Student ID or School ID is empty")
            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true

        if homeworkList.isEmpty {
            showTableMessage("Loading homework...")
        }

        NetworkManager.shared.request(
            urlString: API.STUDENT_HOMEWORK,
            method: .GET,
            requiresAuth: true,
            parameters: [
                "student_id": studentId
            ],
            headers: [
                "X-School-Id": schoolId
            ]
        ) { [weak self]
            (result: Result<APIResponse<StudentHomeworkData>, NetworkError>) in

            guard let self = self else {
                return
            }

            DispatchQueue.main.async {

                self.isLoading = false
                self.TableView.refreshControl?.endRefreshing()

                switch result {

                case .success(let response):

                    if response.success,
                       let homeworkData = response.data {

                        self.studentHomeworkData =
                            homeworkData

                        self.homeworkList =
                            homeworkData.homeworks

                        self.loadedStudentId =
                            studentId

                        print("✅ Homework fetched successfully")
                        print("✅ Student: \(homeworkData.student.name)")
                        print("✅ Admission number: \(homeworkData.student.admissionNumber)")
                        print("✅ Homework count: \(homeworkData.homeworks.count)")

                        if self.homeworkList.isEmpty {

                            self.showTableMessage(
                                "No homework available."
                            )

                            self.TableView.reloadData()

                            // Navigate to empty homework screen.
                            self.navigateToEmptyHomeworkVC()

                        } else {

                            // Homework is available.
                            self.hasNavigatedToEmptyHomework = false
                            self.hideTableMessage()
                            self.TableView.reloadData()
                        }

                    } else if response.success {

                        // The request succeeded but returned no data.
                        self.studentHomeworkData = nil
                        self.homeworkList.removeAll()
                        self.loadedStudentId = studentId

                        self.showTableMessage(
                            "No homework available."
                        )

                        self.TableView.reloadData()

                        print("ℹ️ Homework API returned empty data")

                        // Navigate to empty homework screen.
                        self.navigateToEmptyHomeworkVC()

                    } else {

                        // API returned success = false.
                        self.studentHomeworkData = nil
                        self.homeworkList.removeAll()

                        self.showTableMessage(
                            "No homework available."
                        )

                        self.TableView.reloadData()

                        print("❌ Homework API returned unsuccessful response")
                    }

                case .failure(let error):

                    self.studentHomeworkData = nil
                    self.homeworkList.removeAll()

                    self.showTableMessage(
                        "Unable to load homework.\nPlease try again."
                    )

                    self.TableView.reloadData()

                    print(
                        "❌ Student homework API failed: \(error)"
                    )
                }
            }
        }
    }

    // MARK: - Pull to Refresh

    @objc
    private func refreshHomework() {

        loadedStudentId = ""
        hasNavigatedToEmptyHomework = false
        fetchStudentHomework()
    }

    // MARK: - Notification Navigation

    private func navigateToNotificationVC() {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let notificationVC =
                storyboard.instantiateViewController(
                    withIdentifier: "NotificationVC"
                ) as? NotificationVC else {

            print("❌ NotificationVC not found")
            return
        }

        notificationVC.hidesBottomBarWhenPushed = true

        if let navigationController = navigationController {

            navigationController.pushViewController(
                notificationVC,
                animated: true
            )

        } else {

            notificationVC.modalPresentationStyle = .fullScreen

            present(
                notificationVC,
                animated: true
            )
        }
    }

    // MARK: - Empty Homework Navigation

    private func navigateToEmptyHomeworkVC() {

        // Prevent duplicate navigation.
        guard !hasNavigatedToEmptyHomework else {
            return
        }

        // Avoid opening it if it is already displayed.
        if navigationController?.topViewController
            is EmptyhomeworkVC {

            hasNavigatedToEmptyHomework = true
            return
        }

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let emptyHomeworkVC =
                storyboard.instantiateViewController(
                    withIdentifier: "EmptyhomeworkVC"
                ) as? EmptyhomeworkVC else {

            print(
                "❌ EmptyhomeworkVC not found. Check Storyboard ID and custom class."
            )

            return
        }

        hasNavigatedToEmptyHomework = true

        emptyHomeworkVC.hidesBottomBarWhenPushed = true

        if let navigationController = navigationController {

            navigationController.pushViewController(
                emptyHomeworkVC,
                animated: true
            )

        } else {

            emptyHomeworkVC.modalPresentationStyle =
                .fullScreen

            present(
                emptyHomeworkVC,
                animated: true
            )
        }
    }

    // MARK: - Homework Details Navigation

    private func navigateToHomeworkDetails(
        with homework: StudentHomework
    ) {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let detailsVC =
                storyboard.instantiateViewController(
                    withIdentifier: "HomeworkDetailsVC"
                ) as? HomeworkDetailsVC else {

            print(
                "❌ HomeworkDetailsVC not found. Check Storyboard ID."
            )

            return
        }

        // Pass selected homework to details screen.
        detailsVC.studentHomework = homework
        detailsVC.hidesBottomBarWhenPushed = true

        if let navigationController = navigationController {

            navigationController.pushViewController(
                detailsVC,
                animated: true
            )

        } else {

            detailsVC.modalPresentationStyle = .fullScreen

            present(
                detailsVC,
                animated: true
            )
        }
    }

    // MARK: - UI Setup

    private func setupUI() {

        Topview.layer.shadowColor =
            UIColor.gray.cgColor

        Topview.layer.shadowOpacity =
            0.4

        Topview.layer.shadowOffset =
            CGSize(
                width: 0,
                height: 4
            )

        Topview.layer.shadowRadius =
            2

        Topview.layer.masksToBounds =
            false
    }

    // MARK: - Table Setup

    private func setupTableView() {

        TableView.delegate = self
        TableView.dataSource = self

        TableView.separatorStyle = .none
        TableView.showsVerticalScrollIndicator = false

        TableView.register(
            UINib(
                nibName: "HomeworkStudentTableViewCell1",
                bundle: nil
            ),
            forCellReuseIdentifier:
                "HomeworkStudentTableViewCell1"
        )

        TableView.register(
            UINib(
                nibName: "HomeworkwithsubTableViewCell2",
                bundle: nil
            ),
            forCellReuseIdentifier:
                "HomeworkwithsubTableViewCell2"
        )

        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(
            self,
            action: #selector(refreshHomework),
            for: .valueChanged
        )

        TableView.refreshControl = refreshControl
    }

    // MARK: - Table Message

    private func showTableMessage(
        _ message: String
    ) {

        let messageLabel = UILabel(
            frame: TableView.bounds
        )

        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .secondaryLabel

        messageLabel.font =
            UIFont.systemFont(
                ofSize: 15,
                weight: .medium
            )

        TableView.backgroundView = messageLabel
    }

    private func hideTableMessage() {
        TableView.backgroundView = nil
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HomeworkVC:
    UITableViewDelegate,
    UITableViewDataSource {

    func numberOfSections(
        in tableView: UITableView
    ) -> Int {

        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        // Index 0 = student header
        // Index 1 onward = homework API data
        return 1 + homeworkList.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        // MARK: Student Header Cell

        if indexPath.row == 0 {

            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier:
                        "HomeworkStudentTableViewCell1",
                    for: indexPath
                ) as! HomeworkStudentTableViewCell1

            cell.selectionStyle = .none

            return cell
        }

        // MARK: Homework Cell

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier:
                    "HomeworkwithsubTableViewCell2",
                for: indexPath
            ) as! HomeworkwithsubTableViewCell2

        cell.selectionStyle = .none

        let homework =
            homeworkList[indexPath.row - 1]

        cell.configure(
            with: homework
        )

        cell.onViewDetailsTapped = { [weak self] in

            self?.navigateToHomeworkDetails(
                with: homework
            )
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        if indexPath.row == 0 {
            return 140
        }

        return 290
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        guard indexPath.row > 0 else {
            return
        }

        let homework =
            homeworkList[indexPath.row - 1]

        print(
            "📘 Selected homework: \(homework.title)"
        )

        navigateToHomeworkDetails(
            with: homework
        )
    }
}

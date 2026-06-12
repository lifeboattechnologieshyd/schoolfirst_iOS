//
//  HomeworkVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var Topview: UIView!
    
    // MARK: - Data Source
    private var homeworkList: [HomeworkModel] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.separatorStyle = .none
        setupUI()
        setupTableView()
        loadHomeworkData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        Topview.layer.shadowColor = UIColor.gray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }

    private func setupTableView() {
        TableView.delegate = self
        TableView.dataSource = self
        TableView.separatorStyle = .none
        
        // Register Cells
        TableView.register(
            UINib(nibName: "HomeworkStudentTableViewCell1", bundle: nil),
            forCellReuseIdentifier: "HomeworkStudentTableViewCell1"
        )

        TableView.register(
            UINib(nibName: "HomeworkwithsubTableViewCell2", bundle: nil),
            forCellReuseIdentifier: "HomeworkwithsubTableViewCell2"
        )
    }
    
    // MARK: - Load Sample Data
    private func loadHomeworkData() {
        homeworkList = [
            HomeworkModel(
                priorityType: .highPriority,
                subject: .mathematics,
                title: "Fractions Exercise",
                description: "Complete the practice problems on pages 45-47 in the workbook. Focus on improper fractions and mixed numbers.",
                dueDate: "Due: Oct 24, 2023",
                teacherName: "Mrs. Smith"
            ),
            
            HomeworkModel(
                priorityType: .medPriority,
                subject: .science,
                title: "Solar System Model",
                description: "Create a scale model of the planets using recyclable materials. Label each planet and include relative distances.",
                dueDate: "Due: Oct 28, 2023",
                teacherName: "Mr. Johnson"
            ),
            
            HomeworkModel(
                priorityType: .done,
                subject: .history,
                title: "The Industrial Revolution",
                description: "Write a 200-word summary on how the invention of the steam engine changed manufacturing and transportation.",
                dueDate: "Finished: Oct 20",
                teacherName: "Ms. Davis"
            )
        ]
        
        TableView.reloadData()
    }
}

// MARK: - UITableView Delegate & DataSource

extension HomeworkVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + homeworkList.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Row 0: Student Header
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "HomeworkStudentTableViewCell1",
                for: indexPath
            ) as! HomeworkStudentTableViewCell1
            cell.selectionStyle = .none
            return cell
        }
        
        // Other Rows: Homework Cell (reused)
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HomeworkwithsubTableViewCell2",
            for: indexPath
        ) as! HomeworkwithsubTableViewCell2
        cell.selectionStyle = .none
        
        let homework = homeworkList[indexPath.row - 1]
        cell.configure(with: homework)
        
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0 {
            return 140
        } else {
            return 290
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row > 0 else { return }
        
        let homework = homeworkList[indexPath.row - 1]
        print("Tapped: \(homework.title) - \(homework.subject.rawValue)")
    }
}

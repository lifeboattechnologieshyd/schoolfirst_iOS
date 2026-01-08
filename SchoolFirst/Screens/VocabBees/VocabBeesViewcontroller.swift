//
//  VocabBeesViewcontroller.swift
//  SchoolFirst
//
//  Created by Lifeboat Technologies on 20/10/25.
//

import UIKit

class VocabBeesViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var BackButton: UIButton!
    
    var vocabBeeStats: VocabBeeStatistics?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.addBottomShadow()
        tblVw.register(UINib(nibName: "ChallengesTableViewCell", bundle: nil), forCellReuseIdentifier: "ChallengesTableViewCell")
        tblVw.register(UINib(nibName: "PracticeTableViewCell", bundle: nil), forCellReuseIdentifier: "PracticeTableViewCell")
        tblVw.register(UINib(nibName: "CompeteTableViewCell", bundle: nil), forCellReuseIdentifier: "CompeteTableViewCell")
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(updateStatsLocally(_:)),
//            name: .vocabBeeStatsUpdated,
//            object: nil
//        )

    }
//    var didOptimisticUpdate = false





    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FINAL FIXED VERSION — NO ERROR!
        if UserManager.shared.kids.isEmpty {
            print("No kids found in VocabBees")
            
            // Simple alert without completion
            let alert = UIAlertController(
                title: "No Kid Added",
                message: "Please add a kid first to use VocabBees",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
            
        } else {
            // Auto-select first kid if none selected or current one is invalid
            if UserManager.shared.vocabBee_selected_student == nil ||
               !UserManager.shared.kids.contains(where: { $0.studentID == UserManager.shared.vocabBee_selected_student?.studentID }) {
                
                UserManager.shared.vocabBee_selected_student = UserManager.shared.kids[0]
                print("Auto-selected kid for VocabBees: \(UserManager.shared.kids[0].name)")
            }
        }
        
        fetchVocabBeeStatistics()
    }
    
    func fetchVocabBeeStatistics() {
        guard let studentID = UserManager.shared.vocabBee_selected_student?.studentID else {
            print("No student selected")
            return
        }
        
        let url = API.VOCABEE_STATISTICS
        let parameters = ["student_id": studentID]
        
        print("📊 Fetching statistics for student: \(studentID)")
        
        NetworkManager.shared.request(urlString: url, parameters: parameters) { [weak self] (result: Result<APIResponse<[VocabBeeStatistics]>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
//                    if self?.didOptimisticUpdate == true {
//                        self?.didOptimisticUpdate = false
//                        return
//                    }

                    print("📊 API Response: \(response)")
                    
                    if let statsArray = response.data, let stats = statsArray.first {
                        self?.vocabBeeStats = stats
                        
                        // ✅ Debug print
                        print("✅ Stats loaded:")
                        print("   - Correct: \(stats.correct_answers ?? 0)")
                        print("   - Wrong: \(stats.wrong_answers ?? 0)")
                        print("   - Total Words: \(stats.total_words ?? 0)")
                        print("   - Total Points: \(stats.total_points ?? 0)")
                        
                    } else {
                        print("⚠️ No stats data, using defaults")
                        self?.vocabBeeStats = VocabBeeStatistics(
                            total_questions: 0,
                            correct_answers: 0,
                            wrong_answers: 0,
                            total_points: 0,
                            last_answer_points: 0,
                            level: 0,
                            total_words: 99526
                        )
                    }
                    self?.tblVw.reloadData()
                    
                case .failure(let error):
                    print("❌ Error fetching statistics: \(error)")
                }
            }
        }
    }
}

extension VocabBeesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengesTableViewCell", for: indexPath) as! ChallengesTableViewCell
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeTableViewCell", for: indexPath) as! PracticeTableViewCell
            
            if let stats = self.vocabBeeStats {
                let correct = stats.correct_answers ?? 0
                let wrong = stats.wrong_answers ?? 0
                let attempted = correct + wrong
                let totalWords = stats.total_words ?? 0
                
                cell.wordsImage.text = "\(attempted)/\(totalWords)"
                
                // ✅ Debug print
                print("📝 Cell updated: \(attempted)/\(totalWords)")
                
            } else {
                cell.wordsImage.text = "0/0"
                print("⚠️ No stats available for cell")
            }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompeteTableViewCell", for: indexPath) as! CompeteTableViewCell
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            UserManager.shared.vocabBee_selected_mode = "DAILY"
        } else if indexPath.row == 1 {
            UserManager.shared.vocabBee_selected_mode = "PRACTICE"
        } else {
            UserManager.shared.vocabBee_selected_mode = "COMPETE"
        }
        
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        if let gradeVC = storyboard.instantiateViewController(withIdentifier: "gradeViewController") as? gradeViewController {
            self.navigationController?.pushViewController(gradeVC, animated: true)
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

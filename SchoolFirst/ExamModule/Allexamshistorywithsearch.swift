import UIKit
import SwiftUI

class Allexamshistorywithsearch: UIViewController {
    
    // ✅ Properties to receive data from ExamhomeVC
    var studentID: String = ""
    var schoolID: String = ""
    
    // Hosting controller reference to update SwiftUI View dynamically
    private var hostingController: UIHostingController<AllExamsHistoryView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide standard navigation bar if you have one,
        // as the SwiftUI view has a custom Header matching the Figma
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Create the SwiftUI View with empty arrays initially
        let swiftUIView = AllExamsHistoryView(upcomingExams: [], completedExams: [], allExams: [])
        
        // Wrap it in a UIHostingController
        hostingController = UIHostingController(rootView: swiftUIView)
        guard let hostingController = hostingController else { return }
        
        // Add as a child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Setup Constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        // ✅ Fetch live API data
        fetchHistoryExams()
    }
    
    // MARK: - API Integration
    private func fetchHistoryExams() {
        // Fallback to UserManager if not passed directly
        let currentStudentID = studentID.isEmpty ? UserManager.shared.resolvedStudentID : studentID
        let currentSchoolID = schoolID.isEmpty ? UserManager.shared.resolvedSchoolID : schoolID
        
        guard !currentStudentID.isEmpty, !currentSchoolID.isEmpty else { return }
        
        let parameters: [String: Any] = ["student_id": currentStudentID]
        let headers: [String: String] = ["X-School-ID": currentSchoolID]
        
        NetworkManager.shared.request(
            urlString: API.GET_EXAMS,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (result: Result<APIResponse<[ExamItem]>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    let fetchedExams = response.data ?? []
                    self.processExamsData(fetchedExams)
                case .failure(let error):
                    print("Failed to fetch exams history: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // ✅ Configure API data into the Dummy Models seamlessly
    private func processExamsData(_ apiExams: [ExamItem]) {
        var upcoming: [ExamModel] = []
        var completed: [ExamModel] = []
        var all: [ExamModel] = []
        
        for item in apiExams {
            let title = item.name ?? "Exam"
            
            // Format dates
            var dateStr = "Dates TBA"
            let start = item.startDate ?? ""
            let end = item.endDate ?? ""
            if !start.isEmpty && !end.isEmpty {
                dateStr = (start == end) ? start : "\(start) to \(end)"
            } else if !start.isEmpty {
                dateStr = start
            } else if !end.isEmpty {
                dateStr = end
            }
            
            let subjects = item.examinationType?.name ?? "Subjects TBA"
            let term = item.academicYear?.name ?? "Current Term"
            
            // Resolve Status dynamically
            let rawStatus = (item.status ?? "Scheduled").lowercased()
            let isUpcoming = rawStatus.contains("scheduled") || rawStatus.contains("upcoming")
            
            let statusEnum: ExamStatus = isUpcoming ? .upcoming : .completed
            let iconEnum: ExamIconType = isUpcoming ? .calendar : .document
            
            // ✅ Mapping to your existing ExamModel dummy structure
            let model = ExamModel(
                title: title,
                dateRange: dateStr,
                subjectsInfo: subjects,
                termInfo: term,
                status: statusEnum,
                type: iconEnum
            )
            
            all.append(model)
            if isUpcoming {
                upcoming.append(model)
            } else {
                completed.append(model)
            }
        }
        
        // Update SwiftUI View Data dynamically
        self.hostingController?.rootView = AllExamsHistoryView(
            upcomingExams: upcoming,
            completedExams: completed,
            allExams: all
        )
    }
}

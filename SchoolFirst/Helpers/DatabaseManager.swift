//
//  DatabaseManager.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/07/25.
//

import Foundation

class DBManager {
    static let shared = DBManager()
    
    var calender: LifeSkillPrompt?
    private init() {}
    
    func saveUser(user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "USER_INFO")
        }
    }
    
    func deleteUser() {
        UserDefaults.standard.removeObject(forKey: "USER_INFO")
        UserDefaults.standard.removeObject(forKey: "ACCESSTOKEN")
        UserDefaults.standard.removeObject(forKey: "REFRESHTOKEN")
        UserDefaults.standard.removeObject(forKey: "LOGGEDIN")
    }
    
//    func allStudents(schools: [School]) -> [Student] {
//        return schools.flatMap { $0.students ?? [] }  // Handle optional students
//    }
    
    func getuser() -> User? {
        if let data = UserDefaults.standard.data(forKey: "USER_INFO") {
            do {
                return try JSONDecoder().decode(User.self, from: data)
            } catch {
                print("❌ Decode failed in get user: \(error)")
            }
        }
        return nil
    }
}

class UserManager {
    static let shared = UserManager()
    private init() {}
    
    var assessmentSelectedStudent: Student!
    var assessment_selected_grade: GradeModel!
    var assessment_selected_subject: GradeSubject!
    var assessment_selected_lesson_ids = [String]()
    var assessment_created_assessment: Assessment!
    
    var curriculamSelectedStudent: Student!
    
    // vocabee
    var vocabBee_selected_mode = "DAILY" // PRACTICE, COMPETE
    var vocabBee_selected_grade: GradeModel!
    var vocabBee_selected_student: Student!
    var vocabBee_selected_date: VocabeeDate!

    
    var kids: [Student] {
        return getUser()?.students ?? []
    }

    var selectedKid: Student? {
        return kids.first ?? nil
    }
    
    var selectedSchool: School? {
        return selectedKid?.school
    }
    
    var user: User? {
        return getUser()
    }
    
    func saveUser(user: User) {
        DBManager.shared.saveUser(user: user)
    }
    
    func getUser() -> User? {
        return DBManager.shared.getuser()
    }
    
    func deleteUser() {
        DBManager.shared.deleteUser()
    }
    func addKid(_ student: Student) {
            guard var currentUser = getUser() else {
                return
            }
            if currentUser.students == nil {
                currentUser.students = []
            }
            if currentUser.students?.contains(where: { $0.studentID == student.studentID }) == false {
                currentUser.students?.append(student)
            }
            
            saveUser(user: currentUser)
        }
    }


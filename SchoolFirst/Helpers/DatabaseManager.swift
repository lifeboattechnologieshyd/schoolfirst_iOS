//
//  DatabaseManager.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/07/25.
//

import Foundation

class DBManager {
    static let shared = DBManager()
    
    var calender : LifeSkillPrompt?
    private init() {}
    
    func saveUser(user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "USER_INFO")
        }
    }
    
    func deleteUser(){
        UserDefaults.standard.removeObject(forKey: "USER_INFO")
        UserDefaults.standard.removeObject(forKey: "ACCESSTOKEN")
        UserDefaults.standard.removeObject(forKey: "REFRESHTOKEN")
        UserDefaults.standard.removeObject(forKey: "LOGGEDIN")
    }
    
    func allStudents(schools: [School]) -> [Student] {
        return schools.flatMap { $0.students }
    }
    
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
    var assessmentSelectedStudent : Student!
    var curriculamSelectedStudent : Student!
    
    
    // vocabee
    var vocabBee_selected_mode = "DAILY" // PRACTICE, COMPETE
    var vocabBee_selected_grade : GradeModel!
    var vocabBee_selected_student : Student!
    
    
    var kids : [Student] {
        return DBManager.shared.allStudents(schools: UserManager.shared.user?.schools ?? [])
    }
    
    func deleteUser(){
        DBManager.shared.deleteUser()
        
        
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
}

struct PasswordValidator {
    
    static func validate(password: String, confirmPassword: String) -> String? {
        // 1. Empty check
        guard !password.isEmpty else { return "Password cannot be empty" }
        guard !confirmPassword.isEmpty else { return "Confirm password cannot be empty" }
        
        // 2. Length check
        guard password.count >= 8 else { return "Password must be at least 8 characters long" }
        
        // 3. Strong password (optional, uncomment if needed)
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$&*]).{8,}$"
        if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password) {
            return "Password must contain uppercase, lowercase, number, and special character"
        }
        
        // 4. Match check
        guard password == confirmPassword else { return "Passwords do not match" }
        
        // ✅ All good
        return nil
    }
}

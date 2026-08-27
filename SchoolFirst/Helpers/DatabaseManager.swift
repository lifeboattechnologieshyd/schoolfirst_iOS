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
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let userInfo = "USER_INFO"
        static let accessToken = "ACCESSTOKEN"
        static let refreshToken = "REFRESHTOKEN"
        static let loggedIn = "LOGGEDIN"
    }
    
    // MARK: - User
    
    func saveUser(user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: Keys.userInfo)
        }
    }
    
    func getuser() -> User? {
        if let data = UserDefaults.standard.data(forKey: Keys.userInfo) {
            do {
                return try JSONDecoder().decode(User.self, from: data)
            } catch {
                print("❌ Decode failed in get user: \(error)")
            }
        }
        return nil
    }
    
    func deleteUser() {
        UserDefaults.standard.removeObject(forKey: Keys.userInfo)
        UserDefaults.standard.removeObject(forKey: Keys.accessToken)
        UserDefaults.standard.removeObject(forKey: Keys.refreshToken)
        UserDefaults.standard.removeObject(forKey: Keys.loggedIn)
    }
    
    // MARK: - Access Token
    
    func saveAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: Keys.accessToken)
        UserDefaults.standard.set(true, forKey: Keys.loggedIn)
        UserDefaults.standard.synchronize()
    }
    
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: Keys.accessToken)
    }
    
    // MARK: - Refresh Token
    
    func saveRefreshToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: Keys.refreshToken)
        UserDefaults.standard.synchronize()
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: Keys.refreshToken)
    }
    
    // MARK: - Login Session (call this after successful login)
    
    func saveLoginSession(user: User, accessToken: String, refreshToken: String?) {
        saveUser(user: user)
        saveAccessToken(accessToken)
        if let refresh = refreshToken, !refresh.isEmpty {
            saveRefreshToken(refresh)
        }
        UserDefaults.standard.set(true, forKey: Keys.loggedIn)
        UserDefaults.standard.synchronize()
    }
    
    func isLoggedIn() -> Bool {
        let flag = UserDefaults.standard.bool(forKey: Keys.loggedIn)
        let token = getAccessToken()
        return flag && !(token ?? "").isEmpty
    }
    
    // MARK: - Auth Header helper (for NetworkManager / APIs)
    
    func authHeaderValue() -> String? {
        guard let token = getAccessToken(), !token.isEmpty else { return nil }
        // Change to "Token \(token)" if your backend uses DRF Token auth
        return "Bearer \(token)"
    }
    
    func authHeaders() -> [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        if let auth = authHeaderValue() {
            headers["Authorization"] = auth
        }
        return headers
    }
}

// MARK: - UserManager

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
    
    // Store the currently active student index
    var selectedKidIndex: Int = 0

    var selectedKid: Student? {
        guard !kids.isEmpty, selectedKidIndex < kids.count else {
            return kids.first
        }
        return kids[selectedKidIndex]
    }
    
    var selectedSchool: School? {
        return selectedKid?.school
    }
    
    var user: User? {
        return getUser()
    }
    
    // MARK: - User
    
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
    
    // MARK: - Tokens (NEW)
    
    func saveAccessToken(_ token: String) {
        DBManager.shared.saveAccessToken(token)
    }
    
    func getAccessToken() -> String? {
        return DBManager.shared.getAccessToken()
    }
    
    func saveRefreshToken(_ token: String) {
        DBManager.shared.saveRefreshToken(token)
    }
    
    func getRefreshToken() -> String? {
        return DBManager.shared.getRefreshToken()
    }
    
    /// Call this once after login API success
    func saveLoginSession(user: User, accessToken: String, refreshToken: String? = nil) {
        DBManager.shared.saveLoginSession(
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
    
    func isLoggedIn() -> Bool {
        return DBManager.shared.isLoggedIn()
    }
    
    func authHeaders() -> [String: String] {
        return DBManager.shared.authHeaders()
    }
}

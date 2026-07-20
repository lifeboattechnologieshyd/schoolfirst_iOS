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
        if let firstStudentSchoolId = user.students?.first?.school?.schoolID {
            UserDefaults.standard.set(firstStudentSchoolId, forKey: "school_id")
            UserDefaults.standard.set(firstStudentSchoolId, forKey: "SchoolID")
            UserDefaults.standard.set(firstStudentSchoolId, forKey: "SCHOOL_ID")
        }
        
        // ── NEW: Save selected student ID + school ID ──────────────────────
        if let firstStudent = user.students?.first {
            saveSelectedStudent(firstStudent)
        }
    }
    
    // MARK: - NEW: Save Selected Student + School IDs to UserDefaults
    func saveSelectedStudent(_ student: Student) {
        
        // Save studentID
        UserDefaults.standard.set(student.studentID, forKey: "STUDENT_ID")
        print("💾 Saved STUDENT_ID:", student.studentID)
        
        // Save schoolID from student's school
        if let schoolID = student.school?.schoolID, !schoolID.isEmpty {
            UserDefaults.standard.set(schoolID, forKey: "school_id")
            UserDefaults.standard.set(schoolID, forKey: "SchoolID")
            UserDefaults.standard.set(schoolID, forKey: "SCHOOL_ID")
            print("💾 Saved SCHOOL_ID:", schoolID)
        } else {
            print("⚠️ saveSelectedStudent — student.school is nil for:", student.name)
        }
    }
    
    // MARK: - NEW: Save Selected Kid Index
    func saveSelectedKidIndex(_ index: Int) {
        UserDefaults.standard.set(index, forKey: "SELECTED_KID_INDEX")
        print("💾 Saved SELECTED_KID_INDEX:", index)
    }
    
    // MARK: - NEW: Load Selected Kid Index
    func loadSelectedKidIndex() -> Int {
        return UserDefaults.standard.integer(forKey: "SELECTED_KID_INDEX")
    }
    
    func deleteUser() {
        UserDefaults.standard.removeObject(forKey: "USER_INFO")
        UserDefaults.standard.removeObject(forKey: "ACCESSTOKEN")
        UserDefaults.standard.removeObject(forKey: "REFRESHTOKEN")
        UserDefaults.standard.removeObject(forKey: "LOGGEDIN")
        UserDefaults.standard.removeObject(forKey: "school_id")
        UserDefaults.standard.removeObject(forKey: "SchoolID")
        UserDefaults.standard.removeObject(forKey: "SCHOOL_ID")
        
        // ── NEW: Clear student + index keys ───────────────────────────────
        UserDefaults.standard.removeObject(forKey: "STUDENT_ID")
        UserDefaults.standard.removeObject(forKey: "SELECTED_KID_INDEX")
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
    
    // MARK: - NEW: Debug Print All Saved Keys
    func debugPrintSavedKeys() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 DBManager — UserDefaults Saved Keys")
        print("   STUDENT_ID         :", UserDefaults.standard.string(forKey: "STUDENT_ID")   ?? "nil")
        print("   SCHOOL_ID          :", UserDefaults.standard.string(forKey: "SCHOOL_ID")    ?? "nil")
        print("   SchoolID           :", UserDefaults.standard.string(forKey: "SchoolID")     ?? "nil")
        print("   school_id          :", UserDefaults.standard.string(forKey: "school_id")    ?? "nil")
        print("   SELECTED_KID_INDEX :", UserDefaults.standard.integer(forKey: "SELECTED_KID_INDEX"))
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

class UserManager {
    static let shared = UserManager()
    private init() {
        // ── NEW: Restore selectedKidIndex from UserDefaults on app launch ──
        _selectedKidIndex = DBManager.shared.loadSelectedKidIndex()
        print("🔄 UserManager init — restored selectedKidIndex:", _selectedKidIndex)
    }
    
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
    
    // ── UPDATED: selectedKidIndex now persisted via UserDefaults ──────────
    private var _selectedKidIndex: Int = 0
    
    var selectedKidIndex: Int {
        get { return _selectedKidIndex }
        set {
            _selectedKidIndex = newValue
            // Persist index to UserDefaults
            DBManager.shared.saveSelectedKidIndex(newValue)
            // Also update STUDENT_ID + SCHOOL_ID whenever kid changes
            if let kid = selectedKid {
                DBManager.shared.saveSelectedStudent(kid)
            }
            print("✅ selectedKidIndex changed to:", newValue,
                  "| kid:", selectedKid?.name ?? "nil")
        }
    }

    var selectedKid: Student? {
        guard !kids.isEmpty, _selectedKidIndex < kids.count else {
            return kids.first
        }
        return kids[_selectedKidIndex]
    }
    
    var selectedSchool: School? {
        return selectedKid?.school
    }
    
    // MARK: - NEW: Resolved IDs with fallback chain
    var resolvedStudentID: String {
        // Priority 1: In-memory selectedKid
        if let sid = selectedKid?.studentID, !sid.isEmpty {
            return sid
        }
        // Priority 2: UserDefaults fallback
        let fallback = UserDefaults.standard.string(forKey: "STUDENT_ID") ?? ""
        print("⚠️ resolvedStudentID — using UserDefaults fallback:", fallback)
        return fallback
    }
    
    var resolvedSchoolID: String {
        // Priority 1: In-memory selectedKid's school
        if let scid = selectedSchool?.schoolID, !scid.isEmpty {
            return scid
        }
        // Priority 2: UserDefaults fallbacks
        for key in ["SCHOOL_ID", "SchoolID", "school_id"] {
            if let scid = UserDefaults.standard.string(forKey: key), !scid.isEmpty {
                print("⚠️ resolvedSchoolID — using UserDefaults[\(key)] fallback:", scid)
                return scid
            }
        }
        print("❌ resolvedSchoolID — all sources are empty")
        return ""
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
        if currentUser.students?.contains(where: {
            $0.studentID == student.studentID
        }) == false {
            currentUser.students?.append(student)
        }
        saveUser(user: currentUser)
    }
    
    // MARK: - NEW: Switch Kid helper
    func switchKid(to index: Int) {
        guard index >= 0, index < kids.count else {
            print("❌ switchKid — invalid index:", index)
            return
        }
        selectedKidIndex = index  // setter handles persistence + ID save
        print("✅ Switched to kid:", kids[index].name,
              "| studentID:", kids[index].studentID,
              "| schoolID :", selectedSchool?.schoolID ?? "nil")
    }
    
    // MARK: - NEW: Debug helper
    func debugPrint() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 UserManager Debug")
        print("   kids count        :", kids.count)
        print("   selectedKidIndex  :", _selectedKidIndex)
        print("   selectedKid.name  :", selectedKid?.name       ?? "nil")
        print("   resolvedStudentID :", resolvedStudentID)
        print("   resolvedSchoolID  :", resolvedSchoolID)
        DBManager.shared.debugPrintSavedKeys()
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

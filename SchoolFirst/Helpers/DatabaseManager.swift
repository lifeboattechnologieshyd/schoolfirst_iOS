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
    
    // MARK: - Save Selected Student + School IDs to UserDefaults
    // ✅ UPDATED: Now also saves NAME, GRADE, SECTION for display without API calls
    func saveSelectedStudent(_ student: Student) {
        
        // Save studentID
        UserDefaults.standard.set(student.studentID, forKey: "STUDENT_ID")
        print("💾 Saved STUDENT_ID:", student.studentID)
        
        // ── ✅ NEW: Save student name ──────────────────────────────────────
        UserDefaults.standard.set(student.name, forKey: "STUDENT_NAME")
        print("💾 Saved STUDENT_NAME:", student.name)
        
        // ── ✅ NEW: Save grade ─────────────────────────────────────────────
        UserDefaults.standard.set(student.grade, forKey: "STUDENT_GRADE")
        print("💾 Saved STUDENT_GRADE:", student.grade)
        
        // ── ✅ NEW: Save section ───────────────────────────────────────────
        UserDefaults.standard.set(student.section ?? "", forKey: "STUDENT_SECTION")
        print("💾 Saved STUDENT_SECTION:", student.section ?? "")
        
        // ── ✅ NEW: Save combined "Grade 5 - A" display string ─────────────
        var gradeSection = student.grade
        if let section = student.section, !section.isEmpty {
            gradeSection = "\(student.grade) - \(section)"
        }
        UserDefaults.standard.set(gradeSection, forKey: "STUDENT_GRADE_SECTION")
        print("💾 Saved STUDENT_GRADE_SECTION:", gradeSection)
        
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
    
    // MARK: - Save Selected Kid Index
    func saveSelectedKidIndex(_ index: Int) {
        UserDefaults.standard.set(index, forKey: "SELECTED_KID_INDEX")
        print("💾 Saved SELECTED_KID_INDEX:", index)
    }
    
    // MARK: - Load Selected Kid Index
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
        
        // ── Clear student + index keys ─────────────────────────────────────
        UserDefaults.standard.removeObject(forKey: "STUDENT_ID")
        UserDefaults.standard.removeObject(forKey: "SELECTED_KID_INDEX")
        
        // ── ✅ NEW: Clear name + grade keys ────────────────────────────────
        UserDefaults.standard.removeObject(forKey: "STUDENT_NAME")
        UserDefaults.standard.removeObject(forKey: "STUDENT_GRADE")
        UserDefaults.standard.removeObject(forKey: "STUDENT_SECTION")
        UserDefaults.standard.removeObject(forKey: "STUDENT_GRADE_SECTION")
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
    
    // MARK: - Debug Print All Saved Keys
    func debugPrintSavedKeys() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 DBManager — UserDefaults Saved Keys")
        print("   STUDENT_ID            :", UserDefaults.standard.string(forKey: "STUDENT_ID")            ?? "nil")
        print("   STUDENT_NAME          :", UserDefaults.standard.string(forKey: "STUDENT_NAME")          ?? "nil")
        print("   STUDENT_GRADE         :", UserDefaults.standard.string(forKey: "STUDENT_GRADE")         ?? "nil")
        print("   STUDENT_SECTION       :", UserDefaults.standard.string(forKey: "STUDENT_SECTION")       ?? "nil")
        print("   STUDENT_GRADE_SECTION :", UserDefaults.standard.string(forKey: "STUDENT_GRADE_SECTION") ?? "nil")
        print("   SCHOOL_ID             :", UserDefaults.standard.string(forKey: "SCHOOL_ID")             ?? "nil")
        print("   SchoolID              :", UserDefaults.standard.string(forKey: "SchoolID")              ?? "nil")
        print("   school_id             :", UserDefaults.standard.string(forKey: "school_id")             ?? "nil")
        print("   SELECTED_KID_INDEX    :", UserDefaults.standard.integer(forKey: "SELECTED_KID_INDEX"))
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

class UserManager {
    static let shared = UserManager()
    private init() {
        // ── Restore selectedKidIndex from UserDefaults on app launch ──────
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
    
    // ── selectedKidIndex persisted via UserDefaults ────────────────────────
    private var _selectedKidIndex: Int = 0
    
    var selectedKidIndex: Int {
        get { return _selectedKidIndex }
        set {
            _selectedKidIndex = newValue
            // Persist index to UserDefaults
            DBManager.shared.saveSelectedKidIndex(newValue)
            // Also update STUDENT_ID + SCHOOL_ID + NAME + GRADE whenever kid changes
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
    
    // MARK: - Resolved IDs with fallback chain
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
    
    // MARK: - ✅ NEW: Resolved Student Name (no API call needed)
    var resolvedStudentName: String {
        // Priority 1: In-memory selectedKid
        if let name = selectedKid?.name, !name.isEmpty {
            return name
        }
        // Priority 2: UserDefaults fallback
        let fallback = UserDefaults.standard.string(forKey: "STUDENT_NAME") ?? ""
        if !fallback.isEmpty {
            print("⚠️ resolvedStudentName — using UserDefaults fallback:", fallback)
            return fallback
        }
        return "Student"
    }
    
    // MARK: - ✅ NEW: Resolved Grade (no API call needed)
    var resolvedStudentGrade: String {
        // Priority 1: In-memory selectedKid
        if let grade = selectedKid?.grade, !grade.isEmpty {
            return grade
        }
        // Priority 2: UserDefaults fallback
        let fallback = UserDefaults.standard.string(forKey: "STUDENT_GRADE") ?? ""
        if !fallback.isEmpty {
            print("⚠️ resolvedStudentGrade — using UserDefaults fallback:", fallback)
            return fallback
        }
        return ""
    }
    
    // MARK: - ✅ NEW: Resolved Section (no API call needed)
    var resolvedStudentSection: String {
        // Priority 1: In-memory selectedKid
        if let section = selectedKid?.section, !section.isEmpty {
            return section
        }
        // Priority 2: UserDefaults fallback
        return UserDefaults.standard.string(forKey: "STUDENT_SECTION") ?? ""
    }
    
    // MARK: - ✅ NEW: Resolved "Grade 5 - A" display string (no API call needed)
    var resolvedGradeSection: String {
        // Priority 1: Build from in-memory selectedKid
        if let kid = selectedKid, !kid.grade.isEmpty {
            if let section = kid.section, !section.isEmpty {
                return "\(kid.grade) - \(section)"
            }
            return kid.grade
        }
        // Priority 2: UserDefaults fallback
        let fallback = UserDefaults.standard.string(forKey: "STUDENT_GRADE_SECTION") ?? ""
        if !fallback.isEmpty {
            print("⚠️ resolvedGradeSection — using UserDefaults fallback:", fallback)
            return fallback
        }
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
    
    // MARK: - Switch Kid helper
    func switchKid(to index: Int) {
        guard index >= 0, index < kids.count else {
            print("❌ switchKid — invalid index:", index)
            return
        }
        selectedKidIndex = index  // setter handles persistence + ID + name + grade save
        print("✅ Switched to kid:", kids[index].name,
              "| studentID:", kids[index].studentID,
              "| schoolID :", selectedSchool?.schoolID ?? "nil")
    }
    
    // MARK: - Debug helper
    func debugPrint() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 UserManager Debug")
        print("   kids count           :", kids.count)
        print("   selectedKidIndex     :", _selectedKidIndex)
        print("   selectedKid.name     :", selectedKid?.name ?? "nil")
        print("   resolvedStudentID    :", resolvedStudentID)
        print("   resolvedStudentName  :", resolvedStudentName)
        print("   resolvedStudentGrade :", resolvedStudentGrade)
        print("   resolvedGradeSection :", resolvedGradeSection)
        print("   resolvedSchoolID     :", resolvedSchoolID)
        DBManager.shared.debugPrintSavedKeys()
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

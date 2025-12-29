//
//  Configurations.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 29/06/25.
//

import Foundation


private enum BuildConfiguration {
    enum Error: Swift.Error {
        case missingkey, invalidValue
    }
    static func value<T>(for key: String) throws -> T where T : LosslessStringConvertible{
        
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else{
            throw Error.missingkey
        }
        switch object {
        case let string as String:
            guard let value = T(string) else {fallthrough}
            return value
        default:
            throw Error.invalidValue
        }
        
    }
}

enum PLISTVALUES {
    static var baseUrl : String {
        do{
            return try BuildConfiguration.value(for: "server_url")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct API {
    
    static let BASE_URL = PLISTVALUES.baseUrl.replacingOccurrences(of: "%2F", with: "/")
    
    
    static let DASHBOARD = BASE_URL + "user/dashboard" // not using now
    static let UPLOAD_FILE = BASE_URL + "userservice/storage/upload" // not using now
    static let ONLINE_STORE_PRODUCTS = BASE_URL + "onlinestore/products"

    
    
    
    
    static let SENDOTP = BASE_URL + "user/authentication/mobile/send-otp"
    static let EMAIL_SENDOTP = BASE_URL + "user/authentication/email/send-otp"
    static let LOGIN = BASE_URL + "user/authentication/login"
    
    static let VERIFY_OTP = BASE_URL + "user/authentication/mobile/verify-otp"
    static let EMAIL_OTP = BASE_URL + "user/authentication/email/verify-otp"
    static let SET_PASSWORD = BASE_URL + "user/authentication/set-password"
    
    //ED
    static let CREATE_ORDER = BASE_URL + "onlinestore/order"

    static let GET_ADDRESS = BASE_URL + "onlinestore/address"
    static let CREATE_ADDRESS = BASE_URL + "onlinestore/address"
    
    static let ONLINE_COURSES = BASE_URL + "courses/online/courses"
    static let EDUTAIN_FEED = BASE_URL + "edutain/feed"
    
    static let EDUTAIN_FEEL = BASE_URL + "events/get/feels"
    static let EVENT_GALLERY = BASE_URL + "events/gallery"
    static let EVENTS_GETEVENTS = BASE_URL + "events/events"
    
    
    static let VOCABEE_STATISTICS = BASE_URL + "vocabee/get/statistics"
    
    
    static let BROADCAST_CALENDER = BASE_URL + "broadcast/calendar/"
    
    
    static let BANNER = BASE_URL + "broadcast/banner?screen=Home"
    
    static let HOMEWORK = BASE_URL + "school/homework"
    static let HOMEWORK_PAST = BASE_URL + "school/homework/past?"
    static let SCHOOL_INFO = BASE_URL + "school/info"
    
    static let NEWS = BASE_URL + "news/"
    
    
    
    // assesssment :
    
    static let GRADES = BASE_URL + "school/grade/unassigned"
    static let SUBJECTS = BASE_URL + "curriculum/subject?grade="
    static let LESSON = BASE_URL + "curriculum/lesson"
    static let CONCEPTS = BASE_URL + "curriculum/concepts?lesson_id="
    
    
    
    static let CURRICULUM_TYPES = BASE_URL + "curriculum/curriculum"
    static let CURRICULUM_CATEGORIES = BASE_URL + "curriculum/categori?grade="
    
    
    // Vocabee
    
    // daily challenges :
    
    static let VOCABEE_GET_DATES = BASE_URL + "vocabee/words/history"
    static let VOCABEE_GET_WORDS_BY_DATES = BASE_URL + "vocabee/daily/words"
    
    static let VOCABEE_PRACTICE_SUBMIT = BASE_URL + "vocabee/word"  // Practice
    
    static let VOCABEE_SUBMIT_WORD = BASE_URL + "vocabee/attempt/words"  // Daily Challenge

    
    // practice :
    static let VOCABEE_GET_PRACTISE_WORDS = BASE_URL + "vocabee/get/word"
    
    
    
    
    // Fee
    static let FEE_GET_DETAILS = BASE_URL + "fees/get/fee"

    // In API struct
    static let FEE_CREATE_PAYMENT = BASE_URL + "fees/payment"
    
    static let ASSESSMENT_CREATE = BASE_URL + "assessments/create/assessments"
    static let ASSESSMENT_ATTEMPT = BASE_URL + "assessments/attempt/assessment"
    static let ASSESSMENT_HISTORY = BASE_URL + "assessments/past/assessments"
    static let ASSESSMENT_HISTORY_ANSWERS = BASE_URL + "assessments/myanswers"
    
    
    static let ASSESSMENT_RESULTS = BASE_URL + "assessments/result"
    

    // GET all addresses & POST new address
    static let ONLINE_STORE_ADDRESS = BASE_URL + "onlinestore/address"

    // PUT/UPDATE address - needs ID appended
    static let EDIT_ADDRESS = BASE_URL + "onlinestore/address/"  // + id
    
    // Attandance :
    
    static let ATTENDANCE_STATS = BASE_URL + "attendance/student/attendance?"
    static let ATTENDANCE_LEAVE_HISTORY = BASE_URL + "attendance/leave/history?"
    static let ATTENDANCE_TIMETABLE = BASE_URL + "attendance/timetable?"
    
}

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
            let url: String = try BuildConfiguration.value(for: "server_url")
            return url
        } catch {
            fatalError("server_url missing in xcconfig")
        }
    }

    // NEW: Property for second Base URL
    static var baseUrl2 : String {
        do{
            let url: String = try BuildConfiguration.value(for: "server_url_2")
            return url
        } catch {
            fatalError("server_url_2 missing in xcconfig")
        }
    }
}

struct API {
    // Existing Base URL
    static let BASE_URL = PLISTVALUES.baseUrl.replacingOccurrences(of: "%2F", with: "/")
    
    // NEW: Second Base URL
    static let BASE_URL_2 = PLISTVALUES.baseUrl2.replacingOccurrences(of: "%2F", with: "/")
    
    // --- Existing Endpoints (Remain Unchanged) ---
    static let DASHBOARD = BASE_URL + "user/dashboard"
    static let UPLOAD_FILE = BASE_URL + "userservice/storage/upload"
    static let ONLINE_STORE_PRODUCTS = BASE_URL + "onlinestore/products"
    
    // --- New Endpoints using BASE_URL_2 ---
    // Example: static let NEW_FEATURE = BASE_URL_2 + "v1/feature"

    
    
    static let SENDOTP = BASE_URL + "user/send-otp"
    static let EMAIL_SENDOTP = BASE_URL + "user/authentication/email/send-otp"
    static let LOGIN = BASE_URL + "user/authentication/login/v2"
    
    static let VERIFY_OTP = BASE_URL + "user/verify-otp"
    static let EMAIL_OTP = BASE_URL + "user/authentication/email/verify-otp"
    static let SET_PASSWORD = BASE_URL + "user/authentication/set-password"
    
    //ED
    static let CREATE_ORDER = BASE_URL_2 + "onlinestore/order"

    static let GET_ADDRESS = BASE_URL_2 + "onlinestore/address"
    static let CREATE_ADDRESS = BASE_URL_2 + "onlinestore/address"
    
    static let ONLINE_COURSES = BASE_URL_2 + "courses/online/courses"
    static let EDUTAIN_FEED = BASE_URL_2 + "edutain/feed"
    
    static let LIKE_FEED = BASE_URL_2 + "edutain/feed/"
    // Usage: LIKE_FEED + feedId + "/like"
    static let EDUTAIN_SEARCH = BASE_URL_2 + "edutain/search"
    static let GET_COMMENTS = BASE_URL_2 + "edutain/comment"
    static let POST_COMMENT = BASE_URL_2 + "edutain/comment"
    
         
    static let WHATSAPP_SHARE = BASE_URL_2 + "edutain/whatsappshare"

    static let EDUTAIN_FEEL = BASE_URL_2 + "events/get/feels"
    static let EVENT_GALLERY = BASE_URL_2 + "events/gallery"
    static let EVENTS_GETEVENTS = BASE_URL_2 + "events/get/event"
    
    
    static let VOCABEE_STATISTICS = BASE_URL_2 + "vocabee/get/statistics"
    
    
    static let BROADCAST_CALENDER = BASE_URL_2 + "broadcast/calendar"
    
    
    static let BANNER = BASE_URL_2 + "broadcast/banner?screen=Home"
         
         
         
    
    static let HOMEWORK = BASE_URL_2 + "school/homework"
    static let HOMEWORK_PAST = BASE_URL_2 + "school/homework/past?"
    static let SCHOOL_INFO = BASE_URL_2 + "school/info"
    
    static let NEWS = BASE_URL_2 + "news/"
    
    
    // In your API/Constants file

    // In your API/Constants file
    static let ADD_STUDENT = BASE_URL_2 + "school/general/student"
    static let GRADES_LIST = BASE_URL_2 + "school/grade/unassigned"
    // Add this to your API struct
    static let GET_STUDENTS = BASE_URL_2 + "backoffice/student"

    // assesssment :
    
    static let GRADES = BASE_URL_2 + "school/grade/unassigned"
    static let SUBJECTS = BASE_URL_2 + "curriculum/subject?grade="
    static let LESSON = BASE_URL_2 + "curriculum/lesson"
    static let CONCEPTS = BASE_URL_2 + "curriculum/concepts?lesson_id="
    
    
    
    static let CURRICULUM_TYPES = BASE_URL_2 + "curriculum/curriculum"
    static let CURRICULUM_CATEGORIES = BASE_URL_2 + "curriculum/categori?grade="
    
    
    // Vocabee
    
    // daily challenges :
    
    static let VOCABEE_GET_DATES = BASE_URL_2 + "vocabee/words/history"
    static let VOCABEE_GET_WORDS_BY_DATES = BASE_URL_2 + "vocabee/daily/words"
    
    static let VOCABEE_PRACTICE_SUBMIT = BASE_URL_2 + "vocabee/word"  // Practice
    
    static let VOCABEE_SUBMIT_WORD = BASE_URL_2 + "vocabee/attempt/words"  // Daily Challenge

    
    // practice :
    static let VOCABEE_GET_PRACTISE_WORDS = BASE_URL_2 + "vocabee/get/word"
    
    
    
    
    // Fee
    static let FEE_GET_DETAILS = BASE_URL_2 + "fees/get/fee"
    static let FEE_TRANSACTIONS = BASE_URL_2 + "fees/transactions"


    // In API struct
    static let FEE_CREATE_PAYMENT = BASE_URL_2 + "fees/payment"
    
    static let ASSESSMENT_CREATE = BASE_URL_2 + "assessments/create/assessments"
    static let ASSESSMENT_ATTEMPT = BASE_URL_2 + "assessments/attempt/assessment"
    static let ASSESSMENT_HISTORY = BASE_URL_2 + "assessments/past/assessments"
    static let ASSESSMENT_HISTORY_ANSWERS = BASE_URL_2 + "assessments/myanswers"
    
    
    static let ASSESSMENT_RESULTS = BASE_URL_2 + "assessments/result"
    

    // GET all addresses & POST new address
    static let ONLINE_STORE_ADDRESS = BASE_URL_2 + "onlinestore/address"

    // PUT/UPDATE address - needs ID appended
    static let EDIT_ADDRESS = BASE_URL_2 + "onlinestore/address/"  // + id
    
    // Attandance :
    
    static let ATTENDANCE_STATS = BASE_URL_2 + "attendance/student/attendance?"
    static let ATTENDANCE_LEAVE_HISTORY = BASE_URL_2 + "attendance/leave/history?"
    static let ATTENDANCE_TIMETABLE = BASE_URL_2 + "attendance/timetable?"
    static let APPLY_LEAVE = BASE_URL_2 + "attendance/apply/leave"
    // Add this to your URLs file
    static let LEAVE_HISTORY = BASE_URL_2 + "attendance/leave/history"
    static let UPDATE_LEAVE = BASE_URL_2 + "attendance/leave/"
    // Add this to your API URLs
    static let DONE_HOMEWORK = BASE_URL_2 + "school/create/homework"

    // Remove duplicate ONLINE_COURSES and keep only these 3 at the bottom

    static let WEBINARS = BASE_URL_2 + "courses/get/webinar"
    static let OFFLINE_COURSES = BASE_URL_2 + "courses/get/course"   // This is your working offline API
    static let PTM_MEETINGS = BASE_URL + "ptm/parent-teacher-meetings"
    static let PTM_COMPLETED_MEETINGS = BASE_URL + "ptm/completed-meetings"
    // PhonePe payment endpoints
    static let FEE_CREATE_PAYMENT_PHONEPE = BASE_URL + "fee/create/payment"
    
    static let STUDENT_PENDING_FEE = BASE_URL + "fee/student-fee/pending"
    static let FEE_COMPLETED_PAYMENT = BASE_URL + "fee/completed/payment"
    static let CALENDAR_EVENTS = BASE_URL + "calendar/event"
    static func PTM_PARENT_RESPONSE(meetingID: String, studentID: String) -> String {
          return BASE_URL + "ptm/parent-response/\(meetingID)?student_id=\(studentID)"
      }
  
}

    


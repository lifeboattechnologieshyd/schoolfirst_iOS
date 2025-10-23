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
    
    
    
    
    
    static let SENDOTP = BASE_URL + "user/authentication/mobile/send-otp"
    static let LOGIN = BASE_URL + "user/authentication/login"
    
    static let VERIFY_OTP = BASE_URL + "user/authentication/mobile/verify-otp"
    static let SET_PASSWORD = BASE_URL + "user/authentication/set-password"
    
    static let ONLINE_COURSES = BASE_URL + "courses/online/courses"
    static let EDUTAIN_FEED = BASE_URL + "edutain/feed"
    
    static let EDUTAIN_FEEL = BASE_URL + "events/get/feels"
    static let EVENT_GALLERY = BASE_URL + "events/gallery"
    static let EVENTS_GETEVENTS = BASE_URL + "events/events"
    
    
    
    
    static let BROADCAST_CALENDER = BASE_URL + "broadcast/calendar/"
    
    
    static let BANNER = BASE_URL + "broadcast/banner?screen=Home"
    
    static let HOMEWORK = BASE_URL + "school/homework"
    static let SCHOOL_INFO = BASE_URL + "school/info"

    static let NEWS = BASE_URL + "news/"
    static let FEE = BASE_URL + "fees/get/fee"
    
    
    
    // assesssment :
    
    static let GRADES = BASE_URL + "school/grade/unassigned"
    static let SUBJECTS = BASE_URL + "curriculum/subject?grade="
    static let LESSON = BASE_URL + "curriculum/lesson"
    static let CONCEPTS = BASE_URL + "curriculum/concepts?lesson_id="
    
    
    
    static let CURRICULUM_TYPES = BASE_URL + "curriculum/curriculum"
    static let CURRICULUM_CATEGORIES = BASE_URL + "curriculum/categori?grade="
    
    


}

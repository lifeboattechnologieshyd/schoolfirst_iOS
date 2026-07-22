//
//  NetworkManager.swift
//  SchoolFirst
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case noaccess
    case noInternet
    case decodingError(String)
    case serverError(String)
}
class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}

    func request<T: Decodable>(
        urlString: String,
        method: HTTPMethod = .GET,
        is_testing : Bool = false,
        requiresAuth: Bool = true,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<APIResponse<T>, NetworkError>) -> Void
    ) {
        
        guard ReachabilityManager.shared.isConnected else {

            DispatchQueue.main.async {
                AlertManager.shared.showNoInternetAlert()
            }

            completion(.failure(.noInternet))
            return
        }
        
        guard var urlComponents = URLComponents(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        if method == .GET, let parameters = parameters {
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        if let parameters = parameters, method == .POST || method == .PUT {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
                return
            }
        }
        
        // ✅ FIX 1: BASE_URL_2 checked FIRST — public server never gets Bearer token
        if requiresAuth,
           let at = UserDefaults.standard.string(forKey: "ACCESSTOKEN"),
           !urlString.contains(API.BASE_URL_2),
           !(urlString.contains(API.SENDOTP) ||
             urlString.contains(API.LOGIN) ||
             urlString.contains(API.VERIFY_OTP) ||
             urlString.contains(API.EMAIL_OTP) ||
             urlString.contains(API.SET_PASSWORD)) {
            request.setValue("Bearer \(at)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                print(String.init(data: data, encoding: .utf8) ?? "-----")
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...399).contains(httpResponse.statusCode)  {
                        print("✅ Success: Status code is \(httpResponse.statusCode)")
                        if is_testing {
                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                               let prettyString = String(data: prettyData, encoding: .utf8) {
                                print("🧪 TEST RAW RESPONSE:\n\(prettyString)")
                            }
                        }
                        let decodedData = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                        print(decodedData)
                        completion(.success(decodedData))
                    }else {

                        print("❌ Error: Status code is \(httpResponse.statusCode)")

                        switch httpResponse.statusCode {

                        case 401:

                            // BASE_URL_2 is a PUBLIC server — its 401 must never
                            // clear the session or redirect to login.
                            if urlString.contains(API.BASE_URL_2) {
                                // Public endpoint — just silently fail, no logout
                                print("⚠️ BASE_URL_2 returned 401 (public endpoint, ignoring auth error)")
                                completion(.failure(.serverError("401")))
                            } else if requiresAuth {
                                // Private endpoint — real session expiry
                                UserDefaults.standard.removeObject(forKey: "ACCESSTOKEN")
                                UserDefaults.standard.removeObject(forKey: "LOGGEDIN")
                                NotificationCenter.default.post(name: Notification.Name("UserSessionExpired"), object: nil)
                                DispatchQueue.main.async {
                                    AlertManager.shared.showAlert(
                                        title: "Session Expired",
                                        message: "Please login again."
                                    )
                                }
                                completion(.failure(.noaccess))
                            } else {
                                completion(.failure(.noaccess))
                            }

                        case 404:
                            // Suppress popup for BASE_URL_2 public endpoints
                            if !urlString.contains(API.BASE_URL_2) {
                                DispatchQueue.main.async {
                                    AlertManager.shared.showAlert(
                                        title: "Not Found",
                                        message: "Requested data not found."
                                    )
                                }
                            } else {
                                print("⚠️ BASE_URL_2 returned 404 for \(urlString)")
                            }
                            completion(.failure(.noData))

                        case 405:
                            // Suppress popup for BASE_URL_2 public endpoints
                            if !urlString.contains(API.BASE_URL_2) {
                                DispatchQueue.main.async {
                                    AlertManager.shared.showAlert(
                                        title: "Method Not Allowed",
                                        message: "Something went wrong. Please try again."
                                    )
                                }
                            } else {
                                print("⚠️ BASE_URL_2 returned 405 for \(urlString)")
                            }
                            completion(.failure(.serverError("405")))

                        case 500:
                            // Suppress popup for BASE_URL_2 public endpoints
                            if !urlString.contains(API.BASE_URL_2) {
                                DispatchQueue.main.async {
                                    AlertManager.shared.showAlert(
                                        title: "Server Error",
                                        message: "Server is temporarily unavailable. Please try again later."
                                    )
                                }
                            } else {
                                print("⚠️ BASE_URL_2 returned 500 for \(urlString)")
                            }
                            completion(.failure(.serverError("500")))

                        default:
                            // Suppress popup for BASE_URL_2 public endpoints
                            if !urlString.contains(API.BASE_URL_2) {
                                DispatchQueue.main.async {
                                    AlertManager.shared.showAlert(
                                        title: "Error",
                                        message: "Unexpected error occurred."
                                    )
                                }
                            } else {
                                print("⚠️ BASE_URL_2 returned \(httpResponse.statusCode) for \(urlString)")
                            }
                            completion(.failure(.serverError("Status Code: \(httpResponse.statusCode)")))
                        }
                    }
                }
            } catch {
                self.logDecodingError(error)
                print("❌ Decoding failed: \(error.localizedDescription)")
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }
    
    func logDecodingError(_ error: Error?) {
        guard let decodingError = error as? DecodingError else {
            print("❌ Non-decoding error:", error)
            return
        }

        switch decodingError {

        case .typeMismatch(let type, let context):
            print("❌ Type mismatch for type:", type)
            print("📍 CodingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
            print("ℹ️ Debug:", context.debugDescription)

        case .valueNotFound(let type, let context):
            print("❌ Value not found for type:", type)
            print("📍 CodingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
            print("ℹ️ Debug:", context.debugDescription)

        case .keyNotFound(let key, let context):
            print("❌ Key not found:", key.stringValue)
            print("📍 CodingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
            print("ℹ️ Debug:", context.debugDescription)

        case .dataCorrupted(let context):
            print("❌ Data corrupted")
            print("📍 CodingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
            print("ℹ️ Debug:", context.debugDescription)

        @unknown default:
            print("❌ Unknown decoding error")
        }
    }

}

struct TestResponsere: Decodable {
    let success: Bool
    let errorCode: Int
    let total : Int?
    let description: String

    enum CodingKeys: String, CodingKey {
        case success, errorCode, description, total
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success     = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        errorCode   = try container.decodeIfPresent(Int.self, forKey: .errorCode) ?? 0
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        total       = try? container.decode(Int.self, forKey: .total)
    }
}

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let errorCode: Int
    let total : Int?
    let description: String
    let data: T?
    
    enum CodingKeys: String, CodingKey {
        case success, errorCode, description, total, data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try container.decodeIfPresent(Int.self, forKey: .errorCode) ?? 0
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        total = try? container.decode(Int.self, forKey: .total)
        // 👇 This safely handles {} or missing fields
        data = try? container.decodeIfPresent(T.self, forKey: .data)
    }
}


struct MobileCheckResponse : Decodable {
    var username : String?
    var profile_pic : String?
    var message : String?
    var password_required : Bool?
    var otp : String?        // Dev backend may return OTP — used for simulator auto-fill
}




struct LoginResponse: Decodable {
    let refreshToken: String
    let accessToken: String
    let isNewUser: Bool
    
    let setNewPassword: Bool
    let user: User

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
        case isNewUser = "is_new_user"
        case setNewPassword = "set_new_password"
        case user
    }
}

struct VerifyOTPResponse: Decodable {
    let access: String
    let refresh: String
    let userId: String
    let schoolId: String?
    let students: [Student]

    enum CodingKeys: String, CodingKey {
        case access, refresh
        case userId = "user_id"
        case schoolId = "school_id"
        case students
    }
}

struct User: Codable {
    let id: String
    let firstName: String?
    let lastName: String?
    let schoolIDs: [String?]
    let username: String
    let profileImage: String?
    let email: String?
    let referralCode: String
    let mobile: Int64?
    let deviceID: String?
    var students : [Student]?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case schoolIDs = "school_ids"
        case username
        case profileImage = "profile_image"
        case email
        case referralCode = "referral_code"
        case mobile
        case deviceID = "device_id"
        case students
    }
    
    // Clean up nulls
    var cleanSchoolIDs: [String] {
        return schoolIDs.compactMap { $0 }
    }

}

// MARK: - Fee Payment Creation Response

struct FeePaymentCreationResponse: Decodable {
    let transactionId: String
    let transactionNumber: String
    let amount: Double
    let token: String
    let orderId: String
    let state: String
    let expireAt: Int64

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case transactionNumber = "transaction_number"
        case amount
        case token
        case orderId = "order_id"
        case state
        case expireAt = "expire_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        transactionId = try container.decodeIfPresent(String.self, forKey: .transactionId) ?? ""
        transactionNumber = try container.decodeIfPresent(String.self, forKey: .transactionNumber) ?? ""
        amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0.0
        token = try container.decodeIfPresent(String.self, forKey: .token) ?? ""
        orderId = try container.decodeIfPresent(String.self, forKey: .orderId) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        expireAt = try container.decodeIfPresent(Int64.self, forKey: .expireAt) ?? 0
    }

    // MARK: - Helpers

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    var expiresAtDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(expireAt / 1000))
    }

    var isExpired: Bool {
        return Date() > expiresAtDate
    }
}

// MARK: - Parent Fee Models
// Endpoint: /fee/student-fee/pending

struct PendingFeeResponse: Decodable {
    let student: PendingFeeStudent
    let fees: [PendingFeeItem]
    let totalPayableAmount: Double

    enum CodingKeys: String, CodingKey {
        case student
        case fees
        case totalPayableAmount = "total_payable_amount"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        student             = try container.decode(PendingFeeStudent.self, forKey: .student)
        fees                = try container.decodeIfPresent([PendingFeeItem].self, forKey: .fees) ?? []
        totalPayableAmount  = try container.decodeIfPresent(Double.self, forKey: .totalPayableAmount) ?? 0.0
    }
}

struct PendingFeeStudent: Decodable {
    let id: String
    let name: String
    let admissionNumber: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case admissionNumber = "admission_number"
    }

    init(from decoder: Decoder) throws {
        let container    = try decoder.container(keyedBy: CodingKeys.self)
        id               = try container.decodeIfPresent(String.self, forKey: .id)              ?? ""
        name             = try container.decodeIfPresent(String.self, forKey: .name)            ?? ""
        admissionNumber  = try container.decodeIfPresent(String.self, forKey: .admissionNumber) ?? ""
    }
}

struct PendingFeeItem: Decodable {
    let studentFeeId: String
    let academicYear: PendingFeeAcademicYear
    let feeType: String
    let installment: String
    let amount: Double
    let concession: Double
    let lateFee: Double
    let paidAmount: Double
    let payableAmount: Double
    let dueDate: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case studentFeeId   = "student_fee_id"
        case academicYear   = "academic_year"
        case feeType        = "fee_type"
        case installment
        case amount
        case concession
        case lateFee        = "late_fee"
        case paidAmount     = "paid_amount"
        case payableAmount  = "payable_amount"
        case dueDate        = "due_date"
        case status
    }

    init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        studentFeeId    = try container.decodeIfPresent(String.self, forKey: .studentFeeId)             ?? ""
        academicYear    = try container.decode(PendingFeeAcademicYear.self, forKey: .academicYear)
        feeType         = try container.decodeIfPresent(String.self, forKey: .feeType)                  ?? ""
        installment     = try container.decodeIfPresent(String.self, forKey: .installment)              ?? ""
        amount          = try container.decodeIfPresent(Double.self, forKey: .amount)                   ?? 0.0
        concession      = try container.decodeIfPresent(Double.self, forKey: .concession)               ?? 0.0
        lateFee         = try container.decodeIfPresent(Double.self, forKey: .lateFee)                  ?? 0.0
        paidAmount      = try container.decodeIfPresent(Double.self, forKey: .paidAmount)               ?? 0.0
        payableAmount   = try container.decodeIfPresent(Double.self, forKey: .payableAmount)            ?? 0.0
        dueDate         = try container.decodeIfPresent(String.self, forKey: .dueDate)                  ?? ""
        status          = try container.decodeIfPresent(String.self, forKey: .status)                   ?? ""
    }

    // MARK: - Helpers

    /// Formatted due date: "10 Jun 2026"
    var formattedDueDate: String {
        let inputFormatter        = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter       = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        if let date = inputFormatter.date(from: dueDate) {
            return outputFormatter.string(from: date)
        }
        return dueDate
    }

    /// ₹3,000
    var formattedPayableAmount: String {
        return "₹\(formatAmount(payableAmount))"
    }

    /// ₹10,000
    var formattedAmount: String {
        return "₹\(formatAmount(amount))"
    }

    /// ₹1,000
    var formattedConcession: String {
        return "₹\(formatAmount(concession))"
    }

    /// ₹7,000
    var formattedPaidAmount: String {
        return "₹\(formatAmount(paidAmount))"
    }

    private func formatAmount(_ value: Double) -> String {
        let formatter                    = NumberFormatter()
        formatter.numberStyle            = .decimal
        formatter.minimumFractionDigits  = 0
        formatter.maximumFractionDigits  = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct PendingFeeAcademicYear: Decodable {
    let id: String
    let name: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id   = try container.decodeIfPresent(String.self, forKey: .id)   ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case id, name
    }
}


// MARK: - PTM Completed Meetings API Models
// Endpoint: /ptm/completed-meetings

// MARK: - PTM Completed Meetings Response Data
struct PTMCompletedMeetingsResponse: Decodable {
    let summary: PTMCompletedSummary
    let meetings: [PTMCompletedMeeting]
}

// MARK: - Summary
struct PTMCompletedSummary: Decodable {
    let totalCompleted: Int
    let attendedCount: Int
    let absentCount: Int

    enum CodingKeys: String, CodingKey {
        case totalCompleted = "total_completed"
        case attendedCount  = "attended_count"
        case absentCount    = "absent_count"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalCompleted = try container.decodeIfPresent(Int.self, forKey: .totalCompleted) ?? 0
        attendedCount  = try container.decodeIfPresent(Int.self, forKey: .attendedCount)  ?? 0
        absentCount    = try container.decodeIfPresent(Int.self, forKey: .absentCount)    ?? 0
    }
}

// MARK: - PTM Completed Meeting
struct PTMCompletedMeeting: Decodable {
    let id: String
    let title: String
    let meetingType: String
    let meetingDate: String
    let startTime: String
    let endTime: String
    let meetingMode: String
    let location: String?
    let meetingLink: String?
    let attendanceStatus: String
    let isAttended: Bool
    let attendedAt: String?
    let remarks: String?
    let staffs: [PTMCompletedStaff]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case meetingType      = "meeting_type"
        case meetingDate      = "meeting_date"
        case startTime        = "start_time"
        case endTime          = "end_time"
        case meetingMode      = "meeting_mode"
        case location
        case meetingLink      = "meeting_link"
        case attendanceStatus = "attendance_status"
        case isAttended       = "is_attended"
        case attendedAt       = "attended_at"
        case remarks
        case staffs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id               = try container.decode(String.self, forKey: .id)
        title            = try container.decodeIfPresent(String.self, forKey: .title)            ?? ""
        meetingType      = try container.decodeIfPresent(String.self, forKey: .meetingType)      ?? ""
        meetingDate      = try container.decodeIfPresent(String.self, forKey: .meetingDate)      ?? ""
        startTime        = try container.decodeIfPresent(String.self, forKey: .startTime)        ?? ""
        endTime          = try container.decodeIfPresent(String.self, forKey: .endTime)          ?? ""
        meetingMode      = try container.decodeIfPresent(String.self, forKey: .meetingMode)      ?? ""
        location         = try container.decodeIfPresent(String.self, forKey: .location)
        meetingLink      = try container.decodeIfPresent(String.self, forKey: .meetingLink)
        attendanceStatus = try container.decodeIfPresent(String.self, forKey: .attendanceStatus) ?? "NOT_MARKED"
        isAttended       = try container.decodeIfPresent(Bool.self,   forKey: .isAttended)       ?? false
        attendedAt       = try container.decodeIfPresent(String.self, forKey: .attendedAt)
        remarks          = try container.decodeIfPresent(String.self, forKey: .remarks)
        staffs           = try container.decodeIfPresent([PTMCompletedStaff].self, forKey: .staffs) ?? []
    }

    // MARK: - Formatted date helper
    var formattedDate: String {
        let inputFormatter        = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter       = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        if let date = inputFormatter.date(from: meetingDate) {
            return outputFormatter.string(from: date)
        }
        return meetingDate
    }

    // MARK: - Formatted time range helper
    var formattedTimeRange: String {
        let inputFormatter        = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        let outputFormatter       = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"

        let start = inputFormatter.date(from: startTime).map {
            outputFormatter.string(from: $0)
        } ?? startTime

        let end = inputFormatter.date(from: endTime).map {
            outputFormatter.string(from: $0)
        } ?? endTime

        return "\(start) - \(end)"
    }

    // MARK: - Attendance status display text
    var attendanceStatusDisplayText: String {
        switch attendanceStatus.uppercased() {
        case "ATTENDED":    return "Attended"
        case "ABSENT":      return "Absent"
        case "NOT_MARKED":  return "Not Marked"
        default:            return attendanceStatus
        }
    }

    // MARK: - Host staff helper
    var hostStaff: PTMCompletedStaff? {
        return staffs.first(where: { $0.isHost })
    }

    // MARK: - Non-host staffs helper
    var nonHostStaffs: [PTMCompletedStaff] {
        return staffs.filter { !$0.isHost }
    }
}

// MARK: - PTM Completed Staff (no profile_image field in completed API)
struct PTMCompletedStaff: Decodable {
    let id: String
    let name: String
    let staffType: String
    let isHost: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case staffType = "staff_type"
        case isHost    = "is_host"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id        = try container.decode(String.self, forKey: .id)
        name      = try container.decodeIfPresent(String.self, forKey: .name)      ?? ""
        staffType = try container.decodeIfPresent(String.self, forKey: .staffType) ?? ""
        isHost    = try container.decodeIfPresent(Bool.self,   forKey: .isHost)    ?? false
    }
}

// MARK: - PTM Response Data

// MARK: - PTM Class Teacher
struct PTMClassTeacher: Decodable {
    let id: String
    let name: String
}

// MARK: - PTM Student
struct PTMStudent: Decodable {
    let id: String
    let name: String
    let admissionNumber: String
    let classTeacher: PTMClassTeacher?  // ✅ Fixed: Object not String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case admissionNumber = "admission_number"
        case classTeacher    = "class_teacher"
    }
}

// MARK: - PTM Staff
struct PTMStaff: Decodable {
    let id: String
    let name: String
    let staffType: String
    let profileImage: String?
    let isHost: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case staffType    = "staff_type"
        case profileImage = "profile_image"
        case isHost       = "is_host"
    }
}

// MARK: - PTM Meeting
struct PTMMeeting: Decodable {
    let id: String
    let title: String
    let description: String
    let meetingType: String
    let meetingDate: String
    let startTime: String
    let endTime: String
    let meetingMode: String
    let location: String?
    let meetingLink: String?
    let status: String
    let academicYear: PTMIdName
    let branch: PTMIdName
    let grade: PTMIdName
    let section: PTMIdName
    let staffs: [PTMStaff]
    let response: PTMMeetingResponse?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case meetingType  = "meeting_type"
        case meetingDate  = "meeting_date"
        case startTime    = "start_time"
        case endTime      = "end_time"
        case meetingMode  = "meeting_mode"
        case location
        case meetingLink  = "meeting_link"
        case status
        case academicYear = "academic_year"
        case branch
        case grade
        case section
        case staffs
        case response
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id           = try container.decode(String.self, forKey: .id)
        title        = try container.decodeIfPresent(String.self, forKey: .title)       ?? ""
        description  = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        meetingType  = try container.decodeIfPresent(String.self, forKey: .meetingType) ?? ""
        meetingDate  = try container.decodeIfPresent(String.self, forKey: .meetingDate) ?? ""
        startTime    = try container.decodeIfPresent(String.self, forKey: .startTime)   ?? ""
        endTime      = try container.decodeIfPresent(String.self, forKey: .endTime)     ?? ""
        meetingMode  = try container.decodeIfPresent(String.self, forKey: .meetingMode) ?? ""
        location     = try container.decodeIfPresent(String.self, forKey: .location)
        meetingLink  = try container.decodeIfPresent(String.self, forKey: .meetingLink)
        status       = try container.decodeIfPresent(String.self, forKey: .status)      ?? ""
        academicYear = try container.decode(PTMIdName.self, forKey: .academicYear)
        branch       = try container.decode(PTMIdName.self, forKey: .branch)
        grade        = try container.decode(PTMIdName.self, forKey: .grade)
        section      = try container.decode(PTMIdName.self, forKey: .section)
        staffs       = try container.decodeIfPresent([PTMStaff].self, forKey: .staffs)  ?? []
        response     = try container.decodeIfPresent(PTMMeetingResponse.self, forKey: .response)
    }

    // MARK: - Formatted date helper
    var formattedDate: String {
        let inputFormatter        = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter        = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        if let date = inputFormatter.date(from: meetingDate) {
            return outputFormatter.string(from: date)
        }
        return meetingDate
    }

    // MARK: - Formatted time range helper
    var formattedTimeRange: String {
        let inputFormatter        = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        let outputFormatter        = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"

        let start = inputFormatter.date(from: startTime).map {
            outputFormatter.string(from: $0)
        } ?? startTime

        let end = inputFormatter.date(from: endTime).map {
            outputFormatter.string(from: $0)
        } ?? endTime

        return "\(start) - \(end)"
    }

    // MARK: - Host staff helper
    var hostStaff: PTMStaff? {
        return staffs.first(where: { $0.isHost })
    }

    // MARK: - Non-host staffs helper
    var nonHostStaffs: [PTMStaff] {
        return staffs.filter { !$0.isHost }
    }
}

// MARK: - Reusable Id + Name object
struct PTMIdName: Decodable {
    let id: String
    let name: String
}

// MARK: - Meeting Response (parent RSVP)
struct PTMMeetingResponse: Decodable {
    let responseStatus: String
    let respondedAt: String?
    let remarks: String?

    enum CodingKeys: String, CodingKey {
        case responseStatus = "response_status"
        case respondedAt    = "responded_at"
        case remarks
    }

    var statusDisplayText: String {
        switch responseStatus {
        case "ATTENDING":     return "Attending"
        case "NOT_ATTENDING": return "Not Attending"
        case "MAYBE":         return "Maybe"
        default:              return responseStatus
        }
    }
}

// MARK: - PTM Response Data
struct PTMResponseData: Decodable {
    let student: PTMStudent
    let meetings: [PTMMeeting]
}
struct School: Codable {
    let schoolID: String
    let schoolName: String
    let smallLogo: String?
    let fullLogo: String?
    let district: String?
    let state: String?
    let coverPic: String?
    let address: String?
    let phoneNumber: String?
    let website: String?
    let email: String?
    let mapLink: String?
    let latitude: String?
    let longitude: String?
    
    enum CodingKeys: String, CodingKey {
        case schoolID = "school_id"
        case schoolName = "school_name"
        case smallLogo = "small_logo"
        case fullLogo = "full_logo"
        case district, state
        case coverPic = "cover_pic"
        case address
        case phoneNumber = "phone_number"
        case website, email
        case mapLink = "map_link"
        case latitude, longitude
        // Fallback keys for verify-otp API which returns "id"/"name"
        case id, name
    }
    
    // ✅ Custom init to handle both "school_id"/"school_name" and "id"/"name" formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try "school_id" first, fall back to "id"
        if let sid = try? container.decode(String.self, forKey: .schoolID) {
            schoolID = sid
        } else {
            schoolID = try container.decode(String.self, forKey: .id)
        }
        // Try "school_name" first, fall back to "name"
        if let sname = try? container.decode(String.self, forKey: .schoolName) {
            schoolName = sname
        } else {
            schoolName = (try? container.decode(String.self, forKey: .name)) ?? ""
        }
        smallLogo = try container.decodeIfPresent(String.self, forKey: .smallLogo)
        fullLogo = try container.decodeIfPresent(String.self, forKey: .fullLogo)
        district = try container.decodeIfPresent(String.self, forKey: .district)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        coverPic = try container.decodeIfPresent(String.self, forKey: .coverPic)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        mapLink = try container.decodeIfPresent(String.self, forKey: .mapLink)
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schoolID, forKey: .schoolID)
        try container.encode(schoolName, forKey: .schoolName)
        try container.encodeIfPresent(smallLogo, forKey: .smallLogo)
        try container.encodeIfPresent(fullLogo, forKey: .fullLogo)
        try container.encodeIfPresent(district, forKey: .district)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(coverPic, forKey: .coverPic)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(mapLink, forKey: .mapLink)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
    }
}
struct Course: Codable {
    let id: String
    let name: String
    let description: String
    let duration: Int
    let hosts: [String]
    let thumbnailImage: String
    let profileImage: String
    let videos: [String]           // Full course videos
    let demoVideo: [String]?       // This is an array!
    let images: [String]
    let courseFee: String
    let finalCourseFee: String
    let audience: String
    let language: String
    let enrollments: Int
    let numberOfChapters: Int
    let numberOfLessons: Int
    let completions: Int
    let trending: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, description, duration, hosts, videos, images, audience, language, enrollments, completions, trending
        case thumbnailImage = "thumbnail_image"
        case profileImage = "profile_image"
        case courseFee = "course_fee"
        case finalCourseFee = "final_course_fee"
        case numberOfChapters = "number_of_chapters"
        case numberOfLessons = "number_of_lessons"
        case demoVideo = "demo_video"           // Maps correctly
    }
}

import Foundation

// MARK: - Feed
struct Feed: Codable {
    let id: String
    let heading: String
    let trending: Bool
    let feedType: String
    let categories: [String]?
    let image: String?
    let remarks: String?
    let schoolId: String?
    let video: String?
    let youtubeVideo: String?
    let description: String
    let description_2: String?
    var likesCount: Int
    var commentsCount: Int
    var whatsappShareCount: Int
    let language: String
    let duration: Int
    let postingDate: String
    let approvedBy: String?
    let approvedTime: String?
    let status: String
    let skill_tested: String?
    let lesson: String?
    let subject: String?
    let grade_id: String?
    let serial_number: Int
    var isLiked: Bool
    var shareCount: Int?
    let f_category: String?

    enum CodingKeys: String, CodingKey {
        case id, heading, trending, categories, image, remarks, video, description, language, duration, status, description_2, serial_number, grade_id, subject, lesson, skill_tested
        case feedType = "feed_type"
        case schoolId = "school_id"
        case youtubeVideo = "youtube_video"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case whatsappShareCount = "whatsapp_share_count"
        case postingDate = "posting_date"
        case approvedBy = "approved_by"
        case approvedTime = "approved_time"
        case isLiked = "is_liked"
        case shareCount = "share_count"
        case f_category
    }
    
    // MARK: - Custom Decoder (Handles missing is_liked field)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decode(String.self, forKey: .id)
        heading = try container.decode(String.self, forKey: .heading)
        description = try container.decode(String.self, forKey: .description)
        trending = try container.decodeIfPresent(Bool.self, forKey: .trending) ?? false
        feedType = try container.decodeIfPresent(String.self, forKey: .feedType) ?? "Image"
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "Published"
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? "English"
        duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0
        postingDate = try container.decodeIfPresent(String.self, forKey: .postingDate) ?? ""
        serial_number = try container.decodeIfPresent(Int.self, forKey: .serial_number) ?? 0
        
        // Optional fields
        categories = try container.decodeIfPresent([String].self, forKey: .categories)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)
        schoolId = try container.decodeIfPresent(String.self, forKey: .schoolId)
        video = try container.decodeIfPresent(String.self, forKey: .video)
        youtubeVideo = try container.decodeIfPresent(String.self, forKey: .youtubeVideo)
        description_2 = try container.decodeIfPresent(String.self, forKey: .description_2)
        approvedBy = try container.decodeIfPresent(String.self, forKey: .approvedBy)
        approvedTime = try container.decodeIfPresent(String.self, forKey: .approvedTime)
        skill_tested = try container.decodeIfPresent(String.self, forKey: .skill_tested)
        lesson = try container.decodeIfPresent(String.self, forKey: .lesson)
        subject = try container.decodeIfPresent(String.self, forKey: .subject)
        grade_id = try container.decodeIfPresent(String.self, forKey: .grade_id)
        f_category = try container.decodeIfPresent(String.self, forKey: .f_category)
        
        // Counts - default to 0 if missing
        likesCount = try container.decodeIfPresent(Int.self, forKey: .likesCount) ?? 0
        commentsCount = try container.decodeIfPresent(Int.self, forKey: .commentsCount) ?? 0
        whatsappShareCount = try container.decodeIfPresent(Int.self, forKey: .whatsappShareCount) ?? 0
        shareCount = try container.decodeIfPresent(Int.self, forKey: .shareCount)
        
        //  KEY FIX: is_liked defaults to false if missing in search API
        isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
    }
    
    // MARK: - Encoder (for Codable conformance)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(heading, forKey: .heading)
        try container.encode(description, forKey: .description)
        try container.encode(trending, forKey: .trending)
        try container.encode(feedType, forKey: .feedType)
        try container.encode(status, forKey: .status)
        try container.encode(language, forKey: .language)
        try container.encode(duration, forKey: .duration)
        try container.encode(postingDate, forKey: .postingDate)
        try container.encode(serial_number, forKey: .serial_number)
        try container.encode(likesCount, forKey: .likesCount)
        try container.encode(commentsCount, forKey: .commentsCount)
        try container.encode(whatsappShareCount, forKey: .whatsappShareCount)
        try container.encode(isLiked, forKey: .isLiked)
        
        try container.encodeIfPresent(categories, forKey: .categories)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(remarks, forKey: .remarks)
        try container.encodeIfPresent(schoolId, forKey: .schoolId)
        try container.encodeIfPresent(video, forKey: .video)
        try container.encodeIfPresent(youtubeVideo, forKey: .youtubeVideo)
        try container.encodeIfPresent(description_2, forKey: .description_2)
        try container.encodeIfPresent(approvedBy, forKey: .approvedBy)
        try container.encodeIfPresent(approvedTime, forKey: .approvedTime)
        try container.encodeIfPresent(skill_tested, forKey: .skill_tested)
        try container.encodeIfPresent(lesson, forKey: .lesson)
        try container.encodeIfPresent(subject, forKey: .subject)
        try container.encodeIfPresent(grade_id, forKey: .grade_id)
        try container.encodeIfPresent(f_category, forKey: .f_category)
        try container.encodeIfPresent(shareCount, forKey: .shareCount)
    }
}

struct Event: Codable {
    let id: String
    let gradeIds: [String]
    let schoolId: String
    let name: String
    let description: String
    let date: String
    let time: String
    let image: String
    let colourCode: String

    enum CodingKeys: String, CodingKey {
        case id
        case gradeIds = "grade_ids"
        case schoolId = "school_id"
        case name
        case description
        case date
        case time,image
        case colourCode = "colour_code"
        
    }
}

import Foundation

struct LifeSkillPrompt: Codable {
    let id: String
    let date: String
    let prompt: String
    let benefit: String
    let youtubeVideoURL: String
    let description: String
    let image: String

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case prompt
        case benefit
        case youtubeVideoURL = "youtube_video_url"
        case description
        case image
    }
}

struct ReadingShort: Codable, Identifiable {
    let id: String
    let youtubeVideo: String
    let title: String
    let description: String
    let likesCount: Int
    let shareCount: Int
    let viewsCount: Int
    let score: Double
    let category: String
    let isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case youtubeVideo = "youtube_video"
        case title
        case description
        case likesCount = "likes_count"
        case shareCount = "share_count"
        case viewsCount = "views_count"
        case score
        case category
        case isLiked = "is_liked"
    }
}

// MARK: - Convenience helpers
extension ReadingShort {
    /// Returns the YouTube video ID for shorts URLs like:
    /// https://youtube.com/shorts/CtpIHuL2r-c
    var youtubeID: String? {
        guard let url = URL(string: youtubeVideo) else { return nil }
        let parts = url.pathComponents // ["\/", "shorts", "CtpIHuL2r-c"]
        if parts.count >= 3, parts[1] == "shorts" { return parts[2] }
        // fallback for watch?v= style links
        if let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let v = comps.queryItems?.first(where: { $0.name == "v" })?.value {
            return v
        }
        return nil
    }

    var youtubeURL: URL? { URL(string: youtubeVideo) }
}


struct Banner: Codable {
    let id: String
    let screen: String
    let image: String
    let status: String
    let schoolId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case screen
        case image
        case status
        case schoolId = "school_id"
    }
}


// MARK: - Cache Keys Using Associated Objects
private struct BulletinHTMLCacheKeys {
    static var descKey = "BulletinHTMLCacheKeys_descKey"
    static var titleKey = "BulletinHTMLCacheKeys_titleKey"
}


class Bulletin: Codable {
    let id: String
    let title: String
    let description: String?
    let categories: [String]?
    let tags: [String]?
    let targetGroups: [String]?
    let schoolId: String
    let gradeIds: [String]
    let images: [String]?
    let videos: [String]?
    let youtubeUrls: [String]?
    let status: String
    let remarks: String?
    let reason: String?
    let sections: [String]?
    let likesCount: Int
    let reporterId: String
    let createdAt: String
    let updatedAt: String
    let approvedAt: String?
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case categories
        case tags
        case targetGroups = "target_groups"
        case schoolId = "school_id"
        case gradeIds = "grade_ids"
        case images
        case videos
        case youtubeUrls = "youtube_urls"
        case status
        case remarks
        case reason
        case sections
        case likesCount = "likes_count"
        case reporterId = "reporter_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case approvedAt = "approved_at"
        case isLiked = "is_liked"
    }
}

extension Bulletin {
    var cachedDescriptionHTML: NSAttributedString? {
        get {
            objc_getAssociatedObject(self, &BulletinHTMLCacheKeys.descKey) as? NSAttributedString
        }
        set {
            objc_setAssociatedObject(self,
                                     &BulletinHTMLCacheKeys.descKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Cached Title HTML
    var cachedTitleHTML: NSAttributedString? {
        get {
            objc_getAssociatedObject(self, &BulletinHTMLCacheKeys.titleKey) as? NSAttributedString
        }
        set {
            objc_setAssociatedObject(self,
                                     &BulletinHTMLCacheKeys.titleKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func prepareHTMLForRendering() {
        // Convert description HTML
        if let desc = self.description {
            self.cachedDescriptionHTML = NSAttributedString.fromHTML(
                desc,
                regularFont: .lexend(.regular, size: 12),
                boldFont: .lexend(.semiBold, size: 14),
                italicFont: .lexend(.regular, size: 14),
                textColor: .black
            )
        }
        
        // Convert title HTML
        self.cachedTitleHTML = NSAttributedString.fromHTML(
            self.title,
            regularFont: .lexend(.semiBold, size: 16),
            boldFont: .lexend(.semiBold, size: 16),
            italicFont: .lexend(.regular, size: 14),
            textColor: .black
        )
    }
    
}

struct Homework: Codable {
    let id: String
    let school: String
    let schoolName: String
    let grade: String
    let gradeName: String
    let homeworkDate: String
    let homeworkDetails: [HomeworkDetail]
    var homeworkTrackerDetails: [HomeworkTrackerDetail]
    let deadline: String
    let doneCount: Int
    let homeworkType: String

    enum CodingKeys: String, CodingKey {
        case id
        case school
        case schoolName = "school_name"
        case grade
        case gradeName = "grade_name"
        case homeworkDate = "homework_date"
        case homeworkDetails = "homework_details"
        case homeworkTrackerDetails = "homework_tracker_details"
        case deadline
        case doneCount = "done_count"
        case homeworkType = "homework_type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        school = try container.decodeIfPresent(String.self, forKey: .school) ?? ""
        schoolName = try container.decodeIfPresent(String.self, forKey: .schoolName) ?? ""
        grade = try container.decodeIfPresent(String.self, forKey: .grade) ?? ""
        gradeName = try container.decodeIfPresent(String.self, forKey: .gradeName) ?? ""
        homeworkDate = try container.decodeIfPresent(String.self, forKey: .homeworkDate) ?? ""
        homeworkDetails = try container.decodeIfPresent([HomeworkDetail].self, forKey: .homeworkDetails) ?? []
        homeworkTrackerDetails = try container.decodeIfPresent([HomeworkTrackerDetail].self, forKey: .homeworkTrackerDetails) ?? []
        deadline = try container.decodeIfPresent(String.self, forKey: .deadline) ?? ""
        doneCount = try container.decodeIfPresent(Int.self, forKey: .doneCount) ?? 0
        homeworkType = try container.decodeIfPresent(String.self, forKey: .homeworkType) ?? ""
    }
}

struct HomeworkDetail: Codable {
    let subject: String
    let description: String
}

struct HomeworkTrackerDetail: Codable {
    let id: String
    let userId: String
    let subject: String
    let description: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case subject
        case description
        case status
    }
}

struct DashboardResponse: Codable {
    let homework: [Homework]
    let news: [Bulletin]
    let banners: [Banner]
    let calendar: [LifeSkillPrompt]
}
struct EventGallery: Codable {
    let id: String
    let eventName: String
    let eventDate: String
    let schoolId: String
    let description: String
    let numberOfPics: Int
    let expiryDate: String?
    let thumbnailImages: [String]
    let images: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case eventName = "event_name"
        case eventDate = "event_date"
        case schoolId = "school_id"
        case description
        case numberOfPics = "number_of_pics"
        case expiryDate = "expiry_date"
        case thumbnailImages = "thumbnail_images"
        case images
    }
}

struct EmptyResponse: Codable {
    
}


struct SchoolInfo: Codable {
    let id: String
    let title: String
    let school: String
    let shortDescription: String
    let longDescription: String
    let image: String
    let purpose: String?
    let aboutUs: String?
    let priority: Int
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case school
        case shortDescription = "short_description"
        case longDescription = "long_description"
        case image
        case purpose
        case aboutUs = "about_us"
        case priority
        case status
    }
}

struct GradeModel: Codable {
    let id: String
    let schoolID: String?
    let name: String
    let section: String
    let numericGrade: Int

    enum CodingKeys: String, CodingKey {
        case id
        case schoolID = "school_id"
        case name
        case section
        case numericGrade = "numeric_grade"
    }
}

struct GradeSubject: Codable {
    let id: String
    let subjectName: String
    let subjectImage: String
    let categoryId: String
    let gradeIds: [String]
    let gradeName: String
    let numberOfLessons: Int
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case subjectName = "subject_name"
        case subjectImage = "subject_image"
        case categoryId = "category_id"
        case gradeIds = "grade_ids"
        case gradeName = "grade_name"
        case numberOfLessons = "number_of_lessons"
        case status
    }
}



struct Lesson: Codable {
    let id: String
    let lessonName: String
    let categoryId: String
    let subjectId: String
    let gradeId: String
    let numberOfConcepts: Int
    let description: String
    let status: String
    let subscription: String
    var selected : Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case lessonName = "lesson_name"
        case categoryId = "category_id"
        case subjectId = "subject_id"
        case gradeId = "grade_id"
        case numberOfConcepts = "number_of_concepts"
        case description
        case status
        case subscription, selected
    }
    init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          id = try container.decode(String.self, forKey: .id)
          lessonName = try container.decode(String.self, forKey: .lessonName)
          categoryId = try container.decode(String.self, forKey: .categoryId)
          subjectId = try container.decode(String.self, forKey: .subjectId)
          gradeId = try container.decode(String.self, forKey: .gradeId)
          numberOfConcepts = try container.decode(Int.self, forKey: .numberOfConcepts)
          description = try container.decode(String.self, forKey: .description)
          status = try container.decode(String.self, forKey: .status)
          subscription = try container.decode(String.self, forKey: .subscription)
          selected = try container.decodeIfPresent(Bool.self, forKey: .selected) ?? false
      }
}

struct FeelItem: Identifiable, Codable, Hashable {
    let id: String
    let youtubeVideo: URL?
    let title: String
    let description: String
    let thumbnailImage: String?
    let likesCount: Int
    let shareCount: Int
    let viewsCount: Int
    let score: Int
    let category: String
    var isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case youtubeVideo = "youtube_video"
        case title
        case description
        case thumbnailImage = "thumbnail_image"
        case likesCount = "likes_count"
        case shareCount = "share_count"
        case viewsCount = "views_count"
        case score
        case category
        case isLiked = "is_liked"
    }
}

struct Curriculum: Codable, Identifiable {
    let id: String
    let curriculumName: String
    let description: String?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case curriculumName = "curriculum_name"
        case description
        case status
    }
}


struct CurriculumCategory: Codable, Identifiable {
    let id: String
    let categoryName: String
    let categoryImage: String
    let gradeIDs: [String]
    let curriculumID: String
    let curriculumName: String
    let status: String
    let gradeName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case categoryName = "category_name"
        case categoryImage = "category_image"
        case gradeIDs = "grade_ids"
        case curriculumID = "curriculum_id"
        case curriculumName = "curriculum_name"
        case status
        case gradeName = "grade_name"
    }
}

struct LessonConcept: Codable, Identifiable {
    let id: String
    let lessonID: String
    let title: String
    let description: String
    let pdfURL: URL?
    let images: [URL]
    let videos: [URL]?
    let youtubeURLs: [URL]?
    let tags: [String]
    let status: String
    let priority: Int
    let curriculumName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case lessonID = "lesson_id"
        case title
        case description
        case pdfURL = "pdf"
        case images
        case videos
        case youtubeURLs = "youtube_urls"
        case tags
        case status
        case priority
        case curriculumName = "curriculum_name"
    }
}

struct VocabeeDate: Codable {
    let date: String
    let totalWords: Int
    let minutes: Int
    let attemptedWords: Int
    let pointsEarned: Int
    let totalPoints: Int
    
    enum CodingKeys: String, CodingKey {
            case date
            case totalWords = "total_words"
            case minutes
            case attemptedWords = "attempted_words"
            case pointsEarned = "points_earned"
            case totalPoints = "total_points"
        }
}

struct WordInfo: Codable {
    let id: String
    let word: String
    let definition: String
    let points: Int
    let usage: String
    let origin: String
    let partsOfSpeech: String?
    let others: String?
    let othersVoice: String?
    let pronunciation: String = ""
    let partsOfSpeechVoice: String = ""
    let definitionVoice: String = ""
    let originVoice: String = ""
    let usageVoice: String = ""
    let date: String?

    enum CodingKeys: String, CodingKey {
        case id
        case word
        case definition
        case points
        case usage
        case origin
        case partsOfSpeech = "parts_of_speech"
        case others
        case othersVoice = "others_voice"
        case pronunciation
        case partsOfSpeechVoice = "parts_of_speech_voice"
        case definitionVoice = "definition_voice"
        case originVoice = "origin_voice"
        case usageVoice = "usage_voice"
        case date
    }
}

struct WordAnswer: Codable {
    let wordId: String
    let userAnswer: String?
    let correctAnswer: String
    let isCorrect: Bool
    let points: Int
    let earned_points: Int
    let total_points: Int
    
    enum CodingKeys: String, CodingKey {
        case wordId = "word_id"
        case userAnswer = "user_answer"
        case correctAnswer = "correct_answer"
        case isCorrect = "is_correct"
        case points, earned_points, total_points
    }
}


// MARK: - Fee


struct StudentFeeDetails: Codable {
    let studentUUID: String
    let studentID: String
    let studentFeeID: String
    let studentName: String
    let studentImage: String?
    let gradeID: String
    let gradeName: String
    let sectionName: String
    let academicYear: String
    let totalFee: Double
    let feePaid: Double
    let pendingFee: Double
    let totalFine: Double
    let finePayable: Double
    let finePaid: Double
    let initialDiscount: Double
    let specialDiscount: Double
    let feeInstallments: [FeeInstallment]
    
    enum CodingKeys: String, CodingKey {
        case studentUUID = "student_uuid"
        case studentID = "student_id"
        case studentFeeID = "student_fee_id"
        case studentName = "student_name"
        case studentImage = "student_image"
        case gradeID = "grade_id"
        case gradeName = "grade_name"
        case sectionName = "section_name"
        case academicYear = "academic_year"
        case totalFee = "total_fee"
        case feePaid = "fee_paid"
        case pendingFee = "pending_fee"
        case totalFine = "total_fine"
        case finePayable = "fine_payable"
        case finePaid = "fine_paid"
        case initialDiscount = "initial_discount"
        case specialDiscount = "special_discount"
        case feeInstallments = "fee_installments"
    }
}

struct FeeInstallment: Codable {
    let installmentNo: Int
    let amount: Double
    let payableAmount: Double
    let feePaid: Double
    let initialDiscount: Double
    let specialDiscount: Double
    let fineAmount: Double
    let fineDays: Int
    let finePerDay: Double
    let dueDate: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case installmentNo = "installment_no"
        case amount
        case payableAmount = "payable_amount"
        case feePaid = "fee_paid"
        case initialDiscount = "initial_discount"
        case specialDiscount = "special_discount"
        case fineAmount = "fine_amount"
        case fineDays = "fine_days"
        case finePerDay = "fine_per_day"
        case dueDate = "due_date"
    }
}
extension FeeInstallment {
    
    var isPaid: Bool {
        return feePaid >= payableAmount
    }
    
    var pendingAmount: Double {
        return payableAmount - feePaid
    }
    
    var isPartiallyPaid: Bool {
        return feePaid > 0 && feePaid < payableAmount
    }
    
    
    /// Calculate fine per day (if API returns 0, calculate from fineAmount/fineDays)
    var calculatedFinePerDay: Double {
        if finePerDay > 0 {
            return finePerDay
        } else if fineDays > 0 && fineAmount > 0 {
            return fineAmount / Double(fineDays)
        }
        return 0.0
    }
    
    /// Check if fine is applicable
    var hasFine: Bool {
        return fineAmount > 0 && fineDays > 0
    }
    
    /// Formatted fine text: "+ Fine (₹5 × 246 Days)"
    var fineDisplayText: String {
        guard hasFine else {
            return "Fine"
        }
        
        let perDay = calculatedFinePerDay
        let daysText = fineDays == 1 ? "Day" : "Days"
        
        return "+ Fine (₹\(formatAmount(perDay)) × \(fineDays) \(daysText))"
    }
    
    /// Fine display text with total amount: "+ Fine (₹5 × 246 Days = ₹1230)"
    var fineDisplayTextWithTotal: String {
        guard hasFine else {
            return "Fine"
        }
        
        let perDay = calculatedFinePerDay
        let daysText = fineDays == 1 ? "Day" : "Days"
        
        return "+ Fine (₹\(formatAmount(perDay)) × \(fineDays) \(daysText) = ₹\(formatAmount(fineAmount)))"
    }
    
    
    /// Convert TimeInterval to formatted date string
    func dueDateFormatted() -> String {
        let date = Date(timeIntervalSince1970: dueDate / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    func dueDateMonthYear() -> String {
        let date = Date(timeIntervalSince1970: dueDate / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    /// Check if due date has passed
    var isOverdue: Bool {
        let date = Date(timeIntervalSince1970: dueDate / 1000)
        return Date() > date && !isPaid
    }
    
    /// Days until due date (negative if overdue)
    var daysUntilDue: Int {
        let date = Date(timeIntervalSince1970: dueDate / 1000)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: date)
        return components.day ?? 0
    }
    
    // MARK: - Private Helpers
    
    private func formatAmount(_ amount: Double) -> String {
        if amount == amount.rounded() {
            return String(format: "%.0f", amount)
        } else {
            return String(format: "%.2f", amount)
        }
    }
}


class Attendance : Codable {
    let attendanceId: String
    let studentId: String
    let gradeId: String
    let totalDays: Int
    let absentDays: Int
    let presentDays: Int

    enum CodingKeys: String, CodingKey {
        case attendanceId = "attendance_id"
        case studentId = "student_id"
        case gradeId = "grade_id"
        case totalDays = "total_days"
        case absentDays = "absent_days"
        case presentDays = "present_days"
    }
}


struct Leave: Codable, Identifiable {
    let id: String
    let studentId: String
    let gradeId: String
    let fromDate: String
    let toDate: String
    let totalDays: Double
    let reasonType: String?
    let reason: String?
    let leaveStatus: String?
    let teacherRemarks: String?
    let leaveDays: [String: LeaveDay]
    enum CodingKeys: String, CodingKey {
        case id
        case studentId = "student_id"
        case gradeId = "grade_id"
        case fromDate = "from_date"
        case toDate = "to_date"
        case totalDays = "total_days"
        case reasonType = "reason_type"
        case reason
        case leaveStatus = "leave_status"
        case teacherRemarks = "teacher_remarks"
        case leaveDays = "leave_days"
    }
}

struct LeaveDay: Codable {
    let dayType: String
    let sessionType: String

    enum CodingKeys: String, CodingKey {
        case dayType = "day_type"
        case sessionType = "session_type"
    }
}



struct Assessment: Codable {
    let id: String
    let gradeID: String
    let gradeName: String
    let subjectID: String
    let subjectName: String
    let name: String
    let description: String
    let numberOfQuestions: Int
    let attemptedQuestions: Int
    let isEvaluationRequired: Bool
    let totalMarks: Int
    let status: String
    let questions: [AssessmentQuestion]

    enum CodingKeys: String, CodingKey {
        case id
        case gradeID = "grade_id"
        case gradeName = "grade_name"
        case subjectID = "subject_id"
        case subjectName = "subject_name"
        case name
        case description
        case numberOfQuestions = "number_of_questions"
        case attemptedQuestions = "attempted_questions"
        case isEvaluationRequired = "is_evaluation_required"
        case totalMarks = "total_marks"
        case status
        case questions
    }
}

struct AssessmentQuestion: Codable {
    let id: String
    let questionType: String
    let question: String
    let options: [String]
    let answer: String
    let description: String
    let marks: Int
    let subjectID: String
    let gradeID: String
    let hint: String
    let skillTested: String
    let levelOfDifficulty: Int

    enum CodingKeys: String, CodingKey {
        case id
        case questionType = "question_type"
        case question
        case options
        case answer
        case description
        case marks
        case subjectID = "subject_id"
        case gradeID = "grade_id"
        case hint
        case skillTested = "skill_tested"
        case levelOfDifficulty = "level_of_difficulty"
    }
}
struct AssessmentAnswerResponse: Codable {
    let id: String
    let questionId: String
    let assessmentId: String
    let userId: String
    let studentId: String
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let marks: Int
    let totalMarks: Int
    let attemptedQuestions: Int
    let correctQuestions: Int
    let wrongQuestions: Int
    let skippedQuestions: Int
    let totalQuestions: Int
    let assessmentStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case assessmentId = "assessment_id"
        case userId = "user_id"
        case studentId = "student_id"
        case userAnswer = "user_answer"
        case correctAnswer = "correct_answer"
        case isCorrect = "is_correct"
        case marks
        case totalMarks = "total_marks"
        case attemptedQuestions = "attempted_questions"
        case correctQuestions = "correct_questions"
        case wrongQuestions = "wrong_questions"
        case skippedQuestions = "skipped_questions"
        case totalQuestions = "total_questions"
        case assessmentStatus = "assessment_status"
    }
}

struct AssessmentSummary: Codable {
    let assessmentId: String
    let assessmentName: String
    let description: String
    let numberOfQuestions: Int
    let totalMarks: Int
    let studentMarks: Int
    let status: String

    enum CodingKeys: String, CodingKey {
        case assessmentId = "assessment_id"
        case assessmentName = "assessment_name"
        case description
        case numberOfQuestions = "number_of_questions"
        case totalMarks = "total_marks"
        case studentMarks = "student_marks"
        case status
    }
}


struct AssessmentResult: Codable {
    let assessmentID: String
    let studentID: String
    let status: String
    let totalMarks: Int
    let studentMarks: Int
    let attemptedQuestions: Int
    let correctQuestions: Int
    let wrongQuestions: Int
    let skippedQuestions: Int

    enum CodingKeys: String, CodingKey {
        case assessmentID = "assessment_id"
        case studentID = "student_id"
        case status
        case totalMarks = "total_marks"
        case studentMarks = "student_marks"
        case attemptedQuestions = "attempted_questions"
        case correctQuestions = "correct_questions"
        case wrongQuestions = "wrong_questions"
        case skippedQuestions = "skipped_questions"
    }
}


struct AssessmentQuestionHistoryDetails: Codable {
    let id: String
    let assessmentId: String
    let questionId: String
    let questionName: String
    let questionType: String
    let options: [String]
    let correctAnswer: String
    let description: String?
    let answerDescription: String?
    let questionMarks: Int
    let userId: String
    let studentId: String
    let userAnswer: String?
    let isCorrect: Bool
    let marks: Int

    enum CodingKeys: String, CodingKey {
        case id
        case assessmentId = "assessment_id"
        case questionId = "question_id"
        case questionName = "question_name"
        case questionType = "question_type"
        case options
        case correctAnswer = "correct_answer"
        case description
        case answerDescription = "ans_description"
        case questionMarks = "question_marks"
        case userId = "user_id"
        case studentId = "student_id"
        case userAnswer = "user_answer"
        case isCorrect = "is_correct"
        case marks
    }
}

struct TimetableResponse: Decodable {
    let date: String
    let weekday: String
    let schedule: [ScheduleItem]
}

struct ScheduleItem: Decodable {
    let id: String
    let session_name: String
    let session_type: String
    let session_start_time: String
    let session_end_time: String
    let session_icon: String?
    let session_duration: Int
    let timetable_id: String?
    let teacher_name: String?
    let subject_name: String?
    let day: String?
    let start_display: String
    let session_number: Int?
    let now: Bool
}

struct VocabBeeStatistics: Codable {
    let total_questions: Int?
    let correct_answers: Int?
    let wrong_answers: Int?
    let total_points: Int?
    let last_answer_points: Int?
    let level: Int?
    let total_words: Int?
}

struct VocabBeeWordResponse: Codable {
    let id: String
    let wordID: String
    let userAnswer: String?
    let correctAnswer: String
    let isCorrect: Bool
    let points: Int

    enum CodingKeys: String, CodingKey {
        case id
        case wordID = "word_id"
        case userAnswer = "user_answer"
        case correctAnswer = "correct_answer"
        case isCorrect = "is_correct"
        case points
    }
}

struct Product: Decodable {
    let id: String
    let itemName: String
    let itemDescription: String
    let thumbnailImage: String
    let listOfImages: [String]
    let mrp: String
    let finalPrice: String
    let discountTag: String?
    let highlights: [String]?
    let isTrending: Bool
    let variants: Variants?
    let specification: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case itemName = "item_name"
        case itemDescription = "item_description"
        case thumbnailImage = "thumbnail_image"
        case listOfImages = "list_of_images"
        case mrp
        case finalPrice = "final_price"
        case discountTag = "discount_tag"
        case highlights
        case isTrending = "is_trending"
        case variants
        case specification
    }
}
struct Variants: Decodable {
    let color: [String]?
    let size: [String]?
    let type: [String]?
}

// MARK: - Delivery Info
struct DeliveryInfo {
    let fullName: String
    let contactNumber: String
    let houseNo: String
    let street: String
    let landmark: String
    let city: String
    let state: String
    let pinCode: String
    let country: String
}

// MARK: - Create Order Response
struct CreateOrderResponseModel: Codable {
    let id: String?
    let orderId: String?
    let orderStatus: String?
    let paymentSessionId: String?
    let paymentLink: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case orderId = "order_id"
        case orderStatus = "order_status"
        case paymentSessionId = "payment_session_id"
        case paymentLink = "payment_link"
        case message
    }

    var getOrderId: String? {
        return orderId ?? id
    }
}
struct CashfreeOrderResponse: Codable {
    let cfOrderId: String?
    let orderId: String?
    let paymentSessionId: String?
    let orderStatus: String?
    let orderAmount: Double?
    let orderCurrency: String?
    let orderExpiryTime: String?
    
    // For error response
    let message: String?
    let code: String?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case cfOrderId = "cf_order_id"
        case orderId = "order_id"
        case paymentSessionId = "payment_session_id"
        case orderStatus = "order_status"
        case orderAmount = "order_amount"
        case orderCurrency = "order_currency"
        case orderExpiryTime = "order_expiry_time"
        case message, code, type
    }
}

struct CreateAddressResponseModel: Codable {
    let id: String?
    let addressId: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case addressId = "address_id"
        case message
    }
}

struct FullAddress: Codable {
    let street: String?
    let country: String?
    let village: String?
    let district: String?
    let houseNo: String?
    let landmark: String?
    
    enum CodingKeys: String, CodingKey {
        case street, country, village, district, landmark
        case houseNo = "house_no"
    }
}

struct AddressModel: Codable {
    let id: String
    let userId: String?
    let contactNumber: Int?
    let fullName: String?
    let fullAddress: FullAddress?
    let mobile: Int?
    let placeName: String?
    let stateName: String?
    let pinCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case contactNumber = "contact_number"
        case fullName = "full_name"
        case fullAddress = "full_address"
        case mobile
        case placeName = "place_name"
        case stateName = "state_name"
        case pinCode = "pin_code"
    }
}

struct FeePaymentRequest: Codable {
    let studentFeeId: String
    let installmentNumber: Int
    let amount: Double
    
    enum CodingKeys: String, CodingKey {
        case studentFeeId = "student_fee_id"
        case installmentNumber = "installment_number"
        case amount
    }
}

struct FeePaymentResponse: Codable {
    let cfOrderId: String
    let paymentSessionId: String
    let orderId: String
    
    enum CodingKeys: String, CodingKey {
        case cfOrderId = "cf_order_id"
        case paymentSessionId = "payment_session_id"
        case orderId = "order_id"
    }
}

// MARK:  FullAddress Extension
extension FullAddress {
    func toDictionary() -> [String: Any] {
        return [
            "street": street ?? "",
            "country": country ?? "",
            "village": village ?? "",
            "district": district ?? "",
            "house_no": houseNo ?? "",
            "landmark": landmark ?? ""
        ]
    }
}

// MARK:  AddressModel Extension
extension AddressModel {
    
    func toParameters() -> [String: Any] {
        var params: [String: Any] = [:]
        
        if let contactNumber = contactNumber {
            params["contact_number"] = contactNumber
        }
        if let fullName = fullName {
            params["full_name"] = fullName
        }
        if let fullAddress = fullAddress {
            params["full_address"] = fullAddress.toDictionary()
        }
        if let mobile = mobile {
            params["mobile"] = mobile
        }
        if let placeName = placeName {
            params["place_name"] = placeName
        }
        if let stateName = stateName {
            params["state_name"] = stateName
        }
        if let pinCode = pinCode {
            params["pin_code"] = pinCode
        }
        
        return params
    }
    
    func getDisplayAddress() -> String {
        var addressComponents: [String] = []
        
        if let houseNo = fullAddress?.houseNo, !houseNo.isEmpty {
            addressComponents.append(houseNo)
        }
        if let street = fullAddress?.street, !street.isEmpty {
            addressComponents.append(street)
        }
        if let landmark = fullAddress?.landmark, !landmark.isEmpty {
            addressComponents.append(landmark)
        }
        if let village = fullAddress?.village, !village.isEmpty {
            addressComponents.append(village)
        }
        if let district = fullAddress?.district, !district.isEmpty {
            addressComponents.append(district)
        }
        if let place = placeName, !place.isEmpty {
            addressComponents.append(place)
        }
        if let state = stateName, !state.isEmpty {
            addressComponents.append(state)
        }
        if let pin = pinCode, !pin.isEmpty {
            addressComponents.append(pin)
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    func getShortDisplayAddress() -> String {
        var addressComponents: [String] = []
        
        if let houseNo = fullAddress?.houseNo, !houseNo.isEmpty {
            addressComponents.append(houseNo)
        }
        if let street = fullAddress?.street, !street.isEmpty {
            addressComponents.append(street)
        }
        if let place = placeName, !place.isEmpty {
            addressComponents.append(place)
        }
        if let pin = pinCode, !pin.isEmpty {
            addressComponents.append(pin)
        }
        
        return addressComponents.joined(separator: ", ")
    }
}

struct PaymentVerificationResponse: Codable {
    let orderId: String
    let paymentStatus: String
    let transactionId: String?
    let amount: Double?
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case paymentStatus = "payment_status"
        case transactionId = "transaction_id"
        case amount
    }
}

struct StudentUpdateResponse: Codable {
    let id: String?
    let studentID: String?
    let studentName: String?
    let name: String?
    let image: String?
    let gradeName: String?
    let gradeId: String?
    let dob: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case studentID = "student_id"
        case studentName = "student_name"
        case name
        case image
        case gradeName = "grade_name"
        case gradeId = "grade_id"
        case dob
        case status
    }
    
    var finalID: String {
        return id ?? studentID ?? ""
    }
    
    var finalName: String {
        return studentName ?? name ?? "Student"
    }
}
struct Grade: Codable {
    let id: String
    let schoolId: String?
    let name: String
    let section: String?
    let numericGrade: Int?
    let age: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case schoolId = "school_id"
        case name
        case section
        case numericGrade = "numeric_grade"
        case age
    }
}
struct FeeTransaction: Decodable {
    let id: String
    let schoolId: String
    let studentId: String
    let referenceId: String
    let transactionTime: Double
    let transactionType: String
    let paymentMode: String
    let installmentNumber: Int
    let amount: Double
    let remarks: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case schoolId = "school_id"
        case studentId = "student_id"
        case referenceId = "reference_id"
        case transactionTime = "transaction_time"
        case transactionType = "transaction_type"
        case paymentMode = "payment_mode"
        case installmentNumber = "installment_number"
        case amount
        case remarks
    }
}

struct ContactJson : Codable {
    let type : String
    let number : String
    
    enum CodingKeys: String, CodingKey {
        case type, number
    }
}
@propertyWrapper
struct SafeOptional<T: Codable>: Codable {

    var wrappedValue: T?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // null → nil
        if container.decodeNil() {
            wrappedValue = nil
            return
        }

        // {} → nil
        if let dict = try? container.decode([String: SafeAnyDecodable].self),
           dict.isEmpty {
            wrappedValue = nil
            return
        }

        // try normal decoding
        wrappedValue = try? container.decode(T.self)
    }

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    func encode(to encoder: Encoder) throws {
           var container = encoder.singleValueContainer()
           if let value = wrappedValue {
               try container.encode(value)
           } else {
               try container.encodeNil()
           }
       }
}
struct SafeAnyDecodable: Codable {}

struct IdNameObj: Codable {
    let id: String
    let name: String
}
struct Student: Codable {
    let studentID: String
    let name: String
    let image: String?
    let fatherName: String?
    let motherName: String?
    let dob: String?
    let address: String?
    let mobile: String?
    let email_json: [[String:String]]?
    let mobile_json: [ContactJson]?
    let grade: String
    let gradeID: String
    let section: String?
    let numeric_grade: Int
    let student_access_token: String?
    let qpass_id: String?
    @SafeOptional var school : School?


    enum CodingKeys: String, CodingKey {
        case studentID = "student_id"
        case name, mobile_json, email_json
        case image, photo_url
        case fatherName = "father_name"
        case motherName = "mother_name"
        case dob, date_of_birth
        case address
        case mobile, father_mobile
        case grade
        case clss
        case gradeID = "grade_id"
        case school = "schools"
        case schoolAlt = "school"  // verify-otp API uses "school" key
        case section, numeric_grade
        case student_access_token, qpass_id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        studentID = try container.decodeIfPresent(String.self, forKey: .studentID) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        image = (try? container.decodeIfPresent(String.self, forKey: .image)) ?? (try? container.decodeIfPresent(String.self, forKey: .photo_url))
        fatherName = try container.decodeIfPresent(String.self, forKey: .fatherName)
        motherName = try container.decodeIfPresent(String.self, forKey: .motherName)
        dob = (try? container.decodeIfPresent(String.self, forKey: .dob)) ?? (try? container.decodeIfPresent(String.self, forKey: .date_of_birth))
        address = try container.decodeIfPresent(String.self, forKey: .address)
        mobile = (try? container.decodeIfPresent(String.self, forKey: .mobile)) ?? (try? container.decodeIfPresent(String.self, forKey: .father_mobile))
        email_json = try container.decodeIfPresent([[String:String]].self, forKey: .email_json)
        mobile_json = try container.decodeIfPresent([ContactJson].self, forKey: .mobile_json)
        
        var tempGradeID = ""
        if let g = try? container.decodeIfPresent(String.self, forKey: .grade) {
            grade = g
        } else if let c = try? container.decodeIfPresent(String.self, forKey: .clss) {
            grade = c
        } else if let obj = try? container.decodeIfPresent(IdNameObj.self, forKey: .grade) {
            grade = obj.name
            tempGradeID = obj.id
        } else {
            grade = ""
        }
        
        gradeID = (try? container.decodeIfPresent(String.self, forKey: .gradeID)) ?? tempGradeID
        
        if let s = try? container.decodeIfPresent(String.self, forKey: .section) {
            section = s
        } else if let obj = try? container.decodeIfPresent(IdNameObj.self, forKey: .section) {
            section = obj.name
        } else {
            section = nil
        }
        
        numeric_grade = try container.decodeIfPresent(Int.self, forKey: .numeric_grade) ?? 0
        student_access_token = try container.decodeIfPresent(String.self, forKey: .student_access_token)
        qpass_id = try container.decodeIfPresent(String.self, forKey: .qpass_id)
        
        // Try "schools" key first, fall back to "school" key (verify-otp API)
        do {
            if let schoolData = try container.decodeIfPresent(School.self, forKey: .school) {
                _school = SafeOptional(wrappedValue: schoolData)
            } else if let schoolData = try container.decodeIfPresent(School.self, forKey: .schoolAlt) {
                _school = SafeOptional(wrappedValue: schoolData)
            } else {
                _school = SafeOptional(wrappedValue: nil)
            }
        } catch {
            print("❌ Failed to decode school: \(error)")
            _school = SafeOptional(wrappedValue: nil)
        }
    }
    
    var id: String {
        return studentID
    }
    
    var displayName: String {
        return name.isEmpty ? "Student" : name
    }
    
    var gradeSection: String {
        if !grade.isEmpty && (section != nil) {
            return "\(grade) - \(section)"
        }
        return grade
    }
    
    init(studentID: String, name: String, image: String?, fatherName: String, motherName: String, dob: String?, address: String?, mobile: String?, grade: String, gradeID: String, section: String, numeric_grade: Int, school: School?) {
        self.studentID = studentID
        self.name = name
        self.image = image
        self.fatherName = fatherName
        self.motherName = motherName
        self.dob = dob
        self.address = address
        self.mobile = mobile
        self.grade = grade
        self.gradeID = gradeID
        self.section = section
        self.numeric_grade = numeric_grade
        self.school = nil
        self.mobile_json = nil
        self.email_json = nil
        self.student_access_token = nil
        self.qpass_id = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(studentID, forKey: .studentID)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(fatherName, forKey: .fatherName)
        try container.encodeIfPresent(motherName, forKey: .motherName)
        try container.encodeIfPresent(dob, forKey: .dob)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(mobile, forKey: .mobile)
        try container.encodeIfPresent(email_json, forKey: .email_json)
        try container.encodeIfPresent(mobile_json, forKey: .mobile_json)
        try container.encode(grade, forKey: .grade)
        try container.encode(gradeID, forKey: .gradeID)
        try container.encodeIfPresent(section, forKey: .section)
        try container.encode(numeric_grade, forKey: .numeric_grade)
        try container.encodeIfPresent(student_access_token, forKey: .student_access_token)
        try container.encodeIfPresent(qpass_id, forKey: .qpass_id)
        if let schoolVal = school {
            try container.encodeIfPresent(schoolVal, forKey: .school)
        }
    }
}
struct LikeResponse: Decodable {
    let likes_count: Int
    let is_liked: Bool
}
extension String {
    
    func stripHTML() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        
        return self
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}

struct CommentsResponse: Codable {
    let comments: [Comment]
}

struct PostCommentResponse: Codable {
    let id: String
}

struct Comment: Codable {
    let commentId: String
    let userId: String
    let parentId: String?
    let comment: String
    let likesCount: Int
    let image: String?
    let userName: String
    let profilePic: String?
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case userId = "user_id"
        case parentId = "parent_id"
        case comment
        case likesCount = "likes_count"
        case image
        case userName = "user_name"
        case profilePic = "profile_pic"
        case createdAt = "created_at"
    }
    
    var formattedTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(createdAt))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
enum FeedCellType {
    case diy
    case stories
}
struct LeaveResponseData: Decodable {
    let leaveId: String?
    let totalDays: Double?
    let leaveDays: [String: LeaveDayInfo]?
    let leaveStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case leaveId = "leave_id"
        case totalDays = "total_days"
        case leaveDays = "leave_days"
        case leaveStatus = "leave_status"
    }
}

struct LeaveDayInfo: Decodable {
    let dayType: String?
    let sessionType: String?
    
    enum CodingKeys: String, CodingKey {
        case dayType = "day_type"
        case sessionType = "session_type"
    }
}
struct LeaveHistoryData: Codable {
    let id: String
    let studentId: String
    let gradeId: String
    let fromDate: String
    let toDate: String
    let totalDays: Double
    let reasonType: String
    let reason: String
    let leaveStatus: String
    let teacherRemarks: String?
    let leaveDays: [String: LeaveDayDetail]
    let holidays: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case studentId = "student_id"
        case gradeId = "grade_id"
        case fromDate = "from_date"
        case toDate = "to_date"
        case totalDays = "total_days"
        case reasonType = "reason_type"
        case reason
        case leaveStatus = "leave_status"
        case teacherRemarks = "teacher_remarks"
        case leaveDays = "leave_days"
        case holidays
    }
    
    var formattedDateRange: String {
        if fromDate == toDate {
            return formatDate(fromDate)
        } else {
            return "\(formatDate(fromDate)) - \(formatDate(toDate))"
        }
    }
    
    var formattedTotalDays: String {
        if totalDays == floor(totalDays) {
            return "\(Int(totalDays)) \(Int(totalDays) == 1 ? "Day" : "Days")"
        } else {
            return "\(totalDays) Days"
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    var leaveMonth: Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: fromDate) {
            return Calendar.current.component(.month, from: date)
        }
        return nil
    }
}

struct LeaveDayDetail: Codable {
    let dayType: String
    let sessionType: String
    
    enum CodingKeys: String, CodingKey {
        case dayType = "day_type"
        case sessionType = "session_type"
    }
}

struct LeaveUpdateResponse: Codable {
    let id: String
    let gradeId: String
    let gradeName: String
    let studentId: String
    let studentName: String
    let fromDate: String
    let toDate: String
    let dayType: String
    let sessionType: String
    let totalDays: Double
    let reason: String
    let leaveStatus: String
    let teacherRemarks: String
    let document: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case gradeId = "grade_id"
        case gradeName = "grade_name"
        case studentId = "student_id"
        case studentName = "student_name"
        case fromDate = "from_date"
        case toDate = "to_date"
        case dayType = "day_type"
        case sessionType = "session_type"
        case totalDays = "total_days"
        case reason
        case leaveStatus = "leave_status"
        case teacherRemarks = "teacher_remarks"
        case document
    }
}
struct OnlineCourse: Codable {
    let id: String
    let name: String
    let description: String
    let duration: Int
    let audience: String
    let thumbnailImage: String
    let profileImage: String?
    let demoVideo: [String]?
    let courseFee: String
    let finalCourseFee: String
    let trending: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, description, duration, audience, trending
        case thumbnailImage = "thumbnail_image"
        case profileImage = "profile_image"
        case demoVideo = "demo_video"
        case courseFee = "course_fee"
        case finalCourseFee = "final_course_fee"
    }
}

struct OfflineCourse: Codable {
    let id: String
    let name: String
    let description: String
    let audience: String
    let venue: String
    let venueFullAddress: String
    let venueLocationLink: String
    let totalSlots: Int
    let totalEnrolled: Int
    let entryFee: String
    let thumbnailImage: String
    let date: Int64
    let trending: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, audience, venue, date, trending
        case venueFullAddress = "venue_full_address"
        case venueLocationLink = "venue_location_link"
        case totalSlots = "total_slots"
        case totalEnrolled = "total_enrolled"
        case entryFee = "entry_fee"
        case thumbnailImage = "thumbnail_image"
    }
}

struct Webinar: Codable {
    let id: String
    let name: String
    let description: String
    let audience: String
    let webinarLink: String
    let totalSlots: Int
    let totalEnrolled: Int
    let entryFee: String
    let duration: Int
    let thumbnailImage: String
    let date: Int64
    let trending: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, audience, duration, date, trending
        case webinarLink = "webinar_link"
        case totalSlots = "total_slots"
        case totalEnrolled = "total_enrolled"
        case entryFee = "entry_fee"
        case thumbnailImage = "thumbnail_image"
    }
}

func formatEntryFee(_ fee: String) -> String {
    if let feeValue = Double(fee) {
        let formattedFee = String(format: "%.2f", feeValue)
        return "₹\(formattedFee)/-"
    } else if fee.isEmpty || fee == "0" || fee == "0.00" {
        return "₹0.00/-"
    } else {
        return "₹\(fee)/-"
    }
}

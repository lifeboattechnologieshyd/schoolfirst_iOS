//
//  NetworkManager.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 26/06/25.
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
    case decodingError(String)
    case serverError(String)
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}

    func request<T: Decodable>(
        urlString: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<APIResponse<T>, NetworkError>) -> Void
    ) {
        
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
        if let at = UserDefaults.standard.string(forKey: "ACCESSTOKEN") {
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
                        let decodedData = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                        completion(.success(decodedData))
                    }else {
                        if httpResponse.statusCode == 401 {
                            completion(.failure(.noaccess))
                        }else{
                            print("❌ Error: Status code is \(httpResponse.statusCode)")
                            completion(.failure(.noData))
                        }
                    }
                }
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }
}



struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let errorCode: Int
    let total : Int?
    let description: String
    let data: T?
}


struct MobileCheckResponse : Decodable {
    var username : String?
    var profile_pic : String?
    var message : String?
    var password_required : Bool?

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

struct User:  Codable {
    let id: String
    let firstName: String?
    let lastName: String?
    let schoolIDs: [String]
    let username: String
    let profileImage: String?
    let email: String?
    let referralCode: String
    let mobile: Int
    let deviceID: String?
    let schools: [School]

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
        case schools
    }
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
    let students: [Student]

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
        case students
    }
}

struct Student: Codable {
    let studentID: String
    let name: String
    let image: String?
    let fatherName: String
    let motherName: String
    let dob: String
    let address: String?
    let mobile: String
    let grade: String
    let gradeID: String
    let section: String

    enum CodingKeys: String, CodingKey {
        case studentID = "student_id"
        case name
        case image
        case fatherName = "father_name"
        case motherName = "mother_name"
        case dob
        case address
        case mobile
        case grade
        case gradeID = "grade_id"
        case section
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
        case id, name, description, duration, hosts, images, audience, language, enrollments, completions, trending
        case thumbnailImage = "thumbnail_image"
        case profileImage = "profile_image"
        case courseFee = "course_fee"
        case finalCourseFee = "final_course_fee"
        case numberOfChapters = "number_of_chapters"
        case numberOfLessons = "number_of_lessons"
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
    let likesCount: Int
    let commentsCount: Int
    let whatsappShareCount: Int
    let language: String
    let duration: Int
    let postingDate: String
    let approvedBy: String?
    let approvedTime: String?
    let status: String
    let isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id, heading, trending, categories, image, remarks, video, description, language, duration, status
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
    let schoolId: String

    enum CodingKeys: String, CodingKey {
        case id
        case screen
        case image
        case status
        case schoolId = "school_id"
    }
}

struct Bulletin: Codable {
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

struct Homework: Codable {
    let id: String
    let school: String
    let schoolName: String
    let grade: String
    let gradeName: String
    let homeworkDate: String
    let homeworkDetails: [HomeworkDetail]
    let homeworkTrackerDetails: [HomeworkTrackerDetail]
    let deadline: String
    let doneCount: Int

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

//
//  BulletinCategoriesService.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/10/26.
//

import Foundation

class BulletinCategoriesService {
    static let shared = BulletinCategoriesService()
    private init() {}
    
    // MARK: - Shared Headers (school id + auth token from DBManager/UserDefaults)
    private func buildHeaders() -> [String: String] {
        let schoolID = UserManager.shared.resolvedSchoolID
        let accessToken = UserDefaults.standard.string(forKey: "ACCESSTOKEN") ?? ""
        
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if !schoolID.isEmpty {
            // ✅ Server requires EXACTLY this header key
            headers["X-School-Id"] = schoolID
            
            // Extra variants for safety (harmless if ignored)
            headers["x-school-id"] = schoolID
            headers["School-Id"] = schoolID
            headers["school_id"] = schoolID
            headers["SchoolID"] = schoolID
        }
        
        if !accessToken.isEmpty {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return headers
    }
    
    // MARK: - 1. Bulletin Categories API
    func fetchBulletinCategories(
        completion: @escaping (Result<[BulletinCategory], NetworkError>) -> Void
    ) {
        let schoolID = UserManager.shared.resolvedSchoolID
        let headers = buildHeaders()
        
        print("📡 Fetching Bulletin Categories — schoolID:", schoolID)
        
        NetworkManager.shared.request(
            urlString: API.BULLETIN_CATEGORIES,
            method: .GET,
            is_testing: true,
            requiresAuth: true,
            parameters: nil,
            headers: headers
        ) { (result: Result<APIResponse<[BulletinCategory]>, NetworkError>) in
            switch result {
            case .success(let response):
                if let categories = response.data {
                    print("✅ Bulletin Categories fetched:", categories.count)
                    completion(.success(categories))
                } else {
                    print("⚠️ Bulletin Categories — empty data")
                    completion(.success([]))
                }
            case .failure(let error):
                print("❌ Bulletin Categories fetch failed:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 2. Bulletins API (student_id + category_id in query params)
    func fetchBulletins(
        categoryId: String? = nil,
        completion: @escaping (Result<[BulletinEntry], NetworkError>) -> Void
    ) {
        let schoolID = UserManager.shared.resolvedSchoolID
        let studentID = UserManager.shared.resolvedStudentID
        let headers = buildHeaders()
        
        // ── Query params for GET request ─────────────────────────────
        // ⚠️ If backend expects different key names (e.g. "studentId"),
        //    change ONLY here.
        var parameters: [String: Any] = [:]
        if !studentID.isEmpty {
            parameters["student_id"] = studentID
        }
        if let categoryId = categoryId, !categoryId.isEmpty {
            // "All" chip → nil, so no category filter is sent
            parameters["category_id"] = categoryId
        }
        
        print("📡 Fetching Bulletins — schoolID:", schoolID,
              "| studentID:", studentID,
              "| categoryId:", categoryId ?? "All")
        
        NetworkManager.shared.request(
            urlString: API.BULLETINS,
            method: .GET,
            is_testing: true,
            requiresAuth: true,
            parameters: parameters.isEmpty ? nil : parameters,
            headers: headers
        ) { (result: Result<APIResponse<BulletinListWrapper>, NetworkError>) in
            switch result {
            case .success(let response):
                let entries = response.data?.data ?? []
                print("✅ Bulletins fetched:", entries.count)
                completion(.success(entries))
            case .failure(let error):
                print("❌ Bulletins fetch failed:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}

import Foundation
import UIKit

enum UploadError: Error {
    case invalidURL
    case serverError(String)
    case unknown
}

class FileUploader {
    
    static func uploadFile(
        urlString: String,
        fileData: Data,
        fileName: String,
        fieldName: String = "files",
        mimeType: String,
        additionalParams: [String: String] = [:],
        headers: [String: String] = [:],
        completion: @escaping (Result<APIResponse<[UploadResponse]>, UploadError>) -> Void
    ) {
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // boundary for multipart
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // add custom headers (auth, etc.)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        var body = Data()
        
        // Add extra params if any
        for (key, value) in additionalParams {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Start upload
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(UploadError.unknown))
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Server error"
                completion(.failure(UploadError.serverError(errorMessage)))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(APIResponse<[UploadResponse]>.self, from: data!)
                completion(.success(decodedData))
            } catch {
                completion(.failure(UploadError.serverError(error.localizedDescription)))
            }
        }.resume()
    }
}
struct UploadResponse: Codable {
    let originalFilename: String
    let fileURL: String
    let filePath: String

    enum CodingKeys: String, CodingKey {
        case originalFilename = "original_filename"
        case fileURL = "file_url"
        case filePath = "file_path"
    }
}

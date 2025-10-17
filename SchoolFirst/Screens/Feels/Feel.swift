//
//  Feed.swift
//  SchoolFirst
//
//  Created by Lifeboat on 17/10/25.
//
 
import Foundation

struct FeelItem: Codable {
    let id: Int
    let title: String
    let imageURL: String
    var likes: Int

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURL = "image_url"
        case likes
    }
}


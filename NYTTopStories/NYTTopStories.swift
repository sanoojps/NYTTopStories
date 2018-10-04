//
//  NYTTopStories.swift
//  NYTTopStories
//
//  Created by Sanooj on 04/10/2018.
//  Copyright © 2018 Sanooj. All rights reserved.
//

import Foundation

// To parse the JSON, add this file to your project and do:
//
//   let nYTTopStories = try? newJSONDecoder().decode(NYTTopStories.self, from: jsonData)
// https://app.quicktype.io
//

import Foundation

struct NYTTopStories: Codable {
    let status: String
    let lastUpdated: String
    let copyright, section: String
    let numResults: Int
    let results: [Result]
    
    enum CodingKeys: String, CodingKey {
        case status
        case lastUpdated = "last_updated"
        case copyright, section
        case numResults = "num_results"
        case results
    }
}

struct Result: Codable {
    let section: String
    let desFacet, orgFacet: [String]
    let byline, abstract: String
    let url: String
    let multimedia: [Multimedia]
    let createdDate: String
    let title, kicker: String
    let geoFacet: [String]
    let itemType: ItemType
    let subsection, materialTypeFacet: String
    let publishedDate: String
    let perFacet: [String]
    let updatedDate: String
    let shortURL: String?
    
    enum CodingKeys: String, CodingKey {
        case section
        case desFacet = "des_facet"
        case orgFacet = "org_facet"
        case byline, abstract, url, multimedia
        case createdDate = "created_date"
        case title, kicker
        case geoFacet = "geo_facet"
        case itemType = "item_type"
        case subsection
        case materialTypeFacet = "material_type_facet"
        case publishedDate = "published_date"
        case perFacet = "per_facet"
        case updatedDate = "updated_date"
        case shortURL = "short_url"
    }
}

enum ItemType: String, Codable {
    case article = "Article"
}

struct Multimedia: Codable {
    let format: Format
    let height, width: Int
    let copyright: String
    let subtype: Subtype
    let type: TypeEnum
    let caption: String
    let url: String
}

enum Format: String, Codable {
    case mediumThreeByTwo210 = "mediumThreeByTwo210"
    case normal = "Normal"
    case standardThumbnail = "Standard Thumbnail"
    case superJumbo = "superJumbo"
    case thumbLarge = "thumbLarge"
}

enum Subtype: String, Codable {
    case photo = "photo"
}

enum TypeEnum: String, Codable {
    case image = "image"
}

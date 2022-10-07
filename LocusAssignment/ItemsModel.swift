//
//  ItemsModel.swift
//  LocusAssignment
//
//  Created by Sumit Gupta on 08/10/22.
// All the codable model type from json is defined here

import Foundation


// MARK: - ItemModel

struct ItemModel: Codable {
    let type: TypeEnum
    let id, title: String
    let dataMap: DataMap
}

// MARK: - DataMap
struct DataMap: Codable {
    let options: [String]?
}

enum TypeEnum: String, Codable {
    case comment = "COMMENT"
    case photo = "PHOTO"
    case singleChoice = "SINGLE_CHOICE"
}

typealias Items = [ItemModel]

//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 06/07/21.
//

import Foundation

public struct FeedItem: Equatable, Codable {
    public let id : UUID
    public let imageURL : URL
    public let description : String?
    public let location : String?
    
    public init(id: UUID, imageURL: URL, desc: String? = nil, location: String? = nil){
        self.id = id
        self.imageURL = imageURL
        self.description = desc
        self.location = location
    }
}

extension FeedItem {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}

public struct FeedResponse: Codable{
    public let items : [FeedItem]
    
    public init(items: [FeedItem] = []){
        self.items = items
    }
}

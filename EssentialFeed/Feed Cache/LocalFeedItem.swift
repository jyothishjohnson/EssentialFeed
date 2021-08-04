//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 04/08/21.
//

import Foundation

public struct LocalFeedItem: Equatable, Codable {
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

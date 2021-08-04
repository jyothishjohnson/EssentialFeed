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
    
    public var remoteFeedItem : RemoteFeedItem {
        RemoteFeedItem(id: self.id, image: self.imageURL, desc: self.description, location: self.location)
    }
}

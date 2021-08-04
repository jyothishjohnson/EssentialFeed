//
//  FeedImage.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 06/07/21.
//

import Foundation

public struct FeedImage: Equatable, Codable {
    public let id : UUID
    public let url : URL
    public let description : String?
    public let location : String?
    
    public init(id: UUID, url: URL, desc: String? = nil, location: String? = nil){
        self.id = id
        self.url = url
        self.description = desc
        self.location = location
    }
    
    public var remoteFeedItem : RemoteFeedItem {
        RemoteFeedItem(id: self.id, image: self.url, desc: self.description, location: self.location)
    }
}

//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 04/08/21.
//

import Foundation

public struct RemoteFeedItem: Codable {
    public let id : UUID
    public let image : URL
    public let description : String?
    public let location : String?
    
    public init(id: UUID, image: URL, desc: String? = nil, location: String? = nil){
        self.id = id
        self.image = image
        self.description = desc
        self.location = location
    }
}

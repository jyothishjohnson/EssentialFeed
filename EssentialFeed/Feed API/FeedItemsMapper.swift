//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 14/07/21.
//

import Foundation

internal struct FeedItemsMapper {
    
    private enum ResponseCode : Int {
        case OK_200 = 200
    }
    
    internal static func map(with data: Data, response: HTTPURLResponse) -> [FeedItem]? {
        guard response.statusCode == ResponseCode.OK_200.rawValue else {
            return nil
        }
        
        return try? JSONDecoder().decode(FeedResponse.self, from: data).items.map{ $0.feedItem }
        
    }
}

public struct FeedResponse: Codable{
    public let items : [Item]
    
    public init(items: [Item] = []){
        self.items = items
    }
}

public struct Item: Codable {
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
    
    public var feedItem : FeedItem {
        return FeedItem(id: id, imageURL: image, desc: description, location: location)
    }
}

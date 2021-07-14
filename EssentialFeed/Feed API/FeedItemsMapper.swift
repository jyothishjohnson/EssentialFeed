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
    
    internal static func map(with data: Data, response: HTTPURLResponse) -> Result<[FeedItem],RemoteFeedLoader.Error> {
        guard response.statusCode == ResponseCode.OK_200.rawValue,
              let rootResponse = try? JSONDecoder().decode(FeedResponse.self, from: data)
              else {
            return .failure(.invalidData)
        }
        
        return .success(rootResponse.feed)
        
    }
}

public struct FeedResponse: Codable{
    public let items : [Item]
    
    var feed: [FeedItem] {
        return items.map{ $0.feedItem }
    }
    
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

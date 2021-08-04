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
    
    internal static func map(with data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == ResponseCode.OK_200.rawValue,
              let rootResponse = try? JSONDecoder().decode(FeedResponse.self, from: data)
              else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return rootResponse.items
    }
}

public struct FeedResponse: Codable{
    public let items : [RemoteFeedItem]
    
    public init(items: [RemoteFeedItem] = []){
        self.items = items
    }
}

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

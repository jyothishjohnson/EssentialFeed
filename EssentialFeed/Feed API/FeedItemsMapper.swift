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

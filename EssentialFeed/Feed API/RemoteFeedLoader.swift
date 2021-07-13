//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 07/07/21.
//

import Foundation

public protocol HTTPClient{
            
    func get(from url : URL, completion : @escaping (Result<(HTTPURLResponse,Data), Error>) -> ())
}

public final class RemoteFeedLoader {
    
    private let client : HTTPClient
    private let url : URL
    
    public init(client: HTTPClient, url : URL){
        self.client = client
        self.url = url
    }
    
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load(completion : @escaping (Result<[FeedItem],Error>) -> ()){
        client.get(from: url){ result in
            
            switch result {
            case .success((let(response,data))):
                
                if let items = FeedItemsMapper.map(with: data, response: response) {
                    completion(.success(items))
                }else {
                    completion(.failure(.invalidData))
                }
            case .failure(_):
                
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct FeedItemsMapper {
    
    enum ResponseCode : Int {
        case OK_200 = 200
    }
    
    static func map(with data: Data, response: HTTPURLResponse) -> [FeedItem]? {
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

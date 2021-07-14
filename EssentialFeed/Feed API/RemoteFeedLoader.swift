//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 07/07/21.
//

import Foundation

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
        client.get(from: url){ [weak self] result in
            
            guard self != nil else {
                return
            }

            switch result {
            case .success((let(response,data))):
                
                completion(FeedItemsMapper.map(with: data, response: response))
                
            case .failure(_):
                
                completion(.failure(.connectivity))
            }
        }
    }
}

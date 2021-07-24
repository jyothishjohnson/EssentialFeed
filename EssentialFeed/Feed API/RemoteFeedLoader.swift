//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 07/07/21.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    private let client : HTTPClient
    private let url : URL
    
    public init(client httpClient: HTTPClient, url loadURL: URL){
        self.client = httpClient
        self.url = loadURL
    }
    
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load(completion : @escaping (LoadFeedResult) -> ()){
        client.get(from: url){ [weak self] result in
            
            guard self != nil else {
                return
            }

            switch result {
            case .success((let(response,data))):
                
                completion(FeedItemsMapper.map(with: data, response: response))
                
            case .failure(_):
                
                completion(.failure(Error.connectivity))
            }
        }
    }
}

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
            case .success((let(_,data))):
                
                if let response = try? JSONDecoder().decode(FeedResponse.self, from: data) {
                    completion(.success(response.items))
                }else {
                    completion(.failure(.invalidData))
                }
            case .failure(_):
                
                completion(.failure(.connectivity))
            }
        }
    }
}

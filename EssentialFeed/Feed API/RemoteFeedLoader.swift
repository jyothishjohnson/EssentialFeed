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
    }
    
    public func load(completion : @escaping (Error) -> () = {_ in} ){
        client.get(from: url){ error in
            completion(.connectivity)
        }
    }
}

public protocol HTTPClient{
            
    func get(from url : URL, completion : @escaping (Error) -> ())
}

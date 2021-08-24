//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 14/07/21.
//

import Foundation

public protocol HTTPClient{
            
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url : URL, completion : @escaping (Result<(HTTPURLResponse,Data), Error>) -> ())
}

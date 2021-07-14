//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 14/07/21.
//

import Foundation

public protocol HTTPClient{
            
    func get(from url : URL, completion : @escaping (Result<(HTTPURLResponse,Data), Error>) -> ())
}

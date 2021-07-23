//
//  URLSessionHTTPClietn.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 23/07/21.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient{
    
    let session : URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnExpectedError: Error{}
    
    public func get(from url : URL, completion : @escaping (Result<(HTTPURLResponse,Data), Error>) -> ()){
        session.dataTask(with: url){ data,response,error in
            
            if let error = error {
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((response,data)))
            }else {
                completion(.failure(UnExpectedError()))

            }
        }.resume()
    }
}

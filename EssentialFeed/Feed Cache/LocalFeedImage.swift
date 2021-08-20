//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 04/08/21.
//

import Foundation

public struct LocalFeedImage: Equatable {
    public let id : UUID
    public let url : URL
    public let description : String?
    public let location : String?
    
    public init(id: UUID, url: URL, desc: String? = nil, location: String? = nil){
        self.id = id
        self.url = url
        self.description = desc
        self.location = location
    }
}

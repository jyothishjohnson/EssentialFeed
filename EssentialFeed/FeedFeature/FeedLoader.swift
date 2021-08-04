//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 06/07/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage],Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> ())
}


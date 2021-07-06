//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 06/07/21.
//

import Foundation

typealias LoadFeedResult = Result<[FeedItem],Error>

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> ())
}


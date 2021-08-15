//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 15/08/21.
//

import Foundation
import EssentialFeed

func uniqueFeedItem() -> FeedImage {
    
    return FeedImage(id: UUID(), url: anyURL(), desc: nil, location: nil)
}

func uniqueItems() -> (models: [FeedImage], local: [LocalFeedImage]){
    let items = [uniqueFeedItem(), uniqueFeedItem()]
    let localItems = items.map{ LocalFeedImage(id: $0.id, url: $0.url, desc: $0.description, location: $0.description) }
    
    return (items, localItems)
}

extension Date {
    
    private var feedCacheMaxAge : Int {
        7
    }
    
    func minusFeedCacheMaxAge() -> Date{
        return adding(days: -feedCacheMaxAge)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Int) -> Date {
        return self + TimeInterval(seconds)
    }
}

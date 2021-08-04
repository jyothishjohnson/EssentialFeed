//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 01/08/21.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    private let store : FeedStore
    private let currentDate : () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion : @escaping (SaveResult) -> ()) {
        store.deleteCachedFeed{ [weak self] error in
            
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            }else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion : @escaping (SaveResult) -> ()){
        store.insert(feed.toLocal(), withTimeStamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        map{ LocalFeedImage(id: $0.id, url: $0.url, desc: $0.description, location: $0.description) }
    }
}

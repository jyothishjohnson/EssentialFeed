//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 01/08/21.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletions = ((Error?) -> ())
    typealias InsertionCompletions = ((Error?) -> ())
    
    func deleteCachedFeed(completion : @escaping DeletionCompletions)
    func insert(_ items: [FeedItem], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions)
}

public final class LocalFeedLoader {
    private let store : FeedStore
    private let currentDate : () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion : @escaping (Error?) -> ()) {
        store.deleteCachedFeed{ [weak self] error in
            
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            }else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion : @escaping (Error?) -> ()){
        store.insert(items, withTimeStamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

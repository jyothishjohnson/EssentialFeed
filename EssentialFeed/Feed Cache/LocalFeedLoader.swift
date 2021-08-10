//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 01/08/21.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    public typealias LoadResult = Swift.Result<[FeedImage],Error>
    
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
    
    public func load(completion : @escaping (LoadResult) -> ()){
        store.retriveCache{ [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
                            
            case let .found(feed, timeStamp) where timeStamp.isValid(maxAgeInDays: 7, currentDate: currentDate()):
                completion(.success(feed.toModels()))
                
            case .empty, .found:
                completion(.success([]))
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

private extension Date {
    
    func isValid(maxAgeInDays: Int, currentDate: Date) -> Bool {
        guard let maxDate = Calendar(identifier: .gregorian)
                .date(byAdding: .day, value: maxAgeInDays, to: self) else {
            return false
        }
        return currentDate < maxDate
    }
}

private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        map{ LocalFeedImage(id: $0.id, url: $0.url, desc: $0.description, location: $0.description) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(id: $0.id, url: $0.url, desc: $0.description, location: $0.location)
        }
    }
}

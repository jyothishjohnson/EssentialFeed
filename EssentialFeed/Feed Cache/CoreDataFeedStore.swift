//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 28/08/21.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}

    public func deleteCachedFeed(completion: @escaping DeletionCompletions) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions) {
        
    }
    
    public func retriveCache(completion: @escaping RetrievalCompletions) {
        completion(.empty)
    }

}

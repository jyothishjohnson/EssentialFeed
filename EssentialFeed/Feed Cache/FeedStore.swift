//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 01/08/21.
//

import Foundation

public enum RetriveCachedFeedResult {
    
    case empty
    case found(feed: [LocalFeedImage], timeStamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletions = ((Error?) -> ())
    typealias InsertionCompletions = ((Error?) -> ())
    typealias RetrievalCompletions = (RetriveCachedFeedResult) -> ()
    
    func deleteCachedFeed(completion : @escaping DeletionCompletions)
    func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions)
    func retriveCache(completion : @escaping RetrievalCompletions)
}

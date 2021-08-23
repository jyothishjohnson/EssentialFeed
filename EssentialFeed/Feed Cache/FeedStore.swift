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
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion : @escaping DeletionCompletions)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retriveCache(completion : @escaping RetrievalCompletions)
}

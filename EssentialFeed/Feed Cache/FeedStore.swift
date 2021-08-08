//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 01/08/21.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletions = ((Error?) -> ())
    typealias InsertionCompletions = ((Error?) -> ())
    typealias RetrievalCompletions = (Error?) -> ()
    
    func deleteCachedFeed(completion : @escaping DeletionCompletions)
    func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions)
    func retriveCache(completion : @escaping RetrievalCompletions)
}

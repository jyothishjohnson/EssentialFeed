//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 08/08/21.
//

import Foundation
import EssentialFeed

final class FeedStoreSpy: FeedStore {
    
    enum RecievedMessage: Equatable {
        case deleteCacheMessage
        case insertCacheMessage(items: [LocalFeedImage], timeStamp: Date)
        case retriveCache
    }
    
//    typealias DeletionCompletions = ((Error?) -> ())
//    typealias InsertionCompletions = ((Error?) -> ())
//    typealias RetrievalCompletions = () -> ()

    private(set) var recievedMessages = [RecievedMessage]()
    private var cacheDeletionFallbacks = [DeletionCompletions]()
    private var cacheInsertionFallbacks = [InsertionCompletions]()
    private var cacheRetrievalFallbacks = [RetrievalCompletions]()
    
    func deleteCachedFeed(completion : @escaping DeletionCompletions){
        recievedMessages.append(.deleteCacheMessage)
        cacheDeletionFallbacks.append(completion)
    }
    
    func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions) {
        cacheInsertionFallbacks.append(completion)
        recievedMessages.append(.insertCacheMessage(items: feed, timeStamp: timeStamp))
    }
    
    func retriveCache(completion : @escaping RetrievalCompletions) {
        cacheRetrievalFallbacks.append(completion)
        recievedMessages.append(.retriveCache)
    }
    
    func completionDeletion(at index: Int = 0, with error: Error) {
        cacheDeletionFallbacks[index](error)
    }
    
    func completeInsertion(at index: Int = 0, with error: Error) {
        cacheInsertionFallbacks[index](error)
    }
    
    func completionDeletionSuccessfully(at index: Int = 0){
        cacheDeletionFallbacks[index](nil)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0){
        cacheInsertionFallbacks[index](nil)
    }
    
    func completeRetrieval(at index: Int = 0, with error: Error) {
        cacheRetrievalFallbacks[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0){
        cacheRetrievalFallbacks[index](.empty)
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timeStamp: Date, at index: Int = 0){
        cacheRetrievalFallbacks[index](.found(feed: feed, timeStamp: timeStamp))
    }
}

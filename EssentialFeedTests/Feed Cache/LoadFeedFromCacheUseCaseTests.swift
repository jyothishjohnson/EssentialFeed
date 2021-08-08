//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 08/08/21.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation(){
        
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages.count, 0)
    }
    
    //MARK: helper functions
    
    private func makeSUT(currentDate : @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut,store)
    }
    
    final class FeedStoreSpy: FeedStore {
        
        enum RecievedMessage: Equatable {
            case deleteCacheMessage
            case insertCacheMessage(items: [LocalFeedImage], timeStamp: Date)
        }
        
        typealias DeletionCompletions = ((Error?) -> ())
        typealias InsertionCompletions = ((Error?) -> ())
        
        private(set) var recievedMessages = [RecievedMessage]()
        private var cacheDeletionFallbacks = [DeletionCompletions]()
        private var cacheInsertionFallbacks = [InsertionCompletions]()
        
        func deleteCachedFeed(completion : @escaping DeletionCompletions){
            recievedMessages.append(.deleteCacheMessage)
            cacheDeletionFallbacks.append(completion)
        }
        
        func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions) {
            cacheInsertionFallbacks.append(completion)
            recievedMessages.append(.insertCacheMessage(items: feed, timeStamp: timeStamp))
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
    }
}

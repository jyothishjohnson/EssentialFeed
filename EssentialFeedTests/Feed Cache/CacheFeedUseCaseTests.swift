//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 27/07/21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store : FeedStore
    private let currentDate : () -> Date
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion : @escaping (Error?) -> ()) {
        store.deleteCachedFeed{ [weak self] error in
            
            guard let self = self else { return }
            
            if error == nil {
                self.store.insert(items, withTimeStamp: self.currentDate(), completion: completion)
            }else {
                completion(error)
            }
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletions = ((Error?) -> ())
    typealias InsertionCompletions = ((Error?) -> ())
    
    func deleteCachedFeed(completion : @escaping DeletionCompletions)
    func insert(_ items: [FeedItem], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions)
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages.count, 0)
    }
    
    func test_saveCommand_requestsCacheDeletion(){
        
        let (sut,store) = makeSUT()
        let items : [FeedItem] = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items){ _ in }
        
        XCTAssertEqual(store.recievedMessages, [.deleteCacheMessage])
    }
    
    func test_saveCommand_doesNotRequestCacheInsertionOnDeletionError(){
        
        let (sut,store) = makeSUT()
        let items : [FeedItem] = [uniqueFeedItem(), uniqueFeedItem()]
        let deletionError = anyError()
        
        sut.save(items){ _ in }
        store.completionDeletion(with: deletionError)
        
        XCTAssertEqual(store.recievedMessages, [.deleteCacheMessage])
    }
    
    func test_saveCommand_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        
        let timeStamp = Date()
        let (sut,store) = makeSUT(currentDate: { timeStamp })
        let items : [FeedItem] = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items){ _ in }
        store.completionDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCacheMessage, .insertCacheMessage(items: items, timeStamp: timeStamp)])
    }
    
    func test_saveCommand_failsOnDeletionError(){
        
        let (sut,store) = makeSUT()
        let deletionError = anyError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completionDeletion(with: deletionError)
        })
    }
    
    func test_saveCommand_failsOnInsertionError(){
        
        let (sut,store) = makeSUT()
        let insertionError = anyError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completionDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_saveCommand_succeedsOnSuccessfulCacheInsertion(){
        
        let (sut,store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completionDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_saveCommand_doesntDeliverDeletionErrorAfterSUTisDeallocated(){
        
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var recievedResult : [Error?] = []
        sut?.save([uniqueFeedItem()], completion: { error in
            recievedResult.append(error)
        })
        
        sut = nil
        store.completionDeletion(with: anyError())
        
        XCTAssertTrue(recievedResult.isEmpty)
    }
    
    //MARK: helper functions
    
    private func makeSUT(currentDate : @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut,store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action : () -> (), file: StaticString = #filePath, line: UInt = #line) {
        var recievedError : NSError?
        
        let exp = expectation(description: "wait for completion")
        sut.save([uniqueFeedItem()]) { error in
            if let error = error {
                recievedError = error as NSError
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(recievedError, expectedError, file: file, line: line)
    }
    
    final class FeedStoreSpy: FeedStore {
        
        enum RecievedMessage: Equatable {
            case deleteCacheMessage
            case insertCacheMessage(items: [FeedItem], timeStamp: Date)
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
        
        func insert(_ items: [FeedItem], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions) {
            cacheInsertionFallbacks.append(completion)
            recievedMessages.append(.insertCacheMessage(items: items, timeStamp: timeStamp))
        }
    }
    
    private func uniqueFeedItem() -> FeedItem {
        
        return FeedItem(id: UUID(), imageURL: anyURL(), desc: nil, location: nil)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://anyURL.com/\(UUID().uuidString)")!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 101)
    }
}

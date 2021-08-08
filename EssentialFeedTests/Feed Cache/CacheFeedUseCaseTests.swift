//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 27/07/21.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages.count, 0)
    }
    
    func test_saveCommand_requestsCacheDeletion(){
        
        let (sut,store) = makeSUT()
        
        sut.save(uniqueItems().models){ _ in }
        
        XCTAssertEqual(store.recievedMessages, [.deleteCacheMessage])
    }
    
    func test_saveCommand_doesNotRequestCacheInsertionOnDeletionError(){
        
        let (sut,store) = makeSUT()
        let deletionError = anyError()
        
        sut.save(uniqueItems().models){ _ in }
        store.completionDeletion(with: deletionError)
        
        XCTAssertEqual(store.recievedMessages, [.deleteCacheMessage])
    }
    
    func test_saveCommand_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        
        let timeStamp = Date()
        let (sut,store) = makeSUT(currentDate: { timeStamp })
        let items = uniqueItems()
        
        sut.save(items.models){ _ in }
        store.completionDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCacheMessage, .insertCacheMessage(items: items.local, timeStamp: timeStamp)])
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
        
        var recievedResult : [LocalFeedLoader.SaveResult] = []
        sut?.save(uniqueItems().models, completion: { error in
            recievedResult.append(error)
        })
        
        sut = nil
        store.completionDeletion(with: anyError())
        
        XCTAssertTrue(recievedResult.isEmpty)
    }
    
    func test_saveCommand_doesntDeliverInsertionErrorAfterSUTisDeallocated(){
        
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var recievedResult : [LocalFeedLoader.SaveResult] = []
        sut?.save(uniqueItems().models, completion: { error in
            recievedResult.append(error)
        })
        
        store.completionDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyError())
        
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
        sut.save(uniqueItems().models) { error in
            if let error = error {
                recievedError = error as NSError
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(recievedError, expectedError, file: file, line: line)
    }
    
    private func uniqueFeedItem() -> FeedImage {
        
        return FeedImage(id: UUID(), url: anyURL(), desc: nil, location: nil)
    }
    
    private func uniqueItems() -> (models: [FeedImage], local: [LocalFeedImage]){
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let localItems = items.map{ LocalFeedImage(id: $0.id, url: $0.url, desc: $0.description, location: $0.description) }
        
        return (items, localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://anyURL.com/\(UUID().uuidString)")!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 101)
    }
}

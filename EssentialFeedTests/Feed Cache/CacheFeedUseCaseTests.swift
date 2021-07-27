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

    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed{ [unowned self] error in
            
            if error == nil {
                self.store.insert(items)
            }
            
        }
    }
}

class FeedStore {
    typealias DeletionCompletions = ((Error?) -> ())
    var deleCachedFeedCallCount = 0
    var insertCacheCallCount = 0
    
    private var cacheDeletionFallbacks = [DeletionCompletions]()
    
    func deleteCachedFeed(completion : @escaping DeletionCompletions){
        deleCachedFeedCallCount += 1
        cacheDeletionFallbacks.append(completion)
    }
    
    func completionDeletion(at index: Int = 0, with error: Error) {
        cacheDeletionFallbacks[index](error)
    }
    
    func completionDeletionSuccessfully(at index: Int = 0){
        cacheDeletionFallbacks[index](nil)
    }
    
    func insert(_ items: [FeedItem]) {
        insertCacheCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation(){
        
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.deleCachedFeedCallCount, 0)
    }
    
    func test_saveCommand_requestsCacheDeletion(){
        
        let (sut,store) = makeSUT()
        let items : [FeedItem] = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleCachedFeedCallCount, 1)
    }
    
    func test_saveCommand_doesNotRequestCacheInsertionOnDeletionError(){
        
        let (sut,store) = makeSUT()
        let items : [FeedItem] = [uniqueFeedItem(), uniqueFeedItem()]
        let deletionError = anyError()
        
        sut.save(items)
        store.completionDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCacheCallCount, 0)
    }
    
    func test_saveCommand_requestNewCacheInsertionOnSuccessfulDeletion() {
        
        let (sut,store) = makeSUT()
        let items : [FeedItem] = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        store.completionDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCacheCallCount, 1)
    }
    
    //MARK: helper functions
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut,store)
    }
    
    func uniqueFeedItem() -> FeedItem {
        
        return FeedItem(id: UUID(), imageURL: anyURL(), desc: nil, location: nil)
    }
    
    func anyURL() -> URL {
        return URL(string: "https://anyURL.com/\(UUID().uuidString)")!
    }

    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 101)
    }
}

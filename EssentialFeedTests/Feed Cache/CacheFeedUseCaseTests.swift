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
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed{ [unowned self] error in
            
            if error == nil {
                self.store.insert(items, withTimeStamp: self.currentDate())
            }
            
        }
    }
}

class FeedStore {
    typealias DeletionCompletions = ((Error?) -> ())
    var deleCachedFeedCallCount = 0
    var insertCacheCallCount = 0
    var caches = [(items: [FeedItem], timeStamp: Date)]()
    
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
    
    func insert(_ items: [FeedItem], withTimeStamp timeStamp: Date) {
        insertCacheCallCount += 1
        caches.append((items, timeStamp))
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
    
    func test_saveCommand_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        
        let timeStamp = Date()
        let (sut,store) = makeSUT(currentDate: { timeStamp })
        let items : [FeedItem] = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        store.completionDeletionSuccessfully()
        
        XCTAssertEqual(store.caches.count, 1)
        XCTAssertEqual(store.caches.first?.items, items)
        XCTAssertEqual(store.caches.first?.timeStamp, timeStamp)
    }
    
    //MARK: helper functions
    
    func makeSUT(currentDate : @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
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

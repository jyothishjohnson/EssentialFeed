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
    
    func test_load_requestsCacheRetrival(){
        
        let (sut,store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache])
    }
    
    func test_load_failsOnRetrievalError(){
        
        let (sut,store) = makeSUT()
        let expectedError = anyError()
        
        expect(sut, toCompleteWith: .failure(expectedError)) {
            store.completeRetrieval(with: expectedError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        
        let (sut,store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCacheImagesOnLessThanSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7DaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timeStamp: lessThan7DaysOldTimeStamp)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timeStamp: sevenDaysOldTimeStamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timeStamp: sevenDaysOldTimeStamp)
        }
    }
    
    
    func test_load_hasNoSideEffectsOnRetrievalError(){
        let (sut,store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache(){
        let (sut,store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache])
    }
    
    func test_load_hasNoSideEffectsOnLessThanSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7DaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: lessThan7DaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache])
    }
    
    func test_load_deletesCacheOnSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7DaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: lessThan7DaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache, .deleteCacheMessage])
    }
    
    func test_load_deletesCacheOnMoreThanSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7DaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: lessThan7DaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache, .deleteCacheMessage])
    }
    
    func test_load_doesNotDeliverResultSUTDeallocation(){
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var recievedResults = [LocalFeedLoader.LoadResult]()
        
        sut?.load(completion: {result in
            recievedResults.append(result)
        })
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(recievedResults.isEmpty)
    }
    
    //MARK: helper functions
    
    private func makeSUT(currentDate : @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut,store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 101)
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
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Int) -> Date {
        return self + TimeInterval(seconds)
    }
}

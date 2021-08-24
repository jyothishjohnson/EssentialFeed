//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 18/08/21.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    
    override func setUp() {
        super.setUp()
        
        clearStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        clearStoreState()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
        
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache(){
        
        let sut = makeSUT()
        
        expect(sut, toRetriveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundCacheOnNonEmptyCache(){
        
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func test_retrieve_hasNoSideEffects_OnNonEmptyCache(){
        
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        
        expect(sut, toRetriveTwice: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetriveTwice: .failure(anyError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues(){
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        let firstInsertionError = insert((uniqueItems().local,Date()), to: sut)
        XCTAssertNil(firstInsertionError,"Expected no errors while first insertion")
        
        let feed = uniqueItems().local
        let timeStamp = Date()
        let secondInsertionError = insert((feed,timeStamp), to: sut)
        XCTAssertNil(secondInsertionError,"Expected no errors while second insertion")
        
        expect(sut, toRetrieve: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueItems().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueItems().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError,"Expected no error while cache deletion")

        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timeStamp = Date()
        
        insert((feed, timeStamp), to: sut)
        expect(sut, toRetrieve: .found(feed: feed, timeStamp: timeStamp))
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError,"Expected no error while deleting cache")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }
    
    func test_store_sideEffectsRunSerially(){
        let sut = makeSUT()
        var completedOperations = [XCTestExpectation]()
        
        let op1 = expectation(description: "OP1")
        sut.insert(uniqueItems().local, withTimeStamp: Date(), completion: {_ in
            completedOperations.append(op1)
            op1.fulfill()
        })
        
        let op2 = expectation(description: "OP2")
        sut.deleteCachedFeed(completion: {_ in
            completedOperations.append(op2)
            op2.fulfill()
        })
        
        let op3 = expectation(description: "OP3")
        sut.insert(uniqueItems().local, withTimeStamp: Date(), completion: {_ in
            completedOperations.append(op3)
            op3.fulfill()
        })
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(completedOperations, [op1,op2,op3], "Expected sideeffects to run serially")
    }
    
    //MARK: helper functions
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
    
    private func clearStoreState(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}

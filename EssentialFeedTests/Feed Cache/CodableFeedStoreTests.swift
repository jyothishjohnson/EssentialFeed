//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 18/08/21.
//

import XCTest
import EssentialFeed

final class CodableFeedStore{
    
    private let storeURL : URL
    
    init(storeURL : URL){
        self.storeURL = storeURL
    }
    
    private struct Cache: Codable{
        let feed : [CodableFeedImage]
        let timeStamp : Date
        
        var localFeed : [LocalFeedImage] {
            feed.map{ $0.localFeedImage }
        }
    }
    
    private struct CodableFeedImage : Codable {
        private let id : UUID
        private let url : URL
        private let description : String?
        private let location : String?
        
        internal init(_ image: LocalFeedImage) {
            self.id = image.id
            self.url = image.url
            self.description = image.description
            self.location = image.location
        }
        
        var localFeedImage : LocalFeedImage {
            LocalFeedImage(id: id, url: url, desc: description, location: location)
        }
    }
    
    func retriveCache(completion : @escaping FeedStore.RetrievalCompletions){
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping FeedStore.InsertionCompletions){
        do {
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timeStamp: timeStamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        }catch {
            completion(error)
        }
    }
    
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletions) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        
        try! FileManager.default.removeItem(at: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
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
    
    //MARK: helper functions
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetriveCachedFeedResult,
                        file: StaticString = #file, line: UInt = #line){
        let exp = expectation(description: "wait for cache retrival")
        
        sut.retriveCache { retrievalResult in
            switch (expectedResult, retrievalResult){
            
            case (.empty, .empty), (.failure,.failure):
                break
            case let (.found(expectedFeed, expectedTimeStamp), .found(recievedFeed, recievedTimeStamp)):
                XCTAssertEqual(expectedFeed, recievedFeed)
                XCTAssertEqual(expectedTimeStamp, recievedTimeStamp)
                
            default:
                XCTFail("Expected \(expectedResult), instead got \(retrievalResult)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetriveTwice expectedResult: RetriveCachedFeedResult,
                        file: StaticString = #file, line: UInt = #line){
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore)
    -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var recievedError : Error?
        sut.insert(cache.feed, withTimeStamp: cache.timestamp) { insertionError in
            recievedError = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return recievedError
    }
    
    private func deleteCache(from sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func clearStoreState(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}

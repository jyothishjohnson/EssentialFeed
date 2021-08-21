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
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timeStamp: timeStamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
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
        
        expect(sut, toRetrive: .empty)
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
        
        expect(sut, toRetrive: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func test_retrieve_hasNoSideEffects_OnNonEmptyCache(){
        
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        
        expect(sut, toRetriveTwice: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        
        let sut = makeSUT()
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut, toRetrive: .failure(anyError()))
    }
    
    //MARK: helper functions
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrive expectedResult: RetriveCachedFeedResult,
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
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) {
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(cache.feed, withTimeStamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func clearStoreState(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}

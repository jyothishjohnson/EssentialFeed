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
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
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
        
        let exp = expectation(description: "wait for completion")
        
        sut.retriveCache { firstResult in
            sut.retriveCache { secondResult in
                switch (firstResult,secondResult) {
                case (.empty,.empty):
                    break
                default:
                    XCTFail("Expected retriving empty result twice, got \(firstResult) and \(secondResult)")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToCache_deliversInsertedValues(){
        
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timeStamp = Date()
        let exp = expectation(description: "wait for insertion")
        
        sut.insert(feed, withTimeStamp: timeStamp) { insertionError in
            
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toRetrive: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func test_retrieve_hasNoSideEffects_OnNonEmptyCache(){
        
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timeStamp = Date()
        let exp = expectation(description: "wait for completion")
        
        sut.insert(feed, withTimeStamp: timeStamp) { insertionError in
            
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            
            sut.retriveCache { firstResult in
                
                sut.retriveCache { secondResult in
                    
                    switch (firstResult,secondResult) {
                    case (let .found(firstFeed,firstTimeStamp),let .found(secondFeed, secondTimeStamp)):
                        XCTAssertEqual(firstFeed, feed)
                        XCTAssertEqual(firstTimeStamp, timeStamp)
                        XCTAssertEqual(secondFeed, feed)
                        XCTAssertEqual(secondTimeStamp, timeStamp)
                        
                    default:
                        XCTFail("Expected found result twice with feed \(feed) and timeStamp \(firstResult), for \(secondResult) instead")
                    }
                    
                    exp.fulfill()
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
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
            
            case (.empty, .empty):
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
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func clearStoreState(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}

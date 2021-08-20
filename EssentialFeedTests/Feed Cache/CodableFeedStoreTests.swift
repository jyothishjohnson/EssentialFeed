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
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed-store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed-store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
        
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        
        sut.retriveCache { result in
            
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
        let exp = expectation(description: "wait for completion")
        
        sut.insert(feed, withTimeStamp: timeStamp) { insertionError in
            
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            
            sut.retriveCache { result in
                
                switch result {
                case let .found(recievedFeed,recievedTimeStamp):
                    XCTAssertEqual(recievedFeed, feed)
                    XCTAssertEqual(recievedTimeStamp, timeStamp)
                    
                default:
                    XCTFail("Expected found result with feed \(feed) and timeStamp \(timeStamp), for \(result) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: helper functions
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("feed-image.store")
        let sut = CodableFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

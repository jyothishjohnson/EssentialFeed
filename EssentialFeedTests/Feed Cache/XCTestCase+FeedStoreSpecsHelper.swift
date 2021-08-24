//
//  XCTestCase+FeedStoreSpecsHelper.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 24/08/21.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetriveCachedFeedResult,
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
    
    func expect(_ sut: FeedStore, toRetriveTwice expectedResult: RetriveCachedFeedResult,
                        file: StaticString = #file, line: UInt = #line){
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore)
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
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
}

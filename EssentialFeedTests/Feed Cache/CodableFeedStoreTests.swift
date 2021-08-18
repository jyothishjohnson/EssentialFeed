//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 18/08/21.
//

import XCTest
import EssentialFeed

final class CodableFeedStore{
    func retriveCache(completion : @escaping FeedStore.RetrievalCompletions){
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyonEmptyCache(){
        
        let sut = CodableFeedStore()
        
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
}

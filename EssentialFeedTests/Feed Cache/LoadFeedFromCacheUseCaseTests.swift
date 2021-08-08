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
        
        var recievedError : Error?
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            
            switch result {
            case .failure(let error):
                recievedError = error
            default:
                XCTFail("Expected failure, recieved \(result)")
            }
            exp.fulfill()
        }
        
        store.completeRetrieval(with: expectedError)
        
        wait(for: [exp], timeout: 1)
        
        
        XCTAssertEqual(recievedError as NSError?, expectedError)
    }
    
//    func test_load_deliversNoImagesOnEmptyCache(){
//        
//        let (sut,store) = makeSUT()
//        let expectedError = anyError()
//        
//        var recievedError : Error?
//        let exp = expectation(description: "Wait for completion")
//        sut.load { error in
//            recievedError = error
//            exp.fulfill()
//        }
//        
//        store.completeRetrieval(with: expectedError)
//        
//        wait(for: [exp], timeout: 1)
//        
//        
//        XCTAssertEqual(recievedError as NSError?, expectedError)
//    }
    
    //MARK: helper functions
    
    private func makeSUT(currentDate : @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut,store)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 101)
    }
}

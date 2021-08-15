//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 15/08/21.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation(){
        
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages.count, 0)
    }
    
    func test_validateCache_deletesCacheOnRetrievalError(){
        let (sut,store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache, .deleteCacheMessage])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache(){
        let (sut,store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache])
    }
    
    func test_validateCache_hasNotDeleteOnLessThanSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7DaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: lessThan7DaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache])
    }
    
    func test_validateCache_deletesSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7DaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: lessThan7DaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache, .deleteCacheMessage])
    }
    
    func test_validateCache_deletesMoreThanSevenDaysOldCache(){
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7DaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: lessThan7DaysOldTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retriveCache, .deleteCacheMessage])
    }
    
    //MARK: helper functions
    
    private func makeSUT(currentDate : @escaping () -> Date = { Date() }, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut,store)
    }
}

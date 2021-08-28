//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 28/08/21.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundCacheOnNonEmptyCache() {
            
    }
    
    func test_retrieve_hasNoSideEffects_OnNonEmptyCache() {
            
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
            
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
            
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues() {
            
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
            
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
            
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
            
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
            
    }
    
    func test_store_sideEffectsRunSerially() {
            
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}


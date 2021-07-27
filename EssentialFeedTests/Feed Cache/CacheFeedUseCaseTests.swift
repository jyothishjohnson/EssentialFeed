//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 27/07/21.
//

import XCTest

class LocalFeedLoader {

    let store : FeedStore

    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    
    var deleCachedFeedCallCount = 0
}
class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation(){
        
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleCachedFeedCallCount, 0)
    }

}

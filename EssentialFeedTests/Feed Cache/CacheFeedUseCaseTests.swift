//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 27/07/21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store : FeedStore

    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleCachedFeedCallCount = 0
    
    func deleteCachedFeed(){
        deleCachedFeedCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation(){
        
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleCachedFeedCallCount, 0)
    }
    
    func test_saveCommand_requestsCacheDeletion(){
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items : [FeedItem] = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleCachedFeedCallCount, 1)
    }
    
    //MARK: helper functions
    
    func uniqueFeedItem() -> FeedItem {
        
        return FeedItem(id: UUID(), imageURL: anyURL(), desc: nil, location: nil)
    }
    
    func anyURL() -> URL {
        return URL(string: "https://anyURL.com/\(UUID().uuidString)")!
    }

}

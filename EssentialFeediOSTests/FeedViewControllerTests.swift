//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Jyothish Johnson on 20/09/21.
//

import XCTest
import EssentialFeed

class FeedViewController: UIViewController {
    
    private var loader : FeedLoader?
    
    convenience init(loader: FeedLoader){
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load{ _ in }
    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed(){
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed(){
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    //MARK: helpers
    
    class LoaderSpy: FeedLoader {
        
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (LoadFeedResult) -> ()) {
            loadCallCount += 1
        }
    }
}

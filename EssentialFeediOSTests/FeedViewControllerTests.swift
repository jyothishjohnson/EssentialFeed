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
        let (_,loader) = makeSUT()

        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed(){
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    //MARK: helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (LoadFeedResult) -> ()) {
            loadCallCount += 1
        }
    }
}

//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 06/07/21.
//

import XCTest

class RemoteFeedLoader {
    func load(){
        HTTPClient.shared.requestedURL = URL(string: "https://example.com")
    }
}

class HTTPClient{
    
    static let shared = HTTPClient()
    
    private init(){}
    
    var requestedURL : URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL(){
        
        //Arrange
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        //Act
        sut.load()
        
        //Assert
        XCTAssertNotNil(client.requestedURL)
    }
}

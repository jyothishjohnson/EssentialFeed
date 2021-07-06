//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 06/07/21.
//

import XCTest

class RemoteFeedLoader {
    
    let client : HTTPClient
    
    init(client: HTTPClient){
        self.client = client
    }
    
    func load(){
        client.get(from: URL(string: "https://example.com")!)
    }
}

protocol HTTPClient{
            
    func get(from url : URL)
}

class HTTPClientSpy: HTTPClient{
    
    func get(from url : URL){
        requestedURL = url
    }
    
    var requestedURL : URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL(){
        
        //Arrange
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        //Act
        sut.load()
        
        //Assert
        XCTAssertNotNil(client.requestedURL)
    }
}

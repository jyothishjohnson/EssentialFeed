//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 06/07/21.
//

import XCTest

class RemoteFeedLoader {
    
    let client : HTTPClient
    let url : URL
    
    init(client: HTTPClient, url : URL){
        self.client = client
        self.url = url
    }
    
    func load(){
        client.get(from: url)
    }
}

protocol HTTPClient{
            
    func get(from url : URL)
}



class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
    
        let (_,client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL(){
        
        //Arrange
        let url = URL(string: "https://example.com")!
        let (sut,client) = makeSUT(url: url)
        
        //Act
        sut.load()
        
        //Assert
        XCTAssertEqual(client.requestedURL,url)
    }
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient{
        
        func get(from url : URL){
            requestedURL = url
        }
        
        var requestedURL : URL?
    }
}

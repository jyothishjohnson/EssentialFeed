//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 06/07/21.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
    
        let (_,client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs,[])
    }
    
    func test_load_requestsDataFromURL(){
        
        //Arrange
        let url = URL(string: "https://example.com")!
        let (sut,client) = makeSUT(url: url)
        
        //Act
        sut.load()
        
        //Assert
        XCTAssertEqual(client.requestedURLs,[url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice(){
        
        //Arrange
        let url = URL(string: "https://example.com")!
        let (sut,client) = makeSUT(url: url)
        
        //Act
        sut.load()
        sut.load()
        
        //Assert
        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    
    func test_load_deliversErrorOnClientError(){
        
        let (sut,client) = makeSUT()
        
        client.error = NSError(domain: "Error", code: 0)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        sut.load{ error in
            capturedErrors.append(error)
        }
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    
    }
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient{
        
        var requestedURLs : [URL] = []
        var error : Error?
        
        func get(from url : URL, completion : @escaping (Error) -> ()){
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }
}

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
        sut.load{ _ in }
        
        //Assert
        XCTAssertEqual(client.requestedURLs,[url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice(){
        
        //Arrange
        let url = URL(string: "https://example.com")!
        let (sut,client) = makeSUT(url: url)
        
        //Act
        sut.load{ _ in }
        sut.load{ _ in }
        
        //Assert
        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    
    func test_load_deliversErrorOnClientError(){
        
        //Given
        let (sut,client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        //When
        sut.load{ error in
            capturedErrors.append(error)
        }
        
        let clientError = NSError(domain: "Error", code: 0)
        client.complete(with: clientError)
        
        //Assert
        XCTAssertEqual(capturedErrors, [.connectivity])
    
    }
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient{
                
        var messages : [(url: URL, completion: (Error) -> ())] = []
        
        var requestedURLs : [URL] {
            return messages.map{ $0.url }
        }

        
        func get(from url : URL, completion : @escaping (Error) -> ()){
            
            messages.append((url,completion))
        }
        
        func complete(with error: Error, at index : Int = 0){
            
            messages[index].completion(error)
        }
    }
}

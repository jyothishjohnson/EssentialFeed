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
        
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "Error", code: 0)
            client.complete(with: clientError)
        }
    
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        
        //Given
        let (sut,client) = makeSUT()
        let responseSample = [199,201,300,400,500]
        
        responseSample.enumerated().forEach { index,response in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                client.complete(withStatusCode: response, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponseWithInvalidJSON(){
        
        //Given
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOnNon200HTTPResponseWithEmptyJSONList(){
        
        //Given
        let (sut,client) = makeSUT()
    
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = Data("{\"items\":[]}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversNoItemsOnNon200HTTPResponseWithJSONItems(){
        
        //Given
        let (sut,client) = makeSUT()
        let item1 = FeedItem(id: UUID(), imageURL: URL(string: "https://url.com")!)
        let item2 = FeedItem(id: UUID(), imageURL: URL(string: "https://url2.com")!, desc: "description", location: "location")
        
        let json = mapJson(with: [item1,item2])
    
        expect(sut, toCompleteWithResult: .success([item1,item2])) {
            let feedItems = json
            client.complete(withStatusCode: 200, data: feedItems)
        }
    }
    
    
    //MARK: helper functions
    
    private func mapJson(with items: [FeedItem]) -> Data {
        
        let response = FeedResponse(items: items)
        return try! JSONEncoder().encode(response)
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: Result<[FeedItem],RemoteFeedLoader.Error>, when action: () -> (), file :StaticString = #file, line: UInt = #line){
        
        var capturedErrors = [Result<[FeedItem],RemoteFeedLoader.Error>]()
        
        //When
        sut.load{ result in
            
            capturedErrors.append(result)
        }
        
        action()
        
        //Assert
        XCTAssertEqual(capturedErrors, [result], file: file, line: line)
        
    }
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient{
                
        var messages : [(url: URL, completion: (Result<(HTTPURLResponse,Data), Error>) -> ())] = []
        
        var requestedURLs : [URL] {
            return messages.map{ $0.url }
        }

        
        func get(from url : URL, completion : @escaping (Result<(HTTPURLResponse,Data), Error>) -> ()){
            
            messages.append((url,completion))
        }
        
        func complete(with error: Error, at index : Int = 0){
            
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code : Int, at index : Int = 0, data : Data = Data()){
            
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)
            
            messages[index].completion(.success((response!,data)))
        }
    }
}

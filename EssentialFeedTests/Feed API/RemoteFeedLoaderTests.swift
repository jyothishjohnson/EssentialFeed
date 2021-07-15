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
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Error", code: 0)
            client.complete(with: clientError)
        }
    
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        
        //Given
        let (sut,client) = makeSUT()
        let responseSample = [199,201,300,400,500]
        
        responseSample.enumerated().forEach { index,response in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let responseJSON = mapToJsonData(with: [])
                client.complete(withStatusCode: response, at: index, data: responseJSON)
            }
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponseWithInvalidJSON(){
        
        //Given
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
        
        //Given
        let (sut,client) = makeSUT()
    
        expect(sut, toCompleteWithResult: success([])) {
            let emptyListJSON = mapToJsonData(with: [])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems(){
        
        //Given
        let (sut,client) = makeSUT()
        let item1 = Item(id: UUID(), image: URL(string: "https://url.com")!)
        let item2 = Item(id: UUID(), image: URL(string: "https://url2.com")!, desc: "description", location: "location")
        
        let json = mapToJsonData(with: [item1,item2])
        
        expect(sut, toCompleteWithResult: success([item1.feedItem,item2.feedItem])) {
            let feedItems = json
            client.complete(withStatusCode: 200, data: feedItems)
        }
    }
    
    func test_doesNotDeliverResultAfterSUTHasBeenDeallocated(){
        
        var (sut,client) : (RemoteFeedLoader?,HTTPClientSpy) = makeSUT()
        
        let json = mapToJsonData(with: [])
        
        var capturedResults = [Result<[FeedItem],Error>]()
        
        sut?.load { result in
            capturedResults.append(result)
        }
        sut = nil
        
        client.complete(withStatusCode: 200, data: json)
        
        XCTAssertEqual(capturedResults.count,[].count)
    }
    
    
    //MARK: helper functions
    
    private func mapToJsonData(with items: [Item]) -> Data {
        
        let response = FeedResponse(items: items)
        return try! JSONEncoder().encode(response)
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: Result<[FeedItem],Error>, when action: () -> (), file :StaticString = #filePath, line: UInt = #line){
        
        var capturedResults = [Result<[FeedItem],Error>]()
        
        let expectation = expectation(description: "Wait for load completion")
        
        //When
        sut.load{ recievedResult in
            capturedResults.append(recievedResult)
            
            switch (expectedResult,recievedResult) {
            
            case (.success(let expectedItems), .success(let recievedItems)):
                XCTAssertEqual(expectedItems, recievedItems, file: file, line: line)
            case let(.failure(expectedFailure as RemoteFeedLoader.Error), .failure(recievedFailure as RemoteFeedLoader.Error)):
                XCTAssertEqual(expectedFailure, recievedFailure, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), recieved \(recievedResult)", file: file, line: line)
            }
            expectation.fulfill()
        }
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut,client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file : StaticString, line: UInt){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Potential Memory Leak", file: file, line: line)
        }
    }
    
    private func failure(_ error : RemoteFeedLoader.Error) -> LoadFeedResult {
        .failure(error)
    }
    
    private func success(_ items : [FeedItem]) -> LoadFeedResult {
        .success(items)
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
        
        func complete(withStatusCode code : Int, at index : Int = 0, data : Data){
            
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)
            
            messages[index].completion(.success((response!,data)))
        }
    }
}

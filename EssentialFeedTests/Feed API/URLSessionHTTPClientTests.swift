//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 17/07/21.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClient{
    
    let session : URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnExpectedError: Error{}
    
    func get(from url : URL, completion : @escaping (Result<(HTTPURLResponse,Data), Error>) -> ()){
        session.dataTask(with: url){ data,response,error in
            
            if let error = error {
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((response,data)))
            }else {
                completion(.failure(UnExpectedError()))

            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getsURL_performsGETRequestWithURL(){
        
        let url = anyURL()
        
        let exp = expectation(description: "wait for result")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
                
    }
    
    func test_getsURL_failsOnRequestError(){
        
        let requestError = anyError()
        
        let recievedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual((recievedError as NSError?)?.domain, requestError.domain)
        XCTAssertEqual((recievedError as NSError?)?.code, requestError.code)
    }
    
    func test_getsURL_failsOnAllInvalidRepresentations(){
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: nil))
    }
    
    func test_getsURL_successOnDataWithHTTPURLResponse(){

        let data = anyData()
        let response = anyHTTPResponse()
        
        let recievedValue = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(recievedValue?.response.url, response.url)
        XCTAssertEqual(recievedValue?.response.statusCode, response.statusCode)
        XCTAssertEqual(recievedValue?.data, data)
    }
    

    func test_getsURL_successOnEmptyWithHTTPURLResponseWithNilData(){

        let response = anyHTTPResponse()
        
        let recievedValues = resultValuesFor(data: nil, response: response, error: nil)

        let emptyData = Data()
        XCTAssertEqual(recievedValues?.data, emptyData)
        XCTAssertEqual(recievedValues?.response.url, response.url)
        XCTAssertEqual(recievedValues?.response.statusCode, response.statusCode)
    }
    
    //MARK: helper methods
    
    private func makeSUT(file : StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient{
        let sut = URLSessionHTTPClient()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file : StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let expectation = expectation(description: "Wait for completion")
        
        var recievedValues : (data: Data, response: HTTPURLResponse)?
        
        sut.get(from: anyURL()){ result in
            switch result {
            case let .success((response,data)):
                recievedValues = (data,response)
            default :
                XCTFail("Expected success got \(result)", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return recievedValues
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file : StaticString = #file, line: UInt = #line) -> Error? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let expectation = expectation(description: "Wait for completion")
        
        var recievedError : Error?
        
        sut.get(from: anyURL()){ result in
            switch result {
            case .failure(let error):
                recievedError = error
            default :
                XCTFail("Expected failure got \(result)", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return recievedError
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://anyurl.com")!
    }
    
    private func anyData() -> Data {
        return "anyData".data(using: .utf8)!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 101)
    }
    
    private func anyHTTPResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func nonHTTPResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private class URLProtocolStub: URLProtocol{
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            observe = nil
        }
        
        private static var stub : Stub?
        private static var observe : ((URLRequest) -> ())?
        
        private struct Stub {
            let error : Error?
            let data : Data?
            let response : URLResponse?
        }
        
        static func stub(data : Data?, response : URLResponse?, error : Error?){
            stub = Stub(error: error, data: data, response: response)
        }
        
        static func observeRequest(completion: @escaping (URLRequest) -> ()){
            observe = completion
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            observe?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else {
                client?.urlProtocolDidFinishLoading(self)
                return
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
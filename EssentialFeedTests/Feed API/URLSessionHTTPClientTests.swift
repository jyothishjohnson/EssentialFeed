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
    
    func get(from url : URL, completion : @escaping (LoadFeedResult) -> ()){
        session.dataTask(with: url){ _,_,error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getsURL_performsGETRequestWithURL(){
        
        let url = URL(string: "https://someURL.com")!
        
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
        
        let url = URL(string: "https://anyurl.com")!
        let error = NSError(domain: "error 101", code: 1)
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let expectation = expectation(description: "Wait for completion")
        
        makeSUT().get(from: url){ result in
            switch result {
            case .failure(let recievedError as NSError):
                XCTAssertEqual(recievedError.domain, error.domain)
                XCTAssertEqual(recievedError.code, error.code)
            default :
                XCTFail("Expected failure got \(result)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    //MARK: helper methods
    
    private func makeSUT() -> URLSessionHTTPClient{
        return URLSessionHTTPClient()
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
            let response : HTTPURLResponse?
        }
        
        static func stub(data : Data?, response : HTTPURLResponse?, error : Error?){
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

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
    
    func test_getsURL_failsOnRequestError(){
        
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "https://anyurl.com")!
        let error = NSError(domain: "error 101", code: 1)
        let sut = URLSessionHTTPClient()
        
        URLProtocolStub.stub(url, data: nil, response: nil, error: error)
        
        let expectation = expectation(description: "Wait for completion")
        
        sut.get(from: url){ result in
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
        URLProtocolStub.stopInterceptingRequests()
    }
    
    //MARK: helper methods
    
    private class URLProtocolStub: URLProtocol{
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        private static var stubs = [URL:Stub]()
        
        private struct Stub {
            let error : Error?
            let data : Data?
            let response : HTTPURLResponse?
        }
        
        static func stub(_ url: URL, data : Data?, response : HTTPURLResponse?, error : Error?){
            stubs[url] = Stub(error: error, data: data, response: response)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            guard let url = request.url , let stub = URLProtocolStub.stubs[url] else {
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

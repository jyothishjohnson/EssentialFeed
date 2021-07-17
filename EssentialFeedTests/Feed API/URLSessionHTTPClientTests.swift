//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 17/07/21.
//

import XCTest

final class URLSessionHTTPClient{
    
    let session : URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url : URL){
        session.dataTask(with: url){ _,_,_ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getsURL_createsDataTaskWithURL() {
        
        let url = URL(string: "https://anyurl.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.recievedURLs, [url])
    }
    
    //MARK: helper methods
    
    private class URLSessionSpy: URLSession{
        
        var recievedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            recievedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}

}

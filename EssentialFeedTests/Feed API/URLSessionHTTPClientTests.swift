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
        session.dataTask(with: url){ _,_,_ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getsURL_resumesDataTaskWithURL() {
        
        let url = URL(string: "https://anyurl.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)

        session.stub(url, with: task)
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    //MARK: helper methods
    
    private class URLSessionSpy: URLSession{
        
        var recievedURLs = [URL]()
        private var stubs = [URL:URLSessionDataTask]()
        
        func stub(_ url: URL, with task : URLSessionDataTask){
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            recievedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {
        }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }


}

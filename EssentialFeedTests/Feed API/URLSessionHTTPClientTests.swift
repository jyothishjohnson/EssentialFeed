//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 17/07/21.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}

final class URLSessionHTTPClient{
    
    let session : HTTPSession
    
    init(session: HTTPSession) {
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

    func test_getsURL_resumesDataTaskWithURL() {
        
        let url = URL(string: "https://anyurl.com")!
        let session = URLSessionSpy()
        let task = HTTPSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)

        session.stub(url, with: task)
        sut.get(from: url){ _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getsURL_failsOnRequestError(){
        
        let url = URL(string: "https://anyurl.com")!
        let error = NSError(domain: "error 101", code: 1)
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)

        session.stub(url, error: error)
        
        let expectation = expectation(description: "Wait for completion")
        sut.get(from: url){ result in
            switch result {
            case .failure(let recievedError as NSError):
                XCTAssertEqual(recievedError, error)
            default :
                XCTFail("Expected failure got \(result)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    //MARK: helper methods
    
    private class URLSessionSpy: HTTPSession{
        
        var recievedURLs = [URL]()
        private var stubs = [URL:Stub]()
        
        private struct Stub {
            let task : HTTPSessionDataTask
            let error : Error?
        }
        
        func stub(_ url: URL, with task : HTTPSessionDataTask = FakeHTTPSessionDataTask(), error : Error? = nil){
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
            recievedURLs.append(url)
            
            guard let stub = stubs[url] else {
                fatalError("Expected stub for \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
        }
    }
    
    private class FakeHTTPSessionDataTask: HTTPSessionDataTask {
        func resume() {
        }
    }
    
    private class HTTPSessionDataTaskSpy: HTTPSessionDataTask {
        
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }


}

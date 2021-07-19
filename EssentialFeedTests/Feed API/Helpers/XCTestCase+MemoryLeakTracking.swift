//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 19/07/21.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file : StaticString, line: UInt){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Potential Memory Leak", file: file, line: line)
        }
    }
}

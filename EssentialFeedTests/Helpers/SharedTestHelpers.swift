//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 15/08/21.
//

import Foundation
import EssentialFeed

func anyError() -> NSError {
    return NSError(domain: "any error", code: 101)
}

func anyURL() -> URL {
    return URL(string: "https://anyURL.com/\(UUID().uuidString)")!
}

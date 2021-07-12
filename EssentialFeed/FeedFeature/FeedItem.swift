//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 06/07/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id : UUID
    let imageURL : URL
    let description : String?
    let location : String?
}

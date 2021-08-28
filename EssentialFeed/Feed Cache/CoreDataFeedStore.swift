//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 28/08/21.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}

    public func deleteCachedFeed(completion: @escaping DeletionCompletions) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions) {
        
    }
    
    public func retriveCache(completion: @escaping RetrievalCompletions) {
        completion(.empty)
    }

    private class ManagedCache: NSManagedObject {
        @NSManaged var timestamp: Date
        @NSManaged var feed: NSOrderedSet
    }

    private class ManagedFeedImage: NSManagedObject {
        @NSManaged var id: UUID
        @NSManaged var imageDescription: String?
        @NSManaged var location: String?
        @NSManaged var url: URL
        @NSManaged var cache: ManagedCache
    }
}

//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 28/08/21.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CoreDataFeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletions) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timeStamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retriveCache(completion: @escaping RetrievalCompletions) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed, timeStamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }

    @objc(ManagedCache)
    private class ManagedCache: NSManagedObject {
        @NSManaged var timestamp: Date
        @NSManaged var feed: NSOrderedSet
        
        var localFeed: [LocalFeedImage] {
            return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
        }
        
        static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
            let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
            request.returnsObjectsAsFaults = false
            return try context.fetch(request).first
        }
        
        static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
            try find(in: context).map(context.delete)
            return ManagedCache(context: context)
        }
    }

    @objc(ManagedFeedImage)
    private class ManagedFeedImage: NSManagedObject {
        @NSManaged var id: UUID
        @NSManaged var imageDescription: String?
        @NSManaged var location: String?
        @NSManaged var url: URL
        @NSManaged var cache: ManagedCache
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, url: url, desc: imageDescription, location: location)
        }
        
        static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
            return NSOrderedSet(array: localFeed.map { local in
                let managed = ManagedFeedImage(context: context)
                managed.id = local.id
                managed.imageDescription = local.description
                managed.location = local.location
                managed.url = local.url
                return managed
            })
        }
    }
    
}

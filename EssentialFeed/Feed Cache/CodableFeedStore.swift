//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Jyothish Johnson on 22/08/21.
//

import Foundation

public final class CodableFeedStore: FeedStore{
    
    private let storeURL : URL
    
    public init(storeURL : URL){
        self.storeURL = storeURL
    }
    
    private struct Cache: Codable{
        let feed : [CodableFeedImage]
        let timeStamp : Date
        
        var localFeed : [LocalFeedImage] {
            feed.map{ $0.localFeedImage }
        }
    }
    
    private struct CodableFeedImage : Codable {
        private let id : UUID
        private let url : URL
        private let description : String?
        private let location : String?
        
        internal init(_ image: LocalFeedImage) {
            self.id = image.id
            self.url = image.url
            self.description = image.description
            self.location = image.location
        }
        
        var localFeedImage : LocalFeedImage {
            LocalFeedImage(id: id, url: url, desc: description, location: location)
        }
    }
    
    public func retriveCache(completion : @escaping RetrievalCompletions){
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], withTimeStamp timeStamp: Date, completion: @escaping InsertionCompletions){
        do {
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timeStamp: timeStamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        }catch {
            completion(error)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletions) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

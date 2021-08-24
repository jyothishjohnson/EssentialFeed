//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Jyothish Johnson on 24/08/21.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundCacheOnNonEmptyCache()
    func test_retrieve_hasNoSideEffects_OnNonEmptyCache()
    

    func test_insert_overridesPreviouslyInsertedCachedValues()

    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_store_sideEffectsRunSerially()
}

protocol FailableRetriveSpecs: FeedStoreSpecs{
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertSpecs: FeedStoreSpecs{
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteSpecs: FeedStoreSpecs{
    func test_delete_deliversErrorOnDeletionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

typealias FailableFeedStore = FailableInsertSpecs & FailableDeleteSpecs & FailableRetriveSpecs


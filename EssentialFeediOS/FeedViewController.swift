//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Jyothish Johnson on 20/09/21.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    
    private var loader : FeedLoader?
    
    public convenience init(loader: FeedLoader){
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load(){
        refreshControl?.beginRefreshing()
        loader?.load{ [weak self] _ in
            guard let self = self else {return}
            self.refreshControl?.endRefreshing()
        }
    }
}

public extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}



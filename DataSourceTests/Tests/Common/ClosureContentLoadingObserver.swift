//
//  ClosureContentLoadingObserver.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 09/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

@testable import DataSource


/// The `ClosureContentLoadingObserver` encapsulates `ContentLoadingObserver` callbacks in closures.
class ClosureContentLoadingObserver : ContentLoadingObserver {

    var willLoadContent: ((sender: ContentLoadingObservable) -> Void)?
    var didLoadContent: ((sender: ContentLoadingObservable, error: NSError?) -> Void)?
    
    init(willLoadContent: ((sender: ContentLoadingObservable) -> Void)? = nil,
        didLoadContent: ((sender: ContentLoadingObservable, error: NSError?) -> Void)? = nil)
    {
        self.willLoadContent = willLoadContent
        self.didLoadContent = didLoadContent
    }

    func willLoadContent(_ sender: ContentLoadingObservable) {
        willLoadContent?(sender: sender)
    }
    
    func didLoadContent(_ sender: ContentLoadingObservable, with error: NSError?) {
        didLoadContent?(sender: sender, error: error)
    }
}

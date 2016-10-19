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

    var willLoadContent: ((_ sender: ContentLoadingObservable) -> Void)?
    var didLoadContent: ((_ sender: ContentLoadingObservable, _ error: Error?) -> Void)?
    
    init(willLoadContent: ((_ sender: ContentLoadingObservable) -> Void)? = nil,
        didLoadContent: ((_ sender: ContentLoadingObservable, _ error: Error?) -> Void)? = nil)
    {
        self.willLoadContent = willLoadContent
        self.didLoadContent = didLoadContent
    }

    func willLoadContent(_ sender: ContentLoadingObservable) {
        willLoadContent?(sender)
    }
    
    func didLoadContent(_ sender: ContentLoadingObservable, with error: Error?) {
        didLoadContent?(sender, error)
    }
}

//
//  ClosureContentLoadingObserver.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 20/10/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import DataSource


class ClosureContentLoadingObserver: ContentLoadingObserver {

    typealias WillLoadContentClosure = ((ContentLoadingObservable) -> Void)
    typealias DidLoadContentClosure = ((ContentLoadingObservable, Error?) -> Void)

    var willLoadContent: WillLoadContentClosure?
    var didLoadContent: DidLoadContentClosure?

    init(willLoadContent: WillLoadContentClosure? = nil,
        didLoadContent: DidLoadContentClosure? = nil)
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

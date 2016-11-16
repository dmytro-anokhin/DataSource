//
//  ClosureUpdateObserver.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 02/11/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import DataSource


class ClosureUpdateObserver: UpdateObserver {

    typealias PerformClosure = ((UpdateType, UpdateObservable) -> Void)

    var perform: PerformClosure?

    init(perform: PerformClosure? = nil) {
        self.perform = perform
    }

    public func perform(update: UpdateType, from sender: UpdateObservable) {
        perform?(update, sender)
    }
}

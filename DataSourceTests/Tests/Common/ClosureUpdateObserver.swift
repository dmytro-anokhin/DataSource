//
//  ClosureUpdateObserver.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 06/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


/// The ClosureUpdateObserver encapsulates UpdateObserver callback in a closure.
class ClosureUpdateObserver : UpdateObserver {

    let closure: (Update, UpdateObservable) -> Void
    
    init(closure: (Update, UpdateObservable) -> Void) {
        self.closure = closure
    }

    func perform(update: Update, from sender: UpdateObservable) {
        closure(update, sender)
    }
}
